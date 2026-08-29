import '../../core/network/api_client.dart';
import '../models/contact_message.dart';
import '../models/json.dart';

class ContactRepository {
  ContactRepository(this._api);

  final ApiClient _api;

  Future<void> submit({
    required String name,
    required String email,
    String? subject,
    required String message,
  }) async {
    await _api.post(
      '/contact',
      authenticated: false,
      body: <String, dynamic>{
        'name': name.trim(),
        'email': email.trim(),
        'subject': subject?.trim(),
        'message': message.trim(),
      },
    );
  }

  Future<List<ContactMessage>> all() async {
    final dynamic data = await _api.get('/contact');
    return J.list(data).map(ContactMessage.fromJson).toList();
  }
}
