# 📚 Flutter Quiz App

A Flutter-based quiz application that allows users to take categorized quizzes, track scores, and view a global leaderboard. The app features Firebase Authentication, Firestore for result storage, and supports both Arabic and English using GetX.

---

## 🚀 Features

- ✅ User authentication with Firebase Auth
- 🧠 Category-based quizzes
- 🧾 Save and update quiz results in Firestore
- 🔁 Automatically updates score if user retakes the same category
- 🌐 Arabic/English language support using GetX
- ⏱️ Countdown timer for each question
- ✅ Shows correct/incorrect feedback after each answer
- 📊 Leaderboard displaying top scorers
- 📱 Fully custom static UI (no layout changes)

---

## 📦 Requirements

- Flutter SDK (latest)
- Firebase project (Auth + Firestore enabled)
- Dio package for API integration
- GetX for state management and localization

---

## 🛠️ Installation

```bash
git clone https://github.com/Maisheta/ITI-QuizApp.git
cd your-repo-name
flutter pub get
flutter run
