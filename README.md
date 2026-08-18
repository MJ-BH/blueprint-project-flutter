# Blueprint Project Flutter

> **Enterprise Flutter Monorepo Architecture with BLoC, Standalone Packages & Strict Governance**  
> *Architectural principles inspired by [Very Good Ventures Flutter Architecture](https://verygood.ventures/blog/very-good-flutter-architecture/).*

This blueprint provides a production-ready starter template for building high-scale Flutter applications based on Clean Architecture principles, Result pattern error handling, Dio/Http network clients, and strict project governance (`RULES.md`).

---

## 🏛️ Architectural Foundation (Very Good Ventures Standards)

Our architectural philosophy strictly adheres to the **Very Good Ventures (VGV) Flutter Architecture**:

1. **Layer Separation & Monorepo Packages (`packages/`):** All reusable domain entities, data providers, API clients, and design system components are extracted into standalone local packages under `packages/` (e.g. `packages/core`, `packages/app_ui`, `packages/explorer_repository`).
2. **UI Isolation:** UI widgets never make direct API, HTTP, or Firebase calls. All data flow is mediated by Repositories and `Cubit`/`BLoC` state management.
3. **Repository Pattern:** Repositories serve as the single source of truth for the application, mapping raw API responses into domain models.
4. **Result Pattern & Error Handling:** Explicit `Result<S, E>` types for predictable error propagation without unhandled runtime crashes.
5. **Testing Discipline:** 100% testable architecture with mandatory unit tests for Blocs, Cubits, and Repositories.

---

## 📁 Monorepo Layout

```
blueprint-project-flutter/
├── RULES.md                    # Non-negotiable development rules (VGV Architecture)
├── packages/                   # Independent local packages (VGV Package Strategy)
│   ├── core/                   # Shared infrastructure (BaseApiService, BaseRepository, Result, Logger, ApiConfig)
│   ├── app_ui/                 # Design system tokens, theme extensions, dynamic components (AppColors, AppButton)
│   └── explorer_repository/   # Monorepo repository package (FakeExplorerApi & ExplorerRepositoryImpl)
├── lib/
│   ├── main.dart               # Entrypoint & RepositoryProvider setup
│   ├── core/                   # App-level routing (AppRouter), context extensions, AppBlocObserver
│   └── features/
│       └── explorer/           # Feature module following Clean Architecture
│           ├── bloc/           # Cubit/BLoC state management
│           └── ui/             # Presentation UI pages & widgets
└── test/                       # Unit & Widget tests
```

---

## 🚀 Key Features

* **VGV Monorepo Modularization:** Independent local packages under `packages/`.
* **Shared Infrastructure (`packages/core`):** `BaseApiService`, `BaseRepository`, `Result<S, E>` pattern, and `Logger`.
* **App-Level Core (`lib/core`):** `AppRouter` navigation, `ContextExtensions`, and `AppBlocObserver`.
* **BLoC/Cubit State Management:** Immutable state flow using `flutter_bloc`.
* **Standalone UI Package (`packages/app_ui`):** Centralized design tokens and custom theme extensions.
* **Mandatory Testing Coverage:** Pre-configured unit and widget test suite.

---

## 🛠️ Getting Started

```bash
# Get dependencies for root and packages
flutter pub get
cd packages/core && flutter pub get && cd ../..
cd packages/app_ui && flutter pub get && cd ../..
cd packages/explorer_repository && flutter pub get && cd ../..

# Run tests
flutter test

# Run app
flutter run
```

---

# 📖 Adding a New Functionality to the Application

This guide outlines the process of adding a new functionality to our application, following our established [Very Good Ventures Architecture](https://verygood.ventures/blog/very-good-flutter-architecture/). The application uses a robust infrastructure in `packages/core` for networking, logging, and error handling with the **Result pattern** and **Cubit/BLoC** for state management.

## Core Infrastructure (`packages/core`)

### 1. Network Layer (`BaseApiService`)

The application uses a centralized API client service wrapper extending `BaseApiService`:

```dart
abstract class BaseApiService {
  final dynamic client;
  BaseApiService(this.client);

  Future<T> handleResponse<T>({
    required Future<dynamic> Function() apiCall,
    required T Function(dynamic data) onSuccess,
    required String logTag,
  }) async {
    try {
      logger.info('Executing API Call', tag: logTag);
      final rawResponse = await apiCall();
      return onSuccess(rawResponse);
    } catch (e, stack) {
      logger.error('API Error encountered', error: e, stackTrace: stack, tag: logTag);
      rethrow;
    }
  }
}
```

### 2. API Configuration (`ApiConfig`)

Standard API configuration settings:

```dart
class ApiConfig {
  static const defaultBaseUrl = 'http://mas.phyliatech.com/';
  static const defaultConnectTimeout = Duration(seconds: 30);
  static const defaultReceiveTimeout = Duration(seconds: 30);

  static const defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
```

### 3. Logging System (`Logger`)

Comprehensive logging implementation:

```dart
final Logger logger = const Logger();

class LogOptions {
  final bool showTime;
  final bool showEmoji;
  final bool logInRelease;
  final LoggerLevel level;

  const LogOptions({
    this.showTime = true,
    this.showEmoji = true,
    this.logInRelease = false,
    this.level = LoggerLevel.debug,
  });
}
```

---

## Step-by-Step Implementation Guide

### 1. API Layer Implementation (`FakeExplorerApi` / `BaseApiService`)

Create the API client for your feature in `packages/explorer_repository/lib/src/api/fake_explorer_api.dart`:

```dart
class FakeExplorerApi extends BaseApiService {
  FakeExplorerApi() : super(null);

  Future<Result<List<Map<String, dynamic>>, Exception>> fetchItems({String? folderId}) async {
    return handleResponse(
      apiCall: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        final filtered = _mockDatabase.where((item) => item['parentId'] == folderId).toList();
        return Result.success<List<Map<String, dynamic>>, Exception>(filtered);
      },
      onSuccess: (result) => result as Result<List<Map<String, dynamic>>, Exception>,
      logTag: 'FakeExplorerApi.fetchItems',
    );
  }
}
```

### 2. Repository Layer Implementation (`ExplorerRepositoryImpl` / `BaseRepository`)

Create a new repository package in `packages/explorer_repository/`:

```dart
class ExplorerRepositoryImpl extends BaseRepository implements ExplorerRepository {
  final FakeExplorerApi _api;

  ExplorerRepositoryImpl({FakeExplorerApi? api})
      : _api = api ?? FakeExplorerApi();

  @override
  Future<Result<List<FileItem>, Exception>> getItems({String? folderId}) async {
    return handleRepositoryCall(
      call: () async {
        final result = await _api.fetchItems(folderId: folderId);
        return result.fold(
          (jsonList) => Result.success(jsonList.map((j) => FileItem.fromJson(j)).toList()),
          (failure) => Result.failure(failure),
        );
      },
      logTag: 'ExplorerRepositoryImpl.getItems',
    );
  }
}
```

### 3. BLoC Layer Implementation (`ExplorerBloc`)

Create the BLoC in your feature directory `lib/features/explorer/bloc/`:

```dart
class ExplorerBloc extends Bloc<ExplorerEvent, ExplorerState> {
  final ExplorerRepository repository;

  ExplorerBloc({required this.repository}) : super(ExplorerInitial()) {
    on<LoadExplorerItems>(_onLoadItems);
  }

  Future<void> _onLoadItems(LoadExplorerItems event, Emitter<ExplorerState> emit) async {
    emit(ExplorerLoading());
    final result = await repository.getItems(folderId: event.folderId);
    result.fold(
      (items) => emit(items.isEmpty ? ExplorerEmpty() : ExplorerLoaded(items: items)),
      (failure) => emit(ExplorerError(failure.toString())),
    );
  }
}
```

### 4. UI Layer Implementation (`ExplorerPage`)

Create your feature UI in `lib/features/explorer/ui/`:

```dart
class ExplorerPage extends StatelessWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExplorerBloc, ExplorerState>(
      builder: (context, state) {
        if (state is ExplorerLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ExplorerLoaded) {
          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) => ListTile(title: Text(state.items[index].name)),
          );
        } else if (state is ExplorerError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox();
      },
    );
  }
}
```

### 5. Adding Routes & Dependency Setup (`lib/core/routing/app_router.dart`)

Add your feature to the app routes in `lib/core/routing/app_router.dart`:

```dart
class AppRouter {
  static const String explorer = '/explorer';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case explorer:
        return MaterialPageRoute(builder: (_) => const ExplorerPage());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold());
    }
  }
}
```

---

## 📐 File Structure Convention (VGV Monorepo Style)

```
lib/
├── core/
│   ├── routing/app_router.dart
│   ├── extensions/context_extensions.dart
│   └── utils/bloc_observer.dart
└── features/
    └── explorer/
        ├── bloc/explorer_bloc.dart
        └── ui/explorer_page.dart

packages/
├── core/                      # Shared framework infrastructure
│   ├── lib/src/network/base_api_service.dart
│   ├── lib/src/repository/base_repository.dart
│   └── lib/src/result/result.dart
├── app_ui/                    # Design system package
└── explorer_repository/      # Feature data repository
    ├── lib/src/api/fake_explorer_api.dart
    └── lib/src/explorer_repository.dart
```

---

## ✅ Best Practices

1. **Error Handling:** Use the `Result` type for error handling, implement clear error messages, and handle loading states gracefully.
2. **State Management:** Keep states immutable, use `copyWith` for state updates, and handle all possible state branches.
3. **Dependency Injection:** Use `RepositoryProvider` for repositories and `BlocProvider` for BLoCs.
4. **Testing:** Write unit tests for each layer (API, Repository, and Cubit/BLoC).

---

## ⚠️ Common Pitfalls to Avoid

1. **Don't Skip Layers:** Always maintain proper data flow: **UI → BLoC → Repository → API**. Never access the API directly from BLoC.
2. **State Management:** Don't modify state directly; always use `emit()` in Cubits.
3. **Error Handling:** Don't swallow errors; properly propagate errors up the chain.
4. **Testing:** Mock dependencies and test both success and error branches.
