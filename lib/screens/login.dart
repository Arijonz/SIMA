import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'about.dart';

/// Halaman login aplikasi SIMA.
/// Menggunakan autentikasi berdasarkan data di Firestore (koleksi 'users').
/// Menyimpan nama user yang berhasil login ke SharedPreferences.
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key untuk validasi form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input username dan password
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Indikator loading saat proses login berlangsung
  bool isLoading = false;

  // Mode untuk daftar pengguna baru
  bool isRegisterMode = false;

  // Fungsi hash password
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Fungsi untuk login atau daftar
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final user = userController.text.trim();
      final password = passwordController.text.trim();
      final hashedPassword = hashPassword(password);

      try {
        final userCollection = FirebaseFirestore.instance.collection('users');

        if (isRegisterMode) {
          final exists = await userCollection
              .where('user', isEqualTo: user)
              .limit(1)
              .get();
          if (exists.docs.isNotEmpty) throw 'User sudah terdaftar';

          await userCollection.add({'user': user, 'password': hashedPassword});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pendaftaran berhasil. Silakan login.')),
          );
          setState(() => isRegisterMode = false);
        } else {
          final querySnapshot = await userCollection
              .where('user', isEqualTo: user)
              .limit(1)
              .get();

          if (querySnapshot.docs.isEmpty) throw 'User tidak ditemukan';

          final userData = querySnapshot.docs.first.data();

          if (userData['password'] != hashedPassword) {
            throw 'Password salah';
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', userData['user']);
          print('Login berhasil, user: ${userData['user']}');

          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar transparan dengan tombol informasi aplikasi
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.info_outline),
          tooltip: 'Tentang Aplikasi',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo aplikasi
                Image.asset('assets/lsima.png', height: 200),
                SizedBox(height: 30),

                // Form login / daftar
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Input Username
                      TextFormField(
                        controller: userController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Username tidak boleh kosong'
                            : null,
                      ),
                      SizedBox(height: 16),

                      // Input Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Password tidak boleh kosong'
                            : null,
                      ),
                      SizedBox(height: 32),

                      // Tombol Login / Daftar / Loading
                      isLoading
                          ? CircularProgressIndicator()
                          : Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _submit,
                                    child: Text(
                                      isRegisterMode ? 'Daftar' : 'Login',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      textStyle: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(
                                      () => isRegisterMode = !isRegisterMode,
                                    );
                                  },
                                  child: Text(
                                    isRegisterMode
                                        ? 'Sudah punya akun? Login'
                                        : 'Belum punya akun? Daftar',
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
