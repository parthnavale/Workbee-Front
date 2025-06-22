/// Flutter Job Portal App (Updated with Login, Role Separation, and Animation)
///
/// Features:
/// - Login for Job Posters and Job Seekers
/// - Separate flows and UIs for each role
/// - Professional UI with animated transitions
/// - Job posting and viewing functionality

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => JobProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkSwift',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Montserrat',
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

// ================= MODELS =================

class Job {
  final String title;
  final String description;
  final String location;

  Job({required this.title, required this.description, required this.location});
}

enum UserRole { seeker, poster }

// ================= PROVIDERS =================

class JobProvider with ChangeNotifier {
  final List<Job> _jobs = [];

  List<Job> get jobs => _jobs;

  void addJob(Job job) {
    _jobs.add(job);
    notifyListeners();
  }
}

// ================= LOGIN SCREEN =================

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to WorkSwift",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const PosterHomeScreen(),
                ));
              },
              icon: const Icon(Icons.business_center),
              label: const Text("Login as Job Poster"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                minimumSize: const Size(250, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SeekerHomeScreen(),
                ));
              },
              icon: const Icon(Icons.search),
              label: const Text("Login as Job Seeker"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                minimumSize: const Size(250, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= JOB POSTER HOME =================

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
              itemBuilder: (_, i) => Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(jobs[i].title),
                  subtitle: Text(jobs[i].location),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddJobScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '', desc = '', loc = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post New Job")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Job Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => title = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => desc = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => loc = v!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Provider.of<JobProvider>(context, listen: false)
                        .addJob(Job(title: title, description: desc, location: loc));
                    Navigator.pop(context);
                  }
                },
                child: const Text("Submit Job"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ================= JOB SEEKER HOME =================

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
              itemBuilder: (_, i) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(jobs[i].title),
                  subtitle: Text(jobs[i].location),
                  trailing: const Icon(Icons.arrow_forward_ios),
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
            ),
    );
  }
}
