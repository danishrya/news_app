import 'dart:convert';
// import 'dart:io';

import 'package:http/http.dart' as http;

class Api {
  Future<List<Map<String, dynamic>>> getApi({String category = ''}) async {
    String url = 'https://berita-indo-api.vercel.app/v1/cnn-news/';
    if (category.isNotEmpty) {
      url += category;
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final jsonList = json['data'] as List;
      return jsonList.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal Menampilkan Data');
    }
  }
}
