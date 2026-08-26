import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activity/activity_screen.dart';
import '../features/builder/builder_screen.dart';
import '../features/home/home_screen.dart';
import '../features/legal/legal_screen.dart';
import '../features/plan/plan_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/routes/routes_screen.dart';
import '../features/session/run_screen.dart';
import 'app_shell.dart';

/// Every destination in the app, named so navigation calls never repeat a
/// path string.
abstract final class AppRoute {
  static const home = '/home';
  static const routes = '/routes';
  static const activity = '/activity';
  static const profile = '/profile';

  /// Opens the builder empty, or with `?template=<key>` to start from one of
  /// the built-in structures.
  static const builder = '/builder';
  static const editRoute = '/builder/:id';
  static const runRoute = '/run/:id';
  static const plan = '/plan';
  static const legalRoute = '/legal/:document';

  static String legal(LegalDocument document) => '/legal/${document.name}';

  static String edit(String id) => '/builder/$id';
  static String fromTemplate(String key) => '/builder?template=$key';
  static String run(String id) => '/run/$id';

  /// Runs a session of the training plan. The route is generated from the plan
  /// rather than loaded from storage, so it carries the session key instead of
  /// a saved route id.
  static String runPlanned(String sessionKey) => '/run/planned?plan=$sessionKey';
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _routesKey = GlobalKey<NavigatorState>(debugLabel: 'routes');
final _activityKey = GlobalKey<NavigatorState>(debugLabel: 'activity');
final _profileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoute.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(
                path: AppRoute.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _routesKey,
            routes: [
              GoRoute(
                path: AppRoute.routes,
                builder: (context, state) => const RoutesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _activityKey,
            routes: [
              GoRoute(
                path: AppRoute.activity,
                builder: (context, state) => const ActivityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileKey,
            routes: [
              GoRoute(
                path: AppRoute.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // The builder covers the dock: editing a route is a focused task.
      GoRoute(
        path: AppRoute.builder,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            BuilderScreen(templateKey: state.uri.queryParameters['template']),
      ),
      GoRoute(
        path: AppRoute.editRoute,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            BuilderScreen(workoutId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoute.legalRoute,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => LegalScreen(
          document: LegalDocument.fromName(state.pathParameters['document']),
        ),
      ),
      GoRoute(
        path: AppRoute.plan,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const PlanScreen(),
      ),
      GoRoute(
        path: AppRoute.runRoute,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => RunScreen(
          workoutId: state.pathParameters['id']!,
          planSessionKey: state.uri.queryParameters['plan'],
        ),
      ),
    ],
  );
});
