import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:kreatif_otopart/data/models/purchase_order.dart';
=======
import 'package:flutter_otopart_offline/data/models/purchase_order.dart';
>>>>>>> 61bd5f38dd367d6fd8d20e8cbc086ce0d3d7e92e

abstract class PurchaseOrderState extends Equatable {
  const PurchaseOrderState();

  @override
  List<Object?> get props => [];
}

class PoInitial extends PurchaseOrderState {}

class PoLoading extends PurchaseOrderState {}

class PoLoaded extends PurchaseOrderState {
  final List<PurchaseOrder> purchaseOrders;

  const PoLoaded(this.purchaseOrders);

  @override
  List<Object?> get props => [purchaseOrders];
}

class PoError extends PurchaseOrderState {
  final String message;

  const PoError(this.message);

  @override
  List<Object?> get props => [message];
}

class PoOperationSuccess extends PurchaseOrderState {
  final String message;
  final PurchaseOrder? purchaseOrder;

  const PoOperationSuccess(this.message, {this.purchaseOrder});

  @override
  List<Object?> get props => [message, purchaseOrder];
}
