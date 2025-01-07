import 'package:dio/dio.dart';

final httpClient = Dio(
  BaseOptions(
    baseUrl: 'https://psrkgrmez.github.io/ap', 
    headers: {
      'X-Content-Type-Options': 'nosniff',
  }),
);

