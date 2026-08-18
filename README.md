# Blueprint Project Flutter

> **Enterprise Flutter Monorepo Architecture with BLoC, Standalone Packages & White-Label Multi-Flavor Support**  
> *Architectural principles inspired by [Very Good Ventures Flutter Architecture](https://verygood.ventures/blog/very-good-flutter-architecture/).*

This blueprint provides a production-ready starter template for building high-scale Flutter applications based on Clean Architecture principles, Result pattern error handling, Dio/Http network clients, and strict project governance (`RULES.md`).

---

## 🌐 White-Label, Multi-Brand & Flavor Possibilities

One of the greatest powers of this architecture is **Single Core Monorepo → Multi-Brand & Multi-Country Deployments**.

By isolating shared logic into `packages/` (`packages/core`, `packages/app_ui`, `packages/*_repository`), you can build and maintain multiple distinct applications or client variants inside `lib/` using the exact same underlying codebase:

* 🏢 **Multi-Client / White-Label Deployments:** Client A (`lib/main_client_a.dart`) vs Client B (`lib/main_client_b.dart`) with unique branding, API endpoints, and feature flags.
* 🌍 **Multi-Country & Regional Variants:** Unique bundle IDs (`com.trvl.us`, `com.trvl.fr`), local currency formats, and country-specific payment gateways.
* 🎨 **Dynamic UI Themes & Branding:** Swapping colors, typography, and logo asset bundles via `packages/app_ui` without modifying feature business logic.
* 🚩 **Feature Flag Governance:** Turning modules on/off dynamically per client tier without resubmitting core app code.

---

## 🏛️ Architectural Foundation (Very Good Ventures Standards)

Our architectural philosophy strictly adheres to the **Very Good Ventures (VGV) Flutter Architecture**:

1. **Layer Separation & Monorepo Packages (`packages/`):** All reusable domain entities, data providers, API clients, and design system components are extracted into standalone local packages under `packages/` (e.g. `packages/core`, `packages/app_ui`, `packages/explorer_repository`).
2. **UI Isolation:** UI widgets never make direct API, HTTP, or Firebase calls. All data flow is mediated by Repositories and `Cubit`/`BLoC` state management.
3. **Repository Pattern:** Repositories serve as the single source of truth for the application, mapping raw API responses into domain models using `BaseMapper<Entity, Dto>`.
4. **Result Pattern & Error Handling:** Explicit `Result<S, E>` types for predictable error propagation without unhandled runtime crashes.
5. **Scoped On-Demand Dependency Injection:** Repositories and Blocs/Cubits are injected at root level for global singletons OR scoped on-demand at feature/page boundaries to ensure proper lifecycle disposal.
6. **Global State Logging (`AppBlocObserver`):** Automatic logging of BLoC creations, state transitions (`currentState ➡️ nextState`), and uncaught exceptions.
7. **Testing Discipline:** 100% testable architecture with mandatory unit tests for Blocs, Cubits, and Repositories.

---

## 📁 Monorepo Layout & Flavor Entry Points

```
blueprint-project-flutter/
├── RULES.md                    # Non-negotiable development rules (VGV Architecture)
├── packages/                   # Shared Reusable Monorepo Packages (REUSED BY ALL FLAVORS)
│   ├── core/                   # Shared infrastructure (BaseApiService, BaseRepository, BaseMapper, Result, Logger)
│   ├── app_ui/                 # Design system tokens, theme extensions, dynamic components (AppColors, AppButton)
│   └── explorer_repository/   # Monorepo repository package (FakeExplorerApi & ExplorerRepositoryImpl)
├── lib/
│   ├── main.dart               # Generic/Demo App entry point
│   ├── main_client_a.dart      # Client A / Brand Alpha target (Custom Theme, API Endpoint A)
│   ├── main_client_b.dart      # Client B / Regional Beta target (Custom Theme, API Endpoint B)
│   ├── core/                   # App-level routing (AppRouter), context extensions, AppBlocObserver
│   └── features/
│       └── explorer/           # Feature module following Clean Architecture
│           ├── bloc/           # Cubit/BLoC state management
│           └── ui/             # Presentation UI pages & widgets
└── test/                       # Unit & Widget tests
```

---

## 🚀 Build Commands for Multi-Brand Flavors

```bash
# Run Generic Demo App
flutter run -t lib/main.dart

# Run Client A Target (Alpha Travel)
flutter run -t lib/main_client_a.dart --flavor clientA

# Run Client B Target (Beta Mobility)
flutter run -t lib/main_client_b.dart --flavor clientB

# Build Release APK for Client A
flutter build apk -t lib/main_client_a.dart --flavor clientA
```

---

# 📖 Core Infrastructure & Feature Implementation Guide

This guide outlines the process of adding a new functionality to our application, following our established [Very Good Ventures Architecture](https://verygood.ventures/blog/very-good-flutter-architecture/).

## 💉 Dependency Injection Strategy (Global vs. Scoped On-Demand)

Dependency injection is **not limited to `main.dart`**. We enforce a **Contextual Scoped & On-Demand Injection Strategy**:

1. **Global Root Injection (`main.dart` / `main_client_a.dart`):**  
   Reserved for app-wide singletons (e.g. Authentication Repository, User Session Storage, Global Network Client).

2. **Scoped Feature Injection (`Page` / `View` Boundary):**  
   Repositories and Cubits specific to a feature are injected **on-demand** when the page route is built. When the user leaves the page, resources are automatically disposed of:

```dart
class NewFeaturePage extends StatelessWidget {
  const NewFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<NewFeatureRepository>(
      create: (context) => NewFeatureRepositoryImpl(
        api: FakeFeatureApi(),
      ),
      child: BlocProvider<NewFeatureCubit>(
        create: (context) => NewFeatureCubit(
          repository: context.read<NewFeatureRepository>(),
        )..loadFeatureData(),
        child: const NewFeatureView(),
      ),
    );
  }
}
```

3. **Sub-tree / Modal On-Demand Injection:**  
   Inject dependencies dynamically inside modal bottom sheets, tab views, or nested route flows (`context.read<T>()` / `RepositoryProvider.value`).

---

## 🛠️ Shared Core Infrastructure (`packages/core`)

### 1. Logging System (`Logger` & `LogOptions`)

Comprehensive logging implementation located in `packages/core/lib/src/logging/logger.dart`:

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

### 2. Global BLoC Observer (`AppBlocObserver`)

App-wide BLoC state change and error logging configured in `lib/core/utils/bloc_observer.dart` and attached in entry points (`main.dart` / `main_client_a.dart`):

```dart
// lib/main_client_a.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Attach Global BLoC Observer for state tracking
  Bloc.observer = AppBlocObserver();

  runApp(const ClientApp(config: config));
}
```

### 3. Base Mapper Package (`BaseMapper<Entity, Dto>`)

Standardized DTO-to-Entity mapping interface located in `packages/core/lib/src/mappers/base_mapper.dart`:

```dart
abstract class BaseMapper<Entity, Dto> {
  const BaseMapper();

  Entity mapToEntity(Dto dto);
  Dto mapToDto(Entity entity);

  List<Entity> mapToEntityList(List<Dto> dtos) {
    return dtos.map(mapToEntity).toList();
  }

  List<Dto> mapToDtoList(List<Entity> entities) {
    return entities.map(mapToDto).toList();
  }
}
```

### 4. Network Layer (`BaseApiService` & `ApiConfig`)

Centralized API service wrapper in `packages/core/lib/src/network/`:

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

---

## 📐 File Structure Convention (VGV Monorepo Style)

```
lib/
├── core/
│   ├── routing/app_router.dart
│   ├── extensions/context_extensions.dart
│   └── utils/bloc_observer.dart
├── main.dart                  # Generic Demo
├── main_client_a.dart         # Client A Target
├── main_client_b.dart         # Client B Target
└── features/
    └── explorer/
        ├── bloc/explorer_bloc.dart
        └── ui/explorer_page.dart

packages/
├── core/                      # Shared framework infrastructure (REUSED)
├── app_ui/                    # Design system package (REUSED & THEMED)
└── explorer_repository/      # Feature data repository (REUSED)
```

---

## ✅ Best Practices

1. **White-Label Reuse:** 100% of code inside `packages/` is shared across all client entry points (`main_client_a.dart`, `main_client_b.dart`).
2. **Error Handling:** Use the `Result` type for error handling, implement clear error messages, and handle loading states gracefully.
3. **Dependency Injection:** Use root `main.dart` for global singletons AND scoped `RepositoryProvider` / `BlocProvider` on demand per feature `Page` boundary.
4. **State Logging:** Attach `AppBlocObserver` to capture all state transitions and uncaught BLoC exceptions.
5. **Data Mapping:** Extend `BaseMapper<Entity, Dto>` for deterministic mapping between network JSON models and domain entities.
6. **Testing:** Write unit tests for each layer (API, Repository, and Cubit/BLoC).
