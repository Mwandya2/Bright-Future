import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';

/// Where a payment has got to.
///
/// Mobile money is asynchronous: the customer approves on their handset, so
/// [pending] is the normal first answer and the app polls until it settles.
enum PaymentStatus { success, pending, cancelled, failed, notConfigured }

class PaymentResult {
  const PaymentResult(
    this.status, {
    this.message,
    this.orderReference,
    this.collectedAmount,
  });

  final PaymentStatus status;
  final String? message;

  /// ClickPesa's reference for this attempt. Worth keeping: it is what the hub
  /// uses to look a payment up, and what the status endpoint takes.
  final String? orderReference;

  final int? collectedAmount;

  bool get isSuccess => status == PaymentStatus.success;
  bool get isPending => status == PaymentStatus.pending;
}

/// Course fees paid by mobile money, through ClickPesa.
///
/// The app never holds a ClickPesa credential. It asks the Bright Future
/// backend to start the payment; the backend talks to ClickPesa using the
/// client id and api key held in its own environment, and reads the amount
/// from the database rather than trusting the app.
///
/// Backend contract (see backend PaymentController.java):
///   POST /api/payments/ussd  { "courseId": "...", "phoneNumber": "0712..." }
///     -> { orderReference, status, channel, amount, phoneNumber }
///   GET  /api/payments/{orderReference}
///     -> { orderReference, status, collectedAmount }
class PaymentService {
  PaymentService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// Apple requires in-app purchase for digital content bought inside an iOS
  /// app. A course taught in person at the hub is a physical service and may
  /// be charged for directly, but a course delivered inside the app may not -
  /// using a third-party gateway there risks App Store rejection.
  ///
  /// So on iOS enrolment is free in the app and the fee is settled on the
  /// website. Android has no such restriction and pays in-app.
  static bool get canPayInApp => defaultTargetPlatform != TargetPlatform.iOS;

  /// Starts a payment: the customer gets a mobile money PIN prompt.
  ///
  /// A [PaymentStatus.pending] result is the success case - the money has not
  /// moved yet. Poll [checkStatus] with the returned reference.
  Future<PaymentResult> startCoursePayment({
    required String courseId,
    required String phoneNumber,
  }) async {
    try {
      final dynamic data = await _api.post(
        '/payments/ussd',
        body: <String, dynamic>{
          'courseId': courseId,
          'phoneNumber': phoneNumber.trim(),
        },
      );

      if (data is! Map) {
        return const PaymentResult(
          PaymentStatus.failed,
          message: 'The payment server returned an unexpected response.',
        );
      }

      final Object? reference = data['orderReference'];
      if (reference is! String || reference.isEmpty) {
        return const PaymentResult(
          PaymentStatus.failed,
          message: 'The payment could not be started. Please try again.',
        );
      }

      return PaymentResult(
        _mapStatus(data['status']),
        message: 'Check your phone and enter your mobile money PIN.',
        orderReference: reference,
      );
    } on ApiException catch (e) {
      if (e.isNotFound) {
        return const PaymentResult(
          PaymentStatus.notConfigured,
          message: 'The payments endpoint is not live on the server yet.',
        );
      }
      return PaymentResult(PaymentStatus.failed, message: e.message);
    } catch (_) {
      return const PaymentResult(
        PaymentStatus.failed,
        message: 'The payment could not be started. Please try again.',
      );
    }
  }

  /// The authoritative status. Never enrol on anything else.
  Future<PaymentResult> checkStatus(String orderReference) async {
    try {
      final dynamic data = await _api.get('/payments/$orderReference');
      if (data is! Map) {
        return PaymentResult(
          PaymentStatus.pending,
          orderReference: orderReference,
        );
      }

      final Object? collected = data['collectedAmount'];
      return PaymentResult(
        _mapStatus(data['status']),
        orderReference: orderReference,
        collectedAmount: collected is num ? collected.toInt() : null,
      );
    } on ApiException catch (e) {
      return PaymentResult(
        PaymentStatus.failed,
        message: e.message,
        orderReference: orderReference,
      );
    } catch (_) {
      // A dropped request mid-poll is not a failed payment - keep waiting.
      return PaymentResult(
        PaymentStatus.pending,
        orderReference: orderReference,
      );
    }
  }

  /// ClickPesa's vocabulary mapped onto ours. Anything unrecognised counts as
  /// still pending rather than failed, so a new status name on their side can
  /// never cause a paid enrolment to be refused.
  static PaymentStatus _mapStatus(Object? raw) {
    switch ((raw ?? '').toString().toUpperCase()) {
      case 'SUCCESS':
      case 'SUCCESSFUL':
      case 'SETTLED':
      case 'PAID':
        return PaymentStatus.success;
      case 'FAILED':
      case 'REJECTED':
      case 'REVERSED':
      case 'REFUNDED':
        return PaymentStatus.failed;
      case 'CANCELLED':
      case 'CANCELED':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }
}
