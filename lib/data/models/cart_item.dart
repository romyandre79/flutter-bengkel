import 'package:equatable/equatable.dart';
import 'package:kreatif_otopart/data/models/product.dart';
import 'package:kreatif_otopart/data/models/product_unit.dart';

class CartItem extends Equatable {
  final Product product;
  final double quantity;
  final String? note;
  final ProductUnit? selectedUnit;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.note,
    this.selectedUnit,
  });

  int get subtotal {
    final price = selectedUnit?.price ?? product.price;
    return (price * quantity).round();
  }

  CartItem copyWith({
    Product? product,
    double? quantity,
    String? note,
    ProductUnit? selectedUnit,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      selectedUnit: selectedUnit ?? this.selectedUnit,
    );
  }

  @override
  List<Object?> get props => [product, quantity, note, selectedUnit];
}
