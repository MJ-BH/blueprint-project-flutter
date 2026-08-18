# Hera Flutter Clean Architecture Blueprint

> **Enterprise Flutter Monorepo Architecture with BLoC, Standalone UI Packages & Strict Governance**

This blueprint provides a production-ready starter template for building high-scale Flutter applications based on Clean Architecture principles, Result pattern error handling, Dio network clients, and strict project governance (`RULES.md`).

---

## 🏛️ Architecture & Project Layout

```
blueprint-project-flutter/
├── RULES.md                    # Non-negotiable development rules
├── packages/                   # Independent local packages
│   ├── app_ui/                 # Design system tokens, theme extensions, dynamic components
│   ├── explorer_repository/   # Monorepo repository package
│   └── aswan_api/              # Base API service & network handlers
├── lib/
│   ├── main.dart               # Entrypoint & RepositoryProvider setup
│   ├── core/                   # Core infrastructure (Dio client, failures, formatters, observers)
│   └── features/
│       └── explorer/           # Feature module following Clean Architecture
│           ├── bloc/           # Cubit/BLoC state management
│           └── ui/             # Presentation UI pages & widgets
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

---

# 📖 Adding a New Functionality to the Application

This guide outlines the process of adding a new functionality to our application, following our established architecture. The application uses a robust infrastructure for networking, logging, and error handling with the **Result pattern** and **Cubit/BLoC** for state management.

## Core Infrastructure

### 1. Network Layer

The application uses a centralized Dio client configuration:

```dart
class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    try {
      logger.debug('Initializing Dio client...');
      
      final dio = Dio()
        ..options = BaseOptions(
          baseUrl: ApiConfig.defaultBaseUrl,
          connectTimeout: ApiConfig.defaultConnectTimeout,
          receiveTimeout: ApiConfig.defaultReceiveTimeout,
          headers: ApiConfig.defaultHeaders,
          validateStatus: (status) => true,
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: _onRequest,
            onResponse: _onResponse,
            onError: _onError,
          ),
        );

      return dio;
    } catch (e, stack) {
      logger.error('Failed to initialize Dio client', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
```

### 2. API Configuration

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

### 3. Logging System

Comprehensive logging implementation:

```dart
final Logger logger = LoggerLogging();

class LogOptions {
  const LogOptions({
    this.showTime = true,
    this.showEmoji = true,
    this.logInRelease = false,
    this.level = LoggerLevel.info,
    this.formatter,
  });
}
```

---

## Step-by-Step Implementation Guide

### 1. API Layer Implementation

Create the API client for your feature in `packages/aswan_api/lib/`:

```dart
class NewFeatureApi extends BaseApiService {
  NewFeatureApi(super.client);

  Future<Result<NewFeatureResponse, Exception>> fetchFeatureData() async {
    return RepositoryHandler.handle(
      repositoryCall: () async {
        final response = await handleResponse(
          apiCall: () => client.get('/api/new-feature'),
          onSuccess: (data) => NewFeatureResponse.fromJson(data),
          logTag: 'NewFeatureApi.fetchFeatureData',
        );
        return Result.success(response);
      },
      logTag: 'NewFeatureApi.fetchFeatureData',
    );
  }

  Future<Result<bool, Exception>> submitData(FeatureRequest request) async {
    try {
      final response = await handleResponse(
        apiCall: () => client.post('/api/endpoint', data: request.toJson()),
        onSuccess: (data) => FeatureResponse.fromJson(data),
        logTag: 'NewFeatureApi.submitData',
      );
      return Result.success(response);
    } catch (e) {
      logger.error('Feature API submission error', error: e);
      return Result.failure(Exception(e.toString()));
    }
  }
}
```

### 2. Repository Layer Implementation

Create a new repository package in `packages/new_feature_repository/`:

```dart
class NewFeatureRepository extends BaseRepository {
  final AswanApi _api;
  final NewFeatureMapper _mapper;

  NewFeatureRepository({
    AswanApi? api,
    NewFeatureMapper? mapper,
  })  : _api = api ?? AswanApi(),
        _mapper = mapper ?? const NewFeatureMapper();

  Future<Result<NewFeatureEntity, Exception>> getFeatureData() async {
    return RepositoryHandler.handle(
      repositoryCall: () async {
        final response = await _api.newFeatureApi.fetchFeatureData();
        return response.fold(
          (success) => Result.success(_mapper.mapToEntity(success)),
          (failure) => Result.failure(failure),
        );
      },
      logTag: 'NewFeatureRepository.getFeatureData',
    );
  }
}
```

### 3. BLoC Layer Implementation

Create the BLoC in your feature directory `lib/presentation/new_feature/bloc/`:

```dart
// State
class NewFeatureState extends Equatable {
  final EnhancedStatus status;
  final NewFeatureEntity? data;
  final String? errorMessage;

  const NewFeatureState({
    this.status = EnhancedStatus.initial,
    this.data,
    this.errorMessage,
  });

  NewFeatureState copyWith({
    EnhancedStatus? status,
    NewFeatureEntity? data,
    String? errorMessage,
  }) {
    return NewFeatureState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}

// Cubit
class NewFeatureCubit extends Cubit<NewFeatureState> {
  final NewFeatureRepository _repository;

  NewFeatureCubit(this._repository) : super(const NewFeatureState());

  Future<void> loadFeatureData() async {
    try {
      emit(state.copyWith(status: EnhancedStatus.loading));

      final result = await _repository.getFeatureData();
      result.fold(
        (success) => emit(state.copyWith(
          status: EnhancedStatus.loaded,
          data: success,
        )),
        (failure) => emit(state.copyWith(
          status: EnhancedStatus.error,
          errorMessage: failure.toString(),
        )),
      );
    } catch (e, s) {
      logger.error('Failed to load feature data', error: e, stackTrace: s);
      emit(state.copyWith(
        status: EnhancedStatus.error,
        errorMessage: 'Failed to load data',
      ));
    }
  }
}
```

### 4. UI Layer Implementation

Create your feature UI in `lib/presentation/new_feature/`:

```dart
class NewFeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => NewFeatureRepository(),
      child: BlocProvider(
        create: (context) => NewFeatureCubit(
          context.read<NewFeatureRepository>(),
        )..loadFeatureData(),
        child: const NewFeatureView(),
      ),
    );
  }
}

class NewFeatureView extends StatelessWidget {
  const NewFeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewFeatureCubit, NewFeatureState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('New Feature')),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NewFeatureState state) {
    switch (state.status) {
      case EnhancedStatus.loading:
        return const Center(child: CircularProgressIndicator());
      
      case EnhancedStatus.loaded:
        return // Your feature UI;
      
      case EnhancedStatus.error:
        return Center(
          child: Text('Error: ${state.errorMessage}'),
        );
      
      default:
        return const SizedBox();
    }
  }
}
```

### 5. Adding Routes & Dependency Setup

Add your feature to the app routes in `lib/app/routes/routes.dart`:

```dart
class AppRouter {
  static const String newFeature = '/new-feature';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case newFeature:
        return MaterialPageRoute(
          builder: (_) => const NewFeaturePage(),
        );
      // ... other routes
    }
  }
}
```

---

## 📐 File Structure Convention

```
lib/
├── presentation/
│   └── new_feature/
│       ├── bloc/
│       │   ├── new_feature_cubit.dart
│       │   └── new_feature_state.dart
│       ├── view/
│       │   ├── new_feature_page.dart
│       │   └── new_feature_view.dart
│       └── widgets/
│           └── feature_specific_widgets.dart
│
packages/
└── new_feature_repository/
    ├── lib/
    │   ├── src/
    │   │   ├── models/
    │   │   └── mappers/
    │   └── new_feature_repository.dart
    └── test/
        └── new_feature_repository_test.dart
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
