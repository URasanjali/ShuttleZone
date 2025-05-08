// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:share_plus/share_plus.dart';

// class QrDisplayScreen extends StatefulWidget {
//   final String qrData;

//   const QrDisplayScreen({super.key, required this.qrData});

//   @override
//   State<QrDisplayScreen> createState() => _QrDisplayScreenState();
// }

// class _QrDisplayScreenState extends State<QrDisplayScreen> {
//   final GlobalKey _qrKey = GlobalKey();
//   bool _isDownloading = false;

//   /// Parses QR data into a structured format
//   Map<String, String> _parseQrData() {
//     final parts = widget.qrData.split('|');
//     return {
//       'userId': parts.length > 1 ? parts[1] : '',
//       'bookingId': parts.length > 2 ? parts[2] : '',
//       'amount': parts.length > 3 ? parts[3] : '',
//       'courtName': parts.length > 4 ? parts[4] : 'your booking',
//     };
//   }

//   /// Captures and shares QR code as an image
//   Future<void> _shareQrCode() async {
//     if (_isDownloading) return;
    
//     setState(() {
//       _isDownloading = true;
//     });

//     try {
//       // Give time for UI to update
//       await Future.delayed(const Duration(milliseconds: 300));

//       // Get the boundary
//       final RenderRepaintBoundary? boundary = 
//           _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          
//       if (boundary == null) {
//         throw Exception("Failed to find QR code render object");
//       }

//       // Convert to image
//       final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       final ByteData? byteData = 
//           await image.toByteData(format: ui.ImageByteFormat.png);

//       if (byteData == null) {
//         throw Exception("Failed to convert image to bytes");
//       }

//       final Uint8List pngBytes = byteData.buffer.asUint8List();

//       // Share the bytes directly
//       final qrInfo = _parseQrData();
//       await Share.shareXFiles(
//         [
//           XFile.fromData(
//             pngBytes,
//             name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png',
//             mimeType: 'image/png',
//           )
//         ],
//         text: 'Your QR Code for ${qrInfo['courtName']}',
//         subject: 'Booking QR Code',
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('QR Code ready to share!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       debugPrint("Error sharing QR code: $e");
//       if (!mounted) return;
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to share QR Code: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isDownloading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final qrInfo = _parseQrData();
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your QR Code'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('QR Code Information'),
//                   content: Text(
//                     'This QR code contains your payment information for ${qrInfo['courtName']}. '
//                     'Show this at the venue to check in for your booking.',
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('OK'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Display payment information
//                 _buildPaymentInfo(qrInfo),
                
//                 const SizedBox(height: 24),

//                 // QR Code with RepaintBoundary
//                 Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: RepaintBoundary(
//                       key: _qrKey,
//                       child: QrImageView(
//                         data: widget.qrData,
//                         version: QrVersions.auto,
//                         size: 250,
//                         backgroundColor: Colors.white,
//                         padding: const EdgeInsets.all(8),
//                         gapless: false,
//                         errorStateBuilder: (context, error) {
//                           return Center(
//                             child: Text(
//                               'Error generating QR code: ${error.toString()}',
//                               textAlign: TextAlign.center,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 // Share button
//                 ElevatedButton.icon(
//                   onPressed: _isDownloading ? null : _shareQrCode,
//                   icon: _isDownloading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Icon(Icons.share),
//                   label: Text(_isDownloading ? "Processing..." : "Share QR Code"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     disabledBackgroundColor: Colors.grey.shade400,
//                   ),
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Help text
//                 Text(
//                   'This QR code will be scanned at the venue',
//                   style: TextStyle(
//                     color: Colors.grey.shade600,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Build payment information widget
//   Widget _buildPaymentInfo(Map<String, String> qrInfo) {
//     final hasBookingInfo = qrInfo['bookingId']!.isNotEmpty && 
//                           qrInfo['courtName']!.isNotEmpty;
    
//     if (!hasBookingInfo) {
//       return const Card(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Text('Payment information not available'),
//         ),
//       );
//     }

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//         side: BorderSide(color: Colors.green.shade100),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Booking: ${qrInfo['courtName']}',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Amount: \$${qrInfo['amount']}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.green,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Booking ID: ${qrInfo['bookingId']}',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Divider(),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(Icons.qr_code_scanner, size: 16, color: Colors.grey[600]),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Present this QR code at the venue',
//                   style: TextStyle(fontStyle: FontStyle.italic),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
// Import for web downloads
import 'dart:html' as html;

class QrDisplayScreen extends StatefulWidget {
  final String qrData;

  const QrDisplayScreen({super.key, required this.qrData});

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isProcessing = false;

  /// Parses QR data into a structured format
  Map<String, String> _parseQrData() {
    final parts = widget.qrData.split('|');
    return {
      'userId': parts.length > 1 ? parts[1] : '',
      'bookingId': parts.length > 2 ? parts[2] : '',
      'amount': parts.length > 3 ? parts[3] : '',
      'courtName': parts.length > 4 ? parts[4] : 'your booking',
    };
  }

  /// Captures QR code as an image and returns the image bytes
  Future<Uint8List?> _captureQrCode() async {
    try {
      // Give time for UI to update if necessary
      await Future.delayed(const Duration(milliseconds: 300));

      // Get the boundary
      final RenderRepaintBoundary? boundary = 
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          
      if (boundary == null) {
        throw Exception("Failed to find QR code render object");
      }

      // Convert to image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = 
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception("Failed to convert image to bytes");
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing QR code: $e");
      return null;
    }
  }

  /// Downloads QR code to the device gallery or browser
  Future<void> _downloadQrCode() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      final Uint8List? pngBytes = await _captureQrCode();
      if (pngBytes == null) {
        throw Exception("Failed to capture QR code");
      }

      if (kIsWeb) {
        // Web platform - use the browser's download mechanism
        _downloadBytesInWeb(pngBytes, "QR_Code.png");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code download started!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Mobile platform - use gallery saver
        // Request storage permission
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception("Storage permission is required to save the QR code");
        }

        // Save to gallery
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 100,
          name: "QR_Code_${DateTime.now().millisecondsSinceEpoch}"
        );

        if (!mounted) return;

        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR Code saved to gallery!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception("Failed to save image: ${result['errorMessage'] ?? 'Unknown error'}");
        }
      }
    } catch (e) {
      debugPrint("Error downloading QR code: $e");
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download QR Code: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Downloads bytes directly in web browser
  void _downloadBytesInWeb(Uint8List bytes, String fileName) {
    // This is only available on web platform
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    html.document.body!.children.add(anchor);

    // Download
    anchor.click();

    // Clean up
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  /// Shares QR code to other apps
  Future<void> _shareQrCode() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      final Uint8List? pngBytes = await _captureQrCode();
      if (pngBytes == null) {
        throw Exception("Failed to capture QR code");
      }

      // Share the bytes directly
      final qrInfo = _parseQrData();
      await Share.shareXFiles(
        [
          XFile.fromData(
            pngBytes,
            name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png',
            mimeType: 'image/png',
          )
        ],
        text: 'Your QR Code for ${qrInfo['courtName']}',
        subject: 'Booking QR Code',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code shared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Error sharing QR code: $e");
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share QR Code: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrInfo = _parseQrData();
    final actionText = kIsWeb ? "Download" : "Save to Gallery";
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('QR Code Information'),
                  content: Text(
                    'This QR code contains your payment information for ${qrInfo['courtName']}. '
                    'Show this at the venue to check in for your booking.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display payment information
                _buildPaymentInfo(qrInfo),
                
                const SizedBox(height: 24),

                // QR Code with RepaintBoundary
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RepaintBoundary(
                      key: _qrKey,
                      child: QrImageView(
                        data: widget.qrData,
                        version: QrVersions.auto,
                        size: 250,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(8),
                        gapless: false,
                        errorStateBuilder: (context, error) {
                          return Center(
                            child: Text(
                              'Error generating QR code: ${error.toString()}',
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Download button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : () => _downloadQrCode(),
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download),
                        label: Text(actionText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Share button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : () => _shareQrCode(),
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Help text
                Text(
                  'This QR code will be scanned at the venue',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build payment information widget
  Widget _buildPaymentInfo(Map<String, String> qrInfo) {
    final hasBookingInfo = qrInfo['bookingId']!.isNotEmpty && 
                          qrInfo['courtName']!.isNotEmpty;
    
    if (!hasBookingInfo) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Payment information not available'),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.green.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking: ${qrInfo['courtName']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: \$${qrInfo['amount']}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Booking ID: ${qrInfo['bookingId']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.qr_code_scanner, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                const Text(
                  'Present this QR code at the venue',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}