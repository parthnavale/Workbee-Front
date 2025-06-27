import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/animated_job_card.dart';
import '../widgets/fade_page_route.dart';
import '../widgets/gradient_background.dart';
import '../models/job.dart';
import 'add_job_screen.dart';

class PosterHomeScreen extends StatelessWidget {
  const PosterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final activeJobs = jobProvider.activeJobs;
    final historyJobs = jobProvider.historyJobs;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Posted Jobs"),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Active Jobs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (activeJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'No active jobs.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              ...activeJobs.map((job) => Stack(
                children: [
                  AnimatedJobCard(job: job, index: activeJobs.indexOf(job)),
                  Positioned(
                    right: 32,
                    top: 8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        jobProvider.cancelJob(job);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              )),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (historyJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'No cancelled jobs.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              ...historyJobs.map((job) => AnimatedJobCard(job: job, index: historyJobs.indexOf(job))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(FadePageRoute(
            page: const AddJobScreen()
          ));
        },
        backgroundColor: const Color(0xFFEAB308),
        foregroundColor: const Color(0xFF10182B),
        child: const Icon(Icons.add),
      ),
    );
  }
} 