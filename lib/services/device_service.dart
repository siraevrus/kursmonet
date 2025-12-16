import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/hive_service.dart';
import '../utils/app_logger.dart';

class DeviceService {
  static const String deviceIdKey = 'device_id';
  static const String deviceRegisteredKey = 'device_registered';
  
  /// Получить или создать device_id
  static Future<String> getDeviceId() async {
    // Сначала проверяем сохраненный device_id
    final savedDeviceId = HiveService.appSettings.get(deviceIdKey);
    if (savedDeviceId != null && savedDeviceId is String && savedDeviceId.isNotEmpty) {
      AppLogger.d('📱 [DEVICE] Используется сохраненный device_id: $savedDeviceId');
      return savedDeviceId;
    }
    
    // Если device_id нет, создаем новый
    AppLogger.i('📱 [DEVICE] Создание нового device_id...');
    final deviceInfo = DeviceInfoPlugin();
    String deviceId;
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Используем Android ID, если доступен, иначе генерируем UUID
        deviceId = androidInfo.id.isNotEmpty 
            ? 'android-${androidInfo.id}' 
            : 'android-${DateTime.now().millisecondsSinceEpoch}';
        AppLogger.d('   Платформа: Android');
        AppLogger.d('   Android ID: ${androidInfo.id}');
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // Используем identifierForVendor, если доступен
        deviceId = iosInfo.identifierForVendor?.isNotEmpty == true
            ? 'ios-${iosInfo.identifierForVendor}'
            : 'ios-${DateTime.now().millisecondsSinceEpoch}';
        AppLogger.d('   Платформа: iOS');
        AppLogger.d('   IdentifierForVendor: ${iosInfo.identifierForVendor}');
      } else {
        // Для других платформ генерируем уникальный ID
        deviceId = 'unknown-${DateTime.now().millisecondsSinceEpoch}';
        AppLogger.d('   Платформа: Unknown');
      }
      
      // Сохраняем device_id
      await HiveService.appSettings.put(deviceIdKey, deviceId);
      AppLogger.i('✅ [DEVICE] device_id создан и сохранен: $deviceId');
      return deviceId;
    } catch (e) {
      AppLogger.e('❌ [DEVICE] Ошибка при получении device_id: $e');
      // В случае ошибки генерируем временный ID
      deviceId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
      await HiveService.appSettings.put(deviceIdKey, deviceId);
      return deviceId;
    }
  }
  
  /// Получить информацию об устройстве для регистрации
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    Map<String, dynamic> deviceData = {
      'device_id': await getDeviceId(),
      'app_version': packageInfo.version,
    };
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData['platform'] = 'Android';
        deviceData['device_name'] = androidInfo.model;
        deviceData['device_type'] = 'mobile';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData['platform'] = 'iOS';
        deviceData['device_name'] = iosInfo.name;
        deviceData['device_type'] = 'mobile';
      } else {
        deviceData['platform'] = 'Unknown';
        deviceData['device_type'] = 'mobile';
      }
    } catch (e) {
      AppLogger.e('❌ [DEVICE] Ошибка при получении информации об устройстве: $e');
    }
    
    return deviceData;
  }
  
  /// Проверить, зарегистрировано ли устройство
  static bool isDeviceRegistered() {
    final registered = HiveService.appSettings.get(deviceRegisteredKey, defaultValue: false);
    return registered == true;
  }
  
  /// Отметить устройство как зарегистрированное
  static Future<void> markDeviceAsRegistered() async {
    await HiveService.appSettings.put(deviceRegisteredKey, true);
    AppLogger.d('✅ [DEVICE] Устройство отмечено как зарегистрированное');
  }
  
  /// Сбросить статус регистрации (для тестирования)
  static Future<void> resetRegistrationStatus() async {
    await HiveService.appSettings.put(deviceRegisteredKey, false);
    AppLogger.d('🔄 [DEVICE] Статус регистрации сброшен');
  }
}

