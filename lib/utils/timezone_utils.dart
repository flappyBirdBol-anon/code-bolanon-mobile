import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimezoneUtils {
  static const String philippinesTimezone = 'Asia/Manila';

  static Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    // Set the local location to Philippines
    tz.setLocalLocation(tz.getLocation(philippinesTimezone));
  }

  static DateTime toPhilippinesTime(DateTime dateTime) {
    final phLocation = tz.getLocation(philippinesTimezone);
    return tz.TZDateTime.from(dateTime, phLocation);
  }

  static DateTime now() {
    final phLocation = tz.getLocation(philippinesTimezone);
    return tz.TZDateTime.now(phLocation);
  }
}
