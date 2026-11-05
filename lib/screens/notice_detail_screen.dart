// DartPad version: paste this whole file into dartpad.dev (Flutter mode).
// Each section below is marked with the real file path it belongs in.
// In a real project, move each section to its own file and add imports.

import 'dart:async';
import 'package:flutter/material.dart';

// ============================================================
// lib/models/notice.dart
// ============================================================
class Notice {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime createdAt;
  final bool isPinned;

  const Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.isPinned = false,
  });

  Notice copyWith({
    String? title,
    String? body,
    String? category,
    bool? isPinned,
  }) {
    return Notice(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      createdAt: createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'isPinned': isPinned,
      };

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        category: json['category'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isPinned: json['isPinned'] as bool? ?? false,
      );
}

// ============================================================
// lib/services/notice_storage.dart
// ============================================================
// In-memory storage that mimics an async persistent store.
// To persist for real, replace the body of loadAll/saveAll with
// shared_preferences (jsonEncode / jsonDecode of the same JSON maps).
class NoticeStorage {
  final List<Map<String, dynamic>> _db = [];

  NoticeStorage({bool seed = true}) {
    if (seed) {
      final now = DateTime.now();
      _db.addAll([
        Notice(
          id: '1',
          title: 'Welcome to the Notice Board',
          body: 'Post, pin, edit and delete notices from this app.',
          category: 'General',
          createdAt: now.subtract(const Duration(days: 2)),
          isPinned: true,
        ).toJson(),
        Notice(
          id: '2',
          title: 'Mid-term exams start Monday',
          body: 'Check the timetable and bring your ID card.',
          category: 'Academic',
          createdAt: now.subtract(const Duration(hours: 5)),
        ).toJson(),
      ]);
    }
  }

  Future<List<Notice>> loadAll() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _db.map(Notice.fromJson).toList();
  }

  Future<void> saveAll(List<Notice> notices) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _db
      ..clear()
      ..addAll(notices.map((n) => n.toJson()));
  }
}

// ============================================================
// lib/providers/notice_provider.dart
// ============================================================
class NoticeProvider extends ChangeNotifier {
  NoticeProvider(this._storage);

  final NoticeStorage _storage;
  List<Notice> _notices = [];
  bool _loading = true;

  bool get isLoading => _loading;

  /// Pinned first, then newest first.
  List<Notice> get notices {
    final sorted = [..._notices];
    sorted.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _notices = await _storage.loadAll();
    _loading = false;
    notifyListeners();
  }

  // State changes happen synchronously (so Dismissible/list rebuilds stay
  // consistent); persistence happens afterwards.
  Future<void> add({
    required String title,
    required String body,
    required String category,
    bool isPinned = false,
  }) async {
    _notices.add(Notice(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      category: category,
      createdAt: DateTime.now(),
      isPinned: isPinned,
    ));
    notifyListeners();
    await _storage.saveAll(_notices);
  }

  Future<void> update(Notice updated) async {
    final i = _notices.indexWhere((n) => n.id == updated.id);
    if (i == -1) return;
    _notices[i] = updated;
    notifyListeners();
    await _storage.saveAll(_notices);
  }

  Future<void> remove(String id) async {
    _notices.removeWhere((n) => n.id == id);
    notifyListeners();
    await _storage.saveAll(_notices);
  }

  Future<void> restore(Notice notice) async {
    if (_notices.any((n) => n.id == notice.id)) return;
    _notices.add(notice);
    notifyListeners();
    await _storage.saveAll(_notices);
  }

  Future<void> togglePin(String id) async {
    final i = _notices.indexWhere((n) => n.id == id);
    if (i == -1) return;
    _notices[i] = _notices[i].copyWith(isPinned: !_notices[i].isPinned);
    notifyListeners();
    await _storage.saveAll(_notices);
  }
}

/// Minimal replacement for the `provider` package (not needed in DartPad).
class NoticeScope extends InheritedNotifier<NoticeProvider> {
  const NoticeScope({
    super.key,
    required NoticeProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static NoticeProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NoticeScope>();
    assert(scope != null, 'NoticeScope not found in widget tree');
    return scope!.notifier!;
  }
}

// ============================================================
// lib/screens/post_notice_screen.dart
// ============================================================
const List<String> kCategories = ['General', 'Academic', 'Event', 'Urgent'];

Color categoryColor(String category) {
  switch (category) {
    case 'Academic':
      return Colors.blue.shade100;
    case 'Event':
      return Colors.green.shade100;
    case 'Urgent':
      return Colors.red.shade100;
    default:
      return Colors.grey.shade300;
  }
}

class PostNoticeScreen extends StatefulWidget {
  /// Pass an existing notice to edit it; leave null to post a new one.
  final Notice? existing;
  const PostNoticeScreen({super.key, this.existing});

  @override
  State<PostNoticeScreen> createState() => _PostNoticeScreenState();
}

class _PostNoticeScreenState extends State<PostNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _body;
  late String _category;
  late bool _pinned;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _body = TextEditingController(text: widget.existing?.body ?? '');
    _category = widget.existing?.category ?? kCategories.first;
    _pinned = widget.existing?.isPinned ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = NoticeScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_isEditing) {
      await provider.update(widget.existing!.copyWith(
        title: _title.text.trim(),
        body: _body.text.trim(),
        category: _category,
        isPinned: _pinned,
      ));
    } else {
      await provider.add(
        title: _title.text.trim(),
        body: _body.text.trim(),
        category: _category,
        isPinned: _pinned,
      );
    }

    messenger.showSnackBar(SnackBar(
      content: Text(_isEditing ? 'Notice updated' : 'Notice posted'),
    ));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Notice' : 'Post Notice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _body,
                maxLines: 6,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().length < 5)
                    ? 'Please enter at least 5 characters'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: kCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pin to top'),
                value: _pinned,
                onChanged: (v) => setState(() => _pinned = v),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isEditing ? 'Save Changes' : 'Post Notice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// lib/screens/manage_notices_screen.dart
// ============================================================
class ManageNoticesScreen extends StatelessWidget {
  const ManageNoticesScreen({super.key});

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = NoticeScope.of(context);
    final notices = provider.notices;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Notices (${notices.length})'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PostNoticeScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Notice'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notices.isEmpty
              ? const Center(
                  child: Text('No notices yet. Tap "New Notice" to add one.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                  itemCount: notices.length,
                  itemBuilder: (context, i) {
                    final n = notices[i];
                    return Dismissible(
                      key: ValueKey(n.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        provider.remove(n.id);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                            content: Text('Deleted "${n.title}"'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () => provider.restore(n),
                            ),
                          ));
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          isThreeLine: true,
                          title: Row(
                            children: [
                              if (n.isPinned)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(Icons.push_pin, size: 16),
                                ),
                              Expanded(
                                child: Text(
                                  n.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: categoryColor(n.category),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(n.category,
                                        style: const TextStyle(fontSize: 12)),
                                  ),
                                  Text(_formatDate(n.createdAt),
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'pin') provider.togglePin(n.id);
                              if (v == 'edit') {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => PostNoticeScreen(existing: n),
                                ));
                              }
                              if (v == 'delete') {
                                provider.remove(n.id);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    content: Text('Deleted "${n.title}"'),
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      onPressed: () => provider.restore(n),
                                    ),
                                  ));
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'pin',
                                child: Text(n.isPinned ? 'Unpin' : 'Pin'),
                              ),
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(
                                  value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ============================================================
// lib/main.dart  (entry point so DartPad can run everything)
// ============================================================
void main() => runApp(const NoticeApp());

class NoticeApp extends StatefulWidget {
  const NoticeApp({super.key});

  @override
  State<NoticeApp> createState() => _NoticeAppState();
}

class _NoticeAppState extends State<NoticeApp> {
  late final NoticeProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = NoticeProvider(NoticeStorage())..load();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NoticeScope(
      provider: _provider,
      child: MaterialApp(
        title: 'Notice Board',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const ManageNoticesScreen(),
      ),
    );
  }
}
