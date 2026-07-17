import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../widgets/weather_info_tile.dart';
import '../widgets/glass_container.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/sunrise_sunset_visual.dart';
import '../widgets/saved_locations_drawer.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import 'loading_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final PermissionService _permissionService = PermissionService();
  final LocationService _locationService = LocationService();
  bool _isFetchingLocation = true;

  // Quick city shortcuts
  static const List<Map<String, String>> _quickCities = [
    {'name': 'London', 'flag': '🇬🇧'},
    {'name': 'Tokyo', 'flag': '🇯🇵'},
    {'name': 'New York', 'flag': '🇺🇸'},
    {'name': 'Paris', 'flag': '🇫🇷'},
    {'name': 'Dubai', 'flag': '🇦🇪'},
    {'name': 'Sydney', 'flag': '🇦🇺'},
    {'name': 'Cairo', 'flag': '🇪🇬'},
    {'name': 'Reykjavik', 'flag': '🇮🇸'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      // 1. Check Location Service Status (GPS)
      final isServiceEnabled = await _locationService
          .isLocationServiceEnabled();
      if (!isServiceEnabled) {
        if (!mounted) return;
        final openSettings = await _showEnableLocationDialog();
        if (openSettings) {
          await _locationService.openLocationSettings();
        } else {
          _fallbackToDefaultCity('Location Services disabled. Showing Tokyo.');
          return;
        }
        final retryServiceEnabled = await _locationService
            .isLocationServiceEnabled();
        if (!retryServiceEnabled) {
          _fallbackToDefaultCity('Location Services disabled. Showing Tokyo.');
          return;
        }
      }

      // 2. Check Permission Status
      ph.PermissionStatus permission = await _permissionService
          .checkLocationPermission();

      if (permission == ph.PermissionStatus.denied) {
        if (!mounted) return;
        final proceed = await _showPermissionExplanationDialog();
        if (proceed) {
          permission = await _permissionService.requestLocationPermission();
        } else {
          _fallbackToDefaultCity('Location permission denied. Showing Tokyo.');
          return;
        }
      }

      if (permission == ph.PermissionStatus.permanentlyDenied) {
        if (!mounted) return;
        final openSettings = await _showPermanentlyDeniedDialog();
        if (openSettings) {
          await _permissionService.openSettings();
        } else {
          _fallbackToDefaultCity(
            'Location permission permanently denied. Showing Tokyo.',
          );
        }
        return;
      }

      if (permission == ph.PermissionStatus.granted ||
          permission == ph.PermissionStatus.limited) {
        final position = await _locationService.getCurrentPosition();
        if (mounted) {
          await context.read<WeatherProvider>().fetchWeatherByCoords(
            position.latitude,
            position.longitude,
          );
        }
      } else {
        _fallbackToDefaultCity(
          'Location permission not granted. Showing Tokyo.',
        );
      }
    } catch (e) {
      _fallbackToDefaultCity('Could not get location. Showing Tokyo.');
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  void _fallbackToDefaultCity(String message) {
    if (mounted) {
      context.read<WeatherProvider>().fetchWeatherByCity('Tokyo');
      _showLocationSnackBar(message);
    }
  }

  Future<bool> _showEnableLocationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Enable Location'),
            content: const Text(
              'Please enable Location Services to get accurate weather updates.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showPermissionExplanationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission'),
            content: const Text(
              'WeatherNow needs access to your location to fetch real-time weather information for your current city.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showPermanentlyDeniedDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Location permission has been permanently denied. Please enable it in the App Settings to get weather updates for your current location.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showLocationSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black54,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
    context.read<WeatherProvider>().fetchWeatherByCity(query.trim());
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _openInMaps(String cityName) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/${Uri.encodeComponent(cityName)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // --- Vivid weather-specific gradients ---
  List<Color> _getGradient(Weather? weather) {
    if (weather == null) {
      return [const Color(0xFF1C1C3A), const Color(0xFF2E2E5E)];
    }
    final icon = weather.icon;
    if (icon.contains('01d')) {
      // Clear day — vivid sky blue
      return [const Color(0xFF0072FF), const Color(0xFF00C6FF)];
    } else if (icon.contains('01n')) {
      // Clear night — cosmic purple-midnight
      return [
        const Color(0xFF0F0C29),
        const Color(0xFF302B63),
        const Color(0xFF24243E),
      ];
    } else if (icon.contains('02') ||
        icon.contains('03') ||
        icon.contains('04')) {
      // Cloudy — vivid indigo-blue
      return weather.isDaytime
          ? [const Color(0xFF373B44), const Color(0xFF4286F4)]
          : [const Color(0xFF1E1F3B), const Color(0xFF3A3D60)];
    } else if (icon.contains('09') || icon.contains('10')) {
      // Rain — electric indigo to deep purple
      return [const Color(0xFF4776E6), const Color(0xFF8E54E9)];
    } else if (icon.contains('11')) {
      // Thunderstorm — dramatic charcoal red
      return [
        const Color(0xFF1A0533),
        const Color(0xFF3D0C5E),
        const Color(0xFF0D0D0D),
      ];
    } else if (icon.contains('13')) {
      // Snow — bright icy cyan-blue
      return [const Color(0xFF4481EB), const Color(0xFF04BEFE)];
    } else if (icon.contains('50')) {
      // Mist — purple-steel
      return [const Color(0xFF4E54C8), const Color(0xFF8F94FB)];
    }
    return [const Color(0xFF1E3C72), const Color(0xFF2A5298)];
  }

  // Accent color per gradient (used for glow effects)
  Color _getAccentColor(Weather? weather) {
    if (weather == null) {
      return const Color(0xFF6C63FF);
    }
    final icon = weather.icon;
    if (icon.contains('01d')) {
      return const Color(0xFF00C6FF);
    }
    if (icon.contains('01n')) {
      return const Color(0xFF7C6DE8);
    }
    if (icon.contains('09') || icon.contains('10')) {
      return const Color(0xFF8E54E9);
    }
    if (icon.contains('11')) {
      return const Color(0xFFFF416C);
    }
    if (icon.contains('13')) {
      return const Color(0xFF04BEFE);
    }
    if (icon.contains('50')) {
      return const Color(0xFF8F94FB);
    }
    return const Color(0xFF4286F4);
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingLocation) {
      return const LoadingScreen();
    }
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final gradient = _getGradient(provider.weather);
        final accent = _getAccentColor(provider.weather);

        return Scaffold(
          key: _scaffoldKey,
          drawer: const SavedLocationsDrawer(),
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Decorative atmospheric blurred background orb
                  if (provider.weather != null)
                    Positioned(
                      top: -80,
                      right: -80,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 320,
                            height: 320,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  accent.withValues(alpha: 0.35),
                                  accent.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Scrollable content
                  RefreshIndicator(
                    onRefresh: provider.refresh,
                    color: Colors.white,
                    backgroundColor: accent.withValues(alpha: 0.8),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Top Controls ──────────────────────────────────
                          _buildTopBar(provider, accent),
                          const SizedBox(height: 10),
                          // ── Quick City Chips ──────────────────────────────
                          _buildQuickCityChips(provider),
                          const SizedBox(height: 24),
                          // ── Main Content ──────────────────────────────────
                          _buildBody(provider, accent),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(WeatherProvider provider, Color accent) {
    return Row(
      children: [
        // Drawer menu
        GlassContainer(
          borderRadius: 14,
          padding: const EdgeInsets.all(10),
          backgroundOpacity: 0.1,
          borderOpacity: 0.2,
          child: InkWell(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Search bar
        Expanded(
          child: GlassContainer(
            borderRadius: 16,
            blur: 20,
            backgroundOpacity: 0.1,
            borderOpacity: 0.25,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: TextField(
                controller: _searchController,
                onSubmitted: _submitSearch,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.white60,
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 0,
                  ),
                  suffixIcon: provider.weather != null
                      ? GestureDetector(
                          onTap: () => provider.toggleFavorite(
                            provider.weather!.cityName,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              provider.isFavorite(provider.weather!.cityName)
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color:
                                  provider.isFavorite(
                                    provider.weather!.cityName,
                                  )
                                  ? Colors.amberAccent
                                  : Colors.white70,
                              size: 20,
                            ),
                          ),
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // °C / °F toggle
        _buildUnitToggle(provider),
      ],
    );
  }

  Widget _buildUnitToggle(WeatherProvider provider) {
    return GestureDetector(
      onTap: provider.toggleUnit,
      child: GlassContainer(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        backgroundOpacity: 0.1,
        borderOpacity: 0.2,
        height: 50,
        width: 72,
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: provider.isCelsius
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    provider.isCelsius ? '°C' : '°F',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: provider.isCelsius
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  provider.isCelsius ? '°F' : '°C',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCityChips(WeatherProvider provider) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // ── 📍 Live Location chip (always first) ──────────────────────────
          GestureDetector(
            onTap: _isFetchingLocation ? null : _getCurrentLocation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: _isFetchingLocation
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: _isFetchingLocation
                    ? Colors.white.withValues(alpha: 0.12)
                    : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.2,
                ),
                boxShadow: _isFetchingLocation
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(
                            0xFF4776E6,
                          ).withValues(alpha: 0.45),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFetchingLocation)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.white70,
                      ),
                    )
                  else
                    const Icon(
                      Icons.my_location_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    _isFetchingLocation ? 'Locating...' : 'My Location',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── City shortcut chips ───────────────────────────────────────────
          ...List.generate(_quickCities.length, (index) {
            final city = _quickCities[index];
            final isActive =
                provider.weather?.cityName.toLowerCase() ==
                city['name']!.toLowerCase();
            return GestureDetector(
              onTap: () => provider.fetchWeatherByCity(city['name']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${city['flag']} ${city['name']}',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: isActive ? 1.0 : 0.75,
                    ),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBody(WeatherProvider provider, Color accent) {
    switch (provider.state) {
      case WeatherState.initial:
        return _buildInitialState(accent);
      case WeatherState.loading:
        return _buildLoadingState(accent);
      case WeatherState.loaded:
        return _buildWeatherContent(provider.weather!, provider, accent);
      case WeatherState.error:
        return _buildErrorState(provider.errorMessage, provider, accent);
    }
  }

  Widget _buildInitialState(Color accent) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.62,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing globe icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.25),
                        accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 72,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Where are you?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search a city above or tap below\nto use your live location.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 14,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 36),

            // ── Big glowing "Use My Location" button ────────────────────────
            GestureDetector(
              onTap: _isFetchingLocation ? null : _getCurrentLocation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: _isFetchingLocation
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: _isFetchingLocation
                      ? Colors.white.withValues(alpha: 0.12)
                      : null,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: _isFetchingLocation
                      ? []
                      : [
                          BoxShadow(
                            color: const Color(
                              0xFF4776E6,
                            ).withValues(alpha: 0.5),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isFetchingLocation)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      _isFetchingLocation
                          ? 'Detecting location...'
                          : 'Use My Location',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Subtle OR divider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or pick a city above',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(Color accent) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Loading forecast data...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    String message,
    WeatherProvider provider,
    Color accent,
  ) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 70,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(
    Weather weather,
    WeatherProvider provider,
    Color accent,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 660;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Hero temperature display ──────────────────────
            _buildHeroDisplay(weather, provider, accent),
            const SizedBox(height: 28),

            // ── View on Maps button ───────────────────────────
            _buildMapButton(weather, accent),
            const SizedBox(height: 24),

            // ── Details grid + hourly (side-by-side on wide) ─
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        HourlyForecastCard(
                          forecasts: weather.hourlyForecasts,
                          isCelsius: provider.isCelsius,
                        ),
                        const SizedBox(height: 16),
                        DailyForecastList(
                          forecasts: weather.dailyForecasts,
                          isCelsius: provider.isCelsius,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _buildDetailsGrid(weather, provider),
                        const SizedBox(height: 16),
                        SunriseSunsetVisual(weather: weather),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  HourlyForecastCard(
                    forecasts: weather.hourlyForecasts,
                    isCelsius: provider.isCelsius,
                  ),
                  const SizedBox(height: 16),
                  DailyForecastList(
                    forecasts: weather.dailyForecasts,
                    isCelsius: provider.isCelsius,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailsGrid(weather, provider),
                  const SizedBox(height: 16),
                  SunriseSunsetVisual(weather: weather),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeroDisplay(
    Weather weather,
    WeatherProvider provider,
    Color accent,
  ) {
    final double currentTemp = provider.isCelsius
        ? weather.tempCelsius
        : (weather.tempCelsius * 9 / 5) + 32;
    final double feelsLike = provider.isCelsius
        ? weather.feelsLikeCelsius
        : (weather.feelsLikeCelsius * 9 / 5) + 32;
    final double maxTemp = provider.isCelsius
        ? weather.tempMaxCelsius
        : (weather.tempMaxCelsius * 9 / 5) + 32;
    final double minTemp = provider.isCelsius
        ? weather.tempMinCelsius
        : (weather.tempMinCelsius * 9 / 5) + 32;

    return Column(
      children: [
        // City & date
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: Colors.white60,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${weather.cityName}, ${weather.country}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 6),
            // Location refresh button with loading spinner
            InkWell(
              onTap: _isFetchingLocation ? null : _getCurrentLocation,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: _isFetchingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white60,
                        ),
                      )
                    : Icon(
                        Icons.my_location_rounded,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 16,
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, d MMMM • h:mm a').format(weather.dateTime),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),

        // Large weather icon + huge Feels Like temperature
        Stack(
          alignment: Alignment.center,
          children: [
            // Glowing background orb behind icon
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.3),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  weather.iconUrl,
                  width: 90,
                  height: 90,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.wb_sunny_rounded,
                    size: 80,
                    color: Colors.amberAccent,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${feelsLike.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 90,
                      fontWeight: FontWeight.w200,
                      height: 1.0,
                      letterSpacing: -4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Condition label
        Text(
          weather.description.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 10),

        // H / L / Actual Temp pill row
        GlassContainer(
          borderRadius: 30,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          backgroundOpacity: 0.1,
          borderOpacity: 0.2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Actual temperature
              Row(
                children: [
                  const Icon(
                    Icons.thermostat_rounded,
                    size: 14,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Actual: ${currentTemp.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 16,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 14),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.arrow_upward_rounded,
                    size: 14,
                    color: Colors.pinkAccent,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'H: ${maxTemp.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 16,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 14),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.arrow_downward_rounded,
                    size: 14,
                    color: Colors.cyanAccent,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'L: ${minTemp.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton(Weather weather, Color accent) {
    return GestureDetector(
      onTap: () => _openInMaps(weather.cityName),
      child: GlassContainer(
        borderRadius: 16,
        backgroundOpacity: 0.12,
        borderOpacity: 0.25,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              '${weather.cityName} on Google Maps',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.open_in_new_rounded,
              color: Colors.white54,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(Weather weather, WeatherProvider provider) {
    final feelsLikeVal =
        '${(provider.isCelsius ? weather.feelsLikeCelsius : (weather.feelsLikeCelsius * 9 / 5) + 32).toStringAsFixed(0)}°';

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.92,
      children: [
        WeatherInfoTile(
          icon: Icons.water_drop_rounded,
          label: 'Humidity',
          value: '${weather.humidity}%',
          iconColor: const Color(0xFF64B5F6),
        ),
        WeatherInfoTile(
          icon: Icons.air_rounded,
          label: 'Wind',
          value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
          iconColor: const Color(0xFF4DB6AC),
        ),
        WeatherInfoTile(
          icon: Icons.compress_rounded,
          label: 'Pressure',
          value: '${weather.pressure} hPa',
          iconColor: const Color(0xFFCE93D8),
        ),
        WeatherInfoTile(
          icon: Icons.visibility_rounded,
          label: 'Visibility',
          value: '${(weather.visibility / 1000).toStringAsFixed(0)} km',
          iconColor: const Color(0xFFFFD54F),
        ),
        WeatherInfoTile(
          icon: Icons.cloud_rounded,
          label: 'Clouds',
          value: '${weather.clouds}%',
          iconColor: const Color(0xFFB0BEC5),
        ),
        WeatherInfoTile(
          icon: Icons.thermostat_rounded,
          label: 'Feels Like',
          value: feelsLikeVal,
          iconColor: const Color(0xFFFFB74D),
        ),
      ],
    );
  }
}
