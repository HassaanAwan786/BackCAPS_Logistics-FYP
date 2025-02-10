import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan License QR"),
      ),
      body: Column(
        children: [
          Gap(MediaQuery.of(context).size.height/9),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 10,
                      color: Theme.of(context).colorScheme.primary
                  ),
                ),
                height: MediaQuery.of(context).size.width/1.2,
                width: MediaQuery.of(context).size.width/1.2,
                child: MobileScanner(
                  controller: MobileScannerController(
                      detectionSpeed: DetectionSpeed.noDuplicates
                  ),
                  onDetect: (capture){
                    Navigator.pop(context, capture.barcodes.first.rawValue);
                  },
                ),
              ),
            ],
          ),
          const Gap(20),
          const Text("Scanning..."),
        ],
      ),
    );
  }
}
