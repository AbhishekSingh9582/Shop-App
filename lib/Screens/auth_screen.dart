import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode {
  SignUp,
  Login,
}

class AuthScreen extends StatelessWidget {
  static const routeArgs = '/AuthScreen';

  Future<void> _refreshPage(BuildContext context) async {
    print('who');
    return Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refreshPage(context),
        child: Stack(
          children: [
            Container(
              height: deviceSize.height,
              width: deviceSize.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    colors: [Colors.amber[100], Colors.pink[200]],
                    end: Alignment.bottomRight),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: deviceSize.height,
                width: deviceSize.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        height: deviceSize.height / 4 - 30,
                        width: deviceSize.width - 30,
                        margin: EdgeInsets.only(bottom: 20),
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 45),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8,
                                color: Colors.black26,
                                offset: Offset(0, 2),
                              )
                            ],
                            color: Colors.deepOrange.shade900),
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            'MyShop',
                            style: TextStyle(
                              // backgroundColor: Colors.transparent,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              // fontSize: 23,
                            ),
                          ),
                        ),
                        transform: Matrix4.rotationZ(-8 * pi / 180)
                          ..translate(-10.0),
                      ),
                    ),
                    Flexible(
                      child: AuthCard(),
                      flex: deviceSize.width > 600 ? 2 : 1,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  var _isLoading = false;
  AuthMode _authMode = AuthMode.Login;

  Map<String, String> authenticationInput = {'Email': '', 'password': ''};

  AnimationController _controller;
  Animation<Size> _heightAnimation;
  Animation<double> _opacityAnimation;
  Animation<Offset> _slideTransition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _heightAnimation = Tween<Size>(
            begin: Size(double.infinity, 260), end: Size(double.infinity, 320))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInBack));

    _heightAnimation.addListener(() => setState(() {}));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideTransition = Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInCirc));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _displayErrorMessage(String errorMess) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(errorMess),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Okay'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
            authenticationInput['Email'], authenticationInput['password']);
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
            authenticationInput['Email'], authenticationInput['password']);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication Failed!';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use ';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Incorrect Email Address ';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Password is too weak ';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that Email';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password ';
      }
      _displayErrorMessage(errorMessage);
    } catch (error) {
      const errorMessage = "Couldn't authenticate you. Please try again later";
      _displayErrorMessage(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedBuilder(
        builder: (context, ch) => Container(
            //height:_authMode == AuthMode.SignUp ? 320 : 260
            height: _heightAnimation.value.height,
            constraints:
                BoxConstraints(minHeight: _heightAnimation.value.height),
            padding: EdgeInsets.all(16.0),
            width: deviceSize.width * 0.75,
            child: ch),
        animation: _heightAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (!value.contains('@') || value.isEmpty) {
                      return 'Invalid Email Address';
                    }
                    return null;
                  },
                  scrollPadding: EdgeInsets.only(bottom: 60),
                  onSaved: (value) {
                    authenticationInput['Email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty || value.length <= 5) {
                      return 'Invalid Password atLeast 5 characters long';
                    }
                    return null;
                  },
                  controller: _passwordController,
                  scrollPadding: EdgeInsets.only(bottom: 95),
                  onSaved: (value) {
                    authenticationInput['password'] = value;
                  },
                ),
                //if (_authMode == AuthMode.SignUp)

                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.SignUp ? 60 : 0,
                      maxHeight: _authMode == AuthMode.SignUp ? 120 : 0),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideTransition,
                      child: TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        scrollPadding: EdgeInsets.only(bottom: 95),
                        validator: _authMode == AuthMode.SignUp
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // ElevatedButton(
                //         child:
                //             Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                //         onPressed: _submit,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(30),
                //         ),
                //         padding:
                //             EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                //         color: Theme.of(context).primaryColor,
                //         textColor: Theme.of(context).primaryTextTheme.button.color,
                //       ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    child:
                        Text(_authMode == AuthMode.Login ? 'Login' : 'SignUp'),
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        textStyle: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .button
                                .color)),
                  ),
                TextButton(
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                    onPressed: _switchAuthMode,
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      primary: Theme.of(context).primaryColor,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
