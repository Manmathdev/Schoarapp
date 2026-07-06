import 'package:flutter/material.dart';
import '../theme.dart';

class BackgroundOrbs extends StatelessWidget {
  final String page;

  const BackgroundOrbs({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (page == 'dashboard') ..._dashboardOrbs(),
        if (page == 'curriculum') ..._curriculumOrbs(),
        if (page == 'planner') ..._plannerOrbs(),
        if (page == 'resources') ..._resourcesOrbs(),
        if (page == 'archive') ..._archiveOrbs(),
      ],
    );
  }

  List<Widget> _dashboardOrbs() {
    return [
      Positioned(
        top: -300,
        right: -200,
        child: Container(
          width: 800,
          height: 800,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x4DB3916E),
                Color(0x1AC8AA8C),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 0.7],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -200,
        left: -150,
        child: Container(
          width: 600,
          height: 600,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x33B3916E),
                Color(0x14C8AA8C),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 0.7],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _curriculumOrbs() {
    return [
      Positioned(
        top: -250,
        left: -150,
        child: Container(
          width: 700,
          height: 700,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x47B3916E),
                Color(0x1AC8AA8C),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 0.7],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -150,
        right: -100,
        child: Container(
          width: 500,
          height: 500,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x2EB3916E),
                Color(0x14C8AA8C),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 0.7],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _plannerOrbs() {
    return [
      Positioned(
        top: -200,
        right: -100,
        child: Container(
          width: 650,
          height: 650,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x47B3916E),
                Color(0x1AC8AA8C),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 0.7],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -100,
        left: -80,
        child: Container(
          width: 500,
          height: 500,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x2EB3916E),
                Color(0x14C8AA8C),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 0.7],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _resourcesOrbs() {
    return [
      Positioned(
        top: -250,
        left: -200,
        child: Container(
          width: 750,
          height: 750,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x47B3916E),
                Color(0x1AC8AA8C),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 0.7],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -100,
        right: -80,
        child: Container(
          width: 450,
          height: 450,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x2EB3916E),
                Color(0x14C8AA8C),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 0.7],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _archiveOrbs() {
    return [
      Positioned(
        top: -300,
        right: -250,
        child: Container(
          width: 800,
          height: 800,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x47B3916E),
                Color(0x1AC8AA8C),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 0.7],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -200,
        left: -150,
        child: Container(
          width: 550,
          height: 550,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x2EB3916E),
                Color(0x14C8AA8C),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 0.7],
            ),
          ),
        ),
      ),
    ];
  }
}
