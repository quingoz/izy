import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/branding.dart';
import '../../core/network/api_service.dart';

final brandingProvider = StateNotifierProvider<BrandingNotifier, BrandingState>((ref) {
  return BrandingNotifier();
});

class BrandingState {
  final Branding branding;
  final bool isLoading;
  final String? error;

  BrandingState({
    required this.branding,
    this.isLoading = false,
    this.error,
  });

  BrandingState copyWith({
    Branding? branding,
    bool? isLoading,
    String? error,
  }) {
    return BrandingState(
      branding: branding ?? this.branding,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BrandingNotifier extends StateNotifier<BrandingState> {
  final ApiService _api = ApiService();

  BrandingNotifier() : super(BrandingState(branding: Branding.defaultBranding())) {
    _loadSavedBranding();
  }

  Future<void> _loadSavedBranding() async {
    final box = await Hive.openBox('branding');
    final savedBranding = box.get('current_branding');

    if (savedBranding != null) {
      state = state.copyWith(
        branding: Branding.fromJson(Map<String, dynamic>.from(savedBranding)),
      );
    }
  }

  Future<void> loadBrandingForComercio(String slug) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.get('/comercios/$slug/branding');
      final branding = Branding.fromJson(response['data']);

      final box = await Hive.openBox('branding');
      await box.put('current_branding', response['data']);

      state = state.copyWith(
        branding: branding,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void resetToDefault() {
    state = state.copyWith(branding: Branding.defaultBranding());
  }

  Future<void> clearBranding() async {
    final box = await Hive.openBox('branding');
    await box.clear();
    resetToDefault();
  }
}
