import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:kreatif_otopart/data/models/product.dart';
=======
import 'package:flutter_otopart_offline/data/models/product.dart';
>>>>>>> 61bd5f38dd367d6fd8d20e8cbc086ce0d3d7e92e

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final String? note;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.note,
  });

  int get subtotal => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? note,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [product, quantity, note];
}
