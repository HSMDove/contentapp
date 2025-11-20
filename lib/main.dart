import 'package:flutter/material.dart';

void main() {
  runApp(const ContentApp());
}

class ContentApp extends StatelessWidget {
  const ContentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Content AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

enum SourceType { youtube, website }

class ContentSource {
  ContentSource({
    required this.name,
    required this.type,
    this.ideaCount = 0,
  });

  final String name;
  final SourceType type;
  int ideaCount;
}

class ContentFolder {
  ContentFolder({required this.name, List<ContentSource>? sources})
      : sources = sources ?? [];

  final String name;
  final List<ContentSource> sources;

  int get totalIdeas => sources.fold(0, (count, source) => count + source.ideaCount);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ContentFolder> _folders = [];

  void _addFolder() async {
    final controller = TextEditingController();

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء مجلد جديد'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'اسم المجلد',
            hintText: 'مثال: أفكار يوتيوب للعلوم',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      setState(() {
        _folders.add(ContentFolder(name: name));
      });
    }
  }

  void _openFolder(ContentFolder folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderDetailPage(
          folder: folder,
          onUpdated: () => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalIdeas = _folders.fold<int>(0, (count, folder) => count + folder.totalIdeas);
    final totalSources = _folders.fold<int>(0, (count, folder) => count + folder.sources.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content AI - إدارة المحتوى'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFolder,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('مجلد جديد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryHeader(totalIdeas: totalIdeas, totalSources: totalSources, folderCount: _folders.length),
            const SizedBox(height: 16),
            Expanded(
              child: _folders.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      itemCount: _folders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final folder = _folders[index];
                        return _FolderCard(
                          folder: folder,
                          onOpen: () => _openFolder(folder),
                          onDelete: () => setState(() => _folders.remove(folder)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.totalIdeas,
    required this.totalSources,
    required this.folderCount,
  });

  final int totalIdeas;
  final int totalSources;
  final int folderCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مساعد الذكاء الاصطناعي لتجميع المصادر والأفكار',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'نظّم قنوات اليوتيوب والمواقع في مجلدات، واحصل على ملخص سريع بعدد الأفكار لكل مجلد.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatChip(icon: Icons.folder_open, label: 'المجلدات', value: '$folderCount'),
            const SizedBox(width: 8),
            _StatChip(icon: Icons.video_library_outlined, label: 'المصادر', value: '$totalSources'),
            const SizedBox(width: 8),
            _StatChip(icon: Icons.lightbulb_outline, label: 'عدد الأفكار', value: '$totalIdeas'),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      avatar: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      label: Text('$label: $value'),
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.folder,
    required this.onOpen,
    required this.onDelete,
  });

  final ContentFolder folder;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    folder.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'حذف المجلد',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
                FilledButton.tonal(
                  onPressed: onOpen,
                  child: const Text('فتح'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _StatChip(icon: Icons.video_library_outlined, label: 'المصادر', value: '${folder.sources.length}'),
                _StatChip(icon: Icons.lightbulb_outline, label: 'الأفكار', value: '${folder.totalIdeas}'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ملخص سريع: ${folder.sources.isEmpty ? 'أضف قناة أو موقع لبدء جمع الأفكار' : 'لديك ${folder.sources.length} مصدرًا يمكن توليد أفكار منها.'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('ابدأ بإضافة مجلد لتنظيم قنواتك ومواقعك'),
        ],
      ),
    );
  }
}

class FolderDetailPage extends StatefulWidget {
  const FolderDetailPage({required this.folder, required this.onUpdated, super.key});

  final ContentFolder folder;
  final VoidCallback onUpdated;

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  SourceType _selectedType = SourceType.youtube;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ideasController = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameController.dispose();
    _ideasController.dispose();
    super.dispose();
  }

  void _addSource() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم القناة أو الموقع'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<SourceType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'النوع'),
                items: const [
                  DropdownMenuItem(value: SourceType.youtube, child: Text('قناة يوتيوب')),
                  DropdownMenuItem(value: SourceType.website, child: Text('موقع إلكتروني')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ideasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الأفكار المتاحة',
                  hintText: 'مثال: 5',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      _nameController.clear();
                      _ideasController.text = '0';
                      Navigator.pop(context);
                    },
                    child: const Text('إلغاء'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) return;
                      final ideas = int.tryParse(_ideasController.text.trim()) ?? 0;
                      setState(() {
                        widget.folder.sources.add(
                          ContentSource(
                            name: name,
                            type: _selectedType,
                            ideaCount: ideas,
                          ),
                        );
                      });
                      widget.onUpdated();
                      _nameController.clear();
                      _ideasController.text = '0';
                      Navigator.pop(context);
                    },
                    child: const Text('إضافة'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _incrementIdeas(ContentSource source) {
    setState(() => source.ideaCount++);
    widget.onUpdated();
  }

  void _removeSource(ContentSource source) {
    setState(() => widget.folder.sources.remove(source));
    widget.onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final totalIdeas = widget.folder.totalIdeas;
    final totalSources = widget.folder.sources.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSource,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مصدر'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FolderSummary(totalIdeas: totalIdeas, totalSources: totalSources),
            const SizedBox(height: 12),
            Expanded(
              child: widget.folder.sources.isEmpty
                  ? const _EmptyFolder()
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        final source = widget.folder.sources[index];
                        return _SourceTile(
                          source: source,
                          onAddIdea: () => _incrementIdeas(source),
                          onRemove: () => _removeSource(source),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: widget.folder.sources.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderSummary extends StatelessWidget {
  const _FolderSummary({required this.totalIdeas, required this.totalSources});

  final int totalIdeas;
  final int totalSources;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص المجلد',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('المصادر: $totalSources'),
            Text('عدد الأفكار الإجمالي: $totalIdeas'),
            const SizedBox(height: 8),
            Text(
              totalIdeas == 0
                  ? 'أضف عدد الأفكار المتاحة لكل مصدر لتتبع إنتاجيتك.'
                  : 'اقتراح: ركّز على المصادر الأعلى أفكارًا وخصص جدول نشر أسبوعي.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source, required this.onAddIdea, required this.onRemove});

  final ContentSource source;
  final VoidCallback onAddIdea;
  final VoidCallback onRemove;

  String get _typeLabel => source.type == SourceType.youtube ? 'يوتيوب' : 'موقع';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(source.type == SourceType.youtube ? Icons.play_circle_outline : Icons.public),
      title: Text(source.name),
      subtitle: Text('النوع: $_typeLabel | الأفكار: ${source.ideaCount}'),
      trailing: Wrap(
        spacing: 8,
        children: [
          IconButton(
            tooltip: 'زيادة عدد الأفكار',
            onPressed: onAddIdea,
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            tooltip: 'إزالة المصدر',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _EmptyFolder extends StatelessWidget {
  const _EmptyFolder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('لا توجد مصادر بعد. أضف قناة يوتيوب أو موقع للبدء.'),
        ],
      ),
    );
  }
}
