/// Flutter Job Portal App (Updated with Login, Role Separation, and Animation)
///
/// Features:
/// - Login for Job Posters and Job Seekers
/// - Separate flows and UIs for each role
/// - Professional UI with animated transitions
/// - Job posting and viewing functionality

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:device_preview/device_preview.dart';
import 'dart:async';

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

// ================= ANIMATED PAGE ROUTE =================
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

// ================= ANIMATED JOB CARD =================
class AnimatedJobCard extends StatefulWidget {
  final Job job;
  final VoidCallback? onTap;
  final int index;
  const AnimatedJobCard({super.key, required this.job, this.onTap, required this.index});

  @override
  State<AnimatedJobCard> createState() => _AnimatedJobCardState();
}

class _AnimatedJobCardState extends State<AnimatedJobCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _offset = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    // Staggered animation
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(widget.job.title),
            subtitle: Text(widget.job.location),
            trailing: widget.onTap != null ? const Icon(Icons.arrow_forward_ios) : null,
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}

// ================= ANIMATED BUTTON =================
class AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Size? minimumSize;
  final IconData? icon;
  const AnimatedScaleButton({super.key, required this.child, required this.onTap, this.backgroundColor, this.foregroundColor, this.minimumSize, this.icon});

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  void _onTapDown(_) => _controller.reverse();
  void _onTapUp(_) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: ElevatedButton.icon(
          onPressed: widget.onTap,
          icon: widget.icon != null ? Icon(widget.icon) : const SizedBox.shrink(),
          label: widget.child,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            minimumSize: widget.minimumSize,
          ),
        ),
      ),
    );
  }
}

// ================= LOGIN SCREEN =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flutter_dash,
              color: Colors.amber,
              size: 32,
            ),
            const SizedBox(width: 6),
            const Text(
              'WorkBee',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          Builder(
            builder: (context) {
              final isWide = MediaQuery.of(context).size.width > 600;
              if (isWide) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Home',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'ForBusiness',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'For Workers',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                );
              } else {
                return PopupMenuButton<String>(
                  color: const Color(0xFF1E293B),
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    // Handle menu selection here
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Home',
                      child: Text('Home', style: TextStyle(color: Colors.white)),
                    ),
                    const PopupMenuItem(
                      value: 'ForBusiness',
                      child: Text('ForBusiness', style: TextStyle(color: Colors.white)),
                    ),
                    const PopupMenuItem(
                      value: 'For Workers',
                      child: Text('For Workers', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1E293B), const Color(0xFF10182B)],
            begin: Alignment.bottomLeft,
            end: Alignment.topLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _opacity,
                child: const Text("Welcome to WorkSwift",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
            AnimatedScaleButton(
              onTap: () {
                Navigator.of(context).push(FadePageRoute(
                  page: const PosterHomeScreen(),
                ));
              },
              icon: Icons.business_center,
              child: const Text("Login as Job Poster"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              minimumSize: const Size(250, 50),
            ),
            const SizedBox(height: 20),
            AnimatedScaleButton(
              onTap: () {
                Navigator.of(context).push(FadePageRoute(
                  page: const SeekerHomeScreen(),
                ));
              },
              icon: Icons.search,
              child: const Text("Login as Job Seeker"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              minimumSize: const Size(250, 50),
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
              itemBuilder: (_, i) => AnimatedJobCard(job: jobs[i], index: i),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(FadePageRoute(page: const AddJobScreen()));
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
