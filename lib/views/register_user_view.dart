import 'package:flutter/material.dart';
import 'package:postman/services/user.dart';
import 'package:postman/widgets/alert.dart';

class RegisterUserView extends StatefulWidget {
  const RegisterUserView({super.key});
  @override
  State<RegisterUserView> createState() => _RegisterUserViewState();
}

class _RegisterUserViewState extends State<RegisterUserView> {
  UserService user = UserService();
  final formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  List<String> roleChoice = ["admin", "user"];
  String? role;
  bool isLoading = false;
  bool showPass = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.green.shade800,
              Colors.green.shade500,
              Colors.green.shade300,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Buat akun baru anda",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 60,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: name,
                                  label: "Full Name",
                                  icon: Icons.person_outline,
                                  validator: (value) => value!.isEmpty
                                      ? "Nama wajib diisi"
                                      : null,
                                ),
                                const Divider(height: 1),
                                _buildTextField(
                                  controller: email,
                                  label: "Email Address",
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => value!.isEmpty
                                      ? "Email wajib diisi"
                                      : null,
                                ),
                                const Divider(height: 1),
                              
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: role,
                                    decoration: const InputDecoration(
                                      hintText: "Pilih Role",
                                      prefixIcon: Icon(
                                        Icons.assignment_ind_outlined,
                                        color: Colors.green,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    items: roleChoice.map((r) {
                                      return DropdownMenuItem<String>(
                                        value: r,
                                        child: Text(r),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        setState(() => role = value),
                                    validator: (value) => value == null
                                        ? "Role wajib dipilih"
                                        : null,
                                  ),
                                ),
                                const Divider(height: 1),
                                _buildTextField(
                                  controller: password,
                                  label: "Password",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: showPass,
                                  togglePassword: () =>
                                      setState(() => showPass = !showPass),
                                  validator: (value) => value!.isEmpty
                                      ? "Password wajib diisi"
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                 
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: MaterialButton(
                            onPressed: isLoading ? null : _handleRegister,
                            color: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.green
                                  )
                                : const Text(
                                    "REGISTER NOW",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.popAndPushNamed(context, '/login');
                          },
                          child: Text(
                            "Sudah punya akun? Login di sini",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? togglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.green),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: togglePassword,
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      var data = {
        "name": name.text,
        "email": email.text,
        "role": role,
        "password": password.text,
      };

      var result = await user.registerUser(data);

      setState(() => isLoading = false);

      if (result.status == true) {
        name.clear();
        email.clear();
        password.clear();
        setState(() => role = null);

        if (!mounted) return;
        AlertMessage().showAlert(context, result.message, true);

        
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        if (!mounted) return;
        AlertMessage().showAlert(context, result.message, false);
      }
    }
  }
}
