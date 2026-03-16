import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:kreatif_otopart/data/models/order.dart';
=======
import 'package:flutter_otopart_offline/data/models/order.dart';
>>>>>>> 61bd5f38dd367d6fd8d20e8cbc086ce0d3d7e92e

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final Map<OrderStatus, int> todayStatusCounts;
  final int todayRevenue;
  final int monthOrderCount;
  final List<Order> recentOrders;

  const DashboardLoaded({
    required this.todayStatusCounts,
    required this.todayRevenue,
    required this.monthOrderCount,
    required this.recentOrders,
  });

  @override
  List<Object?> get props => [
        todayStatusCounts,
        todayRevenue,
        monthOrderCount,
        recentOrders,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
