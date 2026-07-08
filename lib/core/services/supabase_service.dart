import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://gbqcgourerfoiydzvkfc.supabase.co';
  static const String anonKey = 'sb_publishable_sKEsmBdN12NTjoA35iSawQ_EeR5KGvC';

  /// Initializes the Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  /// Global getter to access the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
}

/// Global shortcut to access the Supabase client anywhere in the app
/// Usage: `final response = await supabase.from('table').select();`
final supabase = SupabaseConfig.client;
