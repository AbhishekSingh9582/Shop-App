import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
//import '../providers/product.dart';
//import '../mode/product.dart';
import './productItem.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavs;

  ProductGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    //final loadedProduct = productData.favoriteItems;
    final loadedProduct =
        showFavs ? productData.favoriteItems : productData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 3 / 2,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 7),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: loadedProduct[i],
        child: ProductItem(
            // loadedProduct[i].id,
            // loadedProduct[i].imageUrl,
            // loadedProduct[i].title,
            ),
      ),
      itemCount: loadedProduct.length,
    );
  }
}
