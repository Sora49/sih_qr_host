import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'results_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? qrText;
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
          isLoading = false;
        });
        print("Data fetched successfully from $successUrl: $data");

        // Navigate to results page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(qrCode: uuid, data: data),
          ),
        );
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
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(Icons.qr_code_scanner, size: 48, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  'Scan a QR Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  qrText != null
                      ? 'Last scanned: $qrText'
                      : 'Position the QR code within the frame above',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        'Fetching data...',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  )
                else if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 24),
                        const SizedBox(height: 8),
                        Text(
                          'Connection Error',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
