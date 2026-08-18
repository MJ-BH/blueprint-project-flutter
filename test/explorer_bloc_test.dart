import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:explorer_repository/explorer_repository.dart';
import 'package:blueprint_project_flutter/features/explorer/bloc/explorer_bloc.dart';

class MockExplorerRepository extends Mock implements ExplorerRepository {}

void main() {
  late MockExplorerRepository mockRepository;

  setUp(() {
    mockRepository = MockExplorerRepository();
  });

  group('ExplorerBloc Unit Tests', () {
    final mockItems = [
      FileItem(
        id: '1',
        name: 'Test Folder',
        type: FileItemType.folder,
        sizeInBytes: 0,
        lastModified: DateTime.now(),
      ),
    ];

    test('initial state is ExplorerInitial', () {
      expect(ExplorerBloc(repository: mockRepository).state, equals(ExplorerInitial()));
    });

    blocTest<ExplorerBloc, ExplorerState>(
      'emits [ExplorerLoading, ExplorerLoaded] when LoadExplorerItems succeeds',
      build: () {
        when(() => mockRepository.getItems(folderId: any(named: 'folderId')))
            .thenAnswer((_) async => mockItems);
        return ExplorerBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadExplorerItems()),
      expect: () => [
        ExplorerLoading(),
        isA<ExplorerLoaded>().having((s) => s.items.length, 'items length', 1),
      ],
    );

    blocTest<ExplorerBloc, ExplorerState>(
      'emits [ExplorerLoading, ExplorerEmpty] when getItems returns empty list',
      build: () {
        when(() => mockRepository.getItems(folderId: any(named: 'folderId')))
            .thenAnswer((_) async => []);
        return ExplorerBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadExplorerItems()),
      expect: () => [
        ExplorerLoading(),
        isA<ExplorerEmpty>(),
      ],
    );
  });
}
