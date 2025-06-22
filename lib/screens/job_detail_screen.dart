import 'package:flutter/material.dart';
import '../models/job.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});
  static const routeName = '/job-detail';

  @override
  Widget build(BuildContext context) {
    final job = ModalRoute.of(context)!.settings.arguments as Job;

    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Location: ${job.location}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          const Text('Description:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(job.description, style: const TextStyle(fontSize: 16)),
        ]),
      ),
    );
  }
}

