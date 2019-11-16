import 'package:connectivity/connectivity.dart';
import 'package:finop/helpers/helpers.dart';
import 'package:finop/screens/registration/choice_screen.dart';
import 'package:finop/screens/registration/login_screen.dart';
import 'package:finop/screens/registration/setup_investor_screen.dart';
import 'package:finop/screens/registration/setup_startup_screen.dart';
import 'package:finop/services/authentication.dart';
import 'package:flutter/material.dart';

import 'package:finop/const/color_const.dart';
import 'package:finop/const/gradient_const.dart';
import 'package:finop/const/images_const.dart';
import 'package:finop/const/size_const.dart';
import 'package:finop/const/string_const.dart';
import 'package:finop/widgets/signup_arrow_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

//  static const String ROUTE_NAME = '/';
  static const String ROUTE_NAME = '/signup';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _isSigningUpUser = false;

  @override
  Widget build(BuildContext context) {
    final _media = MediaQuery.of(context).size;

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _isSigningUpUser,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
//            gradient: SIGNUP_BACKGROUND,
              ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 60.0, horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Image.asset(
                              'assets/images/finop/finopp.png',
//                              RegistrationImagePath.SignUpLogo,
                              height: _media.height / 9,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "WELCOME!",
                            style: TextStyle(
                              letterSpacing: 4,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                              fontSize: TEXT_LARGE_SIZE,
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            'Sign up',
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w200,
                                fontSize: 40),
                          ),
                          Text(
                            'to continue.',
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w200,
                                fontSize: 40),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Container(
                            height: _media.height / 3.8,
                            decoration: BoxDecoration(
                              gradient: SIGNUP_CARD_BACKGROUND,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 15,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: inputText("EMAIL",
                                        'example@gmail.com', _email, false),
                                  ),
                                  Divider(
                                    height: 5,
                                    color: Colors.black,
                                  ),
                                  Expanded(
                                      child: inputText("PASSWORD", '******',
                                          _password, true)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            StringConst.SIGN_UP_TEXT,
                            style: TextStyle(color: MAIN_COLOR),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () => Navigator.pushNamed(
                                context, LoginScreen.ROUTE_NAME),
                            child: Text(StringConst.SIGN_IN),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
                Positioned(
                  bottom: _media.height / 6.3,
                  right: 15,
                  child: SignUpArrowButton(
                    icon: IconData(0xe901, fontFamily: 'Icons'),
                    iconSize: 9,
                    onTap: () => initiateSignInProcess(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget inputText(
    String fieldName,
    String hintText,
    TextEditingController controller,
    bool obSecure,
  ) {
    return TextField(
      style: TextStyle(height: 1.3),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: fieldName,
        labelStyle: TextStyle(
          fontSize: TEXT_NORMAL_SIZE,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
          height: 0,
        ),
        border: InputBorder.none,
      ),
      obscureText: obSecure,
    );
  }

  void turnOnProgressIndicator() {
    setState(() {
      _isSigningUpUser = true;
    });
  }

  void turnOffProgressIndicator() {
    setState(() {
      _isSigningUpUser = false;
    });
  }

  Future<String> signUserUp(String email, String password) async {
    String userId = await widget.auth.signUp(email, password);
    return userId;
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else if (connectivityResult == ConnectivityResult.none) {
      showToast(StringConst.NO_INTERNET_CONNECTION, duration: 3);
    }
    return false;
  }

  void showToast(String msg, {int duration}) {
    Toast.show(msg, context, duration: duration, gravity: Toast.BOTTOM);
  }

  initiateSignInProcess() async {
    if (await checkInternetConnection()) {
      try {
        turnOnProgressIndicator();
        String userId = await signUserUp(_email.text, _password.text);

        if (userId.length > 0 && userId != null) {
          //save user ID and navigate to setup
          print("USER_ID:: $userId");
          Helper.saveUserId(userId);
          String accountType = await getAccountType();
          navigateUserToSetupAccount(accountType);
        } else {
          turnOffProgressIndicator();
        }
      } catch (e) {
        print("ERROR:: $e");
        turnOffProgressIndicator();
      }
    }
  }

  Future<String> getAccountType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accountType = prefs.get(StringConst.ACCOUNT_TYPE_KEY);
    return accountType;
  }

  Future<void> setCurrentStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        StringConst.SETUP_STEP_KEY, StringConst.BASIC_INFO_STEP_VALUE);
  }

  void navigateUserToSetupAccount(String accountType) {
    switch (accountType) {
      case StringConst.START_UP_VALUE:
        setCurrentStep();
        Navigator.pushNamed(context, SetupStartUpScreen.ROUTE_NAME);
        break;
      case StringConst.INVESTOR_VALUE:
        setCurrentStep();
        Navigator.pushNamed(context, SetupInvestorScreen.ROUTE_NAME);
        break;
      default:
        Navigator.pushNamed(context, SetupStartUpScreen.ROUTE_NAME);
    }
  }
}
