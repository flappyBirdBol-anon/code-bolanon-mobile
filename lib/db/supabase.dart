import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://hunzbzxfijnduvevfctk.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh1bnpienhmaWpuZHV2ZXZmY3RrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkwNjYyMDMsImV4cCI6MjA1NDY0MjIwM30.n9GxpvrM2BWoBen5zXZMlWlFXk4NqRb-YlSpSnRDPKs';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
}
