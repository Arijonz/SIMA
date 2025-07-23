import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Halaman list untuk menambahkan atau mengedit data mahasiswa
/// - Jika menerima DocumentSnapshot sebagai argumen, maka berfungsi sebagai form edit
/// - Jika tidak menerima argumen, maka berfungsi sebagai form tambah
/// Field yang diisi: nama, NIM, jurusan, tanggal lahir (dengan date picker), dan angkatan
/// Data akan disimpan ke koleksi 'mahasiswa' di Firestore
class MahasiswaFormScreen extends StatefulWidget {
  @override
  State<MahasiswaFormScreen> createState() => _MahasiswaFormScreenState();
}

class _MahasiswaFormScreenState extends State<MahasiswaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nimController = TextEditingController();
  final TextEditingController jurusanController = TextEditingController();
  final TextEditingController tglLahirController = TextEditingController();
  final TextEditingController angkatanController = TextEditingController();
  final TextEditingController kelaminController = TextEditingController();

  DocumentSnapshot? editingDoc;

  /// Menangani argumen untuk mode edit
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is DocumentSnapshot) {
      editingDoc = args;
      final data = editingDoc!.data() as Map<String, dynamic>;

      namaController.text = data['nama'] ?? '';
      nimController.text = data['nim'] ?? '';
      jurusanController.text = data['jurusan'] ?? '';
      tglLahirController.text = data['tgl_lahir'] ?? '';
      angkatanController.text = data['angkatan'] ?? '';
      kelaminController.text = data['kelamin'] ?? '';
    }
  }

  /// Menyimpan data ke Firestore (tambah atau update)
  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nama': namaController.text.trim(),
        'nim': nimController.text.trim(),
        'jurusan': jurusanController.text.trim(),
        'tgl_lahir': tglLahirController.text.trim(),
        'angkatan': angkatanController.text.trim(),
        'kelamin': kelaminController.text.trim(),
      };

      if (editingDoc != null) {
        await FirebaseFirestore.instance
            .collection('mahasiswa')
            .doc(editingDoc!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('mahasiswa').add(data);
      }

      Navigator.pop(context);
    }
  }

  /// Memunculkan date picker untuk memilih tanggal lahir
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 20)),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
    );

    if (picked != null) {
      String formatted = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        tglLahirController.text = formatted;
      });
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    nimController.dispose();
    jurusanController.dispose();
    tglLahirController.dispose();
    angkatanController.dispose();
    kelaminController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = editingDoc != null;

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
            title: Text(isEdit ? 'Edit Mahasiswa' : 'Tambah Mahasiswa'),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: nimController,
                decoration: InputDecoration(labelText: 'NIM'),
                validator: (value) =>
                    value!.isEmpty ? 'NIM tidak boleh kosong' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: jurusanController,
                decoration: InputDecoration(labelText: 'Jurusan'),
                validator: (value) =>
                    value!.isEmpty ? 'Jurusan tidak boleh kosong' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: tglLahirController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickDate,
                validator: (value) =>
                    value!.isEmpty ? 'Tanggal lahir wajib diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: angkatanController,
                decoration: InputDecoration(labelText: 'Angkatan'),
                validator: (value) =>
                    value!.isEmpty ? 'Angkatan tidak boleh kosong' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: kelaminController,
                decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                validator: (value) =>
                    value!.isEmpty ? 'Jenis Kelamin tidak boleh kosong' : null,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _simpanData,
                child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
