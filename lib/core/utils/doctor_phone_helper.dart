import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _doctorPhoneKey = 'doctor_phone_number';
  static const String _doctorNameKey = 'doctor_name';

  // Save doctor phone number
  static Future<bool> saveDoctorPhone(String phoneNumber) async {
    try {
      print('📱 Saving doctor phone: $phoneNumber');
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setString(_doctorPhoneKey, phoneNumber);
      print('✅ Save result: $result');
      return result;
    } catch (e) {
      print('❌ Error saving phone: $e');
      return false;
    }
  }

  // Get doctor phone number
  static Future<String?> getDoctorPhoneNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString(_doctorPhoneKey);
      print('📱 Retrieved doctor phone from storage: $phone');
      return phone;
    } catch (e) {
      print('❌ Error getting phone: $e');
      return null;
    }
  }

  // Save doctor name (optional)
  static Future<bool> saveDoctorName(String name) async {
    try {
      print('👨‍⚕️ Saving doctor name: $name');
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_doctorNameKey, name);
    } catch (e) {
      print('❌ Error saving doctor name: $e');
      return false;
    }
  }

  // Get doctor name
  static Future<String?> getDoctorName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_doctorNameKey);
    } catch (e) {
      return null;
    }
  }

  // Delete all doctor info
  static Future<bool> deleteDoctorInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_doctorPhoneKey);
      await prefs.remove(_doctorNameKey);
      return true;
    } catch (e) {
      print('❌ Error deleting doctor info: $e');
      return false;
    }
  }

  // Check if doctor info exists
  static Future<bool> hasDoctorInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString(_doctorPhoneKey);
      print('🔍 Has doctor info? ${phone != null}');
      return phone != null;
    } catch (e) {
      return false;
    }
  }

  // Clear all storage (debug)
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('🧹 Cleared all storage');
    } catch (e) {
      print('❌ Error clearing storage: $e');
    }
  }
}

class DoctorPhoneHelper {
  static bool isValidPhone(String phone) {
    print('🔍 Validating phone: $phone');

    if (phone.isEmpty) {
      print('❌ Phone is empty');
      return false;
    }

    // Clean the phone number (remove spaces, dashes, parentheses)
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    print('🧹 Cleaned phone: $cleaned');

    // Check length
    if (cleaned.length < 10) {
      print('❌ Phone too short: ${cleaned.length} digits');
      return false;
    }

    if (cleaned.length > 15) {
      print('❌ Phone too long: ${cleaned.length} digits');
      return false;
    }

    // Basic validation regex
    final isValid = RegExp(r'^(\+\d{1,4})?\d{10,15}$').hasMatch(cleaned);
    print('✅ Phone validation result: $isValid');
    return isValid;
  }

  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length == 10) {
      // Format as US number: (XXX) XXX-XXXX
      final areaCode = cleaned.substring(0, 3);
      final firstPart = cleaned.substring(3, 6);
      final secondPart = cleaned.substring(6, 10);
      return '+1 ($areaCode) $firstPart-$secondPart';
    } else if (cleaned.length == 11 && cleaned.startsWith('1')) {
      // Format US with country code
      final areaCode = cleaned.substring(1, 4);
      final firstPart = cleaned.substring(4, 7);
      final secondPart = cleaned.substring(7, 11);
      return '+1 ($areaCode) $firstPart-$secondPart';
    }

    // Return as is for international numbers
    return phone;
  }

  static Future<String?> getDoctorPhoneNumber() async {
    final phone = await StorageService.getDoctorPhoneNumber();
    print('📱 Helper retrieved phone: $phone');
    return phone;
  }

  static Future<bool> saveDoctorPhone(String phone) async {
    print('💾 Saving doctor phone via helper: $phone');
    final result = await StorageService.saveDoctorPhone(phone);
    print('💾 Save result: $result');
    return result;
  }

  // Debug function to print all stored values
  static Future<void> debugPrintStorage() async {
    print('\n🔍 DEBUG - STORAGE CONTENTS 🔍');
    final phone = await getDoctorPhoneNumber();
    final name = await StorageService.getDoctorName();
    final hasInfo = await StorageService.hasDoctorInfo();

    print('Phone: $phone');
    print('Name: $name');
    print('Has Doctor Info: $hasInfo');
    print('📱 End of debug info 📱\n');
  }
}