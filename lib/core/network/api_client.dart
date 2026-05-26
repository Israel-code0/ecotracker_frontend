import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio = Dio(
    BaseOptions(
      // Points directly to your Spring Boot local development server port
      // baseUrl: 'http://localhost:8081/api/carbon',
      baseUrl: 'https://ecotrackerbackend-production.up.railway.app/api/carbon',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}