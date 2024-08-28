import 'dart:typed_data';

import 'package:escpos_usb_printer/escpos_usb_printer.dart';
import 'package:escpos_usb_printer/escpos_usb_printer_method_channel.dart';
import 'package:escpos_usb_printer/escpos_usb_printer_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEscposUsbPrinterPlatform
    with MockPlatformInterfaceMixin
    implements EscposUsbPrinterPlatform {
  @override
  Future<bool?> initService() => Future.value(true);

  @override
  Future<String?> getPrinterStatus() => Future.value("Ready");

  @override
  Future<bool?> printTicket(Uint8List imageBytes, Map<String, dynamic> json) =>
      Future.value(true);

  @override
  Future<bool?> printKitchenTicket(
          Uint8List imageBytes, Map<String, dynamic> json) =>
      Future.value(true);

  @override
  Future<bool?> printOfflineTicket(
          Uint8List imageBytes, Map<String, dynamic> json) =>
      Future.value(true);

  void main() {
    final EscposUsbPrinterPlatform initialPlatform =
        EscposUsbPrinterPlatform.instance;

    test('$MethodChannelEscposUsbPrinter is the default instance', () {
      expect(initialPlatform, isInstanceOf<MethodChannelEscposUsbPrinter>());
    });

    test('getPlatformVersion', () async {
      EscposUsbPrinter escposUsbPrinterPlugin = EscposUsbPrinter();
      MockEscposUsbPrinterPlatform fakePlatform =
          MockEscposUsbPrinterPlatform();
      EscposUsbPrinterPlatform.instance = fakePlatform;

      expect(await escposUsbPrinterPlugin.initService(), '42');
    });
  }
}
