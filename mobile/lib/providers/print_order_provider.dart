import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/services/notification_service.dart';
import '../core/utils/formatters.dart';
import '../data/models/enums.dart';
import '../data/models/print_order.dart';
import '../data/repositories/print_order_repository.dart';
import 'load_state.dart';

class PrintOrderProvider extends ChangeNotifier with LoadState {
  PrintOrderProvider(this._repo);

  final PrintOrderRepository _repo;

  List<PrintOrder> _orders = <PrintOrder>[];
  List<PrintOrder> get orders => _orders;

  List<PrintOrder> get active =>
      _orders.where((PrintOrder o) => o.isActive).toList();

  List<PrintOrder> get history =>
      _orders.where((PrintOrder o) => !o.isActive).toList();

  Future<void> load({bool refresh = false}) async {
    beginLoad(refresh: refresh);
    try {
      _orders = await _repo.mine();
      endLoad();
    } on ApiException catch (e) {
      final List<PrintOrder> cached = _repo.cached();
      if (cached.isNotEmpty) {
        _orders = cached;
        endLoad(fromCache: true);
      } else {
        endLoad(error: e.message);
      }
    } catch (_) {
      endLoad(error: 'Could not load your print orders.');
    }
  }

  /// Creates the order and, when [filePath] is given, tries to attach the file.
  /// A failed attachment never loses the order - it is reported separately.
  Future<String?> create({
    required ServiceType serviceType,
    String? description,
    int copies = 1,
    bool color = false,
    String? filePath,
  }) async {
    PrintOrder created;
    try {
      created = await _repo.create(
        serviceType: serviceType,
        description: description,
        copies: copies,
        color: color,
      );
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not submit the order. Please try again.';
    }

    String? attachmentWarning;
    if (filePath != null && filePath.isNotEmpty) {
      try {
        created = await _repo.uploadAttachment(
          orderId: created.id,
          filePath: filePath,
        );
      } catch (_) {
        attachmentWarning =
            'Order submitted, but the file could not be uploaded. Bring it on a '
            'flash drive or email it to the hub.';
      }
    }

    _orders = <PrintOrder>[created, ..._orders];
    notifyListeners();

    await NotificationService.instance.showLocal(
      title: 'Print order submitted',
      body:
          '${serviceType.label} x$copies - estimated ${Fmt.price(created.estimatedPrice)}.',
      route: '/printing',
      record: true,
    );

    return attachmentWarning;
  }

  void reset() {
    _orders = <PrintOrder>[];
    notifyListeners();
  }
}
