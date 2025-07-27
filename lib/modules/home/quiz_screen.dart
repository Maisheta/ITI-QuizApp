import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'dart:async';
import 'category_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/firebase_service.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  String? selectedAnswer;
  int timeLeft = 30;
  bool isLoading = true;
  int currentQuestionIndex = 0;
  bool showAnswer = false;
  Timer? timer;
  int totalQuestions = 10;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  Locale currentLocale = const Locale('en');

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    startTimer();
  }

  void toggleLanguage() {
    setState(() {
      currentLocale = currentLocale.languageCode == 'en'
          ? const Locale('ar')
          : const Locale('en');
      Get.updateLocale(currentLocale);
    });
  }

  Future<void> fetchQuestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Dio().get(
        "https://opentdb.com/api.php?amount=$totalQuestions&type=multiple",
      );
      final List results = response.data['results'];
      final unescape = HtmlUnescape();

      questions = results.map((result) {
        final options = List<String>.from(
          result['incorrect_answers'].map((o) => unescape.convert(o)),
        )..add(unescape.convert(result['correct_answer']));
        options.shuffle();
        return {
          "question": unescape.convert(result['question']),
          "options": options,
          "correctAnswer": unescape.convert(result['correct_answer']),
        };
      }).toList();

      setState(() {
        isLoading = false;
        currentQuestionIndex = 0;
        selectedAnswer = null;
        showAnswer = false;
        correctAnswers = 0;
        wrongAnswers = 0;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        questions = [
          {
            "question": "connection_error".tr,
            "options": ["retry".tr],
            "correctAnswer": "retry".tr,
          },
        ];
      });
    }
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 30;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        t.cancel();
        showTimeOutDialog();
      }
    });
  }

  Future<void> saveQuizResult() async {
    FirebaseService().saveQuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: 10,
      category: widget.category,
    );
  }

  void showTimeOutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("time_up".tr),
        content: Text("time_over".tr),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              fetchQuestions();
              startTimer();
            },
            child: Text("ok".tr),
          ),
        ],
      ),
    );
  }

  void handleSubmit() {
    if (selectedAnswer != null) {
      setState(() {
        showAnswer = true;

        if (selectedAnswer ==
            questions[currentQuestionIndex]["correctAnswer"]) {
          correctAnswers++;
        } else {
          wrongAnswers++;
        }
      });

      Future.delayed(Duration(seconds: 3), () {
        if (currentQuestionIndex < totalQuestions - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = null;
            showAnswer = false;
          });
          startTimer();
        } else {
          saveQuizResult();

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Quiz Finished"),
              content: Text(
                "You've completed the quiz.\n"
                "Correct Answers: $correctAnswers\n"
                "Incorrect Answers: $wrongAnswers",
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryScreen()),
                    );
                  },

                  child: Text("restart".tr),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6CC), Color(0xFFF4C4C4), Color(0xFFE1BEE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconButton(Icons.arrow_back),
                    Text(
                      '${'round'.tr} - 1',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildIconButton(Icons.save),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'question'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFF5E6CC),
                                            Color(0xFFF4C4C4),
                                            Color(0xFFE1BEE7),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${currentQuestionIndex + 1}/$totalQuestions",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFF5E6CC),
                                        Color(0xFFF4C4C4),
                                        Color(0xFFE1BEE7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    questions[currentQuestionIndex]["question"],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFFA726),
                                        Color(0xFFF48FB1),
                                        Color(0xFFAB47BC),
                                      ],
                                    ),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: timeLeft / 30,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFA726),
                                            Color(0xFFF48FB1),
                                            Color(0xFFAB47BC),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Time 00:${timeLeft.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                ...List.generate(
                                  questions[currentQuestionIndex]["options"]
                                      .length,
                                  (index) {
                                    String option =
                                        questions[currentQuestionIndex]["options"][index];
                                    Color? optionColor;
                                    if (showAnswer) {
                                      if (option ==
                                          questions[currentQuestionIndex]["correctAnswer"]) {
                                        optionColor = Colors.green.withOpacity(
                                          0.3,
                                        );
                                      } else if (option == selectedAnswer) {
                                        optionColor = Colors.red.withOpacity(
                                          0.3,
                                        );
                                      }
                                    }

                                    return GestureDetector(
                                      onTap: showAnswer
                                          ? null
                                          : () {
                                              setState(() {
                                                selectedAnswer = option;
                                              });
                                            },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: optionColor ?? Colors.white,
                                          gradient:
                                              optionColor == null &&
                                                  selectedAnswer == option
                                              ? LinearGradient(
                                                  colors: [
                                                    Color(0xFFFFA726),
                                                    Color(0xFFF48FB1),
                                                    Color(0xFFAB47BC),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : null,
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
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Radio<String>(
                                              value: option,
                                              groupValue: selectedAnswer,
                                              onChanged: showAnswer
                                                  ? null
                                                  : (value) {
                                                      setState(() {
                                                        selectedAnswer = value;
                                                      });
                                                    },
                                            ),
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFFA726),
                                        Color(0xFFF48FB1),
                                        Color(0xFFAB47BC),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        (selectedAnswer == null || showAnswer)
                                        ? null
                                        : handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      minimumSize: Size(double.infinity, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text("Submit Answer"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CategoryScreen()),
          );
        },
        child: Icon(icon, color: Colors.black, size: 24),
      ),
    );
  }
}
