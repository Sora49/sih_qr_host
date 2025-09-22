import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? qrText;
  Map<String, dynamic>? rowData;
  bool isLoading = false;
  String? errorMessage;

  Future<bool> testConnectivity() async {
    try {
      print("Testing basic internet connectivity...");
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print("Internet connectivity test failed: $e");
      return false;
    }
  }

  Future<void> fetchRowData(String uuid) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      rowData = null;
    });

    try {
      // Test connectivity first
      bool hasInternet = await testConnectivity();
      if (!hasInternet) {
        throw Exception("No internet connectivity");
      }

      // List of server addresses to try (Render production + local backup)
      final List<String> serverUrls = [
        "https://sih-qr-host.onrender.com/search/$uuid", // Render production
        "http://192.168.29.2:5000/search/$uuid", // Local backup
        "http://127.0.0.1:5000/search/$uuid", // Localhost backup
      ];

      http.Response? response;
      String? successUrl;

      // Try each URL until one works
      for (String url in serverUrls) {
        try {
          print("Trying to connect to: $url");
          response = await http
              .get(
                Uri.parse(url),
                headers: {'Content-Type': 'application/json'},
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            successUrl = url;
            print("Successfully connected to: $url");
            break;
          } else {
            print(
              "Server responded with status ${response.statusCode} for $url",
            );
          }
        } catch (e) {
          print("Failed to connect to $url: $e");
          continue;
        }
      }

      if (response == null || response.statusCode != 200) {
        throw Exception("Failed to connect to any Flask server");
      }

      if (response.body.isEmpty) {
        throw Exception("Server returned empty response");
      }

      try {
        final data = jsonDecode(response.body);
        setState(() {
          rowData = data;
          isLoading = false;
        });
        print("Data fetched successfully from $successUrl: $data");
      } catch (e) {
        throw Exception("Failed to parse JSON response: $e");
      }
    } catch (error) {
      print("Error fetching data: $error");
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              child: MobileScanner(
                onDetect: (BarcodeCapture capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      setState(() {
                        qrText = barcode.rawValue!;
                      });
                      fetchRowData(barcode.rawValue!);
                    }
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanned QR Code:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    qrText ?? 'No QR code scanned yet',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (errorMessage != null)
                    Text(
                      'Error: $errorMessage',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    )
                  else if (rowData != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data from Database:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...rowData!.entries
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                    ),
                                    child: Text(
                                      '${entry.key}: ${entry.value}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
