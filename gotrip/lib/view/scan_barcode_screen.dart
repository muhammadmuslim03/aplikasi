import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controller/checkin_checkout_controller.dart';
import '../controller/history_controller.dart';

class ScanBarcodeScreen extends StatefulWidget {
  const ScanBarcodeScreen({super.key});

  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.code128, BarcodeFormat.qrCode],
  );

  final CheckinCheckoutController _controller = Get.put(
    CheckinCheckoutController(),
  );

  bool _isHandlingScan = false;
  String _lastCode = '';

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isHandlingScan) return;

    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.trim().isNotEmpty, orElse: () => '');

    if (code.isEmpty) return;

    setState(() {
      _isHandlingScan = true;
      _lastCode = code;
    });

    await _scannerController.stop();

    final success = await _controller.submitBarcode(code);
    if (success && Get.isRegistered<HistoryController>()) {
      await Get.find<HistoryController>().refreshHistory();
    }

    if (!mounted) return;

    if (!success) {
      await Future.delayed(const Duration(milliseconds: 800));
      await _scannerController.start();
      setState(() => _isHandlingScan = false);
    }
  }

  Future<void> _scanAgain() async {
    setState(() {
      _isHandlingScan = false;
      _lastCode = '';
    });
    await _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Check-in / Check-out'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Kamera tidak dapat digunakan. Pastikan izin kamera aktif.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[100], fontSize: 15),
                  ),
                ),
              );
            },
          ),
          _ScannerFrame(isLoading: _controller.isSubmitting),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Obx(() {
              final loading = _controller.isSubmitting.value;
              final message = _controller.lastMessage.value;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loading
                          ? 'Memproses barcode...'
                          : message.isNotEmpty
                          ? message
                          : 'Arahkan kamera ke barcode admin.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1D4F44),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_lastCode.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _lastCode,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _scanAgain,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4F44),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  final RxBool isLoading;

  const _ScannerFrame({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 260,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Obx(
            () => isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
