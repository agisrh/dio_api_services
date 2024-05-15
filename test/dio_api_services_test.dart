// import 'package:flutter_test/flutter_test.dart';
// import 'package:dio_api_services/dio_api_services.dart';
// import 'package:dio_api_services/dio_api_services_platform_interface.dart';
// import 'package:dio_api_services/dio_api_services_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockDioApiServicesPlatform
//     with MockPlatformInterfaceMixin
//     implements DioApiServicesPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final DioApiServicesPlatform initialPlatform = DioApiServicesPlatform.instance;

//   test('$MethodChannelDioApiServices is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelDioApiServices>());
//   });

//   test('getPlatformVersion', () async {
//     DioApiServices dioApiServicesPlugin = DioApiServices();
//     MockDioApiServicesPlatform fakePlatform = MockDioApiServicesPlatform();
//     DioApiServicesPlatform.instance = fakePlatform;

//     expect(await dioApiServicesPlugin.getPlatformVersion(), '42');
//   });
// }
