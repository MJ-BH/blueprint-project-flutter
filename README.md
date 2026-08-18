# Hera Flutter Clean Architecture Blueprint

> **Enterprise Flutter Monorepo Architecture with BLoC, Standalone UI Packages & Strict Governance**

This blueprint provides a production-ready starter template for building high-scale Flutter applications based on Clean Architecture principles and strict project governance (`RULES.md`).

---

## 🏛️ Architecture & Project Layout

```
blueprint-project-flutter/
├── RULES.md                    # Non-negotiable development rules
├── packages/                   # Independent local packages
│   └── app_ui/                 # Design system tokens, theme extensions, dynamic components
├── lib/
│   ├── main.dart               # Entrypoint & RepositoryProvider setup
│   └── features/
│       └── auth/               # Feature module following Clean Architecture
│           ├── data/           # Remote DataSources & DTOs
│           ├── domain/         # Entities, Repository Interfaces & Use Cases
│           └── presentation/   # Cubit/BLoC state management & UI screens
└── test/                       # Unit & Widget tests
```

---

## 🚀 Key Features

* **Strict Separation of Concerns:** UI widgets never make direct API or SDK calls.
* **BLoC/Cubit State Management:** Immutable state flow using `flutter_bloc`.
* **Standalone UI Package (`packages/app_ui`):** Centralized design tokens and custom theme extensions.
* **Mandatory Testing Coverage:** Pre-configured unit and widget test suite.

---

## 🛠️ Getting Started

```bash
# Get dependencies for root and packages
flutter pub get
cd packages/app_ui && flutter pub get && cd ../..

# Run tests
flutter test

# Run app
flutter run
```
