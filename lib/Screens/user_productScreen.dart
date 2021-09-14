import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/user_productItem.dart';
import '../widgets/app_drawer.dart';
import 'edit_productScreen.dart';

class UserProductScreen extends StatelessWidget {
  static final String routeArgs = '/UserProductScreen';

  Future<void> _refreshPage(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .getandsetProduct(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Product'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).pushNamed(EditProductScreen.routeArgs))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshPage(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshPage(context),
                    child: Consumer<ProductProvider>(
                      builder: (ctx, productData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productData.items.length,
                          itemBuilder: (_, i) => Column(children: [
                            UserProductItem(
                              id: productData.items[i].id,
                              title: productData.items[i].title,
                              imageUrl: productData.items[i].imageUrl,
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
