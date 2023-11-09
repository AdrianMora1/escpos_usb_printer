import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'escpos_usb_printer_method_channel.dart';

abstract class EscposUsbPrinterPlatform extends PlatformInterface {
  /// Constructs a EscposUsbPrinterPlatform.
  EscposUsbPrinterPlatform() : super(token: _token);

  static final Object _token = Object();

  static EscposUsbPrinterPlatform _instance = MethodChannelEscposUsbPrinter();

  /// The default instance of [EscposUsbPrinterPlatform] to use.
  ///
  /// Defaults to [MethodChannelEscposUsbPrinter].
  static EscposUsbPrinterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EscposUsbPrinterPlatform] when
  /// they register themselves.
  static set instance(EscposUsbPrinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
