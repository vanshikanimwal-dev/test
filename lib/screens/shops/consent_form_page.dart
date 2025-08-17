//
// import 'package:flutter/material.dart';
// import 'dart:ui'; // For ImageFilter.blur
// import 'package:ferrero_asset_management/widgets/styled_button.dart';
// import 'package:ferrero_asset_management/widgets/custom_text_form_field.dart';
// import 'package:ferrero_asset_management/models/asset_details_model.dart'; // Ensure this import is correct
// import 'package:provider/provider.dart';
// import 'package:ferrero_asset_management/provider/data_provider.dart';
// import 'package:ferrero_asset_management/screens/assets/asset_capture_page.dart';
// import 'package:ferrero_asset_management/services/app_api_service.dart'; // <--- ADD THIS IMPORT
//
// class ConsentFormPage extends StatefulWidget {
//   final AssetDetails assetDetails;
//   final String username;
//
//   const ConsentFormPage({
//     super.key,
//     required this.assetDetails,
//     required this.username,
//   });
//
//   @override
//   State<ConsentFormPage> createState() => _ConsentFormPageState();
// }
//
// class _ConsentFormPageState extends State<ConsentFormPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _outletUniqueCodeController = TextEditingController();
//   final TextEditingController _outletAddressController = TextEditingController();
//   final TextEditingController _VCTypeController = TextEditingController();
//   final TextEditingController _serialNumberController = TextEditingController();
//   final TextEditingController _outletOwnerNameController = TextEditingController();
//   final TextEditingController _outletOwnerNumberController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _postalCodeController = TextEditingController();
//
//   final FocusNode _outletUniqueCodeFocus = FocusNode();
//   final FocusNode _outletAddressFocus = FocusNode();
//   final FocusNode _VCTypeFocus = FocusNode();
//   final FocusNode _serialNumberFocus = FocusNode();
//   final FocusNode _outletOwnerNameFocus = FocusNode();
//   final FocusNode _outletOwnerNumberFocus = FocusNode();
//   final FocusNode _stateFocus = FocusNode();
//   final FocusNode _postalCodeFocus = FocusNode();
//
//   final ValueNotifier<bool> _outletUniqueCodeFocused = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _outletAddressFocused = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _VCTypeFocused = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _serialNumberFocused = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _outletOwnerNameFocused = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _outletOwnerNumberFocused = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _stateFocused = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> _postalCodeFocused = ValueNotifier<bool>(false);
//
//   bool _isCompletedStatus = false;
//
//   // These will now hold the network URLs for existing images and location string
//   Map<String, String?> _preExistingImages = {};
//   String? _preExistingLocation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _outletUniqueCodeFocus.addListener(() => _outletUniqueCodeFocused.value = _outletUniqueCodeFocus.hasFocus);
//     _outletAddressFocus.addListener(() => _outletAddressFocused.value = _outletAddressFocus.hasFocus);
//     _VCTypeFocus.addListener(() => _VCTypeFocused.value = _VCTypeFocus.hasFocus);
//     _serialNumberFocus.addListener(() => _serialNumberFocused.value = _serialNumberFocus.hasFocus);
//     _outletOwnerNameFocus.addListener(() => _outletOwnerNameFocused.value = _outletOwnerNameFocus.hasFocus);
//     _outletOwnerNumberFocus.addListener(() => _outletOwnerNumberFocused.value = _outletOwnerNumberFocus.hasFocus);
//     _stateFocus.addListener(() => _stateFocused.value = _stateFocus.hasFocus);
//     _postalCodeFocus.addListener(() => _postalCodeFocused.value = _postalCodeFocus.hasFocus);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         setState(() {
//           _outletUniqueCodeController.text = widget.assetDetails.uoc;
//           _outletAddressController.text = widget.assetDetails.address;
//           _VCTypeController.text = widget.assetDetails.vcType;
//           _serialNumberController.text = widget.assetDetails.vcSerialNo;
//           _outletOwnerNameController.text = widget.assetDetails.contactPerson;
//           _outletOwnerNumberController.text = widget.assetDetails.mobileNumber;
//           _stateController.text = widget.assetDetails.state;
//           _postalCodeController.text = widget.assetDetails.postalCode;
//
//           _isCompletedStatus = widget.assetDetails.status.toLowerCase() == 'completed';
//
//           // --- Populate pre-existing image URLs and location from fetched assetDetails ---
//           _preExistingImages = {
//             'outlet_exteriors_photo': AppApiService.getFullImageUrl(widget.assetDetails.outletExteriorsPhoto),
//             'asset_pics': AppApiService.getFullImageUrl(widget.assetDetails.assetPics),
//             'outlet_owner_ids_pics': AppApiService.getFullImageUrl(widget.assetDetails.outletOwnerIdsPics),
//             'outlet_owner_pic': AppApiService.getFullImageUrl(widget.assetDetails.outletOwnerPic),
//             'serial_no_pic': AppApiService.getFullImageUrl(widget.assetDetails.serialNoPic),
//           };
//
//           if (widget.assetDetails.latitude != null && widget.assetDetails.longitude != null) {
//             _preExistingLocation = 'Lat: ${widget.assetDetails.latitude}, Lng: ${widget.assetDetails.longitude}';
//           } else {
//             _preExistingLocation = null;
//           }
//           // --- END Populate ---
//
//           // If the shop is completed, make all fields read-only
//           if (_isCompletedStatus) {
//             _outletUniqueCodeController.text = widget.assetDetails.uoc;
//             _outletAddressController.text = widget.assetDetails.address;
//             _VCTypeController.text = widget.assetDetails.vcType;
//             _serialNumberController.text = widget.assetDetails.vcSerialNo;
//             _outletOwnerNameController.text = widget.assetDetails.contactPerson;
//             _outletOwnerNumberController.text = widget.assetDetails.mobileNumber;
//             _stateController.text = widget.assetDetails.state;
//             _postalCodeController.text = widget.assetDetails.postalCode;
//           }
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _outletUniqueCodeController.dispose();
//     _outletAddressController.dispose();
//     _VCTypeController.dispose();
//     _serialNumberController.dispose();
//     _outletOwnerNameController.dispose();
//     _outletOwnerNumberController.dispose();
//     _stateController.dispose();
//     _postalCodeController.dispose();
//
//     _outletUniqueCodeFocus.dispose();
//     _outletAddressFocus.dispose();
//     _VCTypeFocus.dispose();
//     _serialNumberFocus.dispose();
//     _outletOwnerNameFocus.dispose();
//     _outletOwnerNumberFocus.dispose();
//     _stateFocus.dispose();
//     _postalCodeFocus.dispose();
//
//     _outletUniqueCodeFocused.dispose();
//     _outletAddressFocused.dispose();
//     _VCTypeFocused.dispose();
//     _serialNumberFocused.dispose();
//     _outletOwnerNameFocused.dispose();
//     _outletOwnerNumberFocused.dispose();
//     _stateFocused.dispose();
//     _postalCodeFocused.dispose();
//
//     super.dispose();
//   }
//
//   void _initiateEAgreement() {
//     // If the shop is completed, directly navigate to AssetCapturePage with pre-existing data
//     if (_isCompletedStatus) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AssetCapturePage(
//             outletName: widget.assetDetails.outletName,
//             outletOwnerNumber: _outletOwnerNumberController.text,
//             username: widget.username,
//             capturedImages: {}, // No new local images yet, so pass empty map
//             capturedLocation: _preExistingLocation, // Pass pre-existing location
//             isShopCompleted: _isCompletedStatus,
//             initialNetworkImagePaths: _preExistingImages, // <--- PASS PRE-EXISTING IMAGE URLs
//           ),
//         ),
//       );
//       return;
//     }
//
//     // If not completed, validate and process form for new agreement
//     if (_formKey.currentState!.validate()) {
//       final dataProvider = Provider.of<DataProvider>(context, listen: false);
//       print('Form Data to be submitted/updated:');
//       print('UOC: ${_outletUniqueCodeController.text}');
//       print('OUTLET_NAME: ${widget.assetDetails.outletName}');
//       print('Address: ${_outletAddressController.text}');
//       print('VC Type: ${_VCTypeController.text}');
//       print('VC Serial No: ${_serialNumberController.text}');
//       print('Contact_Person: ${_outletOwnerNameController.text}');
//       print('Mobile Number: ${_outletOwnerNumberController.text}');
//       print('State: ${_stateController.text}');
//       print('Postal Code: ${_postalCodeController.text}');
//
//       // Update DataProvider with current form values
//       dataProvider.updateString('UOC', _outletUniqueCodeController.text);
//       dataProvider.updateString('OUTLET_NAME', widget.assetDetails.outletName);
//       dataProvider.updateString('Address', _outletAddressController.text);
//       dataProvider.updateString('VC Type', _VCTypeController.text);
//       dataProvider.updateString('VC Serial No', _serialNumberController.text);
//       dataProvider.updateString('Contact_Person', _outletOwnerNameController.text);
//       dataProvider.updateString('Mobile Number', _outletOwnerNumberController.text);
//       dataProvider.updateString('State', _stateController.text);
//       dataProvider.updateString('Postal Code', _postalCodeController.text);
//       dataProvider.setUsername(widget.username);
//
//       // Navigate to AssetCapturePage for new capture
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AssetCapturePage(
//             outletName: widget.assetDetails.outletName,
//             outletOwnerNumber: _outletOwnerNumberController.text,
//             username: widget.username,
//             capturedImages: {}, // Start with empty captured images for new capture
//             capturedLocation: null, // Start with no captured location for new capture
//             isShopCompleted: _isCompletedStatus,
//             initialNetworkImagePaths: _preExistingImages, // Pass existing images for display
//           ),
//         ),
//       );
//     } else {
//       if (mounted) {
//         _showDialog('Validation Error', 'Please fill all required fields correctly.');
//       }
//     }
//   }
//
//   void _showDialog(String title, String message) {
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       builder: (BuildContext Context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(Context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAF6EF),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
//                   child: GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.arrow_back_ios, color: Colors.brown, size: 20),
//                         Text('Back', style: TextStyle(fontSize: 18, color: Colors.brown)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12.0),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//                     child: Container(
//                       height: 1.0,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.withOpacity(0.1),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text.rich(
//                       TextSpan(
//                         text: 'OUTLET_NAME: ',
//                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
//                         children: const [TextSpan(text: '*', style: TextStyle(fontSize: 18, color: Colors.red))],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       height: 50,
//                       padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                       decoration: BoxDecoration(
//                         color: Colors.brown,
//                         borderRadius: BorderRadius.circular(8.0),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 3,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           Image.asset('assets/logo.png', height: 30, width: 30),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               widget.assetDetails.outletName,
//                               style: const TextStyle(color: Colors.white, fontSize: 16),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextFormField(
//                   controller: _outletUniqueCodeController,
//                   labelText: 'UOC:',
//                   hintText: 'Enter unique code...',
//                   focusNode: _outletUniqueCodeFocus,
//                   isFocusedNotifier: _outletUniqueCodeFocused,
//                   validator: (value) => value == null || value.isEmpty ? 'Please enter UOC' : null,
//                   readOnly: _isCompletedStatus,
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextFormField(
//                   controller: _outletAddressController,
//                   labelText: 'Address:',
//                   hintText: 'Enter outlet address...',
//                   focusNode: _outletAddressFocus,
//                   isFocusedNotifier: _outletAddressFocused,
//                   validator: (value) => value == null || value.isEmpty ? 'Please enter Address' : null,
//                   readOnly: _isCompletedStatus,
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextFormField(
//                   controller: _stateController,
//                   labelText: 'State:',
//                   hintText: 'Enter state...',
//                   focusNode: _stateFocus,
//                   isFocusedNotifier: _stateFocused,
//                   validator: (value) => value == null || value.isEmpty ? 'Please enter State' : null,
//                   readOnly: _isCompletedStatus,
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextFormField(
//                   controller: _postalCodeController,
//                   labelText: 'Postal Code:',
//                   hintText: 'Enter postal code...',
//                   keyboardType: TextInputType.number,
//                   focusNode: _postalCodeFocus,
//                   isFocusedNotifier: _postalCodeFocused,
//                   validator: (value) => value == null || value.isEmpty ? 'Please enter Postal Code' : null,
//                   readOnly: _isCompletedStatus,
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextFormField(
//                   controller: _VCTypeController,
//                   labelText: 'VC Type:',
//                   hintText: 'Enter asset type...',
//                   focusNode: _VCTypeFocus,
//                   isFocusedNotifier: _VCTypeFocused,
//                   validator: (value) => value == null || value.isEmpty ? 'Please enter VC Type' : null,
//                   readOnly: _isCompletedStatus,
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextFormField(
//                   controller: _serialNumberController,
//                   labelText: 'VC Serial No:',
//                   hintText: 'Enter serial number...',
//                   focusNode: _serialNumberFocus,
//                   isFocusedNotifier: _serialNumberFocused,
//                   validator: (value) => value == null || value.isEmpty ? 'Please enter VC Serial No' : null,
//                   readOnly: _isCompletedStatus,
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextFormField(
//                   controller: _outletOwnerNameController,
//                   labelText: 'Contact Person:',
//                   hintText: 'Enter owner\'s name...',
//                   focusNode: _outletOwnerNameFocus,
//                   isFocusedNotifier: _outletOwnerNameFocused,
//                   validator: (value) => value == null || value.isEmpty ? 'Please enter Contact Person' : null,
//                   readOnly: _isCompletedStatus,
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextFormField(
//                   controller: _outletOwnerNumberController,
//                   labelText: 'Mobile Number:',
//                   hintText: 'Enter owner\'s number...',
//                   keyboardType: TextInputType.phone,
//                   focusNode: _outletOwnerNumberFocus,
//                   isFocusedNotifier: _outletOwnerNumberFocused,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter mobile number';
//                     }
//                     if (value.length < 10) {
//                       return 'Please enter a valid 10-digit number';
//                     }
//                     return null;
//                   },
//                   readOnly: _isCompletedStatus,
//                 ),
//                 const SizedBox(height: 30),
//                 Center(
//                   child: styledButton(
//                     text: 'Initiate E-agreement',
//                     onPressed: _initiateEAgreement,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
//
import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter.blur
import 'package:ferrero_asset_management/widgets/styled_button.dart';
import 'package:ferrero_asset_management/widgets/custom_text_form_field.dart';
import 'package:ferrero_asset_management/models/asset_details_model.dart';
import 'package:provider/provider.dart';
import 'package:ferrero_asset_management/provider/data_provider.dart';
import 'package:ferrero_asset_management/screens/assets/asset_capture_page.dart';
import 'package:ferrero_asset_management/services/app_api_service.dart';

class ConsentFormPage extends StatefulWidget {
  final AssetDetails assetDetails;
  final String username;

  const ConsentFormPage({
    super.key,
    required this.assetDetails,
    required this.username,
  });

  @override
  State<ConsentFormPage> createState() => _ConsentFormPageState();
}

class _ConsentFormPageState extends State<ConsentFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _outletUniqueCodeController = TextEditingController();
  final TextEditingController _outletAddressController = TextEditingController();
  final TextEditingController _VCTypeController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _outletOwnerNameController = TextEditingController();
  final TextEditingController _outletOwnerNumberController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  final FocusNode _outletUniqueCodeFocus = FocusNode();
  final FocusNode _outletAddressFocus = FocusNode();
  final FocusNode _VCTypeFocus = FocusNode();
  final FocusNode _serialNumberFocus = FocusNode();
  final FocusNode _outletOwnerNameFocus = FocusNode();
  final FocusNode _outletOwnerNumberFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _postalCodeFocus = FocusNode();

  final ValueNotifier<bool> _outletUniqueCodeFocused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _outletAddressFocused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _VCTypeFocused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _serialNumberFocused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _outletOwnerNameFocused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _outletOwnerNumberFocused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _stateFocused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _postalCodeFocused = ValueNotifier<bool>(false);

  bool _isCompletedStatus = false;

  // These will now hold the network URLs for existing images and location string
  Map<String, String?> _preExistingImages = {};
  String? _preExistingLocation;

  @override
  void initState() {
    super.initState();

    _outletUniqueCodeFocus.addListener(() => _outletUniqueCodeFocused.value = _outletUniqueCodeFocus.hasFocus);
    _outletAddressFocus.addListener(() => _outletAddressFocused.value = _outletAddressFocus.hasFocus);
    _VCTypeFocus.addListener(() => _VCTypeFocused.value = _VCTypeFocus.hasFocus);
    _serialNumberFocus.addListener(() => _serialNumberFocused.value = _serialNumberFocus.hasFocus);
    _outletOwnerNameFocus.addListener(() => _outletOwnerNameFocused.value = _outletOwnerNameFocus.hasFocus);
    _outletOwnerNumberFocus.addListener(() => _outletOwnerNumberFocused.value = _outletOwnerNumberFocus.hasFocus);
    _stateFocus.addListener(() => _stateFocused.value = _stateFocus.hasFocus);
    _postalCodeFocus.addListener(() => _postalCodeFocused.value = _postalCodeFocus.hasFocus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Initialize controllers with data from the AssetDetails model
          _outletUniqueCodeController.text = widget.assetDetails.uoc ?? '';
          _outletAddressController.text = widget.assetDetails.address ?? '';
          _VCTypeController.text = widget.assetDetails.vcType ?? '';
          _serialNumberController.text = widget.assetDetails.vcSerialNo ?? '';
          _outletOwnerNameController.text = widget.assetDetails.contactPerson ?? '';
          _outletOwnerNumberController.text = widget.assetDetails.mobileNumber ?? '';
          _stateController.text = widget.assetDetails.state ?? '';
          _postalCodeController.text = widget.assetDetails.postalCode ?? '';

          _isCompletedStatus = widget.assetDetails.status?.toLowerCase() == 'completed';

          // Populate pre-existing image URLs and location from fetched assetDetails
          _preExistingImages = {
            'outlet_exteriors_photo': AppApiService.getFullImageUrl(widget.assetDetails.outletExteriorsPhoto),
            'asset_pics': AppApiService.getFullImageUrl(widget.assetDetails.assetPics),
            'outlet_owner_ids_pics': AppApiService.getFullImageUrl(widget.assetDetails.outletOwnerIdsPics),
            'outlet_owner_pic': AppApiService.getFullImageUrl(widget.assetDetails.outletOwnerPic),
            'serial_no_pic': AppApiService.getFullImageUrl(widget.assetDetails.serialNoPic),
          };

          if (widget.assetDetails.latitude != null && widget.assetDetails.longitude != null) {
            _preExistingLocation = 'Lat: ${widget.assetDetails.latitude}, Lng: ${widget.assetDetails.longitude}';
          } else {
            _preExistingLocation = null;
          }

          // If the shop is completed, make all fields read-only
          if (_isCompletedStatus) {
            // Fields are already populated, just need to ensure they are read-only
            // This is handled by the `readOnly` parameter on the CustomTextFormField widgets.
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _outletUniqueCodeController.dispose();
    _outletAddressController.dispose();
    _VCTypeController.dispose();
    _serialNumberController.dispose();
    _outletOwnerNameController.dispose();
    _outletOwnerNumberController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();

    _outletUniqueCodeFocus.dispose();
    _outletAddressFocus.dispose();
    _VCTypeFocus.dispose();
    _serialNumberFocus.dispose();
    _outletOwnerNameFocus.dispose();
    _outletOwnerNumberFocus.dispose();
    _stateFocus.dispose();
    _postalCodeFocus.dispose();

    _outletUniqueCodeFocused.dispose();
    _outletAddressFocused.dispose();
    _VCTypeFocused.dispose();
    _serialNumberFocused.dispose();
    _outletOwnerNameFocused.dispose();
    _outletOwnerNumberFocused.dispose();
    _stateFocused.dispose();
    _postalCodeFocused.dispose();

    super.dispose();
  }

  void _initiateEAgreement() {
    // If the shop is completed, directly navigate to AssetCapturePage with pre-existing data
    if (_isCompletedStatus) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssetCapturePage(
            outletName: widget.assetDetails.outletName,
            outletOwnerNumber: _outletOwnerNumberController.text,
            username: widget.username,
            capturedImages: {}, // No new local images yet, so pass empty map
            capturedLocation: _preExistingLocation, // Pass pre-existing location
            isShopCompleted: _isCompletedStatus,
            initialNetworkImagePaths: _preExistingImages, // PASS PRE-EXISTING IMAGE URLs
          ),
        ),
      );
      return;
    }

    // If not completed, validate and process form for new agreement
    if (_formKey.currentState!.validate()) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      print('Form Data to be submitted/updated:');
      print('UOC: ${_outletUniqueCodeController.text}');
      print('OUTLET_NAME: ${widget.assetDetails.outletName}');
      print('Address: ${_outletAddressController.text}');
      print('VC Type: ${_VCTypeController.text}');
      print('VC Serial No: ${_serialNumberController.text}');
      print('Contact_Person: ${_outletOwnerNameController.text}');
      print('Mobile Number: ${_outletOwnerNumberController.text}');
      print('State: ${_stateController.text}');
      print('Postal Code: ${_postalCodeController.text}');

      // Update DataProvider with current form values
      dataProvider.updateString('UOC', _outletUniqueCodeController.text);
      dataProvider.updateString('OUTLET_NAME', widget.assetDetails.outletName);
      dataProvider.updateString('Address', _outletAddressController.text);
      dataProvider.updateString('VC Type', _VCTypeController.text);
      dataProvider.updateString('VC Serial No', _serialNumberController.text);
      dataProvider.updateString('Contact_Person', _outletOwnerNameController.text);
      dataProvider.updateString('Mobile Number', _outletOwnerNumberController.text);
      dataProvider.updateString('State', _stateController.text);
      dataProvider.updateString('Postal Code', _postalCodeController.text);
      dataProvider.setUsername(widget.username);

      // Navigate to AssetCapturePage for new capture
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssetCapturePage(
            outletName: widget.assetDetails.outletName,
            outletOwnerNumber: _outletOwnerNumberController.text,
            username: widget.username,
            capturedImages: {}, // Start with empty captured images for new capture
            capturedLocation: null, // Start with no captured location for new capture
            isShopCompleted: _isCompletedStatus,
            initialNetworkImagePaths: _preExistingImages, // Pass existing images for display
          ),
        ),
      );
    } else {
      if (mounted) {
        _showDialog('Validation Error', 'Please fill all required fields correctly.');
      }
    }
  }

  void _showDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext Context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(Context).pop();
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
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
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      height: 1.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'OUTLET_NAME: ',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                        children: const [TextSpan(text: '*', style: TextStyle(fontSize: 18, color: Colors.red))],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/logo.png', height: 30, width: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.assetDetails.outletName ?? 'N/A', // Handle null case
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _outletUniqueCodeController,
                  labelText: 'UOC:',
                  hintText: 'Enter unique code...',
                  focusNode: _outletUniqueCodeFocus,
                  isFocusedNotifier: _outletUniqueCodeFocused,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter UOC' : null,
                  readOnly: _isCompletedStatus,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _outletAddressController,
                  labelText: 'Address:',
                  hintText: 'Enter outlet address...',
                  focusNode: _outletAddressFocus,
                  isFocusedNotifier: _outletAddressFocused,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter Address' : null,
                  readOnly: _isCompletedStatus,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _stateController,
                  labelText: 'State:',
                  hintText: 'Enter state...',
                  focusNode: _stateFocus,
                  isFocusedNotifier: _stateFocused,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter State' : null,
                  readOnly: _isCompletedStatus,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _postalCodeController,
                  labelText: 'Postal Code:',
                  hintText: 'Enter postal code...',
                  keyboardType: TextInputType.number,
                  focusNode: _postalCodeFocus,
                  isFocusedNotifier: _postalCodeFocused,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter Postal Code' : null,
                  readOnly: _isCompletedStatus,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _VCTypeController,
                  labelText: 'VC Type:',
                  hintText: 'Enter asset type...',
                  focusNode: _VCTypeFocus,
                  isFocusedNotifier: _VCTypeFocused,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter VC Type' : null,
                  readOnly: _isCompletedStatus,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _serialNumberController,
                  labelText: 'VC Serial No:',
                  hintText: 'Enter serial number...',
                  focusNode: _serialNumberFocus,
                  isFocusedNotifier: _serialNumberFocused,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter VC Serial No' : null,
                  readOnly: _isCompletedStatus,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _outletOwnerNameController,
                  labelText: 'Contact Person:',
                  hintText: 'Enter owner\'s name...',
                  focusNode: _outletOwnerNameFocus,
                  isFocusedNotifier: _outletOwnerNameFocused,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter Contact Person' : null,
                  readOnly: _isCompletedStatus,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _outletOwnerNumberController,
                  labelText: 'Mobile Number:',
                  hintText: 'Enter owner\'s number...',
                  keyboardType: TextInputType.phone,
                  focusNode: _outletOwnerNumberFocus,
                  isFocusedNotifier: _outletOwnerNumberFocused,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid 10-digit number';
                    }
                    return null;
                  },
                  readOnly: _isCompletedStatus,
                ),
                const SizedBox(height: 30),
                Center(
                  child: styledButton(
                    text: 'Initiate E-agreement',
                    onPressed: _initiateEAgreement,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
