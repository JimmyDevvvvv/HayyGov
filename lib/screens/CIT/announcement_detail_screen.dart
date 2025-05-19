import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../screens/GOV/pdf_viewer_screen.dart';
import '../../models/announcement.dart';
import '../../models/comment.dart';
import '../../services/announcement_service.dart';
import '../../services/comment_filter_service.dart'; // 🧠 Import the AI filter

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final service = AnnouncementService();
  final _controller = TextEditingController();
  bool anonymous = false;

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.announcement;
    final hasImage = a.picture.isNotEmpty;
    final hasEndTime = a.endTime != null;

    return Scaffold(
      appBar: AppBar(title: Text(a.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      a.picture,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  a.info,
                  style: const TextStyle(fontSize: 16),
                ),
                if (a.pdfUrl != null && a.pdfUrl!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('View PDF'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PdfViewerScreen(pdfUrl: a.pdfUrl!),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  "📍 ${a.location}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  hasEndTime
                      ? "🕒 ${_formatDate(a.timestamp)} → ${_formatDate(a.endTime!)}"
                      : "🕒 ${_formatDate(a.timestamp)}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 30),
                const Text(
                  "Comments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<CommentModel>>(
                  stream: service.getComments(a.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final comments = snapshot.data!;
                    if (comments.isEmpty) {
                      return const Text("No comments yet.");
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.grey),
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        return ListTile(
                          title: Text(c.author),
                          subtitle: Text(c.text),
                          trailing: Text(
                              "${c.timestamp.hour}:${c.timestamp.minute.toString().padLeft(2, '0')}"),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Write a comment...'),
                  ),
                ),
                Column(
                  children: [
                    const Text("Anon"),
                    Switch(
                      value: anonymous,
                      onChanged: (val) =>
                          setState(() => anonymous = val),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    // 🔍 Check for offensive content
                    final isOffensive =
                        await CommentFilterService.isOffensive(text);

                    if (isOffensive) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Inappropriate Comment"),
                          content: const Text(
                              "Your comment seems offensive and cannot be posted."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    // ✅ Submit the comment
                    final comment = CommentModel(
                      text: text,
                      author: anonymous ? "Anonymous" : "You",
                      timestamp: DateTime.now(),
                    );

                    await service.addComment(a.id, comment);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
