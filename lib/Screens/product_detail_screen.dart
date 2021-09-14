import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeArgs = '/product_item';
  @override
  Widget build(BuildContext context) {
    String productId = ModalRoute.of(context).settings.arguments as String;

    final loadedProduct = Provider.of<ProductProvider>(context, listen: false)
        .findById(productId);

    return Scaffold(
        // appBar: AppBar(
        //   title: Text(loadedProduct.title),
        // ),
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          iconTheme: IconThemeData(color: Colors.black, size: 10),
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                loadedProduct.title,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.orange[600],
                    backgroundColor: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            background: Hero(
                tag: loadedProduct.id,
                child:
                    Image.network(loadedProduct.imageUrl, fit: BoxFit.cover)),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          SizedBox(
            height: 10,
          ),
          Text(
            'Price \$${loadedProduct.price}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: Text(
              '${loadedProduct.description}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 700,
          )
        ]))
      ],
    ));
  }
}
