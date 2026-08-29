/// Named routes. Keeping them in one place makes deep links and push
/// notification payloads (`{"route": "/bookings"}`) easy to wire up.
class Routes {
  const Routes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String adminLogin = '/admin-login';
  static const String home = '/home';
  static const String courses = '/courses';
  static const String myCourses = '/my-courses';
  static const String bookings = '/bookings';
  static const String newBooking = '/bookings/new';
  static const String printing = '/printing';
  static const String newPrintOrder = '/printing/new';
  static const String ecosystem = '/ecosystem';
  static const String contact = '/contact';
  static const String about = '/about';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminCourses = '/admin/courses';
  static const String adminBookings = '/admin/bookings';
  static const String adminOrders = '/admin/orders';
  static const String adminMessages = '/admin/messages';
}
