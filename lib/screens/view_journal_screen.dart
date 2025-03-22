import 'package:flutter/material.dart';

class ViewJournalScreen extends StatefulWidget {
  final String title;
  final String content;
  final String date;

  const ViewJournalScreen({
    Key? key,
    required this.title,
    required this.content,
    required this.date,
  }) : super(key: key);

  @override
  State<ViewJournalScreen> createState() => _ViewJournalScreenState();
}

class _ViewJournalScreenState extends State<ViewJournalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.date.toString(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              widget.content,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}