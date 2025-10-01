import 'package:flutter/material.dart';
import 'package:news_app/api/api.dart';
import 'package:news_app/screen/detail_screen.dart';

import 'package:intl/intl.dart';

class SearchApi extends StatefulWidget {
  const SearchApi({super.key});

  @override
  State<SearchApi> createState() => _SearchApiState();
}

class _SearchApiState extends State<SearchApi> {
  String _selectedCategory = '';

  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allNews = [];
  List<Map<String, dynamic>> _filterNews = [];
  bool isLoading = false;

  Future<void> fetchNews(String type) async {
    setState(() {
      isLoading = true;
    });

    final data = await Api().getApi(category: type);
    setState(() {
      _allNews = data;
      _filterNews = data;
      isLoading = false;
    });
  }

  _applySearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filterNews = _allNews;
      });
    } else {
      setState(() {
        _filterNews = _allNews.where((item) {
          final title = item['title'].toString().toLowerCase();
          final snippet = item['contentSnippet'].toString().toLowerCase();
          final search = query.toLowerCase();
          return title.contains(search) || snippet.contains(search);
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews(_selectedCategory);
    _searchController.addListener(() {
      _applySearch(_searchController.text);
    });
  }

  Widget categoryButton(String label, String category) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedCategory == category
            ? Colors.blue
            : Colors.grey[100],
        foregroundColor: _selectedCategory == category
            ? Colors.white
            : Colors.black,
      ),
      onPressed: () {
        setState(() {
          _selectedCategory = category;
        });
        fetchNews(category);
      },
      child: Text(label),
    );
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd MM yyyy, HH:mm').format(dateTime);
  }

  bool isBoomarked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('News App', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                  size: 28,
                ),
                hintText: 'Search news...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: EdgeInsets.all(10),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                categoryButton('semua', ''),
                SizedBox(width: 10),
                categoryButton('nasional', 'nasional'),
                SizedBox(width: 10),
                categoryButton('internasional', 'internasional'),
                SizedBox(width: 10),
                categoryButton('ekonomi', 'ekonomi'),
                SizedBox(width: 10),
                categoryButton('olahraga', 'olahraga'),
                SizedBox(width: 10),
                categoryButton('teknologi', 'teknologi'),
                SizedBox(width: 10),
                categoryButton('hiburan', 'hiburan'),
                SizedBox(width: 10),
                categoryButton('gaya-hidup', 'gaya-hidup'),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _filterNews.isEmpty
                ? Center(child: Text('No news Found'))
                : Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: _filterNews.length,
                      itemBuilder: (context, index) {
                        final item = _filterNews[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(
                                  milliseconds: 750,
                                ), // atur durasi animasi
                                reverseTransitionDuration: const Duration(
                                  milliseconds: 750,
                                ), // balik juga
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        DetailScreen(
                                          newsDetail: item,
                                          
                                        ),
                              ),
                            );
                          },

                          child: Hero(
                            tag: item['title'],
                            child: Card(
                              margin: EdgeInsets.only(bottom: 16.0),
                              elevation: 2.0,
                              shadowColor: Colors.black.withOpacity(0.1),
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
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isBoomarked = !isBoomarked;
                                            });
                                          },
                                          icon: Icon(
                                            isBoomarked
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                          ),
                                          constraints: BoxConstraints(),
                                          padding: EdgeInsets.zero,
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                      ),
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
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
