<div align="center">

  <img src="assets/images/icon.png" alt="AuroraLex Suite Logo" width="120" height="120" />

  # ⚖️ AuroraLex Suite

  **Next-Gen AI-Powered Legal Assistant**

  [![Flutter](https://img.shields.io/badge/Flutter-3.19-%2302569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.0-%230175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Core-%23FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
  [![Gemini AI](https://img.shields.io/badge/AI-Gemini%20Pro-8E44AD?style=for-the-badge&logo=google-bard&logoColor=white)](https://deepmind.google/technologies/gemini/)
  [![License](https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge)](LICENSE)

  <p align="center">
    <a href="#-features">Features</a> •
    <a href="#-tech-stack">Tech Stack</a> •
    <a href="#-installation">Installation</a> •
    <a href="#-screenshots">Screenshots</a>
  </p>
</div>

---

## 🌟 About

**AuroraLex Suite** is a comprehensive mobile assistant designed to reduce the workload and increase the efficiency of legal professionals, powered by **Google Gemini AI**. Going beyond traditional legal apps, it offers AI-based consultation, smart case tracking, and secure document management in a single modern interface.

---

## 🚀 Features

### 🤖 AI Legal Advisor
> *An intelligent assistant that researches, analyzes, and summarizes for you.*
*   **Legal Expert**: Specialized in Constitution, Criminal, Procedure, and Civil Law.
*   **Academic Analysis**: Detailed legal interpretations based on statutes.
*   **Context Memory**: Seamless chat experience that remembers previous conversations.

### 📁 Smart Case Tracker
*   **Case Management**: Detailed tracking and status management for all your cases.
*   **Calendar & Reminders**: Never miss a hearing date.
*   **Document Vault**: Securely store and categorize your case files.

### 📚 Interactive Legal Dictionary
*   **Bilingual**: 48+ essential legal terms in Turkish and English.
*   **Categorical Access**: Filter by Criminal, Civil, Commercial Law, etc.
*   **Illustrated Explanations**: Practical usage scenarios for each term.

### 🔐 High Security
*   **Biometric Login**: Fingerprint and Face Recognition (FaceID/TouchID).
*   **Cloud Security**: Data protected by Firebase Authentication.
*   **Privacy Focused**: Your personal data is secure.

---

## 🛠️ Tech Stack

| Area | Technology | Detail |
|------|-----------|-------|
| **Frontend** | ![Flutter](https://img.shields.io/badge/-Flutter-02569B?logo=flutter&logoColor=white) | Material Design 3, Responsive UI |
| **Language** | ![Dart](https://img.shields.io/badge/-Dart-0175C2?logo=dart&logoColor=white) | Null Safety, Async/Await |
| **Backend** | ![Firebase](https://img.shields.io/badge/-Firebase-FFCA28?logo=firebase&logoColor=black) | Auth, Firestore, Storage, Functions |
| **AI Model** | ![Gemini](https://img.shields.io/badge/-Gemini-8E44AD?logo=google-bard&logoColor=white) | Google Generative AI SDK |
| **State Mng.** | ![Riverpod](https://img.shields.io/badge/-Riverpod-2D3748?logo=riverpod&logoColor=white) | Hooks Riverpod |
| **Routing** | ![GoRouter](https://img.shields.io/badge/-GoRouter-2D3748) | Declarative Routing |

---

## 📱 Installation

Follow these steps to run the project locally:

### 1. Clone the Project
```bash
git clone https://github.com/MANOROMAN/AuroraLex-Suite.git
cd AuroraLex-Suite
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup API Keys
For security reasons, API keys are not included in the repo. Update the following files with your own keys:

*   `lib/src/services/ai_service.dart`:
    ```dart
    _apiKey = 'YOUR_GEMINI_API_KEY';
    ```
*   `lib/src/core/config/firebase_options.dart`:
    ```dart
    apiKey: 'YOUR_FIREBASE_API_KEY',
    ```

### 4. Run the App
```bash
flutter run
```

---

## 📂 Project Structure

```
lib/
├── src/
│   ├── core/            # Configuration, Constants, Theme
│   ├── features/        # Feature-based Modules (Auth, Dashboard, etc.)
│   ├── services/        # API and Backend Services
│   ├── widgets/         # Reusable Widgets
│   └── app.dart         # Main App Widget
└── main.dart            # Entry Point
```

---

## ⚠️ Disclaimer

*This application is a tool developed to assist legal professionals. AI-generated content is advisory and does not constitute professional legal advice. Always consult a qualified lawyer before making critical decisions.*

---

<div align="center">

  **Developed with ❤️ by AuroraLex Team**
  
  [![GitHub](https://img.shields.io/badge/GitHub-MANOROMAN-181717?style=flat&logo=github)](https://github.com/MANOROMAN)

</div>
