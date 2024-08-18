import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/model/admin_model.dart';
import 'package:disacare/pages/admin/admin_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  //Firebase Auth
  final _auth = FirebaseAuth.instance;

  //Form Key
  final _formKey = GlobalKey<FormState>();

  //TextEditing Controller
  final usernameController = TextEditingController();
  final emailRegisController = TextEditingController();
  final addressController = TextEditingController();
  final passwordRegisController = TextEditingController();
  final repasswordRegisController = TextEditingController();

  bool repassToogle = true;
  bool passToogle = true;

  @override
  void dispose() {
    usernameController.dispose();
    emailRegisController.dispose();
    addressController.dispose();
    passwordRegisController.dispose();
    repasswordRegisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Username Field
    final usernamefield = TextFormField(
      autofocus: false,
      controller: usernameController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("Username tidak boleh kosong");
        }
        if (!regex.hasMatch(value)) {
          return ("Masukkan Nama Valid(Min. 3 huruf)");
        }
        return null;
      },
      onSaved: (value) {
        usernameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Username",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //EmailRegis Field
    final emailregisfield = TextFormField(
      autofocus: false,
      controller: emailRegisController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        // reg expression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter a Valid Email");
        }
        return null;
      },
      onSaved: (value) {
        emailRegisController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Address Field
    final addressfield = TextFormField(
      autofocus: false,
      controller: addressController,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Alamat Tidak Boleh Kosong");
        }
        return null;
      },
      onSaved: (value) {
        addressController.text = value!;
      },
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.map),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Alamat",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    //Password Field
    final passwordregisfield = TextFormField(
      autofocus: false,
      obscureText: passToogle,
      controller: passwordRegisController,
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
        passwordRegisController.text = value!;
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

    //RePassword Field
    final repasswordregisfield = TextFormField(
      autofocus: false,
      obscureText: repassToogle,
      controller: repasswordRegisController,
      validator: (value) {
        if (repasswordRegisController.text != passwordRegisController.text) {
          return "Kata Sandi Tidak Sama";
        }
        if (value!.isEmpty) {
          return ("Kata Sandi Tidak Boleh Kosong");
        }
        return null;
      },
      onSaved: (value) {
        repasswordRegisController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              repassToogle = !repassToogle;
            });
          },
          child: Icon(repassToogle ? Icons.visibility_off : Icons.visibility),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Ulangi Kata Sandi",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Register Button
    final registerButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            checkUsernameExists(usernameController.text).then((exists) {
              if (exists) {
                Fluttertoast.showToast(msg: "Username ini telah ada");
              } else {
                signUp(emailRegisController.text, passwordRegisController.text);
              }
            });
          }
        },
        child: const Text(
          "Sign Up",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminHomePage(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.blue,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //Icon Back Button
                const SizedBox(height: 10),
                //Create Account Text
                const Text(
                  'Registrasi Akun Admin',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                //Create Account Subtitle
                const Text(
                  'Membuat akun baru',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                //Username Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: usernamefield,
                ),
                const SizedBox(
                  height: 20,
                ),
                //Email Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: emailregisfield,
                ),
                const SizedBox(
                  height: 20,
                ),
                //Address Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: addressfield,
                ),
                const SizedBox(
                  height: 20,
                ),
                //Password Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: passwordregisfield,
                ),
                const SizedBox(
                  height: 20,
                ),
                //RE-Confirm Password Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: repasswordregisfield,
                ),
                const SizedBox(
                  height: 20,
                ),
                // Regis Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: registerButton,
                ),
                const SizedBox(
                  height: 35,
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ),
      )),
    );
  }

  Future<bool> checkUsernameExists(String username) async {
    final normalizedUsername = username.toLowerCase();
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('username_holder', isEqualTo: normalizedUsername)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        postDetailsToFirestore();
        Fluttertoast.showToast(msg: 'Berhasil membuat akun admin');
      } catch (error) {
        Fluttertoast.showToast(msg: "Akun email sudah ada");
      }
    }
  }

  postDetailsToFirestore() async {
    if (!mounted) return;

    // calling our firestore
    // calling our user model
    // sending these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    AdminModel adminModel = AdminModel();

    adminModel.email = user!.email;
    adminModel.uid = user.uid;
    adminModel.username = usernameController.text;
    adminModel.usernameholder = usernameController.text.toLowerCase();
    adminModel.alamat = addressController.text;
    adminModel.password = passwordRegisController.text;
    adminModel.repassword = repasswordRegisController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(adminModel.toMap());

    if (mounted) {
      Navigator.pushAndRemoveUntil(
          (context),
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
          (route) => false);
    }
  }
}
