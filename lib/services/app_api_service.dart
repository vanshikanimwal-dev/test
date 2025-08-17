//
// import 'dart:convert'; // Required for JSON encoding/decoding
// import 'dart:io';     // Required for File operations (image upload)
// import 'package:http/http.dart' as http; // Required for HTTP requests
// import 'package:logging/logging.dart';   // Required for logging
// import 'package:path/path.dart' as p;     // Required for path manipulation (image upload)
// import 'package:http_parser/http_parser.dart'; // Required for MediaType
//
// // Required because these models and provider classes are used within the service logic
// import 'package:ferrero_asset_management/provider/data_provider.dart';
// import 'package:ferrero_asset_management/models/asset_details_model.dart';
//
// import 'package:flutter/services.dart'; // Required for MethodChannel (SMS functionality)
//
//
// /// A consolidated API and platform service for the Ferrero Asset Management application.
// /// This class follows the Singleton pattern to ensure only one instance
// /// is used throughout the application, managing various API calls
// /// (HTTP requests) and platform-specific functionalities (like SMS).
// class AppApiService {
//   // --- Singleton Setup ---
//   static final AppApiService _instance = AppApiService._internal();
//   factory AppApiService() {
//     return _instance;
//   }
//   AppApiService._internal();
//   // --- End Singleton Setup ---
//
//   // Logger for this consolidated service
//   static final Logger _log = Logger('AppApiService');
//
//   // --- API Base URLs and Paths ---
//   // CONSOLIDATED AND CORRECTED BASE URL FOR ALL API CALLS
//   static const String _apiBaseUrl = 'https://sarsatiya.store/XJAAM1-0.0.1-SNAPSHOT';
//
//   // Paths relative to the new _apiBaseUrl
//   static const String _assetUploadPath = '/assets/AddAssetFromMobile';
//   static const String _allAssetDetailsPath = '/assets/GetAllAssetDetails';
//   static const String _openStatusAssetsPath = '/assets/GetOpenStatusAssets';
//   static const String _closedStatusAssetsPath = '/assets/GetClosedStatusAssets';
//   static const String _inProgressStatusAssetsPath = '/assets/GetInProgressStatusAssets';
//   static const String _completedStatusAssetsPath = '/assets/GetCompletedStatusAssets';
//
//   // --- Image Base URL for fetching images ---
//   static const String _imageBaseUrl = 'https://sarsatiya.store/images/'; // Placeholder, adjust as needed.
//
//   // Helper to construct full image URLs from relative paths
//   static String getFullImageUrl(String? relativePath) {
//     if (relativePath == null || relativePath.isEmpty) {
//       return '';
//     }
//     final cleanedPath = relativePath.replaceAll('/opt/apache/webapps/images/', '');
//     return '$_imageBaseUrl$cleanedPath';
//   }
//
//   // --- Method Channel for SMS ---
//   static const MethodChannel _smsMethodChannel = MethodChannel('com.ferrero.asset_management/sms');
//
//   /// Uploads data and images as a multipart request to the asset management backend.
//   ///
//   /// Requires a [DataProvider] instance containing the data and image paths,
//   /// and a [bearerToken] for authorization.
//   /// Returns a [Map<String, dynamic>] indicating success/failure and a message.
//   Future<Map<String, dynamic>> uploadDataWithJsonAndImages({
//     required DataProvider dataProvider,
//     required String? bearerToken,
//   }) async {
//     _log.fine("uploadDataWithJsonAndImages called. Token received: ${bearerToken != null && bearerToken.isNotEmpty ? "Present" : "MISSING/EMPTY"}");
//
//     if (bearerToken == null || bearerToken.isEmpty) {
//       _log.severe("Bearer token is null or empty in AppApiService.uploadDataWithJsonAndImages.");
//       return {'success': false, 'message': 'Authentication token is missing.'};
//     }
//
//     try {
//       final Uri uploadUri = Uri.parse('$_apiBaseUrl$_assetUploadPath');
//       var request = http.MultipartRequest('POST', uploadUri);
//
//       request.headers['Authorization'] = 'Bearer $bearerToken';
//
//       // --- CONSTRUCT JSON DATA IN THE EXACT REQUESTED FORMAT FROM POSTMAN ---
//       Map<String, dynamic> jsonDataMap = {
//         'vcType': dataProvider.vcType ?? '',
//         'vcSerialNo': dataProvider.vcSerialNo ?? '',
//         'uoc': dataProvider.uoc ?? '',
//         'outletName': dataProvider.outletNameFromConsentForm ?? '',
//         'address': dataProvider.address ?? '',
//         'state': dataProvider.state ?? '',
//         'postalCode': dataProvider.postalCode ?? '',
//         'contactPerson': dataProvider.contactPerson ?? '',
//         'mobileNumber': dataProvider.mobileNumberFromConsentForm ?? '',
//         'status': 'completed',
//         'latitude': null, // Initialize as null, will be updated if location exists
//         'longitude': null, // Initialize as null, will be updated if location exists
//         'outletExteriorsPhoto': '', // Default to empty string
//         'assetPics': '',
//         'outletOwnerIdsPics': '',
//         'outletOwnerPic': '',
//         'serialNoPic': '',
//         // Removed mobfield, createDate, updateDate, firstName, lastName
//         // as they are NOT present in the working Postman cURL JSON.
//       };
//
//       final capturedLocationString = dataProvider.capturedLocation;
//       if (capturedLocationString != null && capturedLocationString.isNotEmpty) {
//         final parts = capturedLocationString.split(', ');
//         if (parts.length == 2) {
//           jsonDataMap['latitude'] = parts[0].replaceFirst('Lat: ', '');
//           jsonDataMap['longitude'] = parts[1].replaceFirst('Lng: ', '');
//         } else {
//           _log.warning('Unexpected location string format: $capturedLocationString');
//         }
//       }
//
//       final String? vcSerialNo = dataProvider.vcSerialNo;
//
//       List<Map<String, String>> loggedImageFiles = [];
//
//       // --- UPDATED: Mapping from DataProvider keys to snake_case JSON keys for image PARTS ---
//       // These are the field names for the actual file parts in the multipart request
//       final Map<String, String> imagePartFieldNames = {
//         'outlet_exteriors_photo': 'outlet_exteriors_photo', // Matches Postman cURL
//         'asset_pics': 'asset_pics', // Matches Postman cURL
//         'outlet_owner_ids_pics': 'outlet_owner_ids_pics', // Matches Postman cURL
//         'outlet_owner_pic': 'outlet_owner_pic', // Matches Postman cURL
//         'serial_no_pic': 'serial_no_pic', // Matches Postman cURL
//       };
//
//       // Define a mapping from DataProvider keys to camelCase JSON keys for image FILENAMES within the JSON payload
//       // These are the keys for the 'outletExteriorsPhoto', 'assetPics', etc. fields inside the JSON string
//       final Map<String, String> jsonImageFilenameKeys = {
//         'outlet_exteriors_photo': 'outletExteriorsPhoto',
//         'asset_pics': 'assetPics',
//         'outlet_owner_ids_pics': 'outletOwnerIdsPics',
//         'outlet_owner_pic': 'outletOwnerPic',
//         'serial_no_pic': 'serialNoPic',
//       };
//
//       for (var entry in dataProvider.allCapturedImages.entries) {
//         final String dataProviderKey = entry.key; // e.g., 'outlet_exteriors_photo'
//         final String? imagePath = entry.value;
//
//         // Get the field name for the multipart file part (snake_case from Postman)
//         final String? multipartFieldName = imagePartFieldNames[dataProviderKey];
//         // Get the key for the JSON payload (camelCase as per your JSON structure)
//         final String? jsonKeyForFilename = jsonImageFilenameKeys[dataProviderKey];
//
//
//         if (imagePath != null && imagePath.isNotEmpty && multipartFieldName != null && jsonKeyForFilename != null) {
//           File imageFile = File(imagePath);
//           if (await imageFile.exists()) {
//             String fileExtension = p.extension(imageFile.path);
//             String desiredFilename = '${jsonKeyForFilename}_${vcSerialNo ?? 'unknown_vc_no'}${fileExtension}';
//
//             // Update the JSON data with the filename
//             jsonDataMap[jsonKeyForFilename] = desiredFilename;
//
//             var multipartFile = await http.MultipartFile.fromPath(
//               multipartFieldName, // Use the snake_case field name for the file part
//               imagePath,
//               filename: desiredFilename,
//             );
//             request.files.add(multipartFile);
//
//             loggedImageFiles.add({
//               'Field': multipartFile.field,
//               'Filename': multipartFile.filename!,
//               'Length': multipartFile.length.toString(),
//               'ContentType': multipartFile.contentType.toString(),
//             });
//           } else {
//             _log.warning('Image file not found for type "$dataProviderKey": $imagePath');
//             jsonDataMap[jsonKeyForFilename] = ''; // Ensure it's an empty string if file not found
//           }
//         } else if (jsonKeyForFilename != null) {
//           jsonDataMap[jsonKeyForFilename] = ''; // Ensure it's an empty string if imagePath is null/empty
//         }
//       }
//
//       final String jsonPayloadString = JsonEncoder.withIndent('  ').convert(jsonDataMap);
//       _log.info('Final JSON Payload String Length: ${jsonPayloadString.length} characters.');
//       print('DEBUG: Full JSON Payload String:\n$jsonPayloadString');
//
//       // --- CRITICAL FIX: Send JSON as a MultipartFile.fromString with field name 'json' ---
//       request.files.add(http.MultipartFile.fromString(
//         'json', // <--- CHANGED THIS TO 'json' as per Postman cURL
//         jsonPayloadString,
//         contentType: MediaType('application', 'json'),
//       ));
//
//       String combinedLogMessage = 'Uploading data with JSON and Images to $uploadUri...\n';
//       combinedLogMessage += 'Headers: ${request.headers}\n';
//       combinedLogMessage += 'JSON data (includes image filenames/empty strings):\n$jsonPayloadString\n';
//
//       combinedLogMessage += 'Files to be uploaded as multipart parts:\n';
//       if (loggedImageFiles.isNotEmpty) {
//         for (var fileData in loggedImageFiles) {
//           combinedLogMessage += '  - Field: ${fileData['Field']}, Filename: ${fileData['Filename']}, Length: ${fileData['Length']}, ContentType: ${fileData['ContentType']}\n';
//         }
//       } else {
//         combinedLogMessage += '  No image files selected for upload.\n';
//       }
//
//       _log.info(combinedLogMessage);
//
//       var response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//
//       _log.info('Upload Response Status: ${response.statusCode}');
//       _log.fine('Upload Response Body: $responseBody');
//
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         return {'success': true, 'message': 'Data and images uploaded successfully!', 'body': responseBody};
//       } else {
//         _log.severe('Upload failed. Status: ${response.statusCode}, Body: ${responseBody}');
//         return {'success': false, 'message': 'Upload failed. Status: ${response.statusCode}', 'body': responseBody};
//       }
//     } catch (e, stackTrace) {
//       _log.severe('An error occurred during upload', e, stackTrace);
//       return {'success': false, 'message': 'An error occurred: ${e.toString()}'};
//     }
//   }
//
//   Future<bool> checkSmsPermission() async {
//     _log.info('Checking SMS permission via MethodChannel.');
//     try {
//       final bool hasPermission = await _smsMethodChannel.invokeMethod('checkSmsPermission');
//       _log.info('SMS permission status: $hasPermission');
//       return hasPermission;
//     } on PlatformException catch (e) {
//       _log.severe("Failed to check SMS permission: '${e.message}'.", e);
//       return false;
//     }
//   }
//
//   Future<bool> sendSms(String phoneNumber, String message) async {
//     _log.info('Attempting to send SMS to $phoneNumber via MethodChannel.');
//     try {
//       final bool success = await _smsMethodChannel.invokeMethod(
//         'sendSms',
//         <String, dynamic>{
//           'phoneNumber': phoneNumber,
//           'message': message,
//         },
//       );
//       _log.info('SMS sent success status: $success');
//       return success;
//     } on PlatformException catch (e) {
//       _log.severe("Failed to send SMS to $phoneNumber: '${e.message}'.", e);
//       return false;
//     }
//   }
//
//   Future<List<AssetDetails>> _fetchAssets(String path, String bearerToken, String endpointName) async {
//     _log.info('Attempting to fetch $endpointName assets from: $_apiBaseUrl$path');
//     try {
//       final response = await http.get(
//         Uri.parse('$_apiBaseUrl$path'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $bearerToken',
//         },
//       );
//       _log.info('Received HTTP response for $endpointName assets with status code: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         _log.fine('Raw response body for $endpointName assets: ${response.body}');
//         final List<dynamic> jsonList = jsonDecode(response.body);
//
//         final List<AssetDetails> assetsData = jsonList.map((json) {
//           try {
//             return AssetDetails.fromJson(json as Map<String, dynamic>);
//           } catch (e, st) {
//             _log.severe('Error parsing an $endpointName asset item: $json', e, st);
//             return null;
//           }
//         }).whereType<AssetDetails>().toList();
//
//         _log.info('Successfully fetched and parsed ${assetsData.length} $endpointName assets.');
//         return assetsData;
//       } else {
//         _log.warning('Failed to fetch $endpointName assets. Status code: ${response.statusCode}, Body: ${response.body}');
//         if (response.statusCode == 401) {
//           throw Exception('Authentication failed for $endpointName assets. Please ensure the token is valid.');
//         } else if (response.statusCode == 403) {
//           throw Exception('Authorization denied for $endpointName assets.');
//         } else {
//           throw Exception('Failed to load $endpointName assets: ${response.statusCode} - ${response.body}');
//         }
//       }
//     } catch (e, stackTrace) {
//       _log.severe('Error fetching $endpointName assets: $e', e, stackTrace);
//       throw Exception('Failed to connect to API for $endpointName assets: $e');
//     }
//   }
//
//   Future<List<AssetDetails>> fetchAllAssetDetails({required String bearerToken}) {
//     return _fetchAssets(_allAssetDetailsPath, bearerToken, 'all asset details');
//   }
//
//   Future<List<AssetDetails>> fetchOpenStatusAssets({required String bearerToken}) {
//     return _fetchAssets(_openStatusAssetsPath, bearerToken, 'open status');
//   }
//
//   Future<List<AssetDetails>> fetchClosedStatusAssets({required String bearerToken}) {
//     return _fetchAssets(_closedStatusAssetsPath, bearerToken, 'closed status');
//   }
//
//   Future<List<AssetDetails>> fetchInProgressStatusAssets({required String bearerToken}) {
//     return _fetchAssets(_inProgressStatusAssetsPath, bearerToken, 'in progress status');
//   }
//
//   Future<List<AssetDetails>> fetchCompletedStatusAssets({required String bearerToken}) {
//     return _fetchAssets(_completedStatusAssetsPath, bearerToken, 'completed status');
//   }
// }
// // // important code above
// //
// //
// //
// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:http/http.dart' as http;
// // // import 'package:logging/logging.dart';
// // // import 'package:path/path.dart' as p;
// // // import 'package:http_parser/http_parser.dart';
// // // import 'package:intl/intl.dart'; // <--- ADD THIS IMPORT for DateFormat
// // //
// // // import 'package:ferrero_asset_management/provider/data_provider.dart';
// // // import 'package:ferrero_asset_management/models/asset_details_model.dart';
// // //
// // // import 'package:flutter/services.dart';
// // //
// // //
// // // class AppApiService {
// // //   static final AppApiService _instance = AppApiService._internal();
// // //   factory AppApiService() {
// // //     return _instance;
// // //   }
// // //   AppApiService._internal();
// // //
// // //   static final Logger _log = Logger('AppApiService');
// // //
// // //   // --- Method Channel for SMS ---
// // //   static const MethodChannel _smsMethodChannel = MethodChannel('com.ferrero.asset_management/sms'); // <--- ADDED THIS DECLARATION
// // //
// // //   static const String _apiBaseUrl = 'https://sarsatiya.store/XJAAM1-0.0.1-SNAPSHOT';
// // //
// // //   static const String _assetUploadPath = '/assets/AddAssetFromMobile';
// // //   static const String _allAssetDetailsPath = '/assets/GetAllAssetDetails';
// // //   static const String _openStatusAssetsPath = '/assets/GetOpenStatusAssets';
// // //   static const String _closedStatusAssetsPath = '/assets/GetClosedStatusAssets';
// // //   static const String _inProgressStatusAssetsPath = '/assets/GetInProgressStatusAssets';
// // //   static const String _completedStatusAssetsPath = '/assets/GetCompletedStatusAssets';
// // //   // NEW: Date range filter API path
// // //   static const String _assetsByDateRangePath = '/assets/GetAssetsByDateRange';
// // //
// // //   static const String _imageBaseUrl = 'https://sarsatiya.store/images/';
// // //
// // //   static String getFullImageUrl(String? relativePath) {
// // //     if (relativePath == null || relativePath.isEmpty) {
// // //       return '';
// // //     }
// // //     // Adjust this replacement based on your actual server setup.
// // //     // Ensure it correctly strips the server-side path prefix.
// // //     final cleanedPath = relativePath.replaceAll('/opt/apache/webapps/', '');
// // //     return '$_imageBaseUrl$cleanedPath';
// // //   }
// // //
// // //   static String? getCreateDateString(List<int>? dateList) {
// // //     if (dateList == null || dateList.length != 3) {
// // //       return null;
// // //     }
// // //     try {
// // //       final DateTime date = DateTime(dateList[0], dateList[1], dateList[2]);
// // //       return DateFormat('yyyy-MM-dd').format(date);
// // //     } catch (e) {
// // //       _log.warning('Error parsing createDate list $dateList: $e');
// // //       return null;
// // //     }
// // //   }
// // //
// // //   Future<Map<String, dynamic>> uploadDataWithJsonAndImages({
// // //     required DataProvider dataProvider,
// // //     required String? bearerToken,
// // //   }) async {
// // //     _log.fine("uploadDataWithJsonAndImages called. Token received: ${bearerToken != null && bearerToken.isNotEmpty ? "Present" : "MISSING/EMPTY"}");
// // //
// // //     if (bearerToken == null || bearerToken.isEmpty) {
// // //       _log.severe("Bearer token is null or empty in AppApiService.uploadDataWithJsonAndImages.");
// // //       return {'success': false, 'message': 'Authentication token is missing.'};
// // //     }
// // //
// // //     try {
// // //       final Uri uploadUri = Uri.parse('$_apiBaseUrl$_assetUploadPath');
// // //       var request = http.MultipartRequest('POST', uploadUri);
// // //
// // //       request.headers['Authorization'] = 'Bearer $bearerToken';
// // //
// // //       Map<String, dynamic> jsonDataMap = {
// // //         'vcType': dataProvider.vcType ?? '',
// // //         'vcSerialNo': dataProvider.vcSerialNo ?? '',
// // //         'uoc': dataProvider.uoc ?? '',
// // //         'outletName': dataProvider.outletNameFromConsentForm ?? '',
// // //         'address': dataProvider.address ?? '',
// // //         'state': dataProvider.state ?? '',
// // //         'postalCode': dataProvider.postalCode ?? '',
// // //         'contactPerson': dataProvider.contactPerson ?? '',
// // //         'mobileNumber': dataProvider.mobileNumberFromConsentForm ?? '',
// // //         'status': 'completed',
// // //         'latitude': null,
// // //         'longitude': null,
// // //         'outletExteriorsPhoto': '',
// // //         'assetPics': '',
// // //         'outletOwnerIdsPics': '',
// // //         'outletOwnerPic': '',
// // //         'serialNoPic': '',
// // //       };
// // //
// // //       final capturedLocationString = dataProvider.capturedLocation;
// // //       if (capturedLocationString != null && capturedLocationString.isNotEmpty) {
// // //         final parts = capturedLocationString.split(', ');
// // //         if (parts.length == 2) {
// // //           jsonDataMap['latitude'] = parts[0].replaceFirst('Lat: ', '');
// // //           jsonDataMap['longitude'] = parts[1].replaceFirst('Lng: ', '');
// // //         } else {
// // //           _log.warning('Unexpected location string format: $capturedLocationString');
// // //         }
// // //       }
// // //
// // //       final String? vcSerialNo = dataProvider.vcSerialNo;
// // //
// // //       List<Map<String, String>> loggedImageFiles = [];
// // //
// // //       final Map<String, String> imagePartFieldNames = {
// // //         'outlet_exteriors_photo': 'outlet_exteriors_photo',
// // //         'asset_pics': 'asset_pics',
// // //         'outlet_owner_ids_pics': 'outlet_owner_ids_pics',
// // //         'outlet_owner_pic': 'outlet_owner_pic',
// // //         'serial_no_pic': 'serial_no_pic',
// // //       };
// // //
// // //       final Map<String, String> jsonImageFilenameKeys = {
// // //         'outlet_exteriors_photo': 'outletExteriorsPhoto',
// // //         'asset_pics': 'assetPics',
// // //         'outlet_owner_ids_pics': 'outletOwnerIdsPics',
// // //         'outlet_owner_pic': 'outletOwnerPic',
// // //         'serial_no_pic': 'serialNoPic',
// // //       };
// // //
// // //       for (var entry in dataProvider.allCapturedImages.entries) {
// // //         final String dataProviderKey = entry.key;
// // //         final String? imagePath = entry.value;
// // //
// // //         final String? multipartFieldName = imagePartFieldNames[dataProviderKey];
// // //         final String? jsonKeyForFilename = jsonImageFilenameKeys[dataProviderKey];
// // //
// // //
// // //         if (imagePath != null && imagePath.isNotEmpty && multipartFieldName != null && jsonKeyForFilename != null) {
// // //           File imageFile = File(imagePath);
// // //           if (await imageFile.exists()) {
// // //             String fileExtension = p.extension(imageFile.path);
// // //             String desiredFilename = '${jsonKeyForFilename}_${vcSerialNo ?? 'unknown_vc_no'}${fileExtension}';
// // //
// // //             jsonDataMap[jsonKeyForFilename] = desiredFilename;
// // //
// // //             var multipartFile = await http.MultipartFile.fromPath(
// // //               multipartFieldName,
// // //               imagePath,
// // //               filename: desiredFilename,
// // //             );
// // //             request.files.add(multipartFile);
// // //
// // //             loggedImageFiles.add({
// // //               'Field': multipartFile.field,
// // //               'Filename': multipartFile.filename!,
// // //               'Length': multipartFile.length.toString(),
// // //               'ContentType': multipartFile.contentType.toString(),
// // //             });
// // //           } else {
// // //             _log.warning('Image file not found for type "$dataProviderKey": $imagePath');
// // //             jsonDataMap[jsonKeyForFilename] = '';
// // //           }
// // //         } else if (jsonKeyForFilename != null) {
// // //           jsonDataMap[jsonKeyForFilename] = '';
// // //         }
// // //       }
// // //
// // //       final String jsonPayloadString = JsonEncoder.withIndent('  ').convert(jsonDataMap);
// // //       _log.info('Final JSON Payload String Length: ${jsonPayloadString.length} characters.');
// // //       print('DEBUG: Full JSON Payload String:\n$jsonPayloadString');
// // //
// // //       request.files.add(http.MultipartFile.fromString(
// // //         'json',
// // //         jsonPayloadString,
// // //         contentType: MediaType('application', 'json'),
// // //       ));
// // //
// // //       String combinedLogMessage = 'Uploading data with JSON and Images to $uploadUri...\n';
// // //       combinedLogMessage += 'Headers: ${request.headers}\n';
// // //       combinedLogMessage += 'JSON data (includes image filenames/empty strings):\n$jsonPayloadString\n';
// // //
// // //       combinedLogMessage += 'Files to be uploaded as multipart parts:\n';
// // //       if (loggedImageFiles.isNotEmpty) {
// // //         for (var fileData in loggedImageFiles) {
// // //           combinedLogMessage += '  - Field: ${fileData['Field']}, Filename: ${fileData['Filename']}, Length: ${fileData['Length']}, ContentType: ${fileData['ContentType']}\n';
// // //         }
// // //       } else {
// // //         combinedLogMessage += '  No image files selected for upload.\n';
// // //       }
// // //
// // //       _log.info(combinedLogMessage);
// // //
// // //       var response = await request.send();
// // //       final responseBody = await response.stream.bytesToString();
// // //
// // //       _log.info('Upload Response Status: ${response.statusCode}');
// // //       _log.fine('Upload Response Body: $responseBody');
// // //
// // //       if (response.statusCode >= 200 && response.statusCode < 300) {
// // //         return {'success': true, 'message': 'Data and images uploaded successfully!', 'body': responseBody};
// // //       } else {
// // //         _log.severe('Upload failed. Status: ${response.statusCode}, Body: ${responseBody}');
// // //         return {'success': false, 'message': 'Upload failed. Status: ${response.statusCode}', 'body': responseBody};
// // //       }
// // //     } catch (e, stackTrace) {
// // //       _log.severe('An error occurred during upload', e, stackTrace);
// // //       return {'success': false, 'message': 'An error occurred: ${e.toString()}'};
// // //     }
// // //   }
// // //
// // //   // --- SMS Service Methods ---
// // //   Future<bool> checkSmsPermission() async {
// // //     _log.info('Checking SMS permission via MethodChannel.');
// // //     try {
// // //       final bool hasPermission = await _smsMethodChannel.invokeMethod('checkSmsPermission');
// // //       _log.info('SMS permission status: $hasPermission');
// // //       return hasPermission;
// // //     } on PlatformException catch (e) {
// // //       _log.severe("Failed to check SMS permission: '${e.message}'.", e);
// // //       return false;
// // //     }
// // //   }
// // //
// // //   Future<bool> sendSms(String phoneNumber, String message) async {
// // //     _log.info('Attempting to send SMS to $phoneNumber via MethodChannel.');
// // //     try {
// // //       final bool success = await _smsMethodChannel.invokeMethod(
// // //         'sendSms',
// // //         <String, dynamic>{
// // //           'phoneNumber': phoneNumber,
// // //           'message': message,
// // //         },
// // //       );
// // //       _log.info('SMS sent success status: $success');
// // //       return success;
// // //     } on PlatformException catch (e) {
// // //       _log.severe("Failed to send SMS to $phoneNumber: '${e.message}'.", e);
// // //       return false;
// // //     }
// // //   }
// // //
// // //   /// Generic method to fetch assets by status or all assets.
// // //   Future<List<AssetDetails>> _fetchAssets(String path, String bearerToken, String endpointName, {Map<String, String>? queryParams}) async {
// // //     Uri uri = Uri.parse('$_apiBaseUrl$path');
// // //     if (queryParams != null && queryParams.isNotEmpty) {
// // //       uri = uri.replace(queryParameters: queryParams);
// // //     }
// // //
// // //     _log.info('Attempting to fetch $endpointName assets from: $uri');
// // //     try {
// // //       final response = await http.get(
// // //         uri,
// // //         headers: {
// // //           'Content-Type': 'application/json',
// // //           'Authorization': 'Bearer $bearerToken',
// // //         },
// // //       );
// // //       _log.info('Received HTTP response for $endpointName assets with status code: ${response.statusCode}');
// // //
// // //       if (response.statusCode == 200) {
// // //         _log.fine('Raw response body for $endpointName assets: ${response.body}');
// // //         final List<dynamic> jsonList = jsonDecode(response.body);
// // //
// // //         final List<AssetDetails> assetsData = jsonList.map((json) {
// // //           try {
// // //             return AssetDetails.fromJson(json as Map<String, dynamic>);
// // //           } catch (e, st) {
// // //             _log.severe('Error parsing an $endpointName asset item: $json', e, st);
// // //             return null;
// // //           }
// // //         }).whereType<AssetDetails>().toList();
// // //
// // //         _log.info('Successfully fetched and parsed ${assetsData.length} $endpointName assets.');
// // //         return assetsData;
// // //       } else {
// // //         _log.warning('Failed to fetch $endpointName assets. Status code: ${response.statusCode}, Body: ${response.body}');
// // //         if (response.statusCode == 401) {
// // //           throw Exception('Authentication failed for $endpointName assets. Please ensure the token is valid.');
// // //         } else if (response.statusCode == 403) {
// // //           throw Exception('Authorization denied for $endpointName assets.');
// // //         } else {
// // //           throw Exception('Failed to load $endpointName assets: ${response.statusCode} - ${response.body}');
// // //         }
// // //       }
// // //     } catch (e, stackTrace) {
// // //       _log.severe('Error fetching $endpointName assets: $e', e, stackTrace);
// // //       throw Exception('Failed to connect to API for $endpointName assets: $e');
// // //     }
// // //   }
// // //
// // //   /// Fetches all asset details (regardless of status).
// // //   Future<List<AssetDetails>> fetchAllAssetDetails({required String bearerToken}) {
// // //     return _fetchAssets(_allAssetDetailsPath, bearerToken, 'all asset details');
// // //   }
// // //
// // //   /// Fetches assets with 'Open' status.
// // //   Future<List<AssetDetails>> fetchOpenStatusAssets({required String bearerToken}) {
// // //     return _fetchAssets(_openStatusAssetsPath, bearerToken, 'open status');
// // //   }
// // //
// // //   /// Fetches assets with 'Closed' status.
// // //   Future<List<AssetDetails>> fetchClosedStatusAssets({required String bearerToken}) {
// // //     return _fetchAssets(_closedStatusAssetsPath, bearerToken, 'closed status');
// // //   }
// // //
// // //   /// Fetches assets with 'In Progress' status.
// // //   Future<List<AssetDetails>> fetchInProgressStatusAssets({required String bearerToken}) {
// // //     return _fetchAssets(_inProgressStatusAssetsPath, bearerToken, 'in progress status');
// // //   }
// // //
// // //   /// Fetches assets with 'Completed' status.
// // //   Future<List<AssetDetails>> fetchCompletedStatusAssets({required String bearerToken}) {
// // //     return _fetchAssets(_completedStatusAssetsPath, bearerToken, 'completed status');
// // //   }
// // //
// // //   // NEW: Fetches assets by a specified date range
// // //   Future<List<AssetDetails>> fetchAssetsByDateRange({
// // //     required String bearerToken,
// // //     required DateTime startDate,
// // //     required DateTime endDate,
// // //   }) {
// // //     final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
// // //     final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
// // //
// // //     final Map<String, String> queryParams = {
// // //       'startDate': formattedStartDate,
// // //       'endDate': formattedEndDate,
// // //     };
// // //     return _fetchAssets(_assetsByDateRangePath, bearerToken, 'assets by date range', queryParams: queryParams);
// // //   }
// // // }
//
//
//
//
//
import 'dart:convert'; // Required for JSON encoding/decoding
import 'dart:io';     // Required for File operations (image upload)
import 'package:http/http.dart' as http; // Required for HTTP requests
import 'package:logging/logging.dart';   // Required for logging
import 'package:path/path.dart' as p;     // Required for path manipulation (image upload)
import 'package:http_parser/http_parser.dart'; // Required for MediaType

// Required because these models and provider classes are used within the service logic
import 'package:ferrero_asset_management/provider/data_provider.dart';
import 'package:ferrero_asset_management/models/asset_details_model.dart';

import 'package:flutter/services.dart'; // Required for MethodChannel (SMS functionality)


/// A consolidated API and platform service for the Ferrero Asset Management application.
/// This class follows the Singleton pattern to ensure only one instance
/// is used throughout the application, managing various API calls
/// (HTTP requests) and platform-specific functionalities (like SMS).
class AppApiService {
  // --- Singleton Setup ---
  static final AppApiService _instance = AppApiService._internal();
  factory AppApiService() {
    return _instance;
  }
  AppApiService._internal();
  // --- End Singleton Setup ---

  // Logger for this consolidated service
  static final Logger _log = Logger('AppApiService');

  // --- API Base URLs and Paths ---
  // CONSOLIDATED AND CORRECTED BASE URL FOR ALL API CALLS
  static const String _apiBaseUrl = 'https://sarsatiya.store/XJAAM1-0.0.1-SNAPSHOT';

  // Paths relative to the new _apiBaseUrl
  static const String _assetUploadPath = '/assets/UpdateorCreateAsset';
  static const String _allAssetDetailsPath = '/assets/GetAllAssetDetails';
  static const String _openStatusAssetsPath = '/assets/GetOpenStatusAssets';
  static const String _closedStatusAssetsPath = '/assets/GetClosedStatusAssets';
  static const String _inProgressStatusAssetsPath = '/assets/GetInProgressStatusAssets';
  static const String _completedStatusAssetsPath = '/assets/GetCompletedStatusAssets';

  // --- Image Base URL for fetching images ---
  static const String _imageBaseUrl = 'https://sarsatiya.store/images/'; // Placeholder, adjust as needed.

  // Helper to construct full image URLs from relative paths
  static String getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    final cleanedPath = relativePath.replaceAll('/opt/apache/webapps/images/', '');
    return '$_imageBaseUrl$cleanedPath';
  }

  // --- Method Channel for SMS ---
  static const MethodChannel _smsMethodChannel = MethodChannel('com.ferrero.asset_management/sms');

  /// Uploads data and images as a multipart request to the asset management backend.
  ///
  /// Requires a [DataProvider] instance containing the data and image paths,
  /// and a [bearerToken] for authorization.
  /// Returns a [Map<String, dynamic>] indicating success/failure and a message.
  Future<Map<String, dynamic>> uploadDataWithJsonAndImages({
    required DataProvider dataProvider,
    required String? bearerToken,
  }) async {
    _log.fine("uploadDataWithJsonAndImages called. Token received: ${bearerToken != null && bearerToken.isNotEmpty ? "Present" : "MISSING/EMPTY"}");

    if (bearerToken == null || bearerToken.isEmpty) {
      _log.severe("Bearer token is null or empty in AppApiService.uploadDataWithJsonAndImages.");
      return {'success': false, 'message': 'Authentication token is missing.'};
    }

    try {
      final Uri uploadUri = Uri.parse('$_apiBaseUrl$_assetUploadPath');
      var request = http.MultipartRequest('POST', uploadUri);

      request.headers['Authorization'] = 'Bearer $bearerToken';

      // --- CONSTRUCT JSON DATA IN THE EXACT REQUESTED FORMAT FROM POSTMAN ---
      Map<String, dynamic> jsonDataMap = {
        'vcType': dataProvider.vcType ?? '',
        'vcSerialNo': dataProvider.vcSerialNo ?? '',
        'uoc': dataProvider.uoc ?? '',
        'outletName': dataProvider.outletNameFromConsentForm ?? '',
        'address': dataProvider.address ?? '',
        'state': dataProvider.state ?? '',
        'postalCode': dataProvider.postalCode ?? '',
        'contactPerson': dataProvider.contactPerson ?? '',
        'mobileNumber': dataProvider.mobileNumberFromConsentForm ?? '',
        'status': 'completed',
        'latitude': null, // Initialize as null, will be updated if location exists
        'longitude': null, // Initialize as null, will be updated if location exists
        'outletExteriorsPhoto': '', // Default to empty string
        'assetPics': '',
        'outletOwnerIdsPics': '',
        'outletOwnerPic': '',
        'serialNoPic': '',
        // Removed mobfield, createDate, updateDate, firstName, lastName
        // as they are NOT present in the working Postman cURL JSON.
      };

      final capturedLocationString = dataProvider.capturedLocation;
      if (capturedLocationString != null && capturedLocationString.isNotEmpty) {
        final parts = capturedLocationString.split(', ');
        if (parts.length == 2) {
          jsonDataMap['latitude'] = parts[0].replaceFirst('Lat: ', '');
          jsonDataMap['longitude'] = parts[1].replaceFirst('Lng: ', '');
        } else {
          _log.warning('Unexpected location string format: $capturedLocationString');
        }
      }

      final String? vcSerialNo = dataProvider.vcSerialNo;

      List<Map<String, String>> loggedImageFiles = [];

      // --- UPDATED: Mapping from DataProvider keys to snake_case JSON keys for image PARTS ---
      // These are the field names for the actual file parts in the multipart request
      final Map<String, String> imagePartFieldNames = {
        'outlet_exteriors_photo': 'outlet_exteriors_photo', // Matches Postman cURL
        'asset_pics': 'asset_pics', // Matches Postman cURL
        'outlet_owner_ids_pics': 'outlet_owner_ids_pics', // Matches Postman cURL
        'outlet_owner_pic': 'outlet_owner_pic', // Matches Postman cURL
        'serial_no_pic': 'serial_no_pic', // Matches Postman cURL
      };

      // Define a mapping from DataProvider keys to camelCase JSON keys for image FILENAMES within the JSON payload
      // These are the keys for the 'outletExteriorsPhoto', 'assetPics', etc. fields inside the JSON string
      final Map<String, String> jsonImageFilenameKeys = {
        'outlet_exteriors_photo': 'outletExteriorsPhoto',
        'asset_pics': 'assetPics',
        'outlet_owner_ids_pics': 'outletOwnerIdsPics',
        'outlet_owner_pic': 'outletOwnerPic',
        'serial_no_pic': 'serialNoPic',
      };

      for (var entry in dataProvider.allCapturedImages.entries) {
        final String dataProviderKey = entry.key; // e.g., 'outlet_exteriors_photo'
        final String? imagePath = entry.value;

        // Get the field name for the multipart file part (snake_case from Postman)
        final String? multipartFieldName = imagePartFieldNames[dataProviderKey];
        // Get the key for the JSON payload (camelCase as per your JSON structure)
        final String? jsonKeyForFilename = jsonImageFilenameKeys[dataProviderKey];


        if (imagePath != null && imagePath.isNotEmpty && multipartFieldName != null && jsonKeyForFilename != null) {
          File imageFile = File(imagePath);
          if (await imageFile.exists()) {
            String fileExtension = p.extension(imageFile.path);
            String desiredFilename = '${jsonKeyForFilename}_${vcSerialNo ?? 'unknown_vc_no'}${fileExtension}';

            // Update the JSON data with the filename
            jsonDataMap[jsonKeyForFilename] = desiredFilename;

            var multipartFile = await http.MultipartFile.fromPath(
              multipartFieldName, // Use the snake_case field name for the file part
              imagePath,
              filename: desiredFilename,
            );
            request.files.add(multipartFile);

            loggedImageFiles.add({
              'Field': multipartFile.field,
              'Filename': multipartFile.filename!,
              'Length': multipartFile.length.toString(),
              'ContentType': multipartFile.contentType.toString(),
            });
          } else {
            _log.warning('Image file not found for type "$dataProviderKey": $imagePath');
            jsonDataMap[jsonKeyForFilename] = ''; // Ensure it's an empty string if file not found
          }
        } else if (jsonKeyForFilename != null) {
          jsonDataMap[jsonKeyForFilename] = ''; // Ensure it's an empty string if imagePath is null/empty
        }
      }

      final String jsonPayloadString = JsonEncoder.withIndent('  ').convert(jsonDataMap);
      _log.info('Final JSON Payload String Length: ${jsonPayloadString.length} characters.');
      print('DEBUG: Full JSON Payload String:\n$jsonPayloadString');

      // --- CRITICAL FIX: Send JSON as a MultipartFile.fromString with field name 'json' ---
      request.files.add(http.MultipartFile.fromString(
        'json', // <--- CHANGED THIS TO 'json' as per Postman cURL
        jsonPayloadString,
        contentType: MediaType('application', 'json'),
      ));

      String combinedLogMessage = 'Uploading data with JSON and Images to $uploadUri...\n';
      combinedLogMessage += 'Headers: ${request.headers}\n';
      combinedLogMessage += 'JSON data (includes image filenames/empty strings):\n$jsonPayloadString\n';

      combinedLogMessage += 'Files to be uploaded as multipart parts:\n';
      if (loggedImageFiles.isNotEmpty) {
        for (var fileData in loggedImageFiles) {
          combinedLogMessage += '  - Field: ${fileData['Field']}, Filename: ${fileData['Filename']}, Length: ${fileData['Length']}, ContentType: ${fileData['ContentType']}\n';
        }
      } else {
        combinedLogMessage += '  No image files selected for upload.\n';
      }

      _log.info(combinedLogMessage);

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      _log.info('Upload Response Status: ${response.statusCode}');
      _log.fine('Upload Response Body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Data and images uploaded successfully!', 'body': responseBody};
      } else {
        _log.severe('Upload failed. Status: ${response.statusCode}, Body: ${responseBody}');
        return {'success': false, 'message': 'Upload failed. Status: ${response.statusCode}', 'body': responseBody};
      }
    } catch (e, stackTrace) {
      _log.severe('An error occurred during upload', e, stackTrace);
      return {'success': false, 'message': 'An error occurred: ${e.toString()}'};
    }
  }

  Future<bool> checkSmsPermission() async {
    _log.info('Checking SMS permission via MethodChannel.');
    try {
      final bool hasPermission = await _smsMethodChannel.invokeMethod('checkSmsPermission');
      _log.info('SMS permission status: $hasPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      _log.severe("Failed to check SMS permission: '${e.message}'.", e);
      return false;
    }
  }

  Future<bool> sendSms(String phoneNumber, String message) async {
    _log.info('Attempting to send SMS to $phoneNumber via MethodChannel.');
    try {
      final bool success = await _smsMethodChannel.invokeMethod(
        'sendSms',
        <String, dynamic>{
          'phoneNumber': phoneNumber,
          'message': message,
        },
      );
      _log.info('SMS sent success status: $success');
      return success;
    } on PlatformException catch (e) {
      _log.severe("Failed to send SMS to $phoneNumber: '${e.message}'.", e);
      return false;
    }
  }

  Future<List<AssetDetails>> _fetchAssets(String path, String bearerToken, String endpointName) async {
    _log.info('Attempting to fetch $endpointName assets from: $_apiBaseUrl$path');
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );
      _log.info('Received HTTP response for $endpointName assets with status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        _log.fine('Raw response body for $endpointName assets: ${response.body}');
        final List<dynamic> jsonList = jsonDecode(response.body);

        final List<AssetDetails> assetsData = jsonList.map((json) {
          try {
            return AssetDetails.fromJson(json as Map<String, dynamic>);
          } catch (e, st) {
            _log.severe('Error parsing an $endpointName asset item: $json', e, st);
            return null;
          }
        }).whereType<AssetDetails>().toList();

        _log.info('Successfully fetched and parsed ${assetsData.length} $endpointName assets.');
        return assetsData;
      } else {
        _log.warning('Failed to fetch $endpointName assets. Status code: ${response.statusCode}, Body: ${response.body}');
        if (response.statusCode == 401) {
          throw Exception('Authentication failed for $endpointName assets. Please ensure the token is valid.');
        } else if (response.statusCode == 403) {
          throw Exception('Authorization denied for $endpointName assets.');
        } else {
          throw Exception('Failed to load $endpointName assets: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e, stackTrace) {
      _log.severe('Error fetching $endpointName assets: $e', e, stackTrace);
      throw Exception('Failed to connect to API for $endpointName assets: $e');
    }
  }

  Future<List<AssetDetails>> fetchAllAssetDetails({required String bearerToken}) {
    return _fetchAssets(_allAssetDetailsPath, bearerToken, 'all asset details');
  }

  Future<List<AssetDetails>> fetchOpenStatusAssets({required String bearerToken}) {
    return _fetchAssets(_openStatusAssetsPath, bearerToken, 'open status');
  }

  Future<List<AssetDetails>> fetchClosedStatusAssets({required String bearerToken}) {
    return _fetchAssets(_closedStatusAssetsPath, bearerToken, 'closed status');
  }

  Future<List<AssetDetails>> fetchInProgressStatusAssets({required String bearerToken}) {
    return _fetchAssets(_inProgressStatusAssetsPath, bearerToken, 'in progress status');
  }

  Future<List<AssetDetails>> fetchCompletedStatusAssets({required String bearerToken}) {
    return _fetchAssets(_completedStatusAssetsPath, bearerToken, 'completed status');
  }
}
