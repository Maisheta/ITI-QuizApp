import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> categories = [];
  final Dio _dio = Dio();
  bool isLoading = true;
  late PageController _pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _dio.get('https://opentdb.com/api_category.php');
      if (response.statusCode == 200) {
        setState(() {
          categories = List<Map<String, dynamic>>.from(
            response.data['trivia_categories'],
          );
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching categories: $e');
      setState(() => isLoading = false);
    }
  }

  void goToNextPage() {
    if (currentPage < (categories.length / 8).ceil() - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentPage++);
    }
  }

  void goToPreviousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentPage--);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6CC), Color(0xFFF4C4C4), Color(0xFFE1BEE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Select Category",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 320,
                              width: screenWidth * 0.85,
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) =>
                                    setState(() => currentPage = index),
                                itemCount: (categories.length / 8).ceil(),
                                itemBuilder: (context, pageIndex) {
                                  final startIndex = pageIndex * 8;
                                  final endIndex = (startIndex + 8).clamp(
                                    0,
                                    categories.length,
                                  );
                                  final currentCategories = categories.sublist(
                                    startIndex,
                                    endIndex,
                                  );

                                  return GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: currentCategories.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                          childAspectRatio: 2.5,
                                        ),
                                    itemBuilder: (context, index) {
                                      final cat = currentCategories[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const QuizScreen(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFFA726),
                                                Color(0xFFF48FB1),
                                                Color(0xFFAB47BC),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                String.fromCharCode(
                                                  97 + index,
                                                ).toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  cat['name'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: currentPage > 0
                                  ? goToPreviousPage
                                  : null,
                              color: currentPage > 0
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed:
                                  currentPage <
                                      (categories.length / 8).ceil() - 1
                                  ? goToNextPage
                                  : null,
                              color:
                                  currentPage <
                                      (categories.length / 8).ceil() - 1
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
