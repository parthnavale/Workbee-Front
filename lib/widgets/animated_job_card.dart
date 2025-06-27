import 'package:flutter/material.dart';
import '../models/job.dart';

class AnimatedJobCard extends StatefulWidget {
  final Job job;
  final VoidCallback? onTap;
  final int index;
  
  const AnimatedJobCard({
    super.key, 
    required this.job, 
    this.onTap, 
    required this.index
  });

  @override
  State<AnimatedJobCard> createState() => _AnimatedJobCardState();
}

class _AnimatedJobCardState extends State<AnimatedJobCard> 
    with SingleTickerProviderStateMixin {
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
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.1), 
      end: Offset.zero
    ).animate(
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
            trailing: widget.onTap != null 
                ? const Icon(Icons.arrow_forward_ios) 
                : null,
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
} 