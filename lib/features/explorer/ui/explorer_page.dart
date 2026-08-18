import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';
import 'package:explorer_repository/explorer_repository.dart';
import '../bloc/explorer_bloc.dart';

/// Entrypoint Page wrapping feature with Scoped On-Demand DI
class ExplorerPage extends StatelessWidget {
  const ExplorerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ExplorerRepository>(
      create: (context) => ExplorerRepositoryImpl(api: FakeExplorerApi()),
      child: BlocProvider<ExplorerBloc>(
        create: (context) => ExplorerBloc(
          repository: context.read<ExplorerRepository>(),
        )..add(const LoadExplorerItems()),
        child: const ExplorerView(),
      ),
    );
  }
}

class ExplorerView extends StatelessWidget {
  const ExplorerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Explorer Example'),
        leading: BlocBuilder<ExplorerBloc, ExplorerState>(
          builder: (context, state) {
            bool canGoBack = false;
            if (state is ExplorerLoaded && state.breadcrumbs.length > 1) canGoBack = true;
            if (state is ExplorerEmpty && state.breadcrumbs.length > 1) canGoBack = true;

            if (canGoBack) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.read<ExplorerBloc>().add(NavigateBackEvent()),
              );
            }
            return const Icon(Icons.folder_shared);
          },
        ),
      ),
      body: Column(
        children: [
          const BreadcrumbsBar(),
          Expanded(
            child: BlocBuilder<ExplorerBloc, ExplorerState>(
              builder: (context, state) {
                if (state is ExplorerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ExplorerError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(state.message, style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Retry',
                          onPressed: () => context.read<ExplorerBloc>().add(const LoadExplorerItems()),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ExplorerEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder_open, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        const Text('This folder is empty', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Create Folder',
                          icon: Icons.create_new_folder,
                          onPressed: () => _showCreateFolderDialog(context),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ExplorerLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ExplorerBloc>().add(LoadExplorerItems(folderId: state.currentFolderId));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppCard(
                            onTap: () {
                              if (item.isFolder) {
                                context.read<ExplorerBloc>().add(LoadExplorerItems(folderId: item.id, folderName: item.name));
                              } else {
                                _showFileDetails(context, item);
                              }
                            },
                            child: Row(
                              children: [
                                _buildFileIcon(item.type),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.isFolder ? 'Folder' : _formatFileSize(item.sizeInBytes),
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () {
                                    context.read<ExplorerBloc>().add(DeleteItemEvent(item.id));
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Add File/Folder'),
        onPressed: () => _showActionBottomSheet(context),
      ),
    );
  }

  Widget _buildFileIcon(FileItemType type) {
    switch (type) {
      case FileItemType.folder:
        return const Icon(Icons.folder, size: 36, color: AppColors.folderIcon);
      case FileItemType.pdf:
        return const Icon(Icons.picture_as_pdf, size: 36, color: Colors.redAccent);
      case FileItemType.image:
        return const Icon(Icons.image, size: 36, color: Colors.greenAccent);
      case FileItemType.document:
        return const Icon(Icons.description, size: 36, color: AppColors.fileIcon);
      case FileItemType.archive:
        return const Icon(Icons.archive, size: 36, color: Colors.purpleAccent);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text('Create New Folder'),
          content: AppTextField(controller: controller, label: 'Folder Name', hint: 'e.g. Invoices'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            AppButton(
              text: 'Create',
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<ExplorerBloc>().add(CreateFolderEvent(controller.text));
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bottomContext) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.create_new_folder, color: AppColors.folderIcon),
                title: const Text('New Folder'),
                onTap: () {
                  Navigator.pop(bottomContext);
                  _showCreateFolderDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFileDetails(BuildContext context, FileItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: Text(item.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Size: ${_formatFileSize(item.sizeInBytes)}'),
              const SizedBox(height: 8),
              Text('Type: ${item.type.name.toUpperCase()}'),
              const SizedBox(height: 8),
              Text('Last Modified: ${item.lastModified.toString().split('.')[0]}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
          ],
        );
      },
    );
  }
}

class BreadcrumbsBar extends StatelessWidget {
  const BreadcrumbsBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExplorerBloc, ExplorerState>(
      builder: (context, state) {
        List<Map<String, String>> breadcrumbs = [];
        if (state is ExplorerLoaded) breadcrumbs = state.breadcrumbs;
        if (state is ExplorerEmpty) breadcrumbs = state.breadcrumbs;

        if (breadcrumbs.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.secondary,
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: breadcrumbs.map((crumb) {
                final isLast = crumb == breadcrumbs.last;
                return Row(
                  children: [
                    InkWell(
                      onTap: isLast ? null : () {
                        final folderId = crumb['id'] == 'root' ? null : crumb['id'];
                        context.read<ExplorerBloc>().add(LoadExplorerItems(folderId: folderId));
                      },
                      child: Text(
                        crumb['name']!,
                        style: TextStyle(
                          color: isLast ? AppColors.accent : AppColors.textSecondary,
                          fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (!isLast) const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
