import 'package:escpos_usb_printer_example/models/branch_info_model.dart';
import 'package:escpos_usb_printer_example/models/products_model.dart';
import 'package:escpos_usb_printer_example/models/ticket_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:escpos_usb_printer/escpos_usb_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _escposUsbPrinterPlugin = EscposUsbPrinter();
  bool _initializedService = false;
  String _printerStatus = "Not Initialized";
  bool _isTicketPrinted = false;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initService() async {
    bool initService;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      initService = await _escposUsbPrinterPlugin.initService() ?? false;
    } on PlatformException {
      initService = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _initializedService = initService;
    });
  }

  Future<void> getPrinterStatus() async {
    String printerStatus;
    try {
      printerStatus = await _escposUsbPrinterPlugin.getPrinterStatus() ??
          "Printer not Initialized";
    } on PlatformException {
      printerStatus = "Printer not initialized";
    }
    if (!mounted) return;
    setState(() {
      _printerStatus = printerStatus;
    });
  }

  Future<void> printTicket() async {
    TicketModel ticket = const TicketModel(
        branchInfoModel: BranchInfoModel(
            address: "Some place in the world", name: "Downtown branch"),
        order: 10,
        productsModel: [
          ProductsModel(price: 20, productName: "Café Américano", quantity: 2),
          ProductsModel(price: 10, productName: "Cafrísimo", quantity: 1)
        ],
        total: 10,
        isOffline: false);
    final Uint8List imageBytes = await loadImageBytes('assets/logoBw.bmp');
    bool isTicketPrinted;
    try {
      isTicketPrinted = await _escposUsbPrinterPlugin.printTicket(
              imageBytes, ticket.toJson()) ??
          false;
    } on PlatformException {
      isTicketPrinted = false;
    }
    if (!mounted) return;
    setState(() {
      _isTicketPrinted = isTicketPrinted;
    });
  }

  Future<void> printKitchenTicket() async {
    TicketModel ticket = const TicketModel(
        branchInfoModel: BranchInfoModel(
            address: "Some place in the world", name: "Downtown branch"),
        order: 10,
        productsModel: [
          ProductsModel(price: 20, productName: "Café Américano", quantity: 2),
          ProductsModel(price: 10, productName: "Cafrísimo", quantity: 1)
        ],
        total: 10,
        isOffline: false);
    final Uint8List imageBytes = await loadImageBytes('assets/logoBw.bmp');
    bool isTicketPrinted;
    try {
      isTicketPrinted = await _escposUsbPrinterPlugin.printTicket(
              imageBytes, ticket.toJson()) ??
          false;
    } on PlatformException {
      isTicketPrinted = false;
    }
    if (!mounted) return;
    setState(() {
      _isTicketPrinted = isTicketPrinted;
    });
  }

  Future<Uint8List> loadImageBytes(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Service initialized: $_initializedService\n'),
            ),
            ElevatedButton(
                onPressed: () {
                  initService();
                },
                child: const Text("Initialize Service")),
            Center(
              child: Text('Printer Status: $_printerStatus\n'),
            ),
            ElevatedButton(
                onPressed: () {
                  getPrinterStatus();
                },
                child: const Text("Get Printer Status")),
            Center(
              child: Text('Ticket printed: $_isTicketPrinted\n'),
            ),
            ElevatedButton(
                onPressed: () {
                  printTicket();
                },
                child: const Text("Print Ticket"))
          ],
        ),
      ),
    );
  }
}
