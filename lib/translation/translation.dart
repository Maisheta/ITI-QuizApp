import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar': {
      'select_category': 'اختر الفئة',
      'submit_answer': 'تأكيد الإجابة',
      'round': 'الجولة',
      'number_question': 'رقم السؤال',
      'time_up': 'انتهى الوقت',
      'time_up_msg': 'لقد انتهى الوقت. سيتم إعادة الكويز.',
      'ok': 'حسنًا',
      'quiz_finished': 'انتهى الاختبار',
      'correct': 'إجابات صحيحة',
      'incorrect': 'إجابات خاطئة',
      'restart': 'إعادة',
      'time': 'الوقت',
      'question': 'السؤال',
    },
    'en': {
      'select_category': 'Select Category',
      'submit_answer': 'Submit Answer',
      'round': 'Round',
      'number_question': 'No of Question',
      'time_up': "Time's Up",
      'time_up_msg': 'Time is over. Restarting the quiz.',
      'ok': 'OK',
      'quiz_finished': 'Quiz Finished',
      'correct': 'Correct Answers',
      'incorrect': 'Incorrect Answers',
      'restart': 'Restart',
      'time': 'Time',
      'question': 'question',
    },
  };
}
