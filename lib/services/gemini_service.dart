import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:io';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final Dio _dio;
  late final GeminiClient _client;
  late final String apiKey;

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    _initializeService();
  }

  void _initializeService() {
    // Get API key from environment variables or compile-time definition
    apiKey = dotenv.env['GEMINI_API_KEY'] ??
        const String.fromEnvironment('GEMINI_API_KEY');

    if (apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
      throw Exception(
          'GEMINI_API_KEY must be provided via .env file or --dart-define');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://generativelanguage.googleapis.com/v1',
        headers: {
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    // Add retry interceptor for better reliability
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response?.statusCode == 429) {
            // Rate limit handling
            print('Rate limit exceeded, retrying after delay...');
          }
          handler.next(error);
        },
      ),
    );

    _client = GeminiClient(_dio, apiKey);
  }

  Dio get dio => _dio;
  String get authApiKey => apiKey;
  GeminiClient get client => _client;
}

class GeminiClient {
  final Dio dio;
  final String apiKey;

  GeminiClient(this.dio, this.apiKey);

  Future<String> analyzeReceipt(File image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await dio.post(
        '/models/gemini-1.5-flash:generateContent',
        queryParameters: {
          'key': apiKey,
        },
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text':
                      '''Analyze this receipt image and extract transaction information. Return ONLY a JSON object with this exact format:
{
  "amount": <number>,
  "description": "<string>",
  "category": "<string>",
  "date": "<YYYY-MM-DD>",
  "merchant": "<string>"
}

For category, choose from: Makanan, Transportasi, Belanja, Hiburan, Kesehatan, Utilitas, Lainnya
If you cannot read the receipt clearly, return: {"error": "Could not read receipt"}'''
                },
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 1024,
            'temperature': 0.1,
          },
        },
      );

      if (response.data['candidates'] != null &&
          response.data['candidates'].isNotEmpty &&
          response.data['candidates'][0]['content'] != null) {
        final parts = response.data['candidates'][0]['content']['parts'];
        final text = parts.isNotEmpty ? parts[0]['text'] : '';
        return text.trim();
      } else {
        throw GeminiException(
          statusCode: response.statusCode ?? 500,
          message: 'Failed to parse response or empty response',
        );
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ??
            e.message ??
            'Network error occurred',
      );
    } catch (e) {
      throw GeminiException(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<String> generateFinancialInsights({
    required List<Map<String, dynamic>> transactions,
    required DateTime currentMonth,
  }) async {
    try {
      final transactionSummary =
          _buildTransactionSummary(transactions, currentMonth);

      final response = await dio.post(
        '/models/gemini-1.5-flash:generateContent',
        queryParameters: {
          'key': apiKey,
        },
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text':
                      '''Analyze the following financial data and provide insights in Indonesian:

$transactionSummary

Please provide:
1. Spending pattern analysis
2. Budget recommendations
3. Areas for improvement
4. Financial health score (1-10)

Keep the response concise and actionable, maximum 300 words.'''
                }
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 512,
            'temperature': 0.3,
          },
        },
      );

      if (response.data['candidates'] != null &&
          response.data['candidates'].isNotEmpty &&
          response.data['candidates'][0]['content'] != null) {
        final parts = response.data['candidates'][0]['content']['parts'];
        final text = parts.isNotEmpty ? parts[0]['text'] : '';
        return text.trim();
      } else {
        return 'Tidak dapat menganalisis data keuangan saat ini.';
      }
    } catch (e) {
      print('Error generating financial insights: $e');
      return 'Analisis keuangan tidak tersedia. Silakan coba lagi nanti.';
    }
  }

  String _buildTransactionSummary(
      List<Map<String, dynamic>> transactions, DateTime currentMonth) {
    final currentMonthTransactions = transactions.where((t) {
      final date = t['date'] as DateTime;
      return date.year == currentMonth.year && date.month == currentMonth.month;
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> categoryExpenses = {};

    for (final transaction in currentMonthTransactions) {
      final amount = transaction['amount'] as double;
      if (transaction['type'] == 'income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
        final category = transaction['category'] as String;
        categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
      }
    }

    return '''
Monthly Financial Summary:
- Total Income: Rp ${totalIncome.toStringAsFixed(0)}
- Total Expenses: Rp ${totalExpense.toStringAsFixed(0)}
- Net Balance: Rp ${(totalIncome - totalExpense).toStringAsFixed(0)}
- Transaction Count: ${currentMonthTransactions.length}

Category Breakdown:
${categoryExpenses.entries.map((e) => '- ${e.key}: Rp ${e.value.toStringAsFixed(0)}').join('\n')}
''';
  }

  Future<Completion> createChat({
    required List<Message> messages,
    String model = 'gemini-1.5-flash-002',
    int maxTokens = 1024,
    double temperature = 1.0,
  }) async {
    try {
      final contents = messages
          .map((m) => {
                'role': m.role,
                'parts': m.content is String
                    ? [
                        {'text': m.content}
                      ]
                    : m.content,
              })
          .toList();

      final response = await dio.post(
        '/models/$model:generateContent',
        queryParameters: {
          'key': apiKey,
        },
        data: {
          'contents': contents,
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'temperature': temperature,
          },
        },
      );

      if (response.data['candidates'] != null &&
          response.data['candidates'].isNotEmpty &&
          response.data['candidates'][0]['content'] != null) {
        final parts = response.data['candidates'][0]['content']['parts'];
        final text = parts.isNotEmpty ? parts[0]['text'] : '';
        return Completion(text: text);
      } else {
        throw GeminiException(
          statusCode: response.statusCode ?? 500,
          message: 'Failed to parse response or empty response',
        );
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ??
            e.message ??
            'Network error occurred',
      );
    } catch (e) {
      throw GeminiException(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<List<String>> listModels() async {
    try {
      final response = await dio.get(
        '/models',
        queryParameters: {
          'key': apiKey,
        },
      );

      final modelList = (response.data['models'] as List)
          .map((model) => model['name'] as String)
          .toList();
      return modelList;
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ??
            e.message ??
            'Failed to fetch models',
      );
    } catch (e) {
      throw GeminiException(
        statusCode: 500,
        message: 'Unexpected error fetching models: ${e.toString()}',
      );
    }
  }
}

class Message {
  final String role;
  final dynamic content;

  Message({required this.role, required this.content});
}

class Completion {
  final String text;

  Completion({required this.text});
}

class GeminiException implements Exception {
  final int statusCode;
  final String message;

  GeminiException({required this.statusCode, required this.message});

  @override
  String toString() => 'GeminiException: $statusCode - $message';
}
