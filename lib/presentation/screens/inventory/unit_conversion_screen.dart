import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kreatif_otopart/core/theme/app_theme.dart';
import 'package:kreatif_otopart/data/models/product.dart';
import 'package:kreatif_otopart/data/models/product_unit.dart';
import 'package:kreatif_otopart/data/repositories/product_repository.dart';
import 'package:kreatif_otopart/logic/cubits/product/product_cubit.dart';

class UnitConversionScreen extends StatefulWidget {
  const UnitConversionScreen({super.key});

  @override
  State<UnitConversionScreen> createState() => _UnitConversionScreenState();
}

class _UnitConversionScreenState extends State<UnitConversionScreen> {
  Product? _selectedProduct;
  ProductUnit? _fromUnit;
  ProductUnit? _toUnit;
  final _qtyController = TextEditingController(text: '1');
  bool _isConverting = false;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _convert() async {
    if (_selectedProduct == null || _fromUnit == null || _toUnit == null) return;
    
    final qty = double.tryParse(_qtyController.text) ?? 0;
    if (qty <= 0) return;

    if (_fromUnit!.stock < qty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok sumber tidak mencukupi'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isConverting = true);
    try {
      final repo = context.read<ProductRepository>();
      
      // Calculate multiplier (To / From)
      // E.g. Box (mult 12) -> Pcs (mult 1). 
      // Multiplier = 12 / 1 = 12.
      // E.g. Pcs (mult 1) -> Box (mult 12).
      // Multiplier = 1 / 12 = 0.0833.
      final multiplier = _fromUnit!.multiplier / _toUnit!.multiplier;

      await repo.convertUnit(
        productId: _selectedProduct!.id!,
        fromUnitId: _fromUnit!.id!,
        toUnitId: _toUnit!.id!,
        fromQty: qty,
        multiplier: multiplier,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konversi stok berhasil'), backgroundColor: Colors.green),
        );
        context.read<ProductCubit>().loadProducts(); // Refresh stock
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal konversi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Satuan Stok', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppThemeColors.headerGradient)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Produk', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoaded) {
                  final goods = state.products.where((p) => p.isGoods && p.units.length > 1).toList();
                  return DropdownButtonFormField<Product>(
                    value: _selectedProduct,
                    isExpanded: true,
                    items: goods.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedProduct = val;
                        _fromUnit = null;
                        _toUnit = null;
                      });
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Pilih produk yang punya banyak satuan'),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            if (_selectedProduct != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dari Satuan', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<ProductUnit>(
                          value: _fromUnit,
                          items: _selectedProduct!.units.map((u) => DropdownMenuItem(value: u, child: Text('${u.unitName} (Sisa: ${u.stock})'))).toList(),
                          onChanged: (val) => setState(() => _fromUnit = val),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                    child: Icon(Icons.arrow_forward),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ke Satuan', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<ProductUnit>(
                          value: _toUnit,
                          items: _selectedProduct!.units.map((u) => DropdownMenuItem(value: u, child: Text(u.unitName))).toList(),
                          onChanged: (val) => setState(() => _toUnit = val),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Jumlah yang Dikonversi', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixText: _fromUnit?.unitName ?? '',
                ),
              ),
              if (_fromUnit != null && _toUnit != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Hasil: ${(double.tryParse(_qtyController.text) ?? 0) * (_fromUnit!.multiplier / _toUnit!.multiplier)} ${_toUnit!.unitName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isConverting ? null : _convert,
                  style: ElevatedButton.styleFrom(backgroundColor: AppThemeColors.primary),
                  child: _isConverting ? const CircularProgressIndicator(color: Colors.white) : const Text('PROSES KONVERSI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
