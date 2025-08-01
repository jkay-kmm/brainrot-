# Brainrot Flutter Project Structure

## 📁 Project Architecture

This project follows **Clean Architecture** principles combined with **MVVM (Model-View-ViewModel)** pattern for better code organization, maintainability, and scalability.

### 🏗️ Folder Structure

```
lib/
├── app.dart                    # Main app configuration
├── main.dart                   # App entry point
├── core/                       # Core functionality
│   ├── constants/              # App constants
│   │   └── app_constants.dart
│   ├── routes/                 # Navigation routes
│   │   └── app_routes.dart
│   ├── themes/                 # App theming
│   │   └── app_theme.dart
│   ├── utils/                  # Utility functions
│   │   └── app_utils.dart
│   └── widgets/                # Reusable widgets
│       ├── custom_button.dart
│       └── custom_text_field.dart
├── data/                       # Data layer
│   ├── model/                  # Data models
│   │   └── user.dart
│   └── services/               # API services
│       └── api_service.dart
├── view/                       # Presentation layer (UI)
│   └── screens/                # App screens
│       ├── home_screen.dart
│       └── splash_screen.dart
└── view_model/                 # Business logic layer
    └── app_view_model.dart
```

## 🔧 Key Features

### Dependencies Used
- **provider**: State management
- **go_router**: Navigation and routing
- **dio**: HTTP client for API calls
- **shared_preferences**: Local storage

### Core Components

#### 1. **App Configuration** (`app.dart`)
- Main app widget with theme and routing setup
- Provider configuration for state management

#### 2. **Routing** (`core/routes/app_routes.dart`)
- Centralized navigation management
- Route definitions and error handling

#### 3. **Theming** (`core/themes/app_theme.dart`)
- Light and dark theme configurations
- Material 3 design system
- Consistent color scheme and styling

#### 4. **State Management** (`view_model/app_view_model.dart`)
- App-level state management
- Theme switching functionality
- Loading states

#### 5. **API Service** (`data/services/api_service.dart`)
- HTTP client configuration
- Request/response interceptors
- Error handling

#### 6. **Utilities** (`core/utils/app_utils.dart`)
- Helper functions for common tasks
- Validation methods
- UI utility functions

#### 7. **Custom Widgets** (`core/widgets/`)
- Reusable UI components
- Consistent styling across the app
- Custom button and text field implementations

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.7.0)
- Dart SDK

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

### Running the App
```bash
flutter run
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📱 App Flow

1. **Splash Screen**: Initial loading screen with animation
2. **Home Screen**: Main application interface with theme toggle
3. **Navigation**: Handled by GoRouter with proper error handling

## 🎨 Customization

### Adding New Screens
1. Create screen in `lib/view/screens/`
2. Add route in `lib/core/routes/app_routes.dart`
3. Create corresponding ViewModel if needed

### Adding New Models
1. Create model in `lib/data/model/`
2. Implement `fromJson()` and `toJson()` methods
3. Add proper documentation

### Adding New Services
1. Create service in `lib/data/services/`
2. Use ApiService for HTTP requests
3. Handle errors appropriately

## 🧪 Testing

```bash
flutter test
```

## 📝 Code Style

- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Document public APIs
- Keep functions small and focused
- Use const constructors where possible

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.
