
import 'package:disacare/pages/firebase_auth.dart';
import 'package:disacare/pages/forgot_password.dart';
import 'package:disacare/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formfield = GlobalKey<FormState>();
  //TextEditing Controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passToogle = true;

  //Firebase
  final _auth = FirebaseAuth.instance;

  //Dispose
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //LoginHP_Button Controller

  void loginphoneUser() {}

  @override
  Widget build(BuildContext context) {
    //Email Field
    final emailField = TextFormField(
      controller: emailController,
      autofocus: false,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Masukkan Email Anda");
        }
        // reg expression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Masukkan Email Valid");
        }
        return null;
      },
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Password Field
    final passwordField = TextFormField(
      controller: passwordController,
      autofocus: false,
      obscureText: passToogle,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Kata Sandi Tidak Boleh Kosong");
        }
        if (!regex.hasMatch(value)) {
          return ("Masukkan Kata Sandi Valid(Min. 6 Character)");
        }
        return null;
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              passToogle = !passToogle;
            });
          },
          child: Icon(passToogle ? Icons.visibility_off : Icons.visibility),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Kata Sandi",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Login Button
    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          if (_formfield.currentState!.validate()) {
            signIn(emailController.text, passwordController.text);
          }
        },
        child: const Text(
          'Login',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formfield,
              child: Column(
                children: [
                  //logo
                  const SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    'assets/img/disacare_logo.jpg',
                    width: 120,
                    height: 135,
                    fit: BoxFit.fill,
                    color: Colors.white,
                    colorBlendMode: BlendMode.multiply,
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  // Text Silahkan Masuk
                  const Text(
                    'Silahkan Masuk',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),

                  //Email Textfield Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: emailField,
                  ),
                  const SizedBox(height: 15),

                  //Password Textfield Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: passwordField,
                  ),

                  const SizedBox(
                    height: 40,
                  ),
                  //Login Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: loginButton,
                  ),
                  const SizedBox(height: 10.0),

                  //Create Account dan Forgot Password Link
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage()),
                            );
                          },
                          child: const Text(
                            'Lupa Kata Sandi?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // //End
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Firebase Routing Page
  void route() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const FirebasePage(),
      ),
    );
  }

  //Firebase Sign In Function
  void signIn(String email, String password) async {
    if (_formfield.currentState!.validate()) {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then(
            (uid) => {
              Fluttertoast.showToast(msg: "Berhasil Login"),
              route(),
            },
          )
          .catchError(
            (onError) => {Fluttertoast.showToast(msg: 'Gagal Melakukan Login')},
          );
    }
  }
}
