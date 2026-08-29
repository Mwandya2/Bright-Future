import '../../core/network/api_client.dart';
import '../models/admin_stats.dart';
import '../models/app_user.dart';
import '../models/enums.dart';
import '../models/json.dart';

class AdminRepository {
  AdminRepository(this._api);

  final ApiClient _api;

  Future<AdminStats> stats() async {
    final dynamic data = await _api.get('/admin/stats');
    return AdminStats.fromJson(J.map(data));
  }

  Future<List<AppUser>> users() async {
    final dynamic data = await _api.get('/admin/users');
    return J.list(data).map(AppUser.fromJson).toList();
  }

  Future<AppUser> updateRole(String userId, UserRole role) async {
    final dynamic data = await _api.patch(
      '/admin/users/$userId/role',
      body: <String, dynamic>{'role': role.api},
    );
    return AppUser.fromJson(J.map(data));
  }
}
