import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart'
    if (dart.library.io) 'path_provider/path_provider.dart';

class ImportService {
  static final ImportService _instance = ImportService._internal();

  factory ImportService() => _instance;

  ImportService._internal();

  Future<List<Map<String, dynamic>>> importFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = result.files.first;
        final bytes =
            kIsWeb ? file.bytes! : await File(file.path!).readAsBytes();
        final extension = file.extension?.toLowerCase();

        switch (extension) {
          case 'csv':
            return _parseCsvFile(bytes);
          case 'xlsx':
          case 'xls':
            return _parseExcelFile(bytes);
          default:
            throw ImportException('Format file tidak didukung: $extension');
        }
      }
      return [];
    } catch (e) {
      throw ImportException('Gagal mengimpor file: ${e.toString()}');
    }
  }

  List<Map<String, dynamic>> _parseCsvFile(List<int> bytes) {
    try {
      final csvString = utf8.decode(bytes);
      final rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty) {
        throw ImportException('File CSV kosong');
      }

      final List<Map<String, dynamic>> transactions = [];
      final headers =
          rows.first.map((e) => e.toString().toLowerCase()).toList();

      // Expected headers: date, amount, description, category, type
      final requiredColumns = ['date', 'amount', 'description'];
      final missingColumns =
          requiredColumns.where((col) => !headers.contains(col)).toList();

      if (missingColumns.isNotEmpty) {
        throw ImportException(
            'Kolom yang diperlukan tidak ditemukan: ${missingColumns.join(', ')}');
      }

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < headers.length) continue;

        final transaction = <String, dynamic>{};
        for (int j = 0; j < headers.length && j < row.length; j++) {
          transaction[headers[j]] = row[j];
        }

        transactions.add(_normalizeTransaction(transaction));
      }

      return transactions;
    } catch (e) {
      throw ImportException('Gagal parsing CSV: ${e.toString()}');
    }
  }

  List<Map<String, dynamic>> _parseExcelFile(List<int> bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.entries.first.value;

      if (sheet.rows.isEmpty) {
        throw ImportException('File Excel kosong');
      }

      final List<Map<String, dynamic>> transactions = [];
      final headers = sheet.rows.first
          .map((cell) => cell?.value?.toString().toLowerCase() ?? '')
          .toList();

      final requiredColumns = ['date', 'amount', 'description'];
      final missingColumns =
          requiredColumns.where((col) => !headers.contains(col)).toList();

      if (missingColumns.isNotEmpty) {
        throw ImportException(
            'Kolom yang diperlukan tidak ditemukan: ${missingColumns.join(', ')}');
      }

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty) continue;

        final transaction = <String, dynamic>{};
        for (int j = 0; j < headers.length && j < row.length; j++) {
          transaction[headers[j]] = row[j]?.value?.toString() ?? '';
        }

        transactions.add(_normalizeTransaction(transaction));
      }

      return transactions;
    } catch (e) {
      throw ImportException('Gagal parsing Excel: ${e.toString()}');
    }
  }

  Map<String, dynamic> _normalizeTransaction(Map<String, dynamic> raw) {
    final normalized = <String, dynamic>{};

    // Parse amount
    final amountStr = raw['amount']?.toString() ?? '0';
    final amount =
        double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;

    // Determine type from amount or explicit type column
    String type = 'expense';
    if (raw.containsKey('type')) {
      final typeStr = raw['type']?.toString().toLowerCase() ?? '';
      type = typeStr.contains('income') || typeStr.contains('pemasukan')
          ? 'income'
          : 'expense';
    } else if (amount < 0) {
      type = 'expense';
    } else if (amount > 0) {
      type = 'income';
    }

    // Parse date
    DateTime date = DateTime.now();
    if (raw.containsKey('date') && raw['date']?.toString().isNotEmpty == true) {
      try {
        final dateStr = raw['date'].toString();
        date = DateTime.tryParse(dateStr) ?? DateTime.now();
      } catch (e) {
        // Use current date if parsing fails
      }
    }

    // Map category
    String category = raw['category']?.toString() ?? 'Lainnya';
    if (![
      'Makanan',
      'Transportasi',
      'Belanja',
      'Hiburan',
      'Kesehatan',
      'Utilitas',
      'Gaji',
      'Lainnya'
    ].contains(category)) {
      category = 'Lainnya';
    }

    normalized['id'] = DateTime.now().millisecondsSinceEpoch + raw.hashCode;
    normalized['type'] = type;
    normalized['amount'] = amount.abs();
    normalized['category'] = category;
    normalized['description'] = raw['description']?.toString() ?? '';
    normalized['date'] = date.toIso8601String();
    normalized['createdAt'] = DateTime.now().toIso8601String();
    normalized['imported'] = true;

    return normalized;
  }

  Future<void> exportTemplate() async {
    final csvData = [
      ['date', 'amount', 'description', 'category', 'type'],
      ['2024-01-15', '50000', 'Makan siang', 'Makanan', 'expense'],
      ['2024-01-16', '2500000', 'Gaji bulanan', 'Gaji', 'income'],
      ['2024-01-17', '25000', 'Ojek online', 'Transportasi', 'expense'],
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    await _downloadFile(csvString, 'template_transaksi.csv');
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }
}

class ImportException implements Exception {
  final String message;

  ImportException(this.message);

  @override
  String toString() => message;
}
