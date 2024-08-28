import 'dart:typed_data';

import 'escpos_usb_printer_platform_interface.dart';

class EscposUsbPrinter {
  Future<bool?> initService() {
    return EscposUsbPrinterPlatform.instance.initService();
  }

  Future<String?> getPrinterStatus() {
    return EscposUsbPrinterPlatform.instance.getPrinterStatus();
  }

  Future<bool?> printTicket(Uint8List imageBytes, Map<String, dynamic> json) {
    return EscposUsbPrinterPlatform.instance.printTicket(imageBytes, json);
  }

  Future<bool?> printKitchenTicket(
      Uint8List imageBytes, Map<String, dynamic> json) {
    return EscposUsbPrinterPlatform.instance
        .printKitchenTicket(imageBytes, json);
  }

  Future<bool?> printOfflineTicket(
      Uint8List imageBytes, Map<String, dynamic> json) {
    return EscposUsbPrinterPlatform.instance
        .printOfflineTicket(imageBytes, json);
  }
}
