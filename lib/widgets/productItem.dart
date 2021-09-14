import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/product_detail_screen.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/product_provider.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String imageUrl;
  // final String title;

  // ProductItem(this.id, this.imageUrl, this.title);
  @override
  Widget build(BuildContext context) {
    Product product = Provider.of<Product>(context);
    // Auth authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProductDetailScreen.routeArgs, arguments: product.id);
        },
        child: GridTile(
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/Images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
              builder: (ctx, currentProduct, _) => IconButton(
                onPressed: () async {
                  try {
                    product.toggleFavoriteStatus();
                    await Provider.of<ProductProvider>(context, listen: false)
                        .trackFavStatus(currentProduct.id,
                            currentProduct.isFavorite, currentProduct);
                  } catch (error) {
                    product.toggleFavoriteStatus();
                  }
                },
                icon: product.isFavorite
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border),
                color: Theme.of(context).accentColor,
              ),
            ),
            title: Text(product.title),
            trailing: Consumer<Cart>(
              builder: (_, cart, ch) => IconButton(
                onPressed: () {
                  cart.addItemInCart(
                      product.title, product.id.toString(), product.price);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Item added to the Cart'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          cart.removeSingleItem(product.id);
                        }),
                  ));
                },
                icon: ch,
              ),
              child: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
