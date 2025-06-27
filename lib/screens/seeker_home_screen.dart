import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/animated_job_card.dart';

class SeekerHomeScreen extends StatelessWidget {
  const SeekerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = Provider.of<JobProvider>(context).jobs;

    return Scaffold(
      appBar: AppBar(title: const Text("Find Jobs")),
      body: jobs.isEmpty
          ? const Center(child: Text("No jobs found."))
          : ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (_, i) => AnimatedJobCard(
                job: jobs[i],
                index: i,
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(jobs[i].title),
                    content: Text(jobs[i].description),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
} 