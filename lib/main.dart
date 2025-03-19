import 'package:code_bolanon/app/app.bottomsheets.dart';
import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/app_strings.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:code_bolanon/utils/app_initializer.dart';
import 'package:code_bolanon/app/app.snackbar.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart' show MediaKit;

import 'package:stacked_services/stacked_services.dart';
import 'package:animated_svg/animated_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Singleton app initializer
final _initializer = AppInitializer();

// Track if non-critical modules are already initialized
bool _nonCriticalModulesInitialized = false;
String? _cachedInitialRoute;

// Setup all modules for initialization
void _setupInitializer() {
  // Register modules with different priorities

  // Essential services
  _initializer.registerModule(
    InitModule(
      name: 'locator',
      priority: InitPriority.critical,
      initializer: () async => await setupLocator(),
    ),
  );

  // Auth is high priority but non-blocking
  _initializer.registerModule(
    InitModule(
      name: 'auth',
      priority: InitPriority.high,
      initializer: () async {
        final authService = locator<AuthService>();
        await authService.initialize();
      },
    ),
  );

  // UI components can be initialized in the background
  _initializer.registerModule(
    InitModule(
      name: 'ui_components',
      priority: InitPriority.high,
      initializer: () async {
        setupDialogUi();
        setupSnackbarUi();
        setupBottomSheetUi();
      },
    ),
  );

  // Media and payment are lower priority
  _initializer.registerModule(
    InitModule(
      name: 'media_kit',
      priority: InitPriority.medium,
      initializer: () async => MediaKit.ensureInitialized(),
    ),
  );

  _initializer.registerModule(
    InitModule(
      name: 'stripe',
      priority: InitPriority.low,
      initializer: () async {
        Stripe.publishableKey = stripePK;
        await Stripe.instance.applySettings();
      },
    ),
  );
}

// Function to determine initial route
Future<String> _determineInitialRoute() async {
  // Return cached route if available to speed up reopening
  if (_cachedInitialRoute != null) {
    return _cachedInitialRoute!;
  }

  try {
    final authService = locator<AuthService>();
    final isLoggedIn = await authService.isLoggedIn();

    // If user is logged in, go directly to main view
    if (isLoggedIn) {
      final route = Routes.mainBodyView;
      _cachedInitialRoute = route;
      return route;
    }

    // Check onboarding status from multiple storage locations
    final hasSeenOnboarding = await authService.getOnboardingStatus();

    // Direct to appropriate view based on onboarding status
    final route = hasSeenOnboarding ? Routes.authView : Routes.onboardingView;

    // Cache the route for faster reopening
    _cachedInitialRoute = route;

    // If we're showing the onboarding view, mark that onboarding has started
    // This ensures if the user exits during onboarding, they won't see it again
    if (route == Routes.onboardingView) {
      await authService.setOnboardingStarted();
    }

    return route;
  } catch (e) {
    print('An error occurred during startup: $e');
    return Routes.onboardingView;
  }
}

// Single global key to manage app state
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to avoid black flicker during orientation changes
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure initializer
  _setupInitializer();

  // Initialize critical modules first (blocking)
  await _initializer.initializeCriticalModules();

  // First, show the splash screen with loading indicator
  runApp(AppLoaderWrapper());

  // Initialize non-critical modules and prepare the app in the background
  await _prepareAppInBackground();
}

/// Prepares app in background and seamlessly transitions to main app
Future<void> _prepareAppInBackground() async {
  // Initialize non-critical modules that affect UI
  if (!_nonCriticalModulesInitialized) {
    // Start their initialization (will continue in background)
    _initializer.initializeNonCriticalModules();
    _nonCriticalModulesInitialized = true;
  }

  // Determine initial route (important for navigation)
  final initialRoute = await _determineInitialRoute();

  // Add a small delay to ensure animations in loader have time to be seen
  // and essential UI components are ready
  await Future.delayed(const Duration(milliseconds: 1500));

  // Navigate to the main app using the same navigator instance
  if (_navigatorKey.currentState != null) {
    _navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (_) => MainApp(initialRoute: initialRoute)),
    );
  }
}

/// Wrapper that ensures the loader is shown until the app is ready
class AppLoaderWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      home: const _AppLoader(),
      theme: ThemeData.light().copyWith(primaryColor: AppColors.primary),
    );
  }
}

/// Enhanced loader with animations and branding
class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late AnimatedSvgController _svgController;

  int _currentTipIndex = 0;
  final List<String> _loadingTips = [
    "Preparing your learning journey...",
    "Loading personalized courses...",
    "Connecting to programming experts...",
    "Optimizing your coding experience...",
    "Setting up interactive tools...",
  ];

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticInOut),
    );

    // Initialize the AnimatedSvg controller
    _svgController = AnimatedSvgController();

    // Start animations
    _logoController.forward();

    // Add repeat behavior for subtle continuous animation
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _logoController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _logoController.forward();
      }
    });

    // Cycle through loading tips
    _setupTipCycling();
  }

  void _setupTipCycling() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _textController.reverse().then((_) {
          setState(() {
            _currentTipIndex = (_currentTipIndex + 1) % _loadingTips.length;
          });
          _textController.forward();
          _setupTipCycling();
        });
      }
    });

    _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _svgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with animation
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: AnimatedSvg(
                            controller: _svgController,
                            size: 350,
                            isActive: true,
                            duration: const Duration(seconds: 3),
                            children: [
                              SvgPicture.asset(
                                PngImages.logo,
                                width: 100,
                                height: 100,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SvgPicture.asset(
                                PngImages.logo,
                                width: 100,
                                height: 100,
                                colorFilter: const ColorFilter.mode(
                                  Color.fromARGB(255, 0, 0, 0),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 70),

            // Custom animated progress indicator
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),

            const SizedBox(height: 70),

            // Loading message with animation
            FadeTransition(
              opacity: _textController,
              child: Text(
                _loadingTips[_currentTipIndex],
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 25),

            FadeTransition(
              opacity: _fadeInAnimation,
              child: Text(
                "Code Bolanon",
                style: GoogleFonts.figtree(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(primaryColor: AppColors.primary),
      initialRoute: initialRoute,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
      restorationScopeId: 'app',
    );
  }
}
