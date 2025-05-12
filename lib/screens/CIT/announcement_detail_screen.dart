import 'package:flutter/material.dart';
import '../../models/announcement.dart';
import '../../models/comment.dart';
import '../../services/announcement_service.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;

  AnnouncementDetailScreen({required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final service = AnnouncementService();
  final _controller = TextEditingController();
  bool anonymous = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.announcement.title)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(widget.announcement.info),
          ),
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: service.getComments(widget.announcement.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    return ListTile(
                      title: Text(c.author),
                      subtitle: Text(c.text),
                      trailing: Text('${c.timestamp.hour}:${c.timestamp.minute}'),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: 'Write a comment...'),
                ),
              ),
              Column(
                children: [
                  Text("Anon"),
                  Switch(
                    value: anonymous,
                    onChanged: (val) => setState(() => anonymous = val),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  final comment = CommentModel(
                    text: text,
                    author: anonymous ? "Anonymous" : "You", // Replace with username if needed
                    timestamp: DateTime.now(),
                  );
                  await service.addComment(widget.announcement.id, comment);
                  _controller.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
