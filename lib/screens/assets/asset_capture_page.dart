
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ferrero_asset_management/provider/data_provider.dart';
import 'package:ferrero_asset_management/widgets/styled_button.dart';
import 'package:ferrero_asset_management/widgets/photo_capture_grid_item.dart';
import 'package:ferrero_asset_management/screens/consent/consent_and_otp_verification_page.dart';
import 'package:ferrero_asset_management/screens/image_viewer/image_viewer_screen.dart';
import 'package:ferrero_asset_management/services/app_api_service.dart'; // Import for getFullImageUrl

class AssetCapturePage extends StatefulWidget {
  final String outletName;
  final String outletOwnerNumber;
  final String username;
  final Map<String, String?> capturedImages; // These are local paths if coming from a previous capture session
  final String? capturedLocation;
  final bool isShopCompleted;
  final Map<String, String?>? initialNetworkImagePaths; // For images fetched from the database

  const AssetCapturePage({
    super.key,
    required this.outletName,
    required this.outletOwnerNumber,
    required this.username,
    required this.capturedImages,
    required this.capturedLocation,
    required this.isShopCompleted,
    this.initialNetworkImagePaths,
  });

  @override
  State<AssetCapturePage> createState() => _AssetCapturePageState();
}

class _AssetCapturePageState extends State<AssetCapturePage> {
  // This map will hold the CURRENT state of images (either local paths or network URLs)
  late Map<String, String?> _currentImagePaths;
  String? _capturedLocation;
  bool _isLoadingLocation = false;
  late bool _isEditable;

  @override
  void initState() {
    super.initState();
    _isEditable = !widget.isShopCompleted;

    // Initialize _currentImagePaths.
    // If we have initial network image paths (from a database fetch), use those.
    // Otherwise, use the capturedImages (which would be local paths from a previous partial capture).
    if (widget.initialNetworkImagePaths != null && widget.initialNetworkImagePaths!.isNotEmpty) {
      _currentImagePaths = Map.from(widget.initialNetworkImagePaths!);
    } else {
      _currentImagePaths = Map.from(widget.capturedImages);
    }

    _capturedLocation = widget.capturedLocation;
  }

  Future<void> _pickImage(String imageType) async {
    if (!_isEditable) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        // When a new image is picked, it's always a local file path
        _currentImagePaths[imageType] = image.path;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_isEditable) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showDialog('Location Permission Denied', 'Location permissions are denied. Please enable them in settings.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showDialog('Location Permission Denied', 'Location permissions are permanently denied. Please enable them in settings.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _capturedLocation = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
      });
    } catch (e) {
      _showDialog('Error Getting Location', 'Could not get location: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _submitShopDetails() async {
    if (!_isEditable) return;

    // Check for required images. Now, _currentImagePaths can contain either local paths or network URLs.
    // For submission, we need to distinguish. We'll only send *local* image paths for upload.
    // If an image is a network URL, it means it already exists on the server.
    final Map<String, String?> imagesForUpload = {};
    bool allImagesCapturedLocally = true;

    for (var entry in _currentImagePaths.entries) {
      final String? path = entry.value;
      if (path != null && path.isNotEmpty) {
        // Check if the path is a local file path (not a network URL)
        if (!path.startsWith('http://') && !path.startsWith('https://')) {
          imagesForUpload[entry.key] = path;
        }
      } else {
        // If any required image is missing (null or empty), mark as not all captured
        if (entry.key == 'outlet_exteriors_photo' ||
            entry.key == 'asset_pics' ||
            entry.key == 'outlet_owner_ids_pics' ||
            entry.key == 'outlet_owner_pic' ||
            entry.key == 'serial_no_pic') {
          allImagesCapturedLocally = false;
        }
      }
    }

    if (!allImagesCapturedLocally) {
      _showDialog('Missing Images', 'Please capture all required images before initiating agreement.');
      return;
    }


    if (_capturedLocation == null || _capturedLocation!.isEmpty) {
      _showDialog('Missing Location', 'Please capture location before initiating agreement.');
      return;
    }

    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // Update dataProvider with all current values, including images (local paths for upload)
    dataProvider.updateString('UOC', dataProvider.uoc); // Assuming UOC is already in dataProvider
    dataProvider.updateString('OUTLET_NAME', dataProvider.outletNameFromConsentForm);
    dataProvider.updateString('Address', dataProvider.address);
    dataProvider.updateString('VC Type', dataProvider.vcType);
    dataProvider.updateString('VC Serial No', dataProvider.vcSerialNo);
    dataProvider.updateString('Contact_Person', dataProvider.contactPerson);
    dataProvider.updateString('Mobile Number', dataProvider.mobileNumberFromConsentForm);
    dataProvider.updateString('State', dataProvider.state);
    dataProvider.updateString('Postal Code', dataProvider.postalCode);
    dataProvider.setUsername(widget.username); // Ensure username is in dataProvider

    // Pass only the *local* image paths for upload
    dataProvider.addImages(imagesForUpload);
    dataProvider.setLocation(_capturedLocation);
    dataProvider.finalizeAllUpdates(); // This will trigger the API call in your DataProvider


    try {
      await _showDialog('Asset Data Captured!', 'Proceeding to consent and OTP verification.');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsentAndOtpVerificationPage(
            outletName: dataProvider.outletNameFromConsentForm ?? widget.outletName,
            outletOwnerNumber: dataProvider.mobileNumberFromConsentForm ?? widget.outletOwnerNumber,
            username: dataProvider.username ?? widget.username,
            capturedImages: _currentImagePaths, // Pass the current state of images (local or network)
            capturedLocation: _capturedLocation,
          ),
        ),
      );
    } catch (e) {
      _showDialog('Error', 'An error occurred: $e');
    }
  }

  Future<void> _openVendorDataUrl() async {
    // Direct path to your image asset
    final String imageAssetPath = 'assets/images/consent_form_image.jpg'; // <--- USE YOUR IMAGE PATH HERE

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          title: 'Consent Form', // Title for the image viewer screen's AppBar
          imageAssetPath: imageAssetPath, // Pass the image asset path
        ),
      ),
    );
  }

  Future<void> _showDialog(String title, String message) async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios, color: Colors.brown, size: 20),
                    Text('Back', style: TextStyle(fontSize: 18, color: Colors.brown)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Capture Assets for: ${widget.outletName}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 30),
            // Location Section
            Text(
              'Location Details:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isEditable ? Colors.brown : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: _isEditable ? Colors.white : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.brown, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capturedLocation ?? 'Location not captured',
                    style: TextStyle(
                      fontSize: 16,
                      color: _capturedLocation != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  styledButton(
                    text: _isLoadingLocation ? 'Getting Location...' : 'Get Location',
                    onPressed: _isLoadingLocation || !_isEditable ? null : _getCurrentLocation,
                    buttonColor: _isEditable ? Colors.brown : Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Photos Section
            Text(
              'Photo Capture:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isEditable ? Colors.brown : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                PhotoCaptureGridItem(
                  label: 'Outlet Exteriors Photo',
                  pickedFilePath: _currentImagePaths['outlet_exteriors_photo'] != null &&
                      !_currentImagePaths['outlet_exteriors_photo']!.startsWith('http')
                      ? _currentImagePaths['outlet_exteriors_photo']
                      : null,
                  networkImageUrl: _currentImagePaths['outlet_exteriors_photo'] != null &&
                      _currentImagePaths['outlet_exteriors_photo']!.startsWith('http')
                      ? _currentImagePaths['outlet_exteriors_photo'] // <--- FIX: Pass directly
                      : null,
                  onTap: () => _pickImage('outlet_exteriors_photo'),
                  isEditable: _isEditable,
                ),
                PhotoCaptureGridItem(
                  label: 'Asset Pics',
                  pickedFilePath: _currentImagePaths['asset_pics'] != null &&
                      !_currentImagePaths['asset_pics']!.startsWith('http')
                      ? _currentImagePaths['asset_pics']
                      : null,
                  networkImageUrl: _currentImagePaths['asset_pics'] != null &&
                      _currentImagePaths['asset_pics']!.startsWith('http')
                      ? _currentImagePaths['asset_pics'] // <--- FIX: Pass directly
                      : null,
                  onTap: () => _pickImage('asset_pics'),
                  isEditable: _isEditable,
                ),
                PhotoCaptureGridItem(
                  label: 'Outlet Owner ID\'s Pics',
                  pickedFilePath: _currentImagePaths['outlet_owner_ids_pics'] != null &&
                      !_currentImagePaths['outlet_owner_ids_pics']!.startsWith('http')
                      ? _currentImagePaths['outlet_owner_ids_pics']
                      : null,
                  networkImageUrl: _currentImagePaths['outlet_owner_ids_pics'] != null &&
                      _currentImagePaths['outlet_owner_ids_pics']!.startsWith('http')
                      ? _currentImagePaths['outlet_owner_ids_pics'] // <--- FIX: Pass directly
                      : null,
                  onTap: () => _pickImage('outlet_owner_ids_pics'),
                  isEditable: _isEditable,
                ),
                PhotoCaptureGridItem(
                  label: 'Outlet Owner Pic',
                  pickedFilePath: _currentImagePaths['outlet_owner_pic'] != null &&
                      !_currentImagePaths['outlet_owner_pic']!.startsWith('http')
                      ? _currentImagePaths['outlet_owner_pic']
                      : null,
                  networkImageUrl: _currentImagePaths['outlet_owner_pic'] != null &&
                      _currentImagePaths['outlet_owner_pic']!.startsWith('http')
                      ? _currentImagePaths['outlet_owner_pic'] // <--- FIX: Pass directly
                      : null,
                  onTap: () => _pickImage('outlet_owner_pic'),
                  isEditable: _isEditable,
                ),
                PhotoCaptureGridItem(
                  label: 'Serial No. Pic',
                  pickedFilePath: _currentImagePaths['serial_no_pic'] != null &&
                      !_currentImagePaths['serial_no_pic']!.startsWith('http')
                      ? _currentImagePaths['serial_no_pic']
                      : null,
                  networkImageUrl: _currentImagePaths['serial_no_pic'] != null &&
                      _currentImagePaths['serial_no_pic']!.startsWith('http')
                      ? _currentImagePaths['serial_no_pic'] // <--- FIX: Pass directly
                      : null,
                  onTap: () => _pickImage('serial_no_pic'),
                  isEditable: _isEditable,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: styledButton(
                text: _isEditable ? 'Initiate Agreement' : 'Continue',
                onPressed: _isEditable ? _submitShopDetails : _openVendorDataUrl,
                buttonColor: Colors.brown,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
