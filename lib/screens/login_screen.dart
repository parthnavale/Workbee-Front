import 'package:flutter/material.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/fade_page_route.dart';
import 'poster_home_screen.dart';
import 'seeker_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
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
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.2), 
      end: Offset.zero
    ).animate(
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
              'WORKBEE',
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
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'ForBusiness',
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'For Workers',
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFFEAB308),
                        foregroundColor: Color(0xFF10182B),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      ),
                      child: const Text(
                        '->] Sign In',
                        style: TextStyle(
                          color: Color(0xFF10182B), 
                          fontWeight: FontWeight.w500
                        ),
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
                    const PopupMenuItem(
                      value: 'Sign In',
                      child: Text('->] Sign In', style: TextStyle(color: Color(0xFFEAB308))),
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
            colors: [Color(0xFF1E293B), Color(0xFF10182B)],
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'Find Workers\n',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'in 5 Minutes',
                          style: TextStyle(color: Color(0xFFEAB308)),
                        ),
                      ],
                    ),
                  ),
                ),
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
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              minimumSize: const Size(250, 50),
              child: const Text("Login as Job Poster"),
            ),
            const SizedBox(height: 20),
            AnimatedScaleButton(
              onTap: () {
                Navigator.of(context).push(FadePageRoute(
                  page: const SeekerHomeScreen(),
                ));
              },
              icon: Icons.search,
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              minimumSize: const Size(250, 50),
              child: const Text("Login as Job Seeker"),
            ),
          ],
        ),
      ),
    );
  }
} 