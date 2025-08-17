//
// import 'package:flutter/foundation.dart';
// import 'package:logging/logging.dart'; // <--- ADDED: For logging
// import 'package:ferrero_asset_management/models/asset_details_model.dart'; // <--- ADDED: Import AssetDetails model
// import 'package:ferrero_asset_management/services/app_api_service.dart'; // <--- ADDED: Import AppApiService
//
// class DataProvider with ChangeNotifier {
//   static final Logger _log = Logger('DataProvider'); // <--- ADDED: Logger
//
//   String? _uoc;
//   String? _outletNameFromConsentForm;
//   String? _address;
//   String? _vcType;
//   String? _vcSerialNo;
//   String? _contactPerson;
//   String? _mobileNumberFromConsentForm; // To distinguish from outletOwnerNumber used for OTP
//   String? _state;
//   String? _postalCode;
//   String? _username;
//
//   // --- Asset Capture Data ---
//   Map<String, String?> _capturedImagesMap = {};
//   String? _capturedLocationString;
//
//   // --- Authentication Data ---
//   String? _bearerToken; // <--- ADDED: Bearer Token property
//
//   // --- Asset Details Data ---
//   List<AssetDetails> _allAssets = []; // <--- ADDED: List for all assets
//   List<AssetDetails> _openAssets = []; // <--- ADDED: List for open assets
//   List<AssetDetails> _closedAssets = []; // <--- ADDED: List for closed assets
//   List<AssetDetails> _inProgressAssets = []; // <--- ADDED: List for in progress assets
//   List<AssetDetails> _completedAssets = []; // <--- ADDED: List for completed assets
//
//
//   // --- Getters for Consent Form Data ---
//   String? get uoc => _uoc;
//   String? get outletNameFromConsentForm => _outletNameFromConsentForm;
//   String? get address => _address;
//   String? get vcType => _vcType;
//   String? get vcSerialNo => _vcSerialNo;
//   String? get contactPerson => _contactPerson;
//   String? get mobileNumberFromConsentForm => _mobileNumberFromConsentForm;
//   String? get state => _state;
//   String? get postalCode => _postalCode;
//   String? get username => _username;
//
//   // --- Getters for Asset Capture Data ---
//   Map<String, String?> get allCapturedImages => Map.unmodifiable(_capturedImagesMap);
//   String? get capturedLocation => _capturedLocationString;
//
//   // --- Getter for Authentication Data ---
//   String? get bearerToken => _bearerToken; // <--- ADDED: Bearer Token getter
//
//   // --- Getters for Asset Details Data ---
//   List<AssetDetails> get allAssets => _allAssets; // <--- ADDED: All Assets getter
//   List<AssetDetails> get openAssets => _openAssets; // <--- ADDED: Open Assets getter
//   List<AssetDetails> get closedAssets => _closedAssets; // <--- ADDED: Closed Assets getter
//   List<AssetDetails> get inProgressAssets => _inProgressAssets; // <--- ADDED: In Progress Assets getter
//   List<AssetDetails> get completedAssets => _completedAssets; // <--- ADDED: Completed Assets getter
//
//
//   // --- Methods to update data (as seen in ConsentFormPage) ---
//   void updateString(String key, String? value) {
//     bool changed = false;
//     switch (key) {
//       case 'UOC':
//         if (_uoc != value) { _uoc = value; changed = true; }
//         break;
//       case 'OUTLET_NAME': // This is the name from the form, potentially editable
//         if (_outletNameFromConsentForm != value) { _outletNameFromConsentForm = value; changed = true; }
//         break;
//       case 'Address':
//         if (_address != value) { _address = value; changed = true; }
//         break;
//       case 'VC Type':
//         if (_vcType != value) { _vcType = value; changed = true; }
//         break;
//       case 'VC Serial No':
//         if (_vcSerialNo != value) { _vcSerialNo = value; changed = true; }
//         break;
//       case 'Contact_Person':
//         if (_contactPerson != value) { _contactPerson = value; changed = true; }
//         break;
//       case 'Mobile Number': // Mobile number from the consent form fields
//         if (_mobileNumberFromConsentForm != value) { _mobileNumberFromConsentForm = value; changed = true; }
//         break;
//       case 'State':
//         if (_state != value) { _state = value; changed = true; }
//         break;
//       case 'Postal Code':
//         if (_postalCode != value) { _postalCode = value; changed = true; }
//         break;
//       case 'USERNAME': // If you pass username to updateString
//         if (_username != value) { _username = value; changed = true; }
//         break;
//       default:
//         _log.warning("DataProvider: Unknown key for updateString: $key");
//     }
//     if (changed) {
//       notifyListeners(); // Decide if individual updates should notify or if you'll do it in bulk
//     }
//   }
//
//   // Sets or updates the entire map of captured image paths.
//   void addImages(Map<String, String?> imagePathsMap) {
//     _capturedImagesMap.addAll(imagePathsMap);
//     _log.info("DataProvider: Updated captured images map. Current map: $_capturedImagesMap");
//     // notifyListeners(); // Notify if UI needs to react to this change immediately
//   }
//
//   /// Sets or updates the captured location string.
//   void setLocation(String? locationString) {
//     if (_capturedLocationString != locationString) {
//       _capturedLocationString = locationString;
//       _log.info("DataProvider: Updated captured location: $_capturedLocationString");
//       // notifyListeners(); // Notify if UI needs to react to this change immediately
//     }
//   }
//
//   /// Sets or updates the username.
//   void setUsername(String? newUsername) {
//     if (_username != newUsername) {
//       _username = newUsername;
//       _log.info("DataProvider: Updated username: $_username");
//       // notifyListeners();
//     }
//   }
//
//   // <--- ADDED: Method to set the Bearer Token ---
//   void setBearerToken(String? token) {
//     if (_bearerToken != token) {
//       _bearerToken = token;
//       _log.info("DataProvider: Bearer token updated.");
//       notifyListeners(); // Notify listeners as token change might affect authentication status
//     }
//   }
//
//   // --- Methods to fetch and set asset lists ---
//
//   Future<void> fetchAndSetAllAssets() async {
//     if (_bearerToken == null) {
//       _log.warning('Bearer token is null, cannot fetch all assets.');
//       _allAssets = []; // Clear list if no token
//       notifyListeners();
//       return;
//     }
//     _log.info('DataProvider: Fetching all assets...');
//     _allAssets = await AppApiService().fetchAllAssetDetails(bearerToken: _bearerToken!);
//     _log.info('DataProvider: Fetched ${_allAssets.length} all assets.');
//     notifyListeners();
//   }
//
//   Future<void> fetchAndSetOpenAssets() async {
//     if (_bearerToken == null) {
//       _log.warning('Bearer token is null, cannot fetch open assets.');
//       _openAssets = []; // Clear list if no token
//       notifyListeners();
//       return;
//     }
//     _log.info('DataProvider: Fetching open assets...');
//     _openAssets = await AppApiService().fetchOpenStatusAssets(bearerToken: _bearerToken!);
//     _log.info('DataProvider: Fetched ${_openAssets.length} open assets.');
//     notifyListeners();
//   }
//
//   Future<void> fetchAndSetClosedAssets() async {
//     if (_bearerToken == null) {
//       _log.warning('Bearer token is null, cannot fetch closed assets.');
//       _closedAssets = []; // Clear list if no token
//       notifyListeners();
//       return;
//     }
//     _log.info('DataProvider: Fetching closed assets...');
//     _closedAssets = await AppApiService().fetchClosedStatusAssets(bearerToken: _bearerToken!);
//     _log.info('DataProvider: Fetched ${_closedAssets.length} closed assets.');
//     notifyListeners();
//   }
//
//   Future<void> fetchAndSetInProgressAssets() async {
//     if (_bearerToken == null) {
//       _log.warning('Bearer token is null, cannot fetch in progress assets.');
//       _inProgressAssets = []; // Clear list if no token
//       notifyListeners();
//       return;
//     }
//     _log.info('DataProvider: Fetching in progress assets...');
//     _inProgressAssets = await AppApiService().fetchInProgressStatusAssets(bearerToken: _bearerToken!);
//     _log.info('DataProvider: Fetched ${_inProgressAssets.length} in progress assets.');
//     notifyListeners();
//   }
//
//   Future<void> fetchAndSetCompletedAssets() async {
//     if (_bearerToken == null) {
//       _log.warning('Bearer token is null, cannot fetch completed assets.');
//       _completedAssets = []; // Clear list if no token
//       notifyListeners();
//       return;
//     }
//     _log.info('DataProvider: Fetching completed assets...');
//     _completedAssets = await AppApiService().fetchCompletedStatusAssets(bearerToken: _bearerToken!);
//     _log.info('DataProvider: Fetched ${_completedAssets.length} completed assets.');
//     notifyListeners();
//   }
//
//   /// You might want a single method to refresh all relevant lists if needed in certain screens.
//   Future<void> refreshAllAssetLists() async {
//     _log.info('DataProvider: Refreshing all asset lists.');
//     await fetchAndSetAllAssets();
//     await fetchAndSetOpenAssets();
//     await fetchAndSetClosedAssets();
//     await fetchAndSetInProgressAssets();
//     await fetchAndSetCompletedAssets();
//     // No notifyListeners here, as individual fetchAndSet methods already call it.
//   }
//
//   // --- Utility Methods ---
//
//   /// Call this after a series of updates if you deferred notifyListeners.
//   void finalizeAllUpdates() {
//     notifyListeners();
//   }
//
//   /// Clears all data in the provider. Useful for starting a new submission or on logout.
//   void clearAllData() {
//     _uoc = null;
//     _outletNameFromConsentForm = null;
//     _address = null;
//     _vcType = null;
//     _vcSerialNo = null;
//     _contactPerson = null;
//     _mobileNumberFromConsentForm = null;
//     _state = null;
//     _postalCode = null;
//     _username = null;
//
//     _capturedImagesMap.clear();
//     _capturedLocationString = null;
//
//     _bearerToken = null; // <--- ADDED: Clear token on logout
//     _allAssets = []; // <--- ADDED: Clear asset lists
//     _openAssets = [];
//     _closedAssets = [];
//     _inProgressAssets = [];
//     _completedAssets = [];
//
//     _log.info("DataProvider: All data cleared.");
//     notifyListeners();
//   }
// }

// lib/provider/data_provider.dart
// import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
// import 'package:logging/logging.dart'; // For logging
// import 'package:ferrero_asset_management/models/asset_details_model.dart'; // Import AssetDetails model
// import 'package:ferrero_asset_management/services/app_api_service.dart'; // Import AppApiService
//
// class DataProvider with ChangeNotifier {
//   static final Logger _log = Logger('DataProvider');
//
//   // --- Consent Form & Asset Upload Data ---
//   String? _uoc;
//   String? _outletNameFromConsentForm; // Outlet name as collected from the consent form
//   String? _address;
//   String? _vcType;
//   String? _vcSerialNo;
//   String? _contactPerson;
//   String? _mobileNumberFromConsentForm; // Mobile number collected from the consent form
//   String? _state;
//   String? _postalCode;
//   String? _username; // User who is filling the form
//
//   Map<String, String?> _capturedImagesMap = {}; // Map of image categories to file paths
//   String? _capturedLocationString; // Captured location string
//
//   // --- Authentication Data ---
//   String? _bearerToken; // Bearer Token for API authentication
//
//   // --- Asset Details Data (Fetched from API) ---
//   List<AssetDetails> _allAssets = []; // All assets regardless of status
//   List<AssetDetails> _openAssets = []; // Assets with 'Open' status
//   List<AssetDetails> _closedAssets = []; // Assets with 'Closed' status
//   List<AssetDetails> _inProgressAssets = []; // Assets with 'In Progress' status
//   List<AssetDetails> _completedAssets = []; // Assets with 'Completed' status
//
//
//   // --- Getters for Consent Form & Asset Upload Data ---
//   String? get uoc => _uoc;
//   String? get outletNameFromConsentForm => _outletNameFromConsentForm;
//   String? get address => _address;
//   String? get vcType => _vcType;
//   String? get vcSerialNo => _vcSerialNo;
//   String? get contactPerson => _contactPerson;
//   String? get mobileNumberFromConsentForm => _mobileNumberFromConsentForm;
//   String? get state => _state;
//   String? get postalCode => _postalCode;
//   String? get username => _username;
//   Map<String, String?> get allCapturedImages => Map.unmodifiable(_capturedImagesMap);
//   String? get capturedLocation => _capturedLocationString;
//
//   // --- Getter for Authentication Data ---
//   String? get bearerToken => _bearerToken;
//
//   // --- Getters for Asset Details Data (Immutable lists) ---
//   List<AssetDetails> get allAssets => List.unmodifiable(_allAssets);
//   List<AssetDetails> get openAssets => List.unmodifiable(_openAssets);
//   List<AssetDetails> get closedAssets => List.unmodifiable(_closedAssets);
//   List<AssetDetails> get inProgressAssets => List.unmodifiable(_inProgressAssets);
//   List<AssetDetails> get completedAssets => List.unmodifiable(_completedAssets);
//
//
//   // --- Methods to update Consent Form & Asset Upload Data ---
//
//   /// Updates string values based on a given key.
//   /// Use this for fields managed through a generic update mechanism (e.g., forms).
//   void updateString(String key, String? value) {
//     bool changed = false;
//     switch (key) {
//       case 'UOC':
//         if (_uoc != value) { _uoc = value; changed = true; }
//         break;
//       case 'OUTLET_NAME':
//         if (_outletNameFromConsentForm != value) { _outletNameFromConsentForm = value; changed = true; }
//         break;
//       case 'Address':
//         if (_address != value) { _address = value; changed = true; }
//         break;
//       case 'VC Type':
//         if (_vcType != value) { _vcType = value; changed = true; }
//         break;
//       case 'VC Serial No':
//         if (_vcSerialNo != value) { _vcSerialNo = value; changed = true; }
//         break;
//       case 'Contact_Person':
//         if (_contactPerson != value) { _contactPerson = value; changed = true; }
//         break;
//       case 'Mobile Number':
//         if (_mobileNumberFromConsentForm != value) { _mobileNumberFromConsentForm = value; changed = true; }
//         break;
//       case 'State':
//         if (_state != value) { _state = value; changed = true; }
//         break;
//       case 'Postal Code':
//         if (_postalCode != value) { _postalCode = value; changed = true; }
//         break;
//       case 'USERNAME':
//         if (_username != value) { _username = value; changed = true; }
//         break;
//       default:
//         _log.warning("DataProvider: Unknown key for updateString: $key. Value: $value");
//     }
//     if (changed) {
//       notifyListeners(); // Notify listeners if any data changed
//     }
//   }
//
//   /// Adds or updates captured image paths.
//   void addImages(Map<String, String?> imagePathsMap) {
//     _capturedImagesMap.addAll(imagePathsMap);
//     _log.info("DataProvider: Updated captured images map. Current count: ${_capturedImagesMap.length}");
//     notifyListeners(); // Notify listeners immediately
//   }
//
//   /// Sets or updates the captured location string.
//   void setLocation(String? locationString) {
//     if (_capturedLocationString != locationString) {
//       _capturedLocationString = locationString;
//       _log.info("DataProvider: Updated captured location: $_capturedLocationString");
//       notifyListeners(); // Notify listeners immediately
//     }
//   }
//
//   /// Sets or updates the username.
//   void setUsername(String? newUsername) {
//     if (_username != newUsername) {
//       _username = newUsername;
//       _log.info("DataProvider: Updated username: $_username");
//       notifyListeners(); // Notify listeners immediately
//     }
//   }
//
//   // --- Method to set the Bearer Token ---
//
//   /// Sets the authentication bearer token.
//   void setBearerToken(String? token) {
//     if (_bearerToken != token) {
//       _bearerToken = token;
//       _log.info("DataProvider: Bearer token updated (hash: ${token?.hashCode})."); // Log hash, not full token
//       notifyListeners(); // Notify listeners as token change might affect authentication status
//     }
//   }
//
//   // --- Methods to fetch and set asset lists ---
//
//   /// Fetches all asset details from the API and updates the _allAssets list.
//   Future<void> fetchAndSetAllAssets() async {
//     if (_bearerToken == null || _bearerToken!.isEmpty) {
//       _log.warning('Bearer token is null or empty, cannot fetch all assets. Clearing current list.');
//       _allAssets = []; // Clear list if no token
//       notifyListeners();
//       return;
//     }
//     _log.info('DataProvider: Fetching all assets...');
//     try {
//       _allAssets = await AppApiService().fetchAllAssetDetails(bearerToken: _bearerToken!);
//       _log.info('DataProvider: Fetched ${_allAssets.length} all assets successfully.');
//     } catch (e, s) {
//       _log.severe('DataProvider: Error fetching all assets: $e', e, s);
//       _allAssets = []; // Clear list on error to prevent displaying stale data
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   /// Fetches assets with 'Open' status and updates the _openAssets list.
//   Future<void> fetchAndSetOpenAssets() async {
//     if (_bearerToken == null || _bearerToken!.isEmpty) {
//       _log.warning('Bearer token is null or empty, cannot fetch open assets. Clearing current list.');
//       _openAssets = [];
//       notifyListeners();
//       return;
//     }
//     _log.info('DataProvider: Fetching open assets...');
//     try {
//       _openAssets = await AppApiService().fetchOpenStatusAssets(bearerToken: _bearerToken!);
//       _log.info('DataProvider: Fetched ${_openAssets.length} open assets successfully.');
//     } catch (e, s) {
//       _log.severe('DataProvider: Error fetching open assets: $e', e, s);
//       _openAssets = [];
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   /// Fetches assets with 'Closed' status and updates the _closedAssets list.
//   Future<void> fetchAndSetClosedAssets() async {
//     if (_bearerToken == null || _bearerToken!.isEmpty) {
//       _log.warning('Bearer token is null or empty, cannot fetch closed assets. Clearing current list.');
//       _closedAssets = [];
//       notifyListeners();
//       return;
//     }
//     _log.info('DataProvider: Fetching closed assets...');
//     try {
//       _closedAssets = await AppApiService().fetchClosedStatusAssets(bearerToken: _bearerToken!);
//       _log.info('DataProvider: Fetched ${_closedAssets.length} closed assets successfully.');
//     } catch (e, s) {
//       _log.severe('DataProvider: Error fetching closed assets: $e', e, s);
//       _closedAssets = [];
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   /// Fetches assets with 'In Progress' status and updates the _inProgressAssets list.
//   Future<void> fetchAndSetInProgressAssets() async {
//     if (_bearerToken == null || _bearerToken!.isEmpty) {
//       _log.warning('Bearer token is null or empty, cannot fetch in progress assets. Clearing current list.');
//       _inProgressAssets = [];
//       notifyListeners();
//       return;
//     }
//     _log.info('DataProvider: Fetching in progress assets...');
//     try {
//       _inProgressAssets = await AppApiService().fetchInProgressStatusAssets(bearerToken: _bearerToken!);
//       _log.info('DataProvider: Fetched ${_inProgressAssets.length} in progress assets successfully.');
//     } catch (e, s) {
//       _log.severe('DataProvider: Error fetching in progress assets: $e', e, s);
//       _inProgressAssets = [];
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   /// Fetches assets with 'Completed' status and updates the _completedAssets list.
//   Future<void> fetchAndSetCompletedAssets() async {
//     if (_bearerToken == null || _bearerToken!.isEmpty) {
//       _log.warning('Bearer token is null or empty, cannot fetch completed assets. Clearing current list.');
//       _completedAssets = [];
//       notifyListeners();
//       return;
//     }
//     _log.info('DataProvider: Fetching completed assets...');
//     try {
//       _completedAssets = await AppApiService().fetchCompletedStatusAssets(bearerToken: _bearerToken!);
//       _log.info('DataProvider: Fetched ${_completedAssets.length} completed assets successfully.');
//     } catch (e, s) {
//       _log.severe('DataProvider: Error fetching completed assets: $e', e, s);
//       _completedAssets = [];
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   /// Refreshes all relevant asset lists by calling their respective fetch methods.
//   /// Useful for screens that need to display various categories of assets.
//   Future<void> refreshAllAssetLists() async {
//     _log.info('DataProvider: Initiating refresh of all asset lists.');
//     // Await each fetch to ensure they complete before the overall refresh is considered done.
//     await fetchAndSetAllAssets();
//     await fetchAndSetOpenAssets();
//     await fetchAndSetClosedAssets();
//     await fetchAndSetInProgressAssets();
//     await fetchAndSetCompletedAssets();
//     // No notifyListeners here, as individual fetchAndSet methods already call it on completion/error.
//     _log.info('DataProvider: All asset lists refreshed.');
//   }
//
//   // --- Utility Methods ---
//
//   /// Triggers a notification to all listeners.
//   /// Use this if you have batched multiple state changes without calling
//   /// `notifyListeners()` after each one (e.g., inside a method that calls multiple setters).
//   void finalizeAllUpdates() {
//     _log.info("DataProvider: Finalizing all updates and notifying listeners.");
//     notifyListeners();
//   }
//
//   /// Clears all data stored in the provider.
//   /// This should be called on user logout or when starting a completely new data entry flow.
//   void clearAllData() {
//     _uoc = null;
//     _outletNameFromConsentForm = null;
//     _address = null;
//     _vcType = null;
//     _vcSerialNo = null;
//     _contactPerson = null;
//     _mobileNumberFromConsentForm = null;
//     _state = null;
//     _postalCode = null;
//     _username = null;
//
//     _capturedImagesMap.clear();
//     _capturedLocationString = null;
//
//     _bearerToken = null; // Clear token on logout
//     _allAssets = []; // Clear asset lists
//     _openAssets = [];
//     _closedAssets = [];
//     _inProgressAssets = [];
//     _completedAssets = [];
//
//     _log.info("DataProvider: All data cleared and listeners notified.");
//     notifyListeners(); // Notify that all data has been cleared
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:ferrero_asset_management/models/asset_details_model.dart';
import 'package:ferrero_asset_management/services/app_api_service.dart';

class DataProvider with ChangeNotifier {
  static final Logger _log = Logger('DataProvider');

  String? _uoc;
  String? _outletNameFromConsentForm;
  String? _address;
  String? _vcType;
  String? _vcSerialNo;
  String? _contactPerson;
  String? _mobileNumberFromConsentForm;
  String? _state;
  String? _postalCode;
  String? _username;
  String? _status; // ADDED: Dedicated field for asset status

  // --- Asset Capture Data ---
  Map<String, String?> _capturedImagesMap = {};
  String? _capturedLocationString;

  // --- Authentication Data ---
  String? _bearerToken;

  // --- Asset Details Data ---
  List<AssetDetails> _allAssets = [];
  List<AssetDetails> _openAssets = [];
  List<AssetDetails> _closedAssets = [];
  List<AssetDetails> _inProgressAssets = [];
  List<AssetDetails> _completedAssets = [];

  // --- Getters for Consent Form Data ---
  String? get uoc => _uoc;
  String? get outletNameFromConsentForm => _outletNameFromConsentForm;
  String? get address => _address;
  String? get vcType => _vcType;
  String? get vcSerialNo => _vcSerialNo;
  String? get contactPerson => _contactPerson;
  String? get mobileNumberFromConsentForm => _mobileNumberFromConsentForm;
  String? get state => _state;
  String? get postalCode => _postalCode;
  String? get username => _username;
  String? get currentStatus => _status; // UPDATED: Getter for the new status field

  // --- Getters for Asset Capture Data ---
  Map<String, String?> get allCapturedImages => Map.unmodifiable(_capturedImagesMap);
  String? get capturedLocation => _capturedLocationString;

  // --- Getter for Authentication Data ---
  String? get bearerToken => _bearerToken;

  // --- Getters for Asset Details Data ---
  List<AssetDetails> get allAssets => _allAssets;
  List<AssetDetails> get openAssets => _openAssets;
  List<AssetDetails> get closedAssets => _closedAssets;
  List<AssetDetails> get inProgressAssets => _inProgressAssets;
  List<AssetDetails> get completedAssets => _completedAssets;


  // --- Methods to update data ---

  // UPDATED: This method now handles form fields correctly
  void updateString(String key, String? value) {
    bool changed = false;
    switch (key) {
      case 'UOC':
        if (_uoc != value) { _uoc = value; changed = true; }
        break;
      case 'OUTLET_NAME':
        if (_outletNameFromConsentForm != value) { _outletNameFromConsentForm = value; changed = true; }
        break;
      case 'Address':
        if (_address != value) { _address = value; changed = true; }
        break;
      case 'VC Type':
        if (_vcType != value) { _vcType = value; changed = true; }
        break;
      case 'VC Serial No':
        if (_vcSerialNo != value) { _vcSerialNo = value; changed = true; }
        break;
      case 'Contact_Person':
        if (_contactPerson != value) { _contactPerson = value; changed = true; }
        break;
      case 'Mobile Number':
        if (_mobileNumberFromConsentForm != value) { _mobileNumberFromConsentForm = value; changed = true; }
        break;
      case 'State':
        if (_state != value) { _state = value; changed = true; }
        break;
      case 'Postal Code':
        if (_postalCode != value) { _postalCode = value; changed = true; }
        break;
      case 'USERNAME':
        if (_username != value) { _username = value; changed = true; }
        break;
      default:
        _log.warning("DataProvider: Unknown key for updateString: $key. Value not stored.");
    }
    if (changed) {
      notifyListeners();
    }
  }

  // ADDED: Dedicated method to update the status
  void updateStatus(String? newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _log.info("DataProvider: Status updated to: $_status");
      notifyListeners();
    }
  }

  void addImages(Map<String, String?> imagePathsMap) {
    _capturedImagesMap.addAll(imagePathsMap);
    _log.info("DataProvider: Updated captured images map. Current map: $_capturedImagesMap");
    // Removed notifyListeners() to avoid excessive rebuilds, can be called in finalizeAllUpdates()
  }

  void setLocation(String? locationString) {
    if (_capturedLocationString != locationString) {
      _capturedLocationString = locationString;
      _log.info("DataProvider: Updated captured location: $_capturedLocationString");
      // Removed notifyListeners()
    }
  }

  void setUsername(String? newUsername) {
    if (_username != newUsername) {
      _username = newUsername;
      _log.info("DataProvider: Updated username: $_username");
      // Removed notifyListeners()
    }
  }

  void setBearerToken(String? token) {
    if (_bearerToken != token) {
      _bearerToken = token;
      _log.info("DataProvider: Bearer token updated.");
      notifyListeners();
    }
  }

  // --- Methods to fetch and set asset lists ---
  Future<void> fetchAndSetAllAssets() async {
    if (_bearerToken == null) {
      _log.warning('Bearer token is null, cannot fetch all assets.');
      _allAssets = [];
      notifyListeners();
      return;
    }
    _log.info('DataProvider: Fetching all assets...');
    _allAssets = await AppApiService().fetchAllAssetDetails(bearerToken: _bearerToken!);
    _log.info('DataProvider: Fetched ${_allAssets.length} all assets.');
    notifyListeners();
  }

  Future<void> fetchAndSetOpenAssets() async {
    if (_bearerToken == null) {
      _log.warning('Bearer token is null, cannot fetch open assets.');
      _openAssets = [];
      notifyListeners();
      return;
    }
    _log.info('DataProvider: Fetching open assets...');
    _openAssets = await AppApiService().fetchOpenStatusAssets(bearerToken: _bearerToken!);
    _log.info('DataProvider: Fetched ${_openAssets.length} open assets.');
    notifyListeners();
  }

  Future<void> fetchAndSetClosedAssets() async {
    if (_bearerToken == null) {
      _log.warning('Bearer token is null, cannot fetch closed assets.');
      _closedAssets = [];
      notifyListeners();
      return;
    }
    _log.info('DataProvider: Fetching closed assets...');
    _closedAssets = await AppApiService().fetchClosedStatusAssets(bearerToken: _bearerToken!);
    _log.info('DataProvider: Fetched ${_closedAssets.length} closed assets.');
    notifyListeners();
  }

  Future<void> fetchAndSetInProgressAssets() async {
    if (_bearerToken == null) {
      _log.warning('Bearer token is null, cannot fetch in progress assets.');
      _inProgressAssets = [];
      notifyListeners();
      return;
    }
    _log.info('DataProvider: Fetching in progress assets...');
    _inProgressAssets = await AppApiService().fetchInProgressStatusAssets(bearerToken: _bearerToken!);
    _log.info('DataProvider: Fetched ${_inProgressAssets.length} in progress assets.');
    notifyListeners();
  }

  Future<void> fetchAndSetCompletedAssets() async {
    if (_bearerToken == null) {
      _log.warning('Bearer token is null, cannot fetch completed assets.');
      _completedAssets = [];
      notifyListeners();
      return;
    }
    _log.info('DataProvider: Fetching completed assets...');
    _completedAssets = await AppApiService().fetchCompletedStatusAssets(bearerToken: _bearerToken!);
    _log.info('DataProvider: Fetched ${_completedAssets.length} completed assets.');
    notifyListeners();
  }

  Future<void> refreshAllAssetLists() async {
    _log.info('DataProvider: Refreshing all asset lists.');
    await fetchAndSetAllAssets();
    await fetchAndSetOpenAssets();
    await fetchAndSetClosedAssets();
    await fetchAndSetInProgressAssets();
    await fetchAndSetCompletedAssets();
  }

  // --- Utility Methods ---
  void finalizeAllUpdates() {
    notifyListeners();
  }

  void clearAllData() {
    _uoc = null;
    _outletNameFromConsentForm = null;
    _address = null;
    _vcType = null;
    _vcSerialNo = null;
    _contactPerson = null;
    _mobileNumberFromConsentForm = null;
    _state = null;
    _postalCode = null;
    _username = null;
    _status = null; // ADDED: Clear the new status field

    _capturedImagesMap.clear();
    _capturedLocationString = null;

    _bearerToken = null;
    _allAssets = [];
    _openAssets = [];
    _closedAssets = [];
    _inProgressAssets = [];
    _completedAssets = [];

    _log.info("DataProvider: All data cleared.");
    notifyListeners();
  }
}
