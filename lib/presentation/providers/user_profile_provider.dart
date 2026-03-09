import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/supabase_service.dart';

class UserProfileState {
  final bool isLoading;
  final Map<String, dynamic>? profile;
  
  const UserProfileState({this.isLoading = false, this.profile});
  
  String get fullName => profile?['full_name'] as String? ?? 'Guest';
  String get email => SupabaseService.instance.client.auth.currentUser?.email ?? 'Not Logged In';

  /// The user's role — 'admin', 'user', etc. Defaults to 'user'.
  String get role => profile?['role'] as String? ?? 'user';

  /// True only if the user has role = 'admin'
  bool get isAdmin => role == 'admin';
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier() : super(const UserProfileState()) {
    _init();
  }

  void _init() {
    SupabaseService.instance.authStateChanges.listen((data) {
      if (data.session != null) {
        fetchProfile();
      } else {
        state = const UserProfileState(isLoading: false, profile: null);
      }
    });

    if (SupabaseService.instance.isAuthenticated) {
      fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    state = UserProfileState(isLoading: true, profile: state.profile);
    try {
      final data = await SupabaseService.instance.getMyProfile();
      if (data != null) {
        state = UserProfileState(isLoading: false, profile: data);
      } else {
        // If profile doesn't exist, try to use metadata if available
        final user = SupabaseService.instance.client.auth.currentUser;
        if (user != null) {
           final meta = user.userMetadata ?? {};
           final name = meta['full_name'] ?? meta['name'] ?? 'Guest';
           state = UserProfileState(isLoading: false, profile: {'full_name': name});
        } else {
           state = const UserProfileState(isLoading: false, profile: null);
        }
      }
    } catch (e) {
      state = UserProfileState(isLoading: false, profile: state.profile);
    }
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier();
});
