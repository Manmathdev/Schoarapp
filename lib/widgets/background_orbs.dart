import 'package:flutter/material.dart';

/// Ambient background orbs, scaled relative to the device's own screen size
/// rather than the website's fixed desktop pixel values. The original
/// values (e.g. an 800px orb positioned at top:-300/right:-200) were tuned
/// for a wide desktop viewport — on a ~390px phone screen they mostly clip
/// off-canvas and barely register, which is why the mobile background reads
/// as flat beige instead of the layered warm glow seen on the website.
class BackgroundOrbs extends StatelessWidget {
  final String page;

  const BackgroundOrbs({super.key, required this.page});

  static const Map<String, _OrbPair> _config = {
    'dashboard': _OrbPair(
      primary: _Orb(sizeFactor: 1.55, top: -0.16, right: -0.35, opacity: 0.40),
      secondary: _Orb(sizeFactor: 1.15, bottom: -0.14, left: -0.30, opacity: 0.30),
    ),
    'curriculum': _OrbPair(
      primary: _Orb(sizeFactor: 1.4, top: -0.14, left: -0.32, opacity: 0.38),
      secondary: _Orb(sizeFactor: 1.0, bottom: -0.10, right: -0.22, opacity: 0.26),
    ),
    'planner': _OrbPair(
      primary: _Orb(sizeFactor: 1.3, top: -0.12, right: -0.22, opacity: 0.38),
      secondary: _Orb(sizeFactor: 1.0, bottom: -0.08, left: -0.18, opacity: 0.26),
    ),
    'resources': _OrbPair(
      primary: _Orb(sizeFactor: 1.5, top: -0.14, left: -0.35, opacity: 0.38),
      secondary: _Orb(sizeFactor: 0.9, bottom: -0.08, right: -0.18, opacity: 0.24),
    ),
    'archive': _OrbPair(
      primary: _Orb(sizeFactor: 1.55, top: -0.16, right: -0.40, opacity: 0.38),
      secondary: _Orb(sizeFactor: 1.1, bottom: -0.14, left: -0.30, opacity: 0.26),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final pair = _config[page] ?? _config['dashboard']!;
    final size = MediaQuery.of(context).size;
    // Base the orb scale on the larger of width/height so it reads
    // consistently across phones, tablets, and foldables.
    final base = size.width > size.height ? size.width : size.width;

    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildOrb(pair.primary, base, size),
          _buildOrb(pair.secondary, base, size),
        ],
      ),
    );
  }

  Widget _buildOrb(_Orb orb, double base, Size screenSize) {
    final diameter = base * orb.sizeFactor;
    return Positioned(
      top: orb.top != null ? screenSize.height * orb.top! : null,
      bottom: orb.bottom != null ? screenSize.height * orb.bottom! : null,
      left: orb.left != null ? screenSize.width * orb.left! : null,
      right: orb.right != null ? screenSize.width * orb.right! : null,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Color.fromRGBO(179, 145, 110, orb.opacity),
              Color.fromRGBO(200, 170, 140, orb.opacity * 0.4),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.75],
          ),
        ),
      ),
    );
  }
}

class _OrbPair {
  final _Orb primary;
  final _Orb secondary;
  const _OrbPair({required this.primary, required this.secondary});
}

class _Orb {
  final double sizeFactor;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double opacity;

  const _Orb({
    required this.sizeFactor,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.opacity,
  });
}
