import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Halaman untuk menampilkan daftar mahasiswa
/// Menampilkan data dari koleksi 'mahasiswa' dalam bentuk ListView.
/// Pengguna dapat mencari, melihat detail, mengedit, atau menghapus data melalui dialog.
/// Data diambil secara real-time menggunakan StreamBuilder.
class MahasiswaListScreen extends StatefulWidget {
  @override
  _MahasiswaListScreenState createState() => _MahasiswaListScreenState();
}

class _MahasiswaListScreenState extends State<MahasiswaListScreen> {
  String searchQuery = '';

  /// Menampilkan dialog dengan pilihan aksi untuk data mahasiswa
  void showOptionsDialog(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(doc['nama'] ?? 'Mahasiswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Lihat Data'),
              onTap: () {
                Navigator.pop(ctx);
                showDetailDialog(context, doc);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Data'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/mahasiswa-form', arguments: doc);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Hapus Data'),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmation(context, doc);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Menampilkan konfirmasi sebelum menghapus data mahasiswa
  void _showDeleteConfirmation(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus data "${doc['nama']}"?',
        ),
        actions: [
          TextButton(child: Text('Batal'), onPressed: () => Navigator.pop(ctx)),
          TextButton(
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('mahasiswa')
                  .doc(doc.id)
                  .delete();
            },
          ),
        ],
      ),
    );
  }

  /// Menampilkan detail informasi mahasiswa dalam dialog
  void showDetailDialog(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detail Mahasiswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${data['nama'] ?? '-'}'),
            Text('NIM: ${data['nim'] ?? '-'}'),
            Text('Jurusan: ${data['jurusan'] ?? '-'}'),
            Text('Tanggal Lahir: ${data['tgl_lahir'] ?? '-'}'),
            if (data['angkatan'] != null) Text('Angkatan: ${data['angkatan']}'),
            Text('Jenis Kelamin: ${data['kelamin'] ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Tutup')),
        ],
      ),
    );
  }

  /// Widget utama yang menampilkan daftar mahasiswa
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
            title: Text('Data Mahasiswa'),
          ),
        ),
      ),
      body: Column(
        children: [
          /*Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari Mahasiswa',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),*/
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mahasiswa')
                  .orderBy('nim')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Terjadi kesalahan.'));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                final data = snapshot.data!.docs.where((doc) {
                  final nama = (doc['nama'] ?? '').toString().toLowerCase();
                  final nim = (doc['nim'] ?? '').toString().toLowerCase();
                  return nama.contains(searchQuery) ||
                      nim.contains(searchQuery);
                }).toList();

                if (data.isEmpty)
                  return Center(child: Text('Data tidak ditemukan.'));

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final mhs = data[index];
                    final nama = mhs['nama'] ?? 'Tanpa Nama';
                    final nim = mhs['nim'] ?? '-';
                    final jurusan = mhs['jurusan'] ?? '-';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(nama),
                      subtitle: Text('NIM: $nim - $jurusan'),
                      onTap: () => showOptionsDialog(context, mhs),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/mahasiswa-form'),
        child: Icon(Icons.add),
      ),
    );
  }
}
