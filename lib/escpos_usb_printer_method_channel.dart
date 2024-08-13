import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'escpos_usb_printer_platform_interface.dart';

/// An implementation of [EscposUsbPrinterPlatform] that uses method channels.
class MethodChannelEscposUsbPrinter extends EscposUsbPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('escpos_usb_printer');

  @override
  Future<bool?> initService() async {
    final bool? isInitialized =
        await methodChannel.invokeMethod<bool>('initService');
    return isInitialized;
  }

  @override
  Future<String?> getPrinterStatus() async {
    final String? printerStatus =
        await methodChannel.invokeMethod<String>('getPrinterStatus');
    return printerStatus;
  }

  @override
  Future<bool?> printTicket(
      Uint8List imageBytes, Map<String, dynamic> json) async {
    try {
      // Convertir el JSON en una cadena
      final String jsonStr = jsonEncode(json);
      // Crear un mapa de argumentos para el Method Channel
      final Map<String, dynamic> args = {
        'image': imageBytes,
        'json': jsonStr, // Incluir la cadena JSON
      };

      final bool? isPrinted =
          await methodChannel.invokeMethod<bool>('printTicket', args);
      return isPrinted;
    } on PlatformException catch (error) {
      debugPrint('Printer Error: ${error.message}');
      return false;
    }
  }

  @override
  Future<bool?> printKitchenTicket(
      Uint8List imageBytes, Map<String, dynamic> json) async {
    try {
      // Convertir el JSON en una cadena
      final String jsonStr = jsonEncode(json);
      // Crear un mapa de argumentos para el Method Channel
      final Map<String, dynamic> args = {
        'image': imageBytes,
        'json': jsonStr, // Incluir la cadena JSON
      };

      final bool? isPrinted =
          await methodChannel.invokeMethod<bool>('printKitchenTicket', args);
      return isPrinted;
    } on PlatformException catch (error) {
      debugPrint('Printer Error: ${error.message}');
      return false;
    }
  }
}
