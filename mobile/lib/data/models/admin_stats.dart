import 'json.dart';

/// Mirrors `AdminStatsDto` on the backend.
class AdminStats {
  const AdminStats({
    this.totalUsers = 0,
    this.totalCourses = 0,
    this.publishedCourses = 0,
    this.totalBookings = 0,
    this.pendingBookings = 0,
    this.totalPrintOrders = 0,
    this.activePrintOrders = 0,
    this.totalContactMessages = 0,
  });

  final int totalUsers;
  final int totalCourses;
  final int publishedCourses;
  final int totalBookings;
  final int pendingBookings;
  final int totalPrintOrders;
  final int activePrintOrders;
  final int totalContactMessages;

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
        totalUsers: J.intVal(json['totalUsers']),
        totalCourses: J.intVal(json['totalCourses']),
        publishedCourses: J.intVal(json['publishedCourses']),
        totalBookings: J.intVal(json['totalBookings']),
        pendingBookings: J.intVal(json['pendingBookings']),
        totalPrintOrders: J.intVal(json['totalPrintOrders']),
        activePrintOrders: J.intVal(json['activePrintOrders']),
        totalContactMessages: J.intVal(json['totalContactMessages']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalUsers': totalUsers,
        'totalCourses': totalCourses,
        'publishedCourses': publishedCourses,
        'totalBookings': totalBookings,
        'pendingBookings': pendingBookings,
        'totalPrintOrders': totalPrintOrders,
        'activePrintOrders': activePrintOrders,
        'totalContactMessages': totalContactMessages,
      };
}
