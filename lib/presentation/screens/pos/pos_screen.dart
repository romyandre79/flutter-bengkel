import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:kreatif_otopart/core/theme/app_theme.dart';
import 'package:kreatif_otopart/logic/cubits/pos/pos_cubit.dart';
import 'package:kreatif_otopart/presentation/screens/pos/widgets/cart_panel.dart';
import 'package:kreatif_otopart/presentation/screens/pos/widgets/service_catalog.dart';
=======
import 'package:flutter_otopart_offline/core/theme/app_theme.dart';
import 'package:flutter_otopart_offline/logic/cubits/pos/pos_cubit.dart';
import 'package:flutter_otopart_offline/presentation/screens/pos/widgets/cart_panel.dart';
import 'package:flutter_otopart_offline/presentation/screens/pos/widgets/service_catalog.dart';
>>>>>>> 61bd5f38dd367d6fd8d20e8cbc086ce0d3d7e92e

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Penjualan'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppThemeColors.error),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Cart?'),
                  content: const Text('Are you sure you want to remove all items?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<PosCubit>().clearCart();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear', style: TextStyle(color: AppThemeColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Left Side: Service Catalog (65%)
          const Expanded(
            flex: 65,
            child: ServiceCatalog(),
          ),
          
          // Right Side: Cart Panel (35%)
          Expanded(
            flex: 35,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                   left: BorderSide(color: AppThemeColors.border),
                ),
              ),
              child: const CartPanel(),
            ),
          ),
        ],
      ),
    );
  }
}
