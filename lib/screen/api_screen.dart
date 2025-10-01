import 'dart:async';
import 'dart:math'; // **IMPORT BARU** untuk fungsi acak

import 'package:flutter/material.dart';
import 'package:news_app/api/api.dart'; // Asumsikan API ini mengembalikan List<Map<String, dynamic>>
import 'package:news_app/screen/detail_screen.dart'; // Asumsikan DetailScreen ada
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class ScreenApi extends StatefulWidget {
  const ScreenApi({super.key});

  @override
  State<ScreenApi> createState() => _ScreenApiState();
}

class _ScreenApiState extends State<ScreenApi> {
  final _selectedCategory = ''.obs;

  final _allNews = <Map<String, dynamic>>[].obs;
  final _filterNews = <Map<String, dynamic>>[].obs;
  final _topNews = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final _pageController = PageController().obs;
  final _timer = Timer.periodic(Duration.zero, (e) {}).obs;

  final _currentPage = 0.obs;
  final isBookmarked = false.obs;

  Future<void> fetchNews(String type) async {
    isLoading.value = true;
    _filterNews.clear();
    _topNews.clear();

    final data = await Api().getApi(category: type);

    // **LOGIKA PENGACAKAN BARU:**
    if (data.isNotEmpty) {
      // 1. Buat salinan data agar data asli (_allNews) tidak terpengaruh
      List<Map<String, dynamic>> shuffledData = List.from(data);

      // 2. Acak data
      shuffledData.shuffle(Random());

      // 3. Ambil hingga 5 item pertama dari hasil pengacakan
      // Cek apakah data cukup, jika kurang dari 5, ambil semua.
      int count = min(5, shuffledData.length);
      _topNews.value = shuffledData.take(count).toList();
    } else {
      _topNews.clear();
    }
    // Sisa logika tetap sama
    _allNews.value = data;
    _filterNews.value = data;
    isLoading.value = false;
  }

  @override
  void initState() {
    super.initState();

    _pageController.value = PageController(initialPage: 0);

    _timer.value = Timer.periodic(Duration.zero, (t) {});

    fetchNews('');

    _startAutoScroll();
  }

  @override
  void dispose() {
    // **PENTING**: Batalkan timer
    if (_timer.value.isActive) {
      _timer.value.cancel();
    }
    _pageController.value.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    // Batalkan timer yang mungkin aktif sebelumnya
    if (_timer.value.isActive) {
      _timer.value.cancel();
    }

    _timer.value = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      // Pastikan _topNews ada isinya sebelum mencoba menggeser
      if (_topNews.isNotEmpty) {
        if (_currentPage.value < _topNews.length - 1) {
          _currentPage.value++;
        } else {
          _currentPage.value = 0;
        }

        if (_pageController.value.hasClients) {
          _pageController.value.animateToPage(
            _currentPage.value,
            duration: Duration(milliseconds: 2000),
            curve: Curves.easeIn,
          );
        }
      }
    });
  }

  // Bungkus ElevatedButton dengan Obx untuk reaktivitas warna tombol
  Widget categoryButton(String label, String category) {
    return Obx(
      () => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedCategory.value == category
              ? Colors.blue
              : Colors.grey[100],
          foregroundColor: _selectedCategory.value == category
              ? Colors.white
              : Colors.black,
        ),
        onPressed: () {
          _selectedCategory.value = category;
          fetchNews(category);
          // Mulai ulang auto-scroll ketika kategori berubah dan data baru dimuat
          // untuk memastikan timer menggunakan _topNews yang baru.
          _startAutoScroll();
        },
        child: Text(label),
      ),
    );
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd MM yyyy, HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'BARKING NEWS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // *PENTING: Bungkus semua konten dinamis yang menggunakan .obs dengan Obx*
      body: Obx(
        () => CustomScrollView(
          slivers: [
            // Top News Slider
            SliverToBoxAdapter(
              // Obx di sini agar diperbarui saat _topNews.isNotEmpty berubah
              child: (_topNews.isNotEmpty)
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      height: 200,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: PageView.builder(
                        controller: _pageController.value,
                        itemCount: _topNews.length,
                        onPageChanged: (index) {
                          // Update _currentPage saat pengguna menggeser secara manual
                          _currentPage.value = index;
                        },
                        itemBuilder: (context, index) {
                          final item = _topNews[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailScreen(newsDetail: item),
                                ),
                              );
                            },
                            child: Hero(
                              // Tambahkan index ke tag untuk memastikan keunikan
                              // karena item['title'] mungkin tidak unik jika diambil acak.
                              // Walaupun item['title'] mungkin sudah cukup unik, ini praktik yang lebih aman.
                              tag: 'top_news_${item['title']}_$index',
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Image.network(
                                      item['image']['small'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.7),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                    child: Text(
                                      item['title'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox.shrink(),
            ),

            // Bagian 'Recommendation'
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text(
                  'Recommendation',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Category Buttons List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 45,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  // categoryButton sudah dibungkus dengan Obx
                  children: [
                    categoryButton('semua', ''),
                    const SizedBox(width: 10),
                    categoryButton('nasional', 'nasional'),
                    const SizedBox(width: 10),
                    categoryButton('internasional', 'internasional'),
                    const SizedBox(width: 10),
                    categoryButton('ekonomi', 'ekonomi'),
                    const SizedBox(width: 10),
                    categoryButton('olahraga', 'olahraga'),
                    const SizedBox(width: 10),
                    categoryButton('teknologi', 'teknologi'),
                    const SizedBox(width: 10),
                    categoryButton('hiburan', 'hiburan'),
                    const SizedBox(width: 10),
                    categoryButton('gaya-hidup', 'gaya-hidup'),
                  ],
                ),
              ),
            ),

            // Berita Utama (Loading, No News, atau List)
            if (isLoading.value)
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filterNews.isEmpty)
              SliverFillRemaining(child: Center(child: Text('No news Found')))
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = _filterNews[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(newsDetail: item),
                        ),
                      );
                    },
                    child: Hero(
                      // Tag Hero di sini HARUS unik untuk setiap item di daftar
                      tag: 'news_item_${item['title']}_$index',
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Image.network(
                                  item['image']['small'],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['link'],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  // Obx di sini agar icon bookmark diperbarui
                                  Obx(
                                    () => IconButton(
                                      onPressed: () {
                                        // Catatan: isBookmarked ini masih global
                                        isBookmarked.value =
                                            !isBookmarked.value;
                                      },
                                      icon: Icon(
                                        isBookmarked.value
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                item['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                item['contentSnippet'],
                                style: TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 12),
                              Text(
                                formatDate(item['isoDate']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: _filterNews.length),
              ),
          ],
        ),
      ),
    );
  }
}
