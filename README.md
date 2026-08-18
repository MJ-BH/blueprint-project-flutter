# Blueprint Project Flutter

> **Enterprise Flutter Monorepo Architecture with BLoC, Standalone Packages & White-Label Multi-Flavor Support**  
> *Architectural principles inspired by [Very Good Ventures Flutter Architecture](https://verygood.ventures/blog/very-good-flutter-architecture/).*

This blueprint provides a production-ready starter template for building high-scale Flutter applications based on Clean Architecture principles, Result pattern error handling, Dio/Http network clients, and strict project governance (`RULES.md`).

---

## 🌐 White-Label, Multi-Brand & Flavor Possibilities

One of the greatest powers of this architecture is **Single Core Monorepo → Multi-Brand & Multi-Country Deployments**.

By isolating shared logic into `packages/` (`packages/core`, `packages/app_ui`, `packages/*_repository`), you can build and maintain multiple distinct applications or client variants inside `lib/` using the exact same underlying codebase:

* 🏢 **Multi-Client / White-Label Deployments:** Client A (`lib/main_client_a.dart`) vs Client B (`lib/main_client_b.dart`) with unique branding, API endpoints, and feature flags.
* 🌍 **Multi-Country & Regional Variants:** Unique bundle IDs (`com.example.us`, `com.example.fr`), local currency formats, and country-specific payment gateways.
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
│   ├── core/                   # Shared framework infrastructure (BaseApiService, BaseRepository, BaseMapper, Result, Logger)
│   │   └── lib/src/
│   │       ├── errors/         # ServerFailure, NetworkFailure, AuthFailure
│   │       ├── logging/        # Logger & LogOptions system
│   │       ├── mappers/        # BaseMapper<Entity, Dto> interface
│   │       ├── network/        # BaseApiService & ApiConfig
│   │       ├── repository/     # BaseRepository wrapper
│   │       └── result/         # Result<S, E> pattern
│   ├── app_ui/                 # Design system tokens, theme extensions, dynamic components (AppColors, AppButton)
│   └── explorer_repository/   # Monorepo repository package (FakeExplorerApi & ExplorerRepositoryImpl)
├── lib/
│   ├── main.dart               # Generic/Demo App entry point
│   ├── main_client_a.dart      # Client A Target (Alpha Brand)
│   ├── main_client_b.dart      # Client B Target (Beta Brand)
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

# Run Client A Target (Alpha Brand)
flutter run -t lib/main_client_a.dart --flavor clientA

# Run Client B Target (Beta Brand)
flutter run -t lib/main_client_b.dart --flavor clientB

# Build Release APK for Client A
flutter build apk -t lib/main_client_a.dart --flavor clientA
```

---

# 📖 How to Add a New Feature to the Application

This step-by-step guide outlines how to implement a new feature following our **Very Good Ventures (VGV) Clean Architecture Monorepo** standard.

```
┌─────────────────────────────────────────────────────────────┐
│ 1. API Layer (packages/feature_repository/lib/src/api/)    │
│    Extends BaseApiService & returns Result<Data, Exception> │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 2. Mapper Layer (packages/feature_repository/lib/src/mappers)│
│    Extends BaseMapper<Entity, Dto>                          │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 3. Repository Layer (packages/feature_repository/lib/src/)  │
│    Extends BaseRepository & maps DTOs to Domain Entities   │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 4. BLoC Layer (lib/features/feature/bloc/)                  │
│    Emits Loading, Loaded, Error using result.fold()         │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 5. UI Layer & Scoped DI (lib/features/feature/ui/)          │
│    FeaturePage wraps RepositoryProvider & BlocProvider      │
└─────────────────────────────────────────────────────────────┘
```

---

### Step 1: API Layer Implementation (`BaseApiService`)

Create your feature API service inside `packages/new_feature_repository/lib/src/api/new_feature_api.dart`:

```dart
import 'package:core/core.dart';

class NewFeatureApi extends BaseApiService {
  NewFeatureApi({dynamic client}) : super(client);

  Future<Result<List<Map<String, dynamic>>, Exception>> fetchFeatureData() async {
    return handleResponse(
      apiCall: () async {
        final response = await client.get('/api/v1/new-feature');
        return Result.success<List<Map<String, dynamic>>, Exception>(response.data);
      },
      onSuccess: (result) => result as Result<List<Map<String, dynamic>>, Exception>,
      logTag: 'NewFeatureApi.fetchFeatureData',
    );
  }
}
```

---

### Step 2: DTO & Mapper Implementation (`BaseMapper<Entity, Dto>`)

Create your Data Transfer Model and Entity Mapper in `packages/new_feature_repository/lib/src/mappers/feature_mapper.dart`:

```dart
import 'package:core/core.dart';
import '../models/feature_entity.dart';

class FeatureDto {
  final String id;
  final String title;

  FeatureDto({required this.id, required this.title});

  factory FeatureDto.fromJson(Map<String, dynamic> json) {
    return FeatureDto(id: json['id'], title: json['title']);
  }
}

class FeatureMapper extends BaseMapper<FeatureEntity, FeatureDto> {
  const FeatureMapper();

  @override
  FeatureEntity mapToEntity(FeatureDto dto) {
    return FeatureEntity(id: dto.id, title: dto.title);
  }

  @override
  FeatureDto mapToDto(FeatureEntity entity) {
    return FeatureDto(id: entity.id, title: entity.title);
  }
}
```

---

### Step 3: Repository Layer Implementation (`BaseRepository`)

Create your repository implementation in `packages/new_feature_repository/lib/src/new_feature_repository.dart`:

```dart
import 'package:core/core.dart';
import 'api/new_feature_api.dart';
import 'mappers/feature_mapper.dart';
import 'models/feature_entity.dart';

abstract class NewFeatureRepository {
  Future<Result<List<FeatureEntity>, Exception>> getFeatureData();
}

class NewFeatureRepositoryImpl extends BaseRepository implements NewFeatureRepository {
  final NewFeatureApi _api;
  final FeatureMapper _mapper;

  NewFeatureRepositoryImpl({NewFeatureApi? api, FeatureMapper? mapper})
      : _api = api ?? NewFeatureApi(),
        _mapper = mapper ?? const FeatureMapper();

  @override
  Future<Result<List<FeatureEntity>, Exception>> getFeatureData() async {
    return handleRepositoryCall(
      call: () async {
        final result = await _api.fetchFeatureData();
        return result.fold(
          (jsonList) {
            final dtos = jsonList.map((j) => FeatureDto.fromJson(j)).toList();
            return Result.success(_mapper.mapToEntityList(dtos));
          },
          (failure) => Result.failure(failure),
        );
      },
      logTag: 'NewFeatureRepositoryImpl.getFeatureData',
    );
  }
}
```

---

### Step 4: BLoC / Cubit Layer Implementation (`flutter_bloc`)

Create your Cubit and State in `lib/features/new_feature/bloc/`:

```dart
// State
abstract class NewFeatureState extends Equatable {
  const NewFeatureState();
  @override
  List<Object?> get props => [];
}

class NewFeatureInitial extends NewFeatureState {}
class NewFeatureLoading extends NewFeatureState {}
class NewFeatureLoaded extends NewFeatureState {
  final List<FeatureEntity> data;
  const NewFeatureLoaded(this.data);
  @override
  List<Object?> get props => [data];
}
class NewFeatureError extends NewFeatureState {
  final String message;
  const NewFeatureError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class NewFeatureCubit extends Cubit<NewFeatureState> {
  final NewFeatureRepository repository;

  NewFeatureCubit({required this.repository}) : super(NewFeatureInitial());

  Future<void> loadData() async {
    emit(NewFeatureLoading());
    final result = await repository.getFeatureData();
    result.fold(
      (entities) => emit(NewFeatureLoaded(entities)),
      (failure) => emit(NewFeatureError(failure.toString())),
    );
  }
}
```

---

### Step 5: UI Layer & Scoped On-Demand DI Implementation

Create your Page entrypoint and View in `lib/features/new_feature/ui/`:

```dart
// 1. Page Entrypoint: Scoped Dependency Injection
class NewFeaturePage extends StatelessWidget {
  const NewFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<NewFeatureRepository>(
      create: (context) => NewFeatureRepositoryImpl(),
      child: BlocProvider<NewFeatureCubit>(
        create: (context) => NewFeatureCubit(
          repository: context.read<NewFeatureRepository>(),
        )..loadData(),
        child: const NewFeatureView(),
      ),
    );
  }
}

// 2. View: Render UI based on BLoC state
class NewFeatureView extends StatelessWidget {
  const NewFeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Feature')),
      body: BlocBuilder<NewFeatureCubit, NewFeatureState>(
        builder: (context, state) {
          if (state is NewFeatureLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NewFeatureLoaded) {
            return ListView.builder(
              itemCount: state.data.length,
              itemBuilder: (context, index) => ListTile(title: Text(state.data[index].title)),
            );
          } else if (state is NewFeatureError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
```

---

### Step 6: Register Route in AppRouter (`lib/core/routing/app_router.dart`)

```dart
class AppRoutes {
  static const String newFeature = '/new-feature';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.newFeature:
        return MaterialPageRoute(builder: (_) => const NewFeaturePage());
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
├── main.dart                  # Generic Demo
├── main_client_a.dart         # Client A Target
└── features/
    └── new_feature/
        ├── bloc/
        │   └── new_feature_cubit.dart
        └── ui/
            └── new_feature_page.dart

packages/
├── core/                      # Shared framework infrastructure (REUSED)
│   ├── lib/src/errors/failures.dart
│   ├── lib/src/logging/logger.dart
│   ├── lib/src/mappers/base_mapper.dart
│   ├── lib/src/network/base_api_service.dart
│   ├── lib/src/repository/base_repository.dart
│   └── lib/src/result/result.dart
├── app_ui/                    # Design system package (REUSED & THEMED)
└── new_feature_repository/    # Feature data repository package
    ├── lib/src/api/new_feature_api.dart
    ├── lib/src/mappers/feature_mapper.dart
    └── lib/src/new_feature_repository.dart
```

---

## ✅ Best Practices Checklist

1. **White-Label Reuse:** 100% of code inside `packages/` is shared across all client entry points (`main_client_a.dart`, `main_client_b.dart`).
2. **Error Handling:** Use the `Result<S, E>` type for explicit error handling, returning success/failure results instead of throwing unhandled exceptions.
3. **Data Mapping:** Always extend `BaseMapper<Entity, Dto>` for deterministic mapping between API DTOs and Domain Entities.
4. **Scoped Dependency Injection:** Inject repositories and BLoCs on-demand at feature `Page` boundaries for automatic memory disposal upon route popping.
5. **State Logging:** Attach `AppBlocObserver` in entry points to log all state changes (`currentState ➡️ nextState`).
6. **Testing:** Write unit tests for each layer (API, Repository, Mapper, and Cubit/BLoC).
