import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:kreatif_otopart/data/models/supplier.dart';
=======
import 'package:flutter_otopart_offline/data/models/supplier.dart';
>>>>>>> 61bd5f38dd367d6fd8d20e8cbc086ce0d3d7e92e

abstract class SupplierState extends Equatable {
  const SupplierState();

  @override
  List<Object?> get props => [];
}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<Supplier> suppliers;

  const SupplierLoaded(this.suppliers);

  @override
  List<Object?> get props => [suppliers];
}

class SupplierError extends SupplierState {
  final String message;

  const SupplierError(this.message);

  @override
  List<Object?> get props => [message];
}

class SupplierOperationSuccess extends SupplierState {
  final String message;
  
  const SupplierOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
