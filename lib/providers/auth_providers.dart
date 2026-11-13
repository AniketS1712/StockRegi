import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentBusinessProvider = FutureProvider<Business?>((ref) async {
  ref.watch(authStateProvider);

  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  final response = await Supabase.instance.client
      .from('businesses')
      .select()
      .eq('owner_id', user.id)
      .maybeSingle();

  if (response == null) return null;
  return Business.fromJson(response);
});

/// Ensures the branded splash screen remains visible for a minimum of 2 seconds on app launch
final splashMinDelayProvider = FutureProvider<void>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
});
