import 'package:flutter/material.dart';

void main() {
  runApp(const CampusConnectApp());
}

// MAIN APPLICATION
class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusConnect',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
      ),
      home: const NoticeListScreen(),
    );
  }
}

// NOTICE LIST SCREEN
class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() =>
      _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  String selectedCategory = 'All';
  String searchText = '';
  bool showSavedOnly = false;

  final List<Map<String, dynamic>> notices = [
    {
      'title': 'Technical Fest 2026',
      'department': 'CSE',
      'description':
          'Join our annual technical festival! Participate in coding competitions, project exhibitions and exciting technical events.',
      'important': true,
      'date': '10 November 2026',
      'author': 'CSE Department',
      'saved': false,
    },
    {
      'title': 'Annual Sports Day',
      'department': 'General',
      'description':
          'Our college is organizing its annual sports day. All students are invited to participate.',
      'important': false,
      'date': '15 November 2026',
      'author': 'Sports Committee',
      'saved': false,
    },
    {
      'title': 'Artificial Intelligence Workshop',
      'department': 'IT',
      'description':
          'Learn about Artificial Intelligence, Machine Learning and modern technology through practical sessions.',
      'important': true,
      'date': '20 November 2026',
      'author': 'IT Department',
      'saved': false,
    },
    {
      'title': 'Electronics Project Exhibition',
      'department': 'ECE',
      'description':
          'Students can display their innovative electronics projects and demonstrate their technical skills.',
      'important': false,
      'date': '25 November 2026',
      'author': 'ECE Department',
      'saved': false,
    },
    {
      'title': 'Campus Placement Training',
      'department': 'EEE',
      'description':
          'Placement training sessions will be conducted for final-year students. Attendance is compulsory.',
      'important': true,
      'date': '28 November 2026',
      'author': 'Training Department',
      'saved': false,
    },
  ];

  final List<String> categories = [
    'All',
    'CSE',
    'IT',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'General',
  ];

  void toggleBookmark(Map<String, dynamic> notice) {
    setState(() {
      notice['saved'] = !(notice['saved'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotices = notices.where((notice) {
      final matchesCategory =
          selectedCategory == 'All' ||
          notice['department'] == selectedCategory;

      final matchesSearch =
          notice['title']
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
          notice['description']
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
          notice['department']
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase());

      final matchesSaved =
          !showSavedOnly || notice['saved'] == true;

      return matchesCategory &&
          matchesSearch &&
          matchesSaved;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CampusConnect',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'College Notice Board',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Saved Notices',
            icon: Icon(
              showSavedOnly
                  ? Icons.home
                  : Icons.bookmarks,
            ),
            onPressed: () {
              setState(() {
                showSavedOnly = !showSavedOnly;
                selectedCategory = 'All';
                searchText = '';
              });
            },
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showSavedOnly
                      ? 'Your Saved Notices'
                      : 'Welcome, Student!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Stay updated with campus announcements.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16, 18, 16, 12,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search notices...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // DEPARTMENT FILTERS
          if (!showSavedOnly)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: 8,
                    ),
                    child: ChoiceChip(
                      label: Text(category),
                      selected:
                          selectedCategory == category,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

          // SECTION TITLE
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18, 15, 18, 10,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showSavedOnly
                      ? 'Bookmarked Notices'
                      : 'Latest Notices',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filteredNotices.length} Notices',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // NOTICE CARDS
          Expanded(
            child: filteredNotices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off,
                          size: 65,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          showSavedOnly
                              ? 'No saved notices yet!'
                              : 'No notices found!',
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: filteredNotices.length,
                    itemBuilder: (context, index) {
                      final notice =
                          filteredNotices[index];

                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.only(
                          bottom: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    NoticeDetailScreen(
                                  notice: notice,
                                  onBookmark: () {
                                    toggleBookmark(notice);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          Colors.blue.shade50,
                                      child: const Icon(
                                        Icons.campaign,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        notice['department'],
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    if (notice['important'])
                                      const Chip(
                                        avatar: Icon(
                                          Icons.priority_high,
                                          color: Colors.red,
                                          size: 17,
                                        ),
                                        label: Text(
                                          'Important',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 11,
                                          ),
                                        ),
                                        backgroundColor:
                                            Color(0xFFFFEEEE),
                                        side: BorderSide.none,
                                        visualDensity:
                                            VisualDensity.compact,
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  notice['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 7),

                                Text(
                                  notice['description'],
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      size: 17,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        notice['date'],
                                        style:
                                            const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                    IconButton(
                                      tooltip: 'Bookmark',
                                      onPressed: () {
                                        toggleBookmark(notice);
                                      },
                                      icon: Icon(
                                        notice['saved']
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: Colors.blue,
                                      ),
                                    ),

                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// NOTICE DETAIL SCREEN
class NoticeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> notice;
  final VoidCallback onBookmark;

  const NoticeDetailScreen({
    super.key,
    required this.notice,
    required this.onBookmark,
  });

  @override
  State<NoticeDetailScreen> createState() =>
      _NoticeDetailScreenState();
}

class _NoticeDetailScreenState
    extends State<NoticeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Save Notice',
            onPressed: () {
              widget.onBookmark();
              setState(() {});
            },
            icon: Icon(
              notice['saved']
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMPORTANT LABEL
            if (notice['important'])
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'IMPORTANT NOTICE',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 18),

            // TITLE
            Text(
              notice['title'],
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            // DEPARTMENT
            _detailRow(
              Icons.school,
              'Department',
              notice['department'],
            ),

            const SizedBox(height: 15),

            // DATE
            _detailRow(
              Icons.calendar_month,
              'Event Date',
              notice['date'],
            ),

            const SizedBox(height: 15),

            // AUTHOR
            _detailRow(
              Icons.person,
              'Posted By',
              notice['author'],
            ),

            const SizedBox(height: 25),

            const Text(
              'Notice Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              notice['description'],
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onBookmark();
                  setState(() {});
                },
                icon: Icon(
                  notice['saved']
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                label: Text(
                  notice['saved']
                      ? 'Remove from Saved'
                      : 'Save This Notice',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
