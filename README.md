# Dio API Services

[![pub package](https://img.shields.io/pub/v/dio_api_services.svg)](https://pub.dev/packages/dio_api_services)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter package that provides a robust HTTP client service built on top of Dio, featuring automatic retry mechanisms, intelligent logging, connectivity checking, and error handling for seamless API integration.

## Features

✨ **Smart HTTP Client**: Built on Dio with enhanced functionality  
🔄 **Automatic Retry**: Configurable retry logic with exponential backoff  
📱 **Connectivity Aware**: Automatic network status checking  
📝 **Advanced Logging**: Comprehensive request/response logging with overlay UI  
🛡️ **Error Handling**: Intelligent error parsing and user-friendly messages  
⚡ **Performance Optimized**: Efficient request/response handling  
🎯 **Type Safe**: Full TypeScript-like safety with Dart  

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  dio_api_services: ^0.0.3
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Setup

```dart
import 'package:dio_api_services/dio_api_services.dart';

// Initialize the service
final apiService = DioApiService(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
);
```

### Making API Calls

```dart
// GET request
final response = await apiService.call(
  '/users',
  method: MethodRequest.GET,
);

// POST request with JSON data
final response = await apiService.call(
  '/users',
  method: MethodRequest.POST,
  request: {
    'name': 'John Doe',
    'email': 'john@example.com',
  },
);

// POST request with form data
final response = await apiService.call(
  '/upload',
  method: MethodRequest.POST,
  request: {
    'file': await MultipartFile.fromFile('/path/to/file.jpg'),
    'description': 'Profile picture',
  },
  useFormData: true,
);
```

## Core Features

### 1. HTTP Methods Support

The package supports all standard HTTP methods:

```dart
// GET Request
await apiService.call('/endpoint', method: MethodRequest.GET);

// POST Request  
await apiService.call('/endpoint', method: MethodRequest.POST, request: data);

// PUT Request
await apiService.call('/endpoint', method: MethodRequest.PUT, request: data);

// DELETE Request
await apiService.call('/endpoint', method: MethodRequest.DELETE);
```

### 2. Automatic Retry Mechanism

Built-in smart retry with configurable delays:

```dart
final apiService = DioApiService(
  baseUrl: 'https://api.example.com',
);

// The service automatically retries failed requests:
// - 1st retry: after 1 second
// - 2nd retry: after 2 seconds  
// - 3rd retry: after 3 seconds
```

### 3. Connectivity Checking

Automatic network status verification before making requests:

```dart
// The service automatically checks connectivity
// Returns offline message if no internet connection
final response = await apiService.call('/endpoint');

if (response.statusCode == 00) {
  print('Offline: ${response.data['message']}');
}
```

### 4. Advanced Logging

Comprehensive logging with customizable options:

```dart
final response = await apiService.call(
  '/endpoint',
  logRequestUrl: true,      // Log request URL
  logRequestHeader: true,   // Log request headers
  logRequestBody: true,     // Log request body
  logResponseBody: true,    // Log response body
  logResponseHeader: false, // Skip response headers
  logResponseError: true,   // Log errors
);
```

### 5. Custom Headers

Easy header management:

```dart
final response = await apiService.call(
  '/protected-endpoint',
  header: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'X-Custom-Header': 'custom-value',
  },
);
```

## Advanced Usage

### Error Handling

The package provides intelligent error handling:

```dart
try {
  final response = await apiService.call('/endpoint');
  
  if (response.statusCode == 200) {
    // Success
    final data = response.data;
  } else {
    // Handle API errors
    final errorMessage = response.data['message'];
    print('API Error: $errorMessage');
  }
} catch (e) {
  print('Network Error: $e');
}
```

### Form Data and File Uploads

```dart
// File upload with form data
final response = await apiService.call(
  '/upload',
  method: MethodRequest.POST,
  useFormData: true,
  request: {
    'file': await MultipartFile.fromFile(
      filePath,
      filename: 'image.jpg',
    ),
    'userId': '123',
    'category': 'profile',
  },
);
```

### Query Parameters

```dart
// GET request with query parameters
final response = await apiService.call(
  '/users',
  method: MethodRequest.GET,
  request: {
    'page': 1,
    'limit': 10,
    'search': 'john',
  },
);
```

## Configuration Options

### Timeout Configuration

```dart
final apiService = DioApiService(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),  // Connection timeout
  receiveTimeout: Duration(seconds: 60),  // Response timeout
);
```

### Retry Configuration

The retry mechanism is pre-configured but can be customized by extending the service:

- **Retries**: 3 attempts
- **Delays**: 1s, 2s, 3s between retries
- **Conditions**: Network errors, timeouts, 5xx status codes

## API Reference

### DioApiService

#### Constructor

```dart
DioApiService({
  required String baseUrl,
  Duration connectTimeout = const Duration(seconds: 90),
  Duration? receiveTimeout = const Duration(seconds: 50),
})
```

#### Methods

##### call()

```dart
Future<Response> call(
  String url, {
  MethodRequest method = MethodRequest.POST,
  dynamic request,
  Map<String, String>? header,
  bool useFormData = false,
  bool logRequestUrl = true,
  bool logRequestHeader = false,
  bool logRequestBody = false,
  bool logResponseBody = true,
  bool logResponseHeader = false,
  bool logResponseError = true,
})
```

**Parameters:**
- `url`: The endpoint URL (relative to baseUrl)
- `method`: HTTP method (GET, POST, PUT, DELETE)
- `request`: Request data (JSON object or query parameters)
- `header`: Custom headers map
- `useFormData`: Convert request to FormData
- `log*`: Logging configuration options

**Returns:** `Future<Response>` - Dio Response object

### MethodRequest Enum

```dart
enum MethodRequest { POST, GET, PUT, DELETE }
```

## Best Practices

### 1. Service Initialization

Create a singleton service instance:

```dart
class ApiClient {
  static final _instance = DioApiService(
    baseUrl: 'https://api.example.com',
  );
  
  static DioApiService get instance => _instance;
}

// Usage
final response = await ApiClient.instance.call('/endpoint');
```

### 2. Error Handling

Always handle both network and API errors:

```dart
Future<List<User>> getUsers() async {
  try {
    final response = await apiService.call('/users', method: MethodRequest.GET);
    
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } else {
      throw ApiException(response.data['message']);
    }
  } catch (e) {
    throw NetworkException('Failed to fetch users: $e');
  }
}
```

### 3. Authentication

Implement token-based authentication:

```dart
class AuthenticatedApiService {
  final DioApiService _apiService;
  String? _token;
  
  AuthenticatedApiService(this._apiService);
  
  void setToken(String token) => _token = token;
  
  Future<Response> authenticatedCall(String url, {
    MethodRequest method = MethodRequest.GET,
    dynamic request,
  }) {
    return _apiService.call(
      url,
      method: method,
      request: request,
      header: {
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
    );
  }
}
```

## Example App

Check out the [example](example/) directory for a complete implementation showing:

- Basic API calls
- Error handling
- Loading states
- Real-world usage patterns

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 **Issues**: [GitHub Issues](https://github.com/agisrh/dio_api_services/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/agisrh/dio_api_services/discussions)
- 🌐 **Homepage**: [agisrh.github.io](https://agisrh.github.io)

---

Made with ❤️ by [agisrh](https://github.com/agisrh)
