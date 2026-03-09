import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:anba_moussa/core/constants/app_constants.dart';

void main() async {
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  final client = Supabase.instance.client;
  
  try {
    final response = await client
        .from('notification_recipients')
        .select('''
          is_read,
          read_at,
          created_at,
          notifications!inner (
            id,
            kind,
            audience,
            title_ar,
            title_en,
            body_ar,
            body_en,
            image_url,
            action_type,
            external_url,
            internal_route,
            internal_id,
            entity_type,
            entity_id,
            sent_at,
            created_at,
            updated_at
          )
        ''')
        // .eq('notifications.is_active', true)
        .order('created_at', ascending: false)
        .limit(1);
    print('SUCCESS: $response');
  } catch (e) {
    print('ERROR: $e');
  }
}
