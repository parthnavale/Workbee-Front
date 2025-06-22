import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import 'add_job_screen.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = Provider.of<JobProvider>(context).jobs;

    return Scaffold(
      appBar: AppBar(title: const Text('Jobs Available')),
      body: jobs.isEmpty
          ? const Center(child: Text('No jobs posted yet!'))
          : ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (_, index) {
                final job = jobs[index];
                return ListTile(
                  title: Text(job.title),
                  subtitle: Text(job.location),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      JobDetailScreen.routeName,
                      arguments: job,
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AddJobScreen.routeName),
        child: const Icon(Icons.add),
      ),
    );
  }
}

