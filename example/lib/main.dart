import 'package:dio_api_services/dio_api_services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio API Services',
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static DioApiService apiService =
      DioApiService(baseUrl: 'https://jsonplaceholder.typicode.com/');

  Future<Response> methodGET() async {
    var response = await apiService.call(
      'users',
      method: MethodRequest.GET,
      showLog: true,
    );
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dio API Services'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await methodGET();
              },
              child: const Text('Enabled'),
            ),
          ],
        ),
      ),
    );
  }
}
