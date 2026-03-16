import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:kreatif_otopart/data/models/product.dart';
=======
import 'package:flutter_otopart_offline/data/models/product.dart';
>>>>>>> 61bd5f38dd367d6fd8d20e8cbc086ce0d3d7e92e

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);
  
  List<Product> get serviceList => products.where((p) => p.isService).toList();
  List<Product> get goodsList => products.where((p) => p.isGoods).toList();

  @override
  List<Object?> get props => [products];
}

class ProductOperationSuccess extends ProductState {
  final String message;

  const ProductOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
