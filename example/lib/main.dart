import 'dart:async';

import 'package:escpos_usb_printer/escpos_usb_printer.dart';
import 'package:escpos_usb_printer_example/models/branch_info_model.dart';
import 'package:escpos_usb_printer_example/models/kitchen_ticket_model.dart';
import 'package:escpos_usb_printer_example/models/kitchen_ticket_product_model.dart';
import 'package:escpos_usb_printer_example/models/kitchen_ticket_product_modifiers_model.dart';
import 'package:escpos_usb_printer_example/models/offline_ticket_model.dart';
import 'package:escpos_usb_printer_example/models/session_info_model.dart';
import 'package:escpos_usb_printer_example/models/ticket_model.dart';
import 'package:escpos_usb_printer_example/models/ticket_payment_method_model.dart';
import 'package:escpos_usb_printer_example/models/ticket_product_modifier_model.dart';
import 'package:escpos_usb_printer_example/models/ticket_products_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool _isKitchenTicketPrinted = false;
  bool _isOfflineTicketPrinted = false;

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
        branchInfo: BranchInfoModel(
            address:
                "Plaza Galerias, Blvrd Antonio Ortiz Mena 201-A, Presidentes, C.P 31210, Chihuahua",
            city: "Chihuahua",
            name: "Plaza Galerias",
            phone: "6141234567",
            postalCode: 31210),
        session: SessionInfoModel(
            line: "Barra", lineId: 1, sessionId: 1, user: "Admin"),
        products: [
          TicketProductsModel(
              price: 80,
              productName: "Cafe Americano",
              quantity: 1,
              modifier: [
                TicketProductModifierModel(
                    price: 60, name: "Chico-12oz", quantity: 1),
                TicketProductModifierModel(
                    price: 10, name: "Oreo", quantity: 1),
                TicketProductModifierModel(
                    price: 10, name: "Shot Extra Espresso", quantity: 1)
              ]),
          TicketProductsModel(
            price: 40,
            productName: "Galleta",
            quantity: 1,
          ),
          TicketProductsModel(
              price: 60,
              productName: "Cafe Latte",
              quantity: 1,
              modifier: [
                TicketProductModifierModel(
                    price: 60, name: "Chico-12oz", quantity: 1),
              ]),
        ],
        subTotal: 150.2,
        tax: 29.8,
        discount: 0,
        total: 180,
        paymentMethods: [
          TicketPaymentMethodModel(amount: 150, payment: "CARD"),
          TicketPaymentMethodModel(amount: 30, payment: "CASH"),
        ],
        totalInWords: "Ciento ochenta",
        urlInvoice: "https://qa.d2h666eo2e1r2p.amplifyapp.com",
        orderId: 10,
        rfc: "CTE180828E84",
        date: "15/Aug/2024 04:14",
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
    KitchenTicketModel ticket = KitchenTicketModel(
        date: DateTime.now().toString(),
        order: 1,
        products: [
          const KitchenTicketProductModel(
              productName: "Cafe Americano",
              quantity: 1,
              modifiers: [
                KitchenTicketProductModifiersModel(name: "Oreo", quantity: 2),
                KitchenTicketProductModifiersModel(
                    name: "Shot extra", quantity: 1)
              ]),
          const KitchenTicketProductModel(
              productName: "Cafe Latte",
              quantity: 1,
              modifiers: [
                KitchenTicketProductModifiersModel(
                    name: "Caramelo", quantity: 2),
              ]),
          const KitchenTicketProductModel(
            productName: "Galleta",
            quantity: 1,
          ),
        ],
        isOffline: false);
    final Uint8List imageBytes = await loadImageBytes('assets/logoBw.bmp');
    bool isKitchenTicketPrinted;
    try {
      isKitchenTicketPrinted = await _escposUsbPrinterPlugin.printKitchenTicket(
              imageBytes, ticket.toJson()) ??
          false;
    } on PlatformException {
      isKitchenTicketPrinted = false;
    }
    if (!mounted) return;
    setState(() {
      _isKitchenTicketPrinted = isKitchenTicketPrinted;
    });
  }

  Future<void> printOfflineTicket() async {
    OfflineTicketModel ticket = OfflineTicketModel(
        branchInfo: const BranchInfoModel(
            address: "Some place in the world", name: "Downtown branch"),
        order: 10,
        products: [
          const TicketProductsModel(
              price: 20,
              productName: "Café Américano",
              quantity: 2,
              modifier: [
                TicketProductModifierModel(
                    price: 10, name: "Extra shot", quantity: 1),
                TicketProductModifierModel(
                    price: 20, name: "Esencia de vainilla", quantity: 2)
              ]),
          const TicketProductsModel(
              price: 10,
              productName: "Cafrísimo",
              quantity: 1,
              modifier: [
                TicketProductModifierModel(
                    price: 10, name: "Azucar extra", quantity: 1)
              ])
        ],
        total: 10,
        isOffline: false,
        date: DateTime.now().toString());
    final Uint8List imageBytes = await loadImageBytes('assets/logoBw.bmp');
    bool isOfflineTicketPrinted;
    try {
      isOfflineTicketPrinted = await _escposUsbPrinterPlugin.printOfflineTicket(
              imageBytes, ticket.toJson()) ??
          false;
    } on PlatformException {
      isOfflineTicketPrinted = false;
    }
    if (!mounted) return;
    setState(() {
      _isOfflineTicketPrinted = isOfflineTicketPrinted;
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              child: Text('Ticket printed: $_isTicketPrinted'),
            ),
            ElevatedButton(
                onPressed: () {
                  printTicket();
                },
                child: const Text("Print Ticket")),
            Center(
              child: Text('Ticket printed: $_isKitchenTicketPrinted'),
            ),
            ElevatedButton(
                onPressed: () {
                  printKitchenTicket();
                },
                child: const Text("Print Kitchen Ticket")),
            Center(
              child: Text('Ticket printed: $_isOfflineTicketPrinted'),
            ),
            ElevatedButton(
                onPressed: () {
                  printOfflineTicket();
                },
                child: const Text("Print Offline Ticket"))
          ],
        ),
      ),
    );
  }
}
