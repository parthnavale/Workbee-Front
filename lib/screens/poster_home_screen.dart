import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/animated_job_card.dart';
import '../widgets/fade_page_route.dart';
import 'add_job_screen.dart';

class PosterHomeScreen extends StatelessWidget {
  const PosterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = Provider.of<JobProvider>(context).jobs;

    return Scaffold(
      appBar: AppBar(title: const Text("Posted Jobs")),
      body: jobs.isEmpty
          ? const Center(child: Text("No jobs posted yet!"))
          : ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (_, i) => AnimatedJobCard(
                job: jobs[i], 
                index: i
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(FadePageRoute(
            page: const AddJobScreen()
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 