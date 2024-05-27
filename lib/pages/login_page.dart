import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_gallery/main.dart';
import 'package:image_gallery/pages/forgot_password_page.dart';

class LoginWidget extends StatefulWidget {
  final Function() onClickedSignUp;
  //!! Key? key ?????
  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const FlutterLogo(
                  size: 120,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? "Enter a valid email"
                          : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) => email != null && email.length < 6
                      ? "Enter min. 6 characters"
                      : null,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  onPressed: signIn,
                  icon: const Icon(Icons.lock_open),
                  label: const Text("Sign In"),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.white),
                  onPressed: signInWithGoogle,
                  icon: Image.asset(
                    "assets/google_logo.png",
                    width: 32,
                  ),
                  label: const Text("Sign In with Google"),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontSize: 20),
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage())),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                      text: "No account?  ",
                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onClickedSignUp,
                          style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                              fontSize: 20),
                          text: "Sign Up",
                        )
                      ]),
                ),
              ],
            )),
      ),
    ));
  }

  Future signIn() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      final snakBar = SnackBar(content: Text(e.message!));
      ScaffoldMessenger.of(context).showSnackBar(snakBar);
    }

    navigatorKey.currentState!.popUntil(((route) => route.isFirst));
  }

  Future signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final user = await googleSignIn.signIn();
      if (user == null) return;

      final googleAuth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
      //!! why catch (e) instead of on FirebaseAuthExeptions catch (e) ?????
    } catch (e) {
      print(e.toString());
    }
  }
}
