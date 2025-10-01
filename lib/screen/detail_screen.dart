import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/api/api.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> newsDetail;
  const DetailScreen({super.key, required this.newsDetail});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isDarkMode = false;

  final PageController _pageController = PageController(viewportFraction: 0.85);
  final _currentPage = 0.obs;

  // pakai obs langsung
  final RxBool _isLoading = true.obs;
  final RxList<Map<String, dynamic>> _relatedNews =
      <Map<String, dynamic>>[].obs;

  Future<void> fetchRelatedNews() async {
    _isLoading.value = true;
    try {
      final data = await Api()
          .getApi(); // harus return List<Map<String, dynamic>>
      _relatedNews.value = data.take(5).toList();
    } catch (e) {
      print("Error fetching related news: $e");
      _relatedNews.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRelatedNews();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News Detail"),
        centerTitle: true,
        backgroundColor: _isDarkMode ? Colors.black26 : Colors.white12,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: _isDarkMode ? Colors.black : Colors.white,
        child: ListView(
          children: [
            Hero(
              tag: widget.newsDetail['title'] ?? '',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.newsDetail['image']['small'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.newsDetail['title'] ?? "No Title",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.newsDetail['contentSnippet'] ?? "No Content",
                      style: TextStyle(
                        fontSize: 18,
                        color: _isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.all(8),
              color: _isDarkMode ? Colors.grey[900] : Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Related News",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(() {
                    if (_isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (_relatedNews.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text("Tidak ada berita terkait ditemukan."),
                        ),
                      );
                    } else {
                      return SizedBox(
                        height: 250,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _relatedNews.length,
                          onPageChanged: (i) => setState(() {
                            _currentPage.value = i;
                          }),
                          itemBuilder: (context, i) {
                            final item = _relatedNews[i];
                            final imageURL = item['image']['small'] ?? '';
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: _currentPage == i ? 8 : 16,
                              ),
                              decoration: BoxDecoration(
                                color: _isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: imageURL.isNotEmpty
                                        ? Image.network(
                                            imageURL,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 150,
                                            errorBuilder: (c, e, s) =>
                                                Container(
                                                  height: 150,
                                                  color: Colors.grey,
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            height: 150,
                                            color: Colors.grey,
                                            child: const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      item['title'] ?? "No Title",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
