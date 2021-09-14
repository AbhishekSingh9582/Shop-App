import 'package:flutter/material.dart';
//import 'package:shop_app/providers/product_provider.dart';
import '../widgets/product_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/product_provider.dart';
import 'cart_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';

enum FilterOptions {
  ViewAllList,
  Favorite,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var isFavorites = false;
  var _isinit = true;
  var _isloaded = true;
  @override
  void initState() {
    // TODO: implement initState
    // Provider.of<ProductProvider>(context).getandsetProduct();  ERROR
    // Future.delayed(
    //   Duration(seconds: 0),
    // ).then((_) {
    //   Provider.of<ProductProvider>(context, listen: false).getandsetProduct();
    // });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isinit) {
      setState(() {
        _isloaded = true;
      });

      Provider.of<ProductProvider>(context).getandsetProduct().then((value) {
        setState(() {
          _isloaded = false;
        });
      });
      _isinit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // ProductProvider productContainer =
    //     Provider.of<ProductProvider>(context, listen: false);

    // Cart cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('SHOP APP'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorite) {
                  isFavorites = true;
                } else {
                  isFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: Text('View All'),
                value: FilterOptions.ViewAllList,
              ),
              PopupMenuItem(
                child: Text('Favorites'),
                value: FilterOptions.Favorite,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.noOfItems.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeArgs);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isloaded
          ? Center(child: CircularProgressIndicator())
          : ProductGrid(isFavorites),
    );
  }
}
