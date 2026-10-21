import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:dio/dio.dart';

export 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';

RestClient createFakeRestClient({Duration latency = Duration.zero}) {
  final dio = Dio();
  dio.interceptors.add(FakeApiInterceptor(latency: latency));
  return RestClient(dio);
}
