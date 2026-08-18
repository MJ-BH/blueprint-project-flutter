# Hera / VGV Project Rules

> **Architectural Standard:** Based on [Very Good Ventures (VGV) Flutter Architecture](https://verygood.ventures/blog/very-good-flutter-architecture/).

These rules are **ABSOLUTE** and must be strictly enforced across all feature branches:

## 1. Architecture (Clean Architecture & VGV BLoC)
- **Strict UI Separation:** The UI layer must NEVER contain business logic or direct API/Firebase calls.
- **State Management:** Use exclusively `Cubit` or `Bloc` (`flutter_bloc`) for managing screen states.
- **VGV Package Strategy:** All data access logic belongs inside independent packages under `packages/` (e.g. `packages/core`, `packages/authentication_repository`).
- **Dependency Injection:** Inject repositories via `RepositoryProvider` in `main.dart`.

## 2. Automated Testing
- **Unit Tests:** Mandatory for every `Cubit`, `Bloc`, `Repository`, or `Model` in `test/`.
- **Widget Tests:** Mandatory for all primary screens and UI components.

## 3. Design System
- Always use theme tokens and components from `packages/app_ui`.
