import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  Future<List<Map<String, dynamic>>> getApi({String category = ''}) async {
    // Perbaikan: Ubah logika URL untuk menyesuaikan dengan struktur API
    String url = 'https://berita-indo-api.vercel.app/v1/cnn-news';
    if (category.isNotEmpty) {
      url += '/$category'; 
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Perbaikan: Ganti nama variabel json
      final decodedData = jsonDecode(response.body);
      
      // Pastikan untuk mengambil data dari key 'data'
      final newsList = decodedData['data'] as List;

      return newsList.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal Menampilkan Data');
    }
  }
}