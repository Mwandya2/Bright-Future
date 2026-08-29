import '../../core/network/api_client.dart';
import '../../core/storage/app_prefs.dart';
import '../models/enums.dart';
import '../models/json.dart';
import '../models/print_order.dart';

class PrintOrderRepository {
  PrintOrderRepository(this._api);

  final ApiClient _api;

  Future<List<PrintOrder>> mine() async {
    final dynamic data = await _api.get('/orders/my');
    final List<PrintOrder> items =
        J.list(data).map(PrintOrder.fromJson).toList();
    await AppPrefs.instance.cacheJson(
      AppPrefs.cacheMyOrders,
      items.map((PrintOrder o) => o.toJson()).toList(),
    );
    return items;
  }

  List<PrintOrder> cached() => AppPrefs.instance
      .readJsonList(AppPrefs.cacheMyOrders)
      .map(PrintOrder.fromJson)
      .toList();

  Future<PrintOrder> create({
    required ServiceType serviceType,
    String? description,
    int copies = 1,
    bool color = false,
  }) async {
    final dynamic data = await _api.post(
      '/orders',
      body: <String, dynamic>{
        'serviceType': serviceType.api,
        'description': description,
        'copies': copies,
        'color': color,
      },
    );
    return PrintOrder.fromJson(J.map(data));
  }

  /// Attaches the file to print. Requires the optional backend endpoint in
  /// `backend-addons/PrintAttachmentController.java`.
  Future<PrintOrder> uploadAttachment({
    required String orderId,
    required String filePath,
  }) async {
    final dynamic data = await _api.uploadFile(
      '/orders/$orderId/attachment',
      filePath: filePath,
    );
    return PrintOrder.fromJson(J.map(data));
  }

  // ── Admin ───────────────────────────────────────────────────
  Future<List<PrintOrder>> all() async {
    final dynamic data = await _api.get('/orders');
    return J.list(data).map(PrintOrder.fromJson).toList();
  }

  Future<PrintOrder> updateStatus(String id, OrderStatus status) async {
    final dynamic data = await _api.patch(
      '/orders/$id/status',
      body: <String, dynamic>{'status': status.api},
    );
    return PrintOrder.fromJson(J.map(data));
  }
}
