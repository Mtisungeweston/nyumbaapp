import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/phone_entry_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/property/property_detail_screen.dart';
import '../screens/landlord/listings_screen.dart';
import '../screens/landlord/add_property_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/chat/chat_screen.dart';

class AppRouter {
  static GoRouter getRouter(bool isAuthenticated) {
    return GoRouter(
      initialLocation: isAuthenticated ? '/home' : '/phone-entry',
      redirect: (context, state) {
        final isAuth = context.read<AuthProvider>().isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/phone-entry' ||
            state.matchedLocation == '/otp-verification';

        if (!isAuth && !isLoggingIn) {
          return '/phone-entry';
        }

        if (isAuth && isLoggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        // Auth Routes
        GoRoute(
          path: '/phone-entry',
          builder: (context, state) => const PhoneEntryScreen(),
        ),
        GoRoute(
          path: '/otp-verification',
          builder: (context, state) => const OTPVerificationScreen(),
        ),

        // Tenant Routes
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/property/:id',
          builder: (context, state) {
            final propertyId = state.pathParameters['id']!;
            return PropertyDetailScreen(propertyId: propertyId);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/chat/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final userName = state.uri.queryParameters['name'] ?? 'User';
            return ChatScreen(
              userId: userId,
              userName: userName,
            );
          },
        ),

        // Landlord Routes
        GoRoute(
          path: '/landlord/listings',
          builder: (context, state) => const ListingsScreen(),
        ),
        GoRoute(
          path: '/landlord/add-property',
          builder: (context, state) => const AddPropertyScreen(),
        ),
      ],
    );
  }
}
