import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/animated_job_card.dart';
import '../widgets/gradient_background.dart';

class SeekerHomeScreen extends StatelessWidget {
  const SeekerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = Provider.of<JobProvider>(context).jobs;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Jobs"),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GradientBackground(
        child: jobs.isEmpty
            ? const Center(
                child: Text(
                  "No jobs found.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: jobs.length,
                itemBuilder: (_, i) => AnimatedJobCard(
                  job: jobs[i],
                  index: i,
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1E293B),
                      title: Text(
                        jobs[i].title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Designation: ${jobs[i].designation}',
                            style: const TextStyle(
                              color: Color(0xFFEAB308),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Location: ${jobs[i].location}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Description:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            jobs[i].description,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: const Text(
                            "Close",
                            style: TextStyle(color: Color(0xFFEAB308)),
                          ),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
} 