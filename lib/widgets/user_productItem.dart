import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/edit_productScreen.dart';
import '../providers/product_provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem({this.id, this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    var scaffold = ScaffoldMessenger.of(context);
    return Padding(
      padding: EdgeInsets.all(4.5),
      child: Ink(
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          // tileColor: Colors.grey[300],
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(100),
          //     ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(title),
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(EditProductScreen.routeArgs, arguments: id);
                  },
                  color: Theme.of(context).primaryColor,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    try {
                      await Provider.of<ProductProvider>(context, listen: false)
                          .deleteProduct(id);
                    } catch (error) {
                      scaffold.showSnackBar(SnackBar(
                          content: Text(
                        ' Not Deleted !',
                        textAlign: TextAlign.center,
                      )));
                    }
                  },
                  color: Theme.of(context).errorColor,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
