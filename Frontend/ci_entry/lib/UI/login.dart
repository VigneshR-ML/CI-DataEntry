import 'package:ci_entry/API/login_api.dart';
import 'package:ci_entry/UI/entryforms.dart';
import 'package:flutter/material.dart';
import './login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginApi api = LoginApi();

  Future<void> loginUser() async {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username and password cannot be empty.")),
      );
      return;
    }

    Map<String, dynamic> response = await api.loginUser(username, password);
    if (!mounted) return;

    if (response.containsKey("error")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response["error"])));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful!")));
      int userId = response["user_id"];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BusEntryForm(userId: userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, size.height * 0.25, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Login",
                  style: TextStyle(
                    fontSize: size.width * 0.15,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 62, 122, 76),
                  ),
                ),
                Text(
                  "Welcome to the CI data entry.",
                  style: TextStyle(
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.normal,
                    color: const Color.fromARGB(148, 29, 62, 37),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Enter your P/no:",
                    floatingLabelStyle: const TextStyle(
                      color: Color.fromARGB(255, 62, 122, 76),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 62, 122, 76),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 62, 122, 76),
                      ),
                    ),
                    prefixIcon: const Icon(Icons.person),
                    prefixIconColor: const Color.fromARGB(255, 62, 122, 76),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    floatingLabelStyle: const TextStyle(
                      color: Color.fromARGB(255, 62, 122, 76),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 62, 122, 76),
                      ),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    prefixIconColor: const Color.fromARGB(255, 62, 122, 76),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: size.height * 0.35,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 62, 122, 76),
                borderRadius: BorderRadius.vertical(top: Radius.circular(150)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: size.height * 0.2,
            child: Center(
              child: ElevatedButton(
                onPressed: loginUser,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.2,
                    vertical: size.height * 0.02,
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    color: const Color.fromARGB(255, 62, 122, 76),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
