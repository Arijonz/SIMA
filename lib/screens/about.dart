import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tentang Aplikasi')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'SIMA - Sistem Informasi Mahasiswa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Aplikasi ini digunakan untuk mengelola data mahasiswa seperti NIM, '
                  'nama, jurusan, dan tanggal lahir. Fitur-fitur utama mencakup autentikasi pengguna, '
                  'penambahan dan pengelolaan data mahasiswa (CRUD). Aplikasi ini dirancang untuk memudahkan institusi pendidikan '
                  'dalam mencatat dan mengelola informasi mahasiswa secara digital.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: Icon(Icons.login),
              label: Text('Kembali ke Halaman Login'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
