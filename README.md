# Finance Tracker

A comprehensive Flutter-based finance tracking application with AI-powered insights using Google's Gemini API.

## Features

- 📱 Cross-platform support (Android, iOS, Web)
- 💰 Transaction management (income/expense tracking)
- 📊 Data visualization with charts and analytics
- 🤖 AI-powered financial insights via Gemini API
- 📷 Receipt scanning with OCR
- 📁 CSV/Excel data import
- 📈 Budget tracking and progress monitoring
- 🎨 Modern Material Design 3 UI

## Getting Started

### Prerequisites

- Flutter SDK 3.16.0 or higher
- Dart SDK 3.2.0 or higher
- Android Studio / VS Code
- Gemini API key (optional, for AI features)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd financetracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up environment variables:
   - Copy `.env.example` to `.env`
   - Add your API keys (optional):
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

4. Run the application:
```bash
flutter run
```

### Building for Production

#### Android APK
```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=your_api_key
```

#### iOS
```bash
flutter build ipa --release --dart-define=GEMINI_API_KEY=your_api_key
```

#### Web
```bash
flutter build web --release --dart-define=GEMINI_API_KEY=your_api_key
```

## CI/CD Setup

### GitHub Actions

The project includes GitHub Actions workflows for automated building:

1. Create the following secrets in your GitHub repository:
   - `GEMINI_API_KEY`: Your Gemini API key

2. Push to `main` or `develop` branch to trigger builds

### Codemagic

The project includes Codemagic configuration:

1. Connect your repository to Codemagic
2. Set up the following environment variables:
   - `GEMINI_API_KEY`: Your Gemini API key
3. Configure signing certificates for iOS/Android releases

## Project Structure

```
lib/
├── core/                    # Core functionality and exports
├── presentation/            # UI screens and widgets
│   ├── dashboard_home/      # Home dashboard
│   ├── transaction_history/ # Transaction listing
│   ├── analytics_dashboard/ # Analytics and charts
│   ├── add_transaction/     # Add/edit transactions
│   ├── receipt_scanner/     # Receipt OCR scanning
│   ├── category_management/ # Category management
│   └── data_import/         # CSV/Excel import
├── services/                # API services
│   └── gemini_service.dart  # Gemini AI integration
├── theme/                   # App theming
├── widgets/                 # Reusable widgets
└── routes/                  # Navigation routes
```

## API Integration

### Gemini AI Features

- **Receipt Analysis**: Automatically extract transaction data from receipt images
- **Financial Insights**: AI-generated spending analysis and recommendations
- **Smart Categorization**: Intelligent transaction categorization

To get a Gemini API key:
1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Create a new API key
3. Add it to your `.env` file or pass via `--dart-define`

## Development

### Code Style

The project follows Flutter/Dart conventions with additional linting rules defined in `analysis_options.yaml`.

### Testing

Run tests with:
```bash
flutter test
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if needed
5. Submit a pull request

## Deployment

### Android

1. Generate a signed APK/AAB:
```bash
flutter build appbundle --release --dart-define=GEMINI_API_KEY=your_api_key
```

2. Upload to Google Play Console

### iOS

1. Build for App Store:
```bash
flutter build ipa --release --dart-define=GEMINI_API_KEY=your_api_key
```

2. Upload via Xcode or Application Loader

### Web

1. Build and deploy:
```bash
flutter build web --release --dart-define=GEMINI_API_KEY=your_api_key
```

2. Deploy to your hosting provider

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `GEMINI_API_KEY` | Google Gemini API key for AI features | No |
| `SUPABASE_URL` | Supabase project URL | No |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | No |

## Troubleshooting

### Common Issues

1. **Build fails with missing API key**: Set the GEMINI_API_KEY environment variable or pass it via --dart-define
2. **Gradle build errors**: Clean the build with `flutter clean && flutter pub get`
3. **iOS build errors**: Run `cd ios && pod install && cd ..`

### Performance

- The app uses efficient state management
- Images are cached using `cached_network_image`
- Large lists use Flutter's built-in optimization

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository or contact the development team.