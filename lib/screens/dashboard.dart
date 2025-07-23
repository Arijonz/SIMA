import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Halaman Dashboard utama aplikasi SIMA
/// Menampilkan jam real-time, jumlah mahasiswa, dan tombol navigasi
class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = '';
  String currentTime = '';
  Timer? _timer;
  int totalMahasiswa = 0;

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  /// Inisialisasi data dashboard
  Future<void> _initDashboard() async {
    await _loadUserName();
    _startClock();
    await _loadTotalMahasiswa();
  }

  /// Mengambil nama user dari SharedPreferences
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('userName');
    setState(() {
      userName = storedUser ?? 'User';
    });
  }

  /// Memulai jam digital real-time
  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
  }

  /// Update nilai currentTime setiap detik
  void _updateTime() {
    final now = DateTime.now().toUtc().add(Duration(hours: 8)); // GMT+8
    final formatter = DateFormat('HH:mm:ss');
    setState(() {
      currentTime = formatter.format(now);
    });
  }

  /// Mengambil jumlah mahasiswa dari Firestore
  Future<void> _loadTotalMahasiswa() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('mahasiswa')
        .get();
    setState(() {
      totalMahasiswa = snapshot.docs.length;
    });
  }

  /// Logout dan hapus SharedPreferences
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Hallo, ${userName.isNotEmpty ? userName : 'User'}'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'SIMA - Sistem Informasi Mahasiswa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),

            // Widget Jam
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    Text(
                      currentTime,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Waktu Saat Ini (GMT+8)',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Widget Jumlah Mahasiswa
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.people, size: 36, color: Colors.teal),
                title: Text('Jumlah Mahasiswa'),
                subtitle: Text(
                  '$totalMahasiswa orang',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 40),

            // Tombol Kelola Mahasiswa
            ElevatedButton.icon(
              icon: Icon(Icons.list),
              label: Text('Kelola Mahasiswa'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                await Navigator.pushNamed(context, '/mahasiswa-list');
                _initDashboard(); // Refresh setelah kembali
              },
            ),
          ],
        ),
      ),
    );
  }
}
