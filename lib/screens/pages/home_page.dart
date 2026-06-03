import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Consistent Dark Theme Color Palette ---
  static const Color _backgroundColor = Color.fromARGB(255, 0, 0, 0);
  static const Color _panelColor = Color(0xFF1C1821);
  static const Color _primaryTextColor = Colors.white;
  static const Color _secondaryTextColor = Color(0xFFBDBDBD);

  // --- State for the Draggable Panel ---
  double _panelFraction = 0.5;
  static const double _minFraction = 0.25;
  static const double _midFraction = 0.5;
  static const double _maxFraction = 0.8;
  static const Duration _animDuration = Duration(milliseconds: 800);

  late GoogleMapController _mapController;
  final LatLng _initialLocation =
      const LatLng(19.1417, 77.3210); // Nanded, Maharashtra

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        _panelFraction != _maxFraction) {
      setState(() {
        _panelFraction = _maxFraction;
      });
    } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward &&
        _scrollController.position.pixels == 0 &&
        _panelFraction != _midFraction) {
      setState(() {
        _panelFraction = _midFraction;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onDragUpdate(DragUpdateDetails details, double screenHeight) {
    setState(() {
      _panelFraction -= details.delta.dy / screenHeight;
      _panelFraction = _panelFraction.clamp(_minFraction, _maxFraction);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final vy = details.velocity.pixelsPerSecond.dy;
    double target = _panelFraction;

    if (vy.abs() > 350) {
      target = (vy > 0) ? _minFraction : _maxFraction;
    } else {
      final distances = {
        _minFraction: (_panelFraction - _minFraction).abs(),
        _midFraction: (_panelFraction - _midFraction).abs(),
        _maxFraction: (_panelFraction - _maxFraction).abs(),
      };
      target =
          distances.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    }

    if (target != _panelFraction) {
      setState(() {
        _panelFraction = target;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Column(
        children: [
          AnimatedContainer(
            duration: _animDuration,
            height: screenHeight * (1 - _panelFraction),
            curve: Curves.easeOut,
            child: Material(
              elevation: 6,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(60)),
              color: _panelColor,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(60)),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _initialLocation,
                        zoom: 12.0,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      zoomControlsEnabled: false,
                      mapType: MapType.hybrid,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onVerticalDragUpdate: (d) =>
                          _onDragUpdate(d, screenHeight),
                      onVerticalDragEnd: _onDragEnd,
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        child: Container(
                          width: 40,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 163, 161, 161),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                color: _backgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Featured Locations',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryTextColor),
                      ),
                    ),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return DemoBox(
                            title: 'Place ${index + 1}',
                            color: Colors
                                .primaries[index % Colors.primaries.length],
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryTextColor),
                      ),
                    ),
                    ListView.builder(
                      itemCount: 20,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.location_on_outlined,
                              color: _secondaryTextColor),
                          title: Text('Activity Log #${index + 1}',
                              style:
                                  const TextStyle(color: _primaryTextColor)),
                          subtitle: Text(
                              'Details about event number ${index + 1}...',
                              style: const TextStyle(
                                  color: _secondaryTextColor)),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: _secondaryTextColor, size: 14),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DemoBox extends StatelessWidget {
  final String title;
  final Color color;

  const DemoBox({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
