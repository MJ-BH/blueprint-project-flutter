import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:explorer_repository/explorer_repository.dart';

// EVENTS
abstract class ExplorerEvent extends Equatable {
  const ExplorerEvent();
  @override
  List<Object?> get props => [];
}

class LoadExplorerItems extends ExplorerEvent {
  final String? folderId;
  final String? folderName;
  const LoadExplorerItems({this.folderId, this.folderName});
  @override
  List<Object?> get props => [folderId, folderName];
}

class CreateFolderEvent extends ExplorerEvent {
  final String name;
  const CreateFolderEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class DeleteItemEvent extends ExplorerEvent {
  final String id;
  const DeleteItemEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class NavigateBackEvent extends ExplorerEvent {}

// STATES
abstract class ExplorerState extends Equatable {
  const ExplorerState();
  @override
  List<Object?> get props => [];
}

class ExplorerInitial extends ExplorerState {}
class ExplorerLoading extends ExplorerState {}

class ExplorerLoaded extends ExplorerState {
  final List<FileItem> items;
  final String? currentFolderId;
  final List<Map<String, String>> breadcrumbs;

  const ExplorerLoaded({
    required this.items,
    this.currentFolderId,
    required this.breadcrumbs,
  });

  @override
  List<Object?> get props => [items, currentFolderId, breadcrumbs];
}

class ExplorerEmpty extends ExplorerState {
  final String? currentFolderId;
  final List<Map<String, String>> breadcrumbs;

  const ExplorerEmpty({this.currentFolderId, required this.breadcrumbs});

  @override
  List<Object?> get props => [currentFolderId, breadcrumbs];
}

class ExplorerError extends ExplorerState {
  final String message;
  const ExplorerError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class ExplorerBloc extends Bloc<ExplorerEvent, ExplorerState> {
  final ExplorerRepository repository;
  final List<Map<String, String>> _breadcrumbs = [{'id': 'root', 'name': 'Root Explorer'}];

  ExplorerBloc({required this.repository}) : super(ExplorerInitial()) {
    on<LoadExplorerItems>(_onLoadItems);
    on<CreateFolderEvent>(_onCreateFolder);
    on<DeleteItemEvent>(_onDeleteItem);
    on<NavigateBackEvent>(_onNavigateBack);
  }

  Future<void> _onLoadItems(LoadExplorerItems event, Emitter<ExplorerState> emit) async {
    emit(ExplorerLoading());

    if (event.folderId != null && event.folderName != null) {
      if (!_breadcrumbs.any((b) => b['id'] == event.folderId)) {
        _breadcrumbs.add({'id': event.folderId!, 'name': event.folderName!});
      }
    } else if (event.folderId == null) {
      _breadcrumbs.clear();
      _breadcrumbs.add({'id': 'root', 'name': 'Root Explorer'});
    }

    final result = await repository.getItems(folderId: event.folderId);
    result.fold(
      (items) {
        if (items.isEmpty) {
          emit(ExplorerEmpty(currentFolderId: event.folderId, breadcrumbs: List.from(_breadcrumbs)));
        } else {
          emit(ExplorerLoaded(items: items, currentFolderId: event.folderId, breadcrumbs: List.from(_breadcrumbs)));
        }
      },
      (failure) => emit(ExplorerError(failure.toString())),
    );
  }

  Future<void> _onCreateFolder(CreateFolderEvent event, Emitter<ExplorerState> emit) async {
    final currentFolderId = _getCurrentFolderId();
    final result = await repository.createFolder(event.name, parentId: currentFolderId);
    result.fold(
      (_) => add(LoadExplorerItems(folderId: currentFolderId)),
      (failure) => emit(ExplorerError(failure.toString())),
    );
  }

  Future<void> _onDeleteItem(DeleteItemEvent event, Emitter<ExplorerState> emit) async {
    final currentFolderId = _getCurrentFolderId();
    final result = await repository.deleteItem(event.id);
    result.fold(
      (_) => add(LoadExplorerItems(folderId: currentFolderId)),
      (failure) => emit(ExplorerError(failure.toString())),
    );
  }

  void _onNavigateBack(NavigateBackEvent event, Emitter<ExplorerState> emit) {
    if (_breadcrumbs.length > 1) {
      _breadcrumbs.removeLast();
      final previousFolder = _breadcrumbs.last;
      final folderId = previousFolder['id'] == 'root' ? null : previousFolder['id'];
      add(LoadExplorerItems(folderId: folderId));
    }
  }

  String? _getCurrentFolderId() {
    if (state is ExplorerLoaded) {
      return (state as ExplorerLoaded).currentFolderId;
    }
    if (state is ExplorerEmpty) {
      return (state as ExplorerEmpty).currentFolderId;
    }
    return null;
  }
}
