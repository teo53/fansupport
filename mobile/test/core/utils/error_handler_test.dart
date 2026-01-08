import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:idol_support/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    group('toAppException', () {
      test('should handle DioException connectionTimeout', () {
        final dioError = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final appException = ErrorHandler.toAppException(dioError);

        expect(appException.type, AppErrorType.timeout);
        expect(appException.localizedKey, 'errorNetwork');
      });

      test('should handle DioException 401 unauthorized', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        final appException = ErrorHandler.toAppException(dioError);

        expect(appException.type, AppErrorType.unauthorized);
        expect(appException.localizedKey, 'errorUnauthorized');
      });

      test('should handle DioException 404 not found', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        final appException = ErrorHandler.toAppException(dioError);

        expect(appException.type, AppErrorType.notFound);
        expect(appException.localizedKey, 'errorNotFound');
      });

      test('should handle DioException 500 server error', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        final appException = ErrorHandler.toAppException(dioError);

        expect(appException.type, AppErrorType.server);
        expect(appException.localizedKey, 'errorServerError');
      });

      test('should handle SocketException', () {
        final socketError = const SocketException('Connection refused');

        final appException = ErrorHandler.toAppException(socketError);

        expect(appException.type, AppErrorType.network);
        expect(appException.localizedKey, 'errorNetwork');
      });

      test('should return same AppException if already AppException', () {
        const original = AppException(
          type: AppErrorType.validation,
          message: 'Test error',
          localizedKey: 'errorInvalidInput',
        );

        final result = ErrorHandler.toAppException(original);

        expect(identical(result, original), isTrue);
      });

      test('should handle unknown errors', () {
        final unknownError = Exception('Unknown error');

        final appException = ErrorHandler.toAppException(unknownError);

        expect(appException.type, AppErrorType.unknown);
        expect(appException.localizedKey, 'errorGeneric');
      });
    });
  });

  group('AppException', () {
    test('should format toString correctly', () {
      const exception = AppException(
        type: AppErrorType.network,
        message: 'Network error',
      );

      expect(
        exception.toString(),
        'AppException(type: AppErrorType.network, message: Network error)',
      );
    });
  });
}
