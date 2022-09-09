import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:upec_mobile/global_variables.dart';
import 'package:upec_mobile/models/user_model.dart';
import 'package:upec_mobile/pages/home_page.dart';
import 'package:upec_mobile/services/user_service.dart';
import 'package:upec_mobile/utilities/color_utility.dart';
import 'package:upec_mobile/utilities/style_utility.dart';
import 'package:upec_mobile/utilities/url_utility.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Dio dio = Dio();

  bool isLoading = false;

  void login(context) async {
    if (usernameController.text == '' || passwordController.text == '') {
      // emit(state.copyWith(status: LoginStatus.error, statusMessage: "Please complete required fields to continue"));
      return;
    }
    setState(() {
      isLoading = true;
    });

    try{
      Response response = await dio.post(
        AppUrls.loginURL,
        data: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text
        }),
        options: Options(headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        }),
      );

      if (!(response.statusCode == 200)) {
        throw Exception(response.data['message']);
      }

      final Map<String, dynamic> responseData = response.data['data'];
      final User user = User.fromJson(responseData);

      UserService.saveUser(user);
      
      setState(() {
        globalCurrentUser.value = user;
        isLoading = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => const HomePage())));
    }on Exception catch (err) {
      setState(() {
        isLoading = false;
      });
      Toast.show(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        appBar: null,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20.0),
                        width: 150,
                        height: 150,
                        child: const Image(
                          fit: BoxFit.fill,
                          image: AssetImage('assets/img/logo.png'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 10,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: (Text('LOGIN',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0))),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter your login credentials',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: AppStyles.defaultPadding),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      height: 50.0,
                      width: MediaQuery.of(context).size.width - 100,
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEFEFEF),
                          hintText: "Enter Valid Email",
                          contentPadding: const EdgeInsets.only(
                              top: 10.0, bottom: 10.0, left: 10.0, right: 20.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide:
                                  const BorderSide(color: Color(0xFFEFEFEF))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide:
                                  const BorderSide(color: Color(0xFFEFEFEF))),
                        ),
                        // validator: (value) {
                        //   if (value?.isEmpty) {
                        //     return 'Enter some text';
                        //   }
                        //   return null;
                        // },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20, bottom: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    PasswordTextField(passwordController: passwordController),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(" Sign Up",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const Text(
                          " Now",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const Divider(
                      height: 20,
                      thickness: 1,
                      indent: 5,
                      endIndent: 5,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: isLoading == false
                            ? Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => login(context),
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 25.0),
                                      width: 250.0,
                                      height: 45.0,
                                      decoration: BoxDecoration(
                                        // color: colorPrimary,
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 2.0,
                                            spreadRadius: 0.0,
                                            offset: Offset(2.0, 2.0),
                                          )
                                        ],
                                        gradient: const LinearGradient(
                                            colors: [
                                              AppColors.accent,
                                              AppColors.primary,
                                              AppColors.secondary,
                                            ],
                                            begin: FractionalOffset(0.0, 1.0),
                                            end: FractionalOffset(1.0, 0.0),
                                            // stops:[0.8, 0.3, 0.1,],
                                            tileMode: TileMode.clamp),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: const Text('Log-in',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              )
                            : Container(
                                margin: const EdgeInsets.all(40),
                                child: const CircularProgressIndicator())),
                    const SizedBox(
                      height: 50,
                    ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //   // TextButton(
                    //   //   child: const Text('Forget password?'),
                    //   //   onPressed:() => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResetPage())
                    //   //   ),
                    //   // )
                    // ],
                    // )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    Key? key,
    required this.passwordController,
  }) : super(key: key);

  final TextEditingController passwordController;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool passwordVisible = false;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 10.0),
          height: 50.0,
          width: MediaQuery.of(context).size.width - 100,
          child: TextFormField(
            controller: widget.passwordController,
            obscureText: !passwordVisible,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFEFEFEF),
              hintText: "Password",
              contentPadding: const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 10.0, right: 20.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Color(0xFFEFEFEF))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Color(0xFFEFEFEF))),
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: Container(
            margin: const EdgeInsets.only(top: 10.0, right: 5.0),
            width: 40.0,
            height: 45.0,
            child: IconButton(
              iconSize: 25,
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () {
                if (!isDisposed) {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                }
              },
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
