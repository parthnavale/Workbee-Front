import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});
  static const routeName = '/add-job';

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '', _description = '', _location = '';

  void _saveJob() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Provider.of<JobProvider>(context, listen: false).addJob(
        Job(title: _title, description: _description, location: _location),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Job')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Job Title'),
              onSaved: (value) => _title = value!,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (value) => _description = value!,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Location'),
              onSaved: (value) => _location = value!,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveJob, child: const Text('Post Job')),
          ]),
        ),
      ),
    );
  }
}

