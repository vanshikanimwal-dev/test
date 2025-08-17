//
// import 'package:flutter/material.dart';
// import 'package:ferrero_asset_management/models/asset_details_model.dart';
// import 'package:ferrero_asset_management/services/app_api_service.dart';
// import 'package:provider/provider.dart';
// import 'package:ferrero_asset_management/provider/data_provider.dart';
// import 'package:logging/logging.dart';
// import 'package:ferrero_asset_management/screens/shops/consent_form_page.dart';
//
// class SearchPage extends StatefulWidget {
//   final String username;
//
//   const SearchPage({super.key, required this.username  });
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//
//   // _assetsFuture is now mainly for initial loading state and RefreshIndicator
//   late Future<List<AssetDetails>> _assetsFuture; // Initialized in initState
//   List<AssetDetails> _allAssets = []; // Stores all fetched assets
//   List<AssetDetails> _filteredAssets = []; // Stores assets after search/filter
//   Set<String> _selectedStatuses = {}; // For status filtering
//   final List<String> _allPossibleStatuses = [
//     'completed',
//     'In Progress',
//     'Open',
//     'Closed',
//   ];
//
//   static final Logger _log = Logger('SearchPage');
//
//   String _fetchStatusMessage = 'Loading assets...'; // Status message for UI
//
//   @override
//   void initState() {
//     super.initState();
//     _log.info('SearchPage: initState - Initializing and calling _fetchAssets.');
//     _assetsFuture = Future.value([]); // Initialize with an empty future, will be updated.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchAssets(); // Trigger initial data fetch
//     });
//     _searchController.addListener(_filterAssets); // Listen for search input changes
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_filterAssets);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   /// Fetches all asset details from the API.
//   /// Handles authentication, data normalization, and updates UI state.
//   Future<void> _fetchAssets() async {
//     final dataProvider = Provider.of<DataProvider>(context, listen: false);
//     final bearerToken = dataProvider.bearerToken;
//
//     _log.info('SearchPage: _fetchAssets - Bearer Token Check: ${bearerToken != null && bearerToken.isNotEmpty ? "Present" : "MISSING/EMPTY"}');
//
//     if (bearerToken == null || bearerToken.isEmpty) {
//       _showDialog('Authentication Error', 'Bearer token missing. Please log in again.');
//       setState(() {
//         _allAssets = [];
//         _filteredAssets = [];
//         _fetchStatusMessage = 'Authentication required. No token.';
//         _assetsFuture = Future.value([]); // Resolve future with empty list if no token
//       });
//       _log.warning('SearchPage: _fetchAssets - Bearer token is null or empty. Cannot fetch assets.');
//       return;
//     }
//
//     setState(() {
//       _fetchStatusMessage = 'Fetching assets...';
//       _log.info('SearchPage: _fetchAssets - UI status set to "Fetching assets...".');
//     });
//
//     try {
//       final List<AssetDetails> assets = await AppApiService().fetchAllAssetDetails(bearerToken: bearerToken);
//       _log.info('SearchPage: _fetchAssets - API call successful. Received ${assets.length} raw assets.');
//
//       setState(() {
//         // Normalize status for all incoming assets
//         _allAssets = assets.map((asset) {
//           return AssetDetails(
//             vcType: asset.vcType,
//             vcSerialNo: asset.vcSerialNo,
//             uoc: asset.uoc,
//             outletName: asset.outletName,
//             address: asset.address,
//             state: asset.state,
//             postalCode: asset.postalCode,
//             contactPerson: asset.contactPerson,
//             mobileNumber: asset.mobileNumber,
//             status: _normalizeStatus(asset.status), // Apply normalization
//             latitude: asset.latitude,
//             longitude: asset.longitude,
//             outletExteriorsPhoto: asset.outletExteriorsPhoto,
//             assetPics: asset.assetPics,
//             outletOwnerIdsPics: asset.outletOwnerIdsPics,
//             outletOwnerPic: asset.outletOwnerPic,
//             serialNoPic: asset.serialNoPic,
//             mobfield: asset.mobfield,
//             createDate: asset.createDate,
//             updateDate: asset.updateDate,
//             firstName: asset.firstName,
//             lastName: asset.lastName,
//           );
//         }).toList();
//
//         _fetchStatusMessage = 'Fetched ${_allAssets.length} assets.';
//         _log.info('SearchPage: _fetchAssets - Successfully normalized and stored ${_allAssets.length} assets.');
//
//         _filterAssets(); // Apply current filters/search to the newly fetched assets
//         _log.info('SearchPage: _fetchAssets - _filteredAssets count after initial filter: ${_filteredAssets.length}');
//
//         // Crucial: Update _assetsFuture so RefreshIndicator and initial state are consistent
//         _assetsFuture = Future.value(_filteredAssets); // Resolve with the current filtered list
//       });
//
//       // Log details of the first few normalized assets for debugging
//       if (_allAssets.isNotEmpty) {
//         _log.info('SearchPage: _fetchAssets - First 3 normalized assets for debug:');
//         for (int i = 0; i < _allAssets.length && i < 3; i++) {
//           _log.info('  ${i + 1}. Outlet: ${_allAssets[i].outletName}, UOC: ${_allAssets[i].uoc}, Status: ${_allAssets[i].status}');
//         }
//       }
//
//     } catch (error, stackTrace) {
//       _log.severe('SearchPage: _fetchAssets - Error fetching assets: $error', error, stackTrace);
//       _showDialog('Error', 'Failed to load assets: ${error.toString().split(':')[0]}. Please try again.');
//       setState(() {
//         _allAssets = [];
//         _filteredAssets = [];
//         _assetsFuture = Future.error(error); // Set future to error state
//         _fetchStatusMessage = 'Error: ${error.toString().split(':')[0]}';
//       });
//     }
//   }
//
//   /// Normalizes status strings from the API to a consistent display format.
//   String _normalizeStatus(String status) {
//     switch (status.toLowerCase().replaceAll(' ', '_')) {
//       case 'in_progress':
//         return 'In Progress';
//       case 'completed':
//         return 'completed';
//       case 'open':
//         return 'Open';
//       case 'closed':
//         return 'Closed';
//       default:
//         _log.warning('SearchPage: _normalizeStatus - Unrecognized status: "$status"');
//         return status; // Return as is if not a recognized variation
//     }
//   }
//
//   /// Filters assets based on search query and selected statuses.
//   void _filterAssets() {
//     String query = _searchController.text.toLowerCase().trim();
//     _log.info('SearchPage: _filterAssets - Filtering with query: "$query", selected statuses: $_selectedStatuses');
//
//     setState(() {
//       _filteredAssets = _allAssets.where((asset) {
//         final matchesSearch = asset.outletName.toLowerCase().contains(query) ||
//             asset.uoc.toLowerCase().contains(query); // Search by UOC as well
//         final matchesStatus = _selectedStatuses.isEmpty || _selectedStatuses.contains(asset.status);
//         return matchesSearch && matchesStatus;
//       }).toList();
//       _log.info('SearchPage: _filterAssets - Resulting _filteredAssets count: ${_filteredAssets.length}');
//       // No need to set _assetsFuture here, as _filteredAssets is directly used by the ListView.
//     });
//   }
//
//   /// Toggles selected status filters and re-filters the assets.
//   void _toggleStatusFilter(String status) {
//     setState(() {
//       if (_selectedStatuses.contains(status)) {
//         _selectedStatuses.remove(status);
//       } else {
//         _selectedStatuses.add(status);
//       }
//       _log.info('SearchPage: _toggleStatusFilter - New selected statuses: $_selectedStatuses');
//       _filterAssets(); // Re-filter assets with new status selection
//       Navigator.pop(context); // Close the drawer after selection
//     });
//   }
//
//   /// Shows a standard AlertDialog.
//   void _showDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   /// Returns a color based on the asset status.
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'completed':
//         return Colors.green.shade700;
//       case 'in progress':
//         return Colors.orange.shade700;
//       case 'open':
//         return Colors.blue.shade700;
//       case 'closed':
//         return Colors.red.shade700;
//       default:
//         return Colors.grey.shade700;
//     }
//   }
//
//   /// A temporary function to test API connectivity and log asset details.
//   Future<void> _testApiCall() async {
//     _log.info('Test API Call: Initiated.');
//     final dataProvider = Provider.of<DataProvider>(context, listen: false);
//     final bearerToken = dataProvider.bearerToken;
//
//     if (bearerToken == null || bearerToken.isEmpty) {
//       _log.warning('Test API Call: Bearer token is missing. Cannot proceed with API test.');
//       _showDialog('API Test Warning', 'No authentication token available. Please ensure you are logged in.');
//       setState(() {
//         _fetchStatusMessage = 'API Test: No token.';
//       });
//       return;
//     }
//
//     _log.info('Test API Call: Bearer Token available: ${bearerToken.substring(0, 10)}...');
//     setState(() {
//       _fetchStatusMessage = 'Running API Test...';
//     });
//
//     try {
//       final List<AssetDetails> testAssets = await AppApiService().fetchAllAssetDetails(bearerToken: bearerToken);
//
//       final List<AssetDetails> normalizedTestAssets = testAssets.map((asset) {
//         return AssetDetails(
//           vcType: asset.vcType, vcSerialNo: asset.vcSerialNo, uoc: asset.uoc,
//           outletName: asset.outletName, address: asset.address, state: asset.state,
//           postalCode: asset.postalCode, contactPerson: asset.contactPerson,
//           mobileNumber: asset.mobileNumber, status: _normalizeStatus(asset.status),
//           latitude: asset.latitude, longitude: asset.longitude,
//           outletExteriorsPhoto: asset.outletExteriorsPhoto, assetPics: asset.assetPics,
//           outletOwnerIdsPics: asset.outletOwnerIdsPics, outletOwnerPic: asset.outletOwnerPic,
//           serialNoPic: asset.serialNoPic, mobfield: asset.mobfield,
//           createDate: asset.createDate, updateDate: asset.updateDate,
//           firstName: asset.firstName, lastName: asset.lastName,
//         );
//       }).toList();
//
//       _log.info('Test API Call: Successfully received ${normalizedTestAssets.length} assets.');
//       setState(() {
//         _fetchStatusMessage = 'API Test: Fetched ${normalizedTestAssets.length} assets.';
//       });
//
//       if (normalizedTestAssets.isNotEmpty) {
//         _log.info('Test API Call: First 5 normalized assets for debug:');
//         for (int i = 0; i < normalizedTestAssets.length && i < 5; i++) {
//           _log.info('  ${i + 1}. Outlet: ${normalizedTestAssets[i].outletName}, UOC: ${normalizedTestAssets[i].uoc}, Status: ${normalizedTestAssets[i].status}');
//         }
//       } else {
//         _log.info('Test API Call: API returned an empty list of assets.');
//       }
//       _showDialog('API Test Result', 'Successfully fetched ${normalizedTestAssets.length} assets. Check Logcat for details.');
//
//     } catch (e, stackTrace) {
//       _log.severe('Test API Call: Error during API test: $e', e, stackTrace);
//       _showDialog('API Test Error', 'An error occurred during API call. Check Logcat. Error: ${e.toString().split(':')[0]}');
//       setState(() {
//         _fetchStatusMessage = 'API Test: Error: ${e.toString().split(':')[0]}';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _log.info('SearchPage: build method entered.');
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAF6EF),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFAF6EF),
//         elevation: 0,
//         leading: Builder(
//           builder: (BuildContext context) {
//             return IconButton(
//               icon: const Icon(Icons.menu, color: Colors.brown),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             );
//           },
//         ),
//         centerTitle: true,
//       ),
//       drawer: Drawer(
//         backgroundColor: const Color(0xFFFAF6EF),
//         child: Column( // Correctly defined children here
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.brown,
//               ),
//               child: Container(
//                 alignment: Alignment.centerLeft,
//                 child: const Text(
//                   'Filter by Status',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: _allPossibleStatuses.map((status) {
//                   return CheckboxListTile(
//                     title: Text(status),
//                     value: _selectedStatuses.contains(status),
//                     onChanged: (bool? value) {
//                       if (value != null) {
//                         _toggleStatusFilter(status); // Use the new toggle method
//                       }
//                     },
//                     activeColor: Colors.brown,
//                     checkColor: Colors.white,
//                   );
//                 }).toList(),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedStatuses.clear();
//                     _filterAssets();
//                   });
//                   Navigator.pop(context); // Close drawer after clearing filters
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red.shade700,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 40),
//                 ),
//                 child: const Text('Clear Filters'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     image: const DecorationImage(
//                       image: AssetImage('assets/rect1.png'),
//                       fit: BoxFit.cover,
//                       repeat: ImageRepeat.repeat,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     style: const TextStyle(color: Colors.white, fontSize: 18),
//                     decoration: const InputDecoration(
//                       hintText: 'Search by Outlet Name or UOC', // Updated hint
//                       hintStyle: TextStyle(color: Colors.white70, fontSize: 18),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       prefixIcon: Icon(Icons.search, color: Colors.white70),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _testApiCall,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueGrey,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                     ),
//                     child: const Text('Run API Test'),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Center(
//                   child: Text(
//                     _fetchStatusMessage,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: _fetchStatusMessage.contains('Error') ? Colors.red : Colors.brown,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             // Removed FutureBuilder here, direct management of _filteredAssets
//             child: RefreshIndicator(
//               onRefresh: _fetchAssets, // Allows pulling down to refresh data
//               child: _filteredAssets.isEmpty && !_fetchStatusMessage.contains('Loading') && !_fetchStatusMessage.contains('Fetching')
//                   ? ListView( // Display message when no results/data
//                 children: [
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.4, // Occupy some space
//                     child: Center(
//                       child: Text(
//                         _fetchStatusMessage.contains('Error')
//                             ? _fetchStatusMessage
//                             : (_searchController.text.isNotEmpty || _selectedStatuses.isNotEmpty
//                             ? 'No assets match your search/filters.'
//                             : 'No assets found. Pull down to refresh.'),
//                         style: const TextStyle(fontSize: 16, color: Colors.grey),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//                   : ListView.builder( // Display the list if data exists
//                 padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//                 itemCount: _filteredAssets.length,
//                 itemBuilder: (context, index) {
//                   final AssetDetails asset = _filteredAssets[index];
//                   Color? statusColor = _getStatusColor(asset.status);
//
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ConsentFormPage(
//                               assetDetails: asset,
//                               username: widget.username,
//                             ),
//                           ),
//                         ).then((_) => _fetchAssets()); // Refresh when returning from detail page
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     '${index + 1}. ${asset.outletName}',
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.brown,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                 ),
//                                 Text(
//                                   asset.status.toUpperCase(), // Display normalized status
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     color: statusColor,
//                                   ),
//                                   textAlign: TextAlign.right,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'UOC: ${asset.uoc}', // Display UOC
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.normal,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:ferrero_asset_management/models/asset_details_model.dart';
// import 'package:ferrero_asset_management/services/app_api_service.dart';
// import 'package:provider/provider.dart';
// import 'package:ferrero_asset_management/provider/data_provider.dart';
// import 'package:logging/logging.dart';
// import 'package:ferrero_asset_management/screens/shops/consent_form_page.dart';
//
// class SearchPage extends StatefulWidget {
//   final String username;
//
//   const SearchPage({super.key, required this.username});
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//
//   // _assetsFuture is used for initial loading state and RefreshIndicator
//   late Future<List<AssetDetails>> _assetsFuture;
//   List<AssetDetails> _allAssets = []; // Stores all fetched assets
//   List<AssetDetails> _filteredAssets = []; // Stores assets after search/filter
//   Set<String> _selectedStatuses = {}; // For status filtering
//   final List<String> _allPossibleStatuses = [
//     'completed',
//     'In Progress',
//     'Open',
//     'Closed',
//   ];
//   String? _selectedDateFilter; // '6_months', '1_year', or null
//
//   static final Logger _log = Logger('SearchPage');
//
//   String _fetchStatusMessage = 'Loading assets...'; // Status message for UI
//
//   @override
//   void initState() {
//     super.initState();
//     _log.info('SearchPage: initState - Initializing and calling _fetchAssets.');
//     _assetsFuture = Future.value([]); // Initialize with an empty future
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchAssets(); // Trigger initial data fetch
//     });
//     _searchController.addListener(_filterAssets); // Listen for search input changes
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_filterAssets);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   /// Fetches all asset details from the API.
//   /// Handles authentication, data normalization, and updates UI state.
//   Future<void> _fetchAssets() async {
//     final dataProvider = Provider.of<DataProvider>(context, listen: false);
//     final bearerToken = dataProvider.bearerToken;
//
//     if (bearerToken == null || bearerToken.isEmpty) {
//       _showDialog('Authentication Error', 'Bearer token missing. Please log in again.');
//       setState(() {
//         _allAssets = [];
//         _filteredAssets = [];
//         _fetchStatusMessage = 'Authentication required. No token.';
//         _assetsFuture = Future.value([]);
//       });
//       _log.warning('SearchPage: _fetchAssets - Bearer token is null or empty. Cannot fetch assets.');
//       return;
//     }
//
//     setState(() {
//       _fetchStatusMessage = 'Fetching assets...';
//     });
//
//     try {
//       final List<AssetDetails> assets = await AppApiService().fetchAllAssetDetails(bearerToken: bearerToken);
//       _log.info('SearchPage: _fetchAssets - API call successful. Received ${assets.length} raw assets.');
//
//       setState(() {
//         // Normalize status for all incoming assets
//         _allAssets = assets.map((asset) {
//           // The AssetDetails.fromJson method now handles the createDate parsing.
//           // We only need to normalize the status string for display/filtering purposes.
//           return asset.copyWith(status: _normalizeStatus(asset.status ?? ''));
//         }).toList();
//
//         _fetchStatusMessage = 'Fetched ${_allAssets.length} assets.';
//         _log.info('SearchPage: _fetchAssets - Successfully normalized and stored ${_allAssets.length} assets.');
//
//         _filterAssets(); // Apply current filters/search to the newly fetched assets
//         _assetsFuture = Future.value(_filteredAssets);
//       });
//     } catch (error, stackTrace) {
//       _log.severe('SearchPage: _fetchAssets - Error fetching assets: $error', error, stackTrace);
//       _showDialog('Error', 'Failed to load assets: ${error.toString().split(':')[0]}. Please try again.');
//       setState(() {
//         _allAssets = [];
//         _filteredAssets = [];
//         _assetsFuture = Future.error(error);
//         _fetchStatusMessage = 'Error: ${error.toString().split(':')[0]}';
//       });
//     }
//   }
//
//   /// Normalizes status strings from the API to a consistent display format.
//   String _normalizeStatus(String status) {
//     switch (status.toLowerCase().replaceAll(' ', '_')) {
//       case 'in_progress':
//         return 'In Progress';
//       case 'completed':
//         return 'completed';
//       case 'open':
//         return 'Open';
//       case 'closed':
//         return 'Closed';
//       default:
//         _log.warning('SearchPage: _normalizeStatus - Unrecognized status: "$status"');
//         return status;
//     }
//   }
//
//   /// Filters assets based on search query, selected statuses, and date range.
//   void _filterAssets() {
//     String query = _searchController.text.toLowerCase().trim();
//     _log.info('SearchPage: _filterAssets - Filtering with query: "$query", selected statuses: $_selectedStatuses, date filter: $_selectedDateFilter');
//
//     setState(() {
//       _filteredAssets = _allAssets.where((asset) {
//         final matchesSearch = asset.outletName?.toLowerCase().contains(query) == true ||
//             asset.uoc?.toLowerCase().contains(query) == true;
//         final matchesStatus = _selectedStatuses.isEmpty || _selectedStatuses.contains(asset.status);
//         final matchesDate = _applyDateFilter(asset);
//         return matchesSearch && matchesStatus && matchesDate;
//       }).toList();
//       _log.info('SearchPage: _filterAssets - Resulting _filteredAssets count: ${_filteredAssets.length}');
//     });
//   }
//
//   /// Applies the date filter based on the selected option.
//   bool _applyDateFilter(AssetDetails asset) {
//     if (_selectedDateFilter == null) {
//       return true; // No filter applied
//     }
//
//     if (asset.createDate == null) {
//       return false; // Cannot filter if date is missing
//     }
//
//     try {
//       final DateTime assetDate = DateTime.parse(asset.createDate!);
//       final DateTime now = DateTime.now();
//
//       if (_selectedDateFilter == '6_months') {
//         final DateTime sixMonthsAgo = now.subtract(const Duration(days: 182)); // Approx 6 months
//         return assetDate.isAfter(sixMonthsAgo);
//       } else if (_selectedDateFilter == '1_year') {
//         final DateTime oneYearAgo = now.subtract(const Duration(days: 365));
//         return assetDate.isAfter(oneYearAgo);
//       }
//     } catch (e) {
//       _log.severe('Error parsing date for asset: ${asset.uoc}. Error: $e');
//       return false; // Return false if date parsing fails
//     }
//
//     return true; // Fallback
//   }
//
//   /// Toggles selected status filters and re-filters the assets.
//   void _toggleStatusFilter(String status) {
//     setState(() {
//       if (_selectedStatuses.contains(status)) {
//         _selectedStatuses.remove(status);
//       } else {
//         _selectedStatuses.add(status);
//       }
//       _log.info('SearchPage: _toggleStatusFilter - New selected statuses: $_selectedStatuses');
//       _filterAssets();
//       Navigator.pop(context); // Close the drawer after selection
//     });
//   }
//
//   /// Sets the date filter and re-filters the assets.
//   void _setDateFilter(String? filter) {
//     setState(() {
//       _selectedDateFilter = filter;
//       _log.info('SearchPage: _setDateFilter - New selected date filter: $_selectedDateFilter');
//       _filterAssets();
//       Navigator.pop(context); // Close the drawer after selection
//     });
//   }
//
//   /// Shows a standard AlertDialog.
//   void _showDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   /// Returns a color based on the asset status.
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'completed':
//         return Colors.green.shade700;
//       case 'in progress':
//         return Colors.orange.shade700;
//       case 'open':
//         return Colors.blue.shade700;
//       case 'closed':
//         return Colors.red.shade700;
//       default:
//         return Colors.grey.shade700;
//     }
//   }
//
//   /// A temporary function to test API connectivity and log asset details.
//   Future<void> _testApiCall() async {
//     _log.info('Test API Call: Initiated.');
//     final dataProvider = Provider.of<DataProvider>(context, listen: false);
//     final bearerToken = dataProvider.bearerToken;
//
//     if (bearerToken == null || bearerToken.isEmpty) {
//       _log.warning('Test API Call: Bearer token is missing. Cannot proceed with API test.');
//       _showDialog('API Test Warning', 'No authentication token available. Please ensure you are logged in.');
//       setState(() {
//         _fetchStatusMessage = 'API Test: No token.';
//       });
//       return;
//     }
//
//     setState(() {
//       _fetchStatusMessage = 'Running API Test...';
//     });
//
//     try {
//       final List<AssetDetails> testAssets = await AppApiService().fetchAllAssetDetails(bearerToken: bearerToken);
//
//       final List<AssetDetails> normalizedTestAssets = testAssets.map((asset) {
//         return asset.copyWith(status: _normalizeStatus(asset.status ?? ''));
//       }).toList();
//
//       _log.info('Test API Call: Successfully received ${normalizedTestAssets.length} assets.');
//       setState(() {
//         _fetchStatusMessage = 'API Test: Fetched ${normalizedTestAssets.length} assets.';
//       });
//
//       if (normalizedTestAssets.isNotEmpty) {
//         _log.info('Test API Call: First 5 normalized assets for debug:');
//         for (int i = 0; i < normalizedTestAssets.length && i < 5; i++) {
//           _log.info('  ${i + 1}. Outlet: ${normalizedTestAssets[i].outletName}, UOC: ${normalizedTestAssets[i].uoc}, Status: ${normalizedTestAssets[i].status}');
//         }
//       } else {
//         _log.info('Test API Call: API returned an empty list of assets.');
//       }
//       _showDialog('API Test Result', 'Successfully fetched ${normalizedTestAssets.length} assets. Check Logcat for details.');
//     } catch (e, stackTrace) {
//       _log.severe('Test API Call: Error during API test: $e', e, stackTrace);
//       _showDialog('API Test Error', 'An error occurred during API call. Check Logcat. Error: ${e.toString().split(':')[0]}');
//       setState(() {
//         _fetchStatusMessage = 'API Test: Error: ${e.toString().split(':')[0]}';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _log.info('SearchPage: build method entered.');
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAF6EF),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFAF6EF),
//         elevation: 0,
//         leading: Builder(
//           builder: (BuildContext context) {
//             return IconButton(
//               icon: const Icon(Icons.menu, color: Colors.brown),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             );
//           },
//         ),
//         centerTitle: true,
//       ),
//       drawer: Drawer(
//         backgroundColor: const Color(0xFFFAF6EF),
//         child: Column(
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.brown,
//               ),
//               child: Container(
//                 alignment: Alignment.centerLeft,
//                 child: const Text(
//                   'Filters',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     child: Text('Filter by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
//                   ),
//                   ..._allPossibleStatuses.map((status) {
//                     return CheckboxListTile(
//                       title: Text(status),
//                       value: _selectedStatuses.contains(status),
//                       onChanged: (bool? value) {
//                         if (value != null) {
//                           _toggleStatusFilter(status);
//                         }
//                       },
//                       activeColor: Colors.brown,
//                       checkColor: Colors.white,
//                     );
//                   }).toList(),
//                   const Divider(),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     child: Text('Filter by Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
//                   ),
//                   RadioListTile<String>(
//                     title: const Text('Past 6 Months'),
//                     value: '6_months',
//                     groupValue: _selectedDateFilter,
//                     onChanged: (String? value) => _setDateFilter(value),
//                     activeColor: Colors.brown,
//                   ),
//                   RadioListTile<String>(
//                     title: const Text('Past 1 Year'),
//                     value: '1_year',
//                     groupValue: _selectedDateFilter,
//                     onChanged: (String? value) => _setDateFilter(value),
//                     activeColor: Colors.brown,
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedStatuses.clear();
//                     _selectedDateFilter = null;
//                     _filterAssets();
//                   });
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red.shade700,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 40),
//                 ),
//                 child: const Text('Clear All Filters'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     image: const DecorationImage(
//                       image: AssetImage('assets/rect1.png'),
//                       fit: BoxFit.cover,
//                       repeat: ImageRepeat.repeat,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     style: const TextStyle(color: Colors.white, fontSize: 18),
//                     decoration: const InputDecoration(
//                       hintText: 'Search by Outlet Name or UOC',
//                       hintStyle: TextStyle(color: Colors.white70, fontSize: 18),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       prefixIcon: Icon(Icons.search, color: Colors.white70),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _testApiCall,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueGrey,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                     ),
//                     child: const Text('Run API Test'),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Center(
//                   child: Text(
//                     _fetchStatusMessage,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: _fetchStatusMessage.contains('Error') ? Colors.red : Colors.brown,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: _fetchAssets,
//               child: _filteredAssets.isEmpty && !_fetchStatusMessage.contains('Loading') && !_fetchStatusMessage.contains('Fetching')
//                   ? ListView(
//                 children: [
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.4,
//                     child: Center(
//                       child: Text(
//                         _fetchStatusMessage.contains('Error')
//                             ? _fetchStatusMessage
//                             : (_searchController.text.isNotEmpty || _selectedStatuses.isNotEmpty || _selectedDateFilter != null
//                             ? 'No assets match your search/filters.'
//                             : 'No assets found. Pull down to refresh.'),
//                         style: const TextStyle(fontSize: 16, color: Colors.grey),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//                   : ListView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//                 itemCount: _filteredAssets.length,
//                 itemBuilder: (context, index) {
//                   final AssetDetails asset = _filteredAssets[index];
//                   Color? statusColor = _getStatusColor(asset.status ?? 'unknown');
//
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ConsentFormPage(
//                               assetDetails: asset,
//                               username: widget.username,
//                             ),
//                           ),
//                         ).then((_) => _fetchAssets());
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     '${index + 1}. ${asset.outletName ?? 'Unknown Outlet'}',
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.brown,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                 ),
//                                 Text(
//                                   (asset.status ?? 'Unknown').toUpperCase(),
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     color: statusColor,
//                                   ),
//                                   textAlign: TextAlign.right,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'UOC: ${asset.uoc ?? 'N/A'}',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.normal,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:ferrero_asset_management/models/asset_details_model.dart';
// import 'package:ferrero_asset_management/services/app_api_service.dart';
// import 'package:provider/provider.dart';
// import 'package:ferrero_asset_management/provider/data_provider.dart';
// import 'package:logging/logging.dart';
// import 'package:ferrero_asset_management/screens/shops/consent_form_page.dart';
//
// class SearchPage extends StatefulWidget {
//   final String username;
//
//   const SearchPage({super.key, required this.username});
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//
//   // _assetsFuture is used for initial loading state and RefreshIndicator
//   late Future<List<AssetDetails>> _assetsFuture;
//   List<AssetDetails> _allAssets = []; // Stores all fetched assets
//   List<AssetDetails> _filteredAssets = []; // Stores assets after search/filter
//   Set<String> _selectedStatuses = {}; // For status filtering
//   final List<String> _allPossibleStatuses = [
//     'completed',
//     'In Progress',
//     'Open',
//     'Closed',
//   ];
//   String? _selectedDateFilter; // '6_months', '1_year', or null
//
//   static final Logger _log = Logger('SearchPage');
//
//   String _fetchStatusMessage = 'Loading assets...'; // Status message for UI
//
//   @override
//   void initState() {
//     super.initState();
//     _log.info('SearchPage: initState - Initializing and calling _fetchAssets.');
//     _assetsFuture = Future.value([]); // Initialize with an empty future
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchAssets(); // Trigger initial data fetch
//     });
//     _searchController.addListener(_filterAssets); // Listen for search input changes
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_filterAssets);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   /// Fetches all asset details from the API.
//   /// Handles authentication, data normalization, and updates UI state.
//   Future<void> _fetchAssets() async {
//     final dataProvider = Provider.of<DataProvider>(context, listen: false);
//     final bearerToken = dataProvider.bearerToken;
//
//     if (bearerToken == null || bearerToken.isEmpty) {
//       _showDialog('Authentication Error', 'Bearer token missing. Please log in again.');
//       setState(() {
//         _allAssets = [];
//         _filteredAssets = [];
//         _fetchStatusMessage = 'Authentication required. No token.';
//         _assetsFuture = Future.value([]);
//       });
//       _log.warning('SearchPage: _fetchAssets - Bearer token is null or empty. Cannot fetch assets.');
//       return;
//     }
//
//     setState(() {
//       _fetchStatusMessage = 'Fetching assets...';
//     });
//
//     try {
//       final List<AssetDetails> assets = await AppApiService().fetchAllAssetDetails(bearerToken: bearerToken);
//       _log.info('SearchPage: _fetchAssets - API call successful. Received ${assets.length} raw assets.');
//
//       setState(() {
//         // Normalize status for all incoming assets
//         _allAssets = assets.map((asset) {
//           // The AssetDetails.fromJson method now handles the createDate parsing.
//           // We only need to normalize the status string for display/filtering purposes.
//           return AssetDetails(
//             uoc: asset.uoc,
//             outletName: asset.outletName,
//             status: _normalizeStatus(asset.status ?? ''),
//             vcSerialNo: asset.vcSerialNo,
//             outletExteriorsPhoto: asset.outletExteriorsPhoto,
//             assetPics: asset.assetPics,
//             outletOwnerIdsPics: asset.outletOwnerIdsPics,
//             outletOwnerPic: asset.outletOwnerPic,
//             serialNoPic: asset.serialNoPic,
//             vcType: asset.vcType,
//             contactPerson: asset.contactPerson,
//             mobileNumber: asset.mobileNumber,
//             address: asset.address,
//             state: asset.state,
//             postalCode: asset.postalCode,
//             latitude: asset.latitude,
//             longitude: asset.longitude,
//             createDate: asset.createDate,
//             updateDate: asset.updateDate,
//           );
//         }).toList();
//
//         _fetchStatusMessage = 'Fetched ${_allAssets.length} assets.';
//         _log.info('SearchPage: _fetchAssets - Successfully normalized and stored ${_allAssets.length} assets.');
//
//         _filterAssets(); // Apply current filters/search to the newly fetched assets
//         _assetsFuture = Future.value(_filteredAssets);
//       });
//     } catch (error, stackTrace) {
//       _log.severe('SearchPage: _fetchAssets - Error fetching assets: $error', error, stackTrace);
//       _showDialog('Error', 'Failed to load assets: ${error.toString().split(':')[0]}. Please try again.');
//       setState(() {
//         _allAssets = [];
//         _filteredAssets = [];
//         _assetsFuture = Future.error(error);
//         _fetchStatusMessage = 'Error: ${error.toString().split(':')[0]}';
//       });
//     }
//   }
//
//   /// Normalizes status strings from the API to a consistent display format.
//   String _normalizeStatus(String status) {
//     switch (status.toLowerCase().replaceAll(' ', '_')) {
//       case 'in_progress':
//         return 'In Progress';
//       case 'completed':
//         return 'completed';
//       case 'open':
//         return 'Open';
//       case 'closed':
//         return 'Closed';
//       default:
//         _log.warning('SearchPage: _normalizeStatus - Unrecognized status: "$status"');
//         return status;
//     }
//   }
//
//   /// Filters assets based on search query, selected statuses, and date range.
//   void _filterAssets() {
//     String query = _searchController.text.toLowerCase().trim();
//     _log.info('SearchPage: _filterAssets - Filtering with query: "$query", selected statuses: $_selectedStatuses, date filter: $_selectedDateFilter');
//
//     setState(() {
//       _filteredAssets = _allAssets.where((asset) {
//         final matchesSearch = asset.outletName?.toLowerCase().contains(query) == true ||
//             asset.uoc?.toLowerCase().contains(query) == true;
//         final matchesStatus = _selectedStatuses.isEmpty || _selectedStatuses.contains(asset.status);
//         final matchesDate = _applyDateFilter(asset);
//         return matchesSearch && matchesStatus && matchesDate;
//       }).toList();
//       _log.info('SearchPage: _filterAssets - Resulting _filteredAssets count: ${_filteredAssets.length}');
//     });
//   }
//
//   /// Applies the date filter based on the selected option.
//   bool _applyDateFilter(AssetDetails asset) {
//     if (_selectedDateFilter == null) {
//       return true; // No filter applied
//     }
//
//     if (asset.createDate == null) {
//       return false; // Cannot filter if date is missing
//     }
//
//     try {
//       final DateTime? assetDate = _getAssetDate(asset.createDate);
//
//       if (assetDate == null) {
//         return false;
//       }
//
//       final DateTime now = DateTime.now();
//
//       if (_selectedDateFilter == '6_months') {
//         final DateTime sixMonthsAgo = now.subtract(const Duration(days: 182)); // Approx 6 months
//         return assetDate.isAfter(sixMonthsAgo);
//       } else if (_selectedDateFilter == '1_year') {
//         final DateTime oneYearAgo = now.subtract(const Duration(days: 365));
//         return assetDate.isAfter(oneYearAgo);
//       }
//     } catch (e) {
//       _log.severe('Error parsing date for asset: ${asset.uoc}. Error: $e');
//       return false; // Return false if date parsing fails
//     }
//
//     return true; // Fallback
//   }
//
//   /// Safely converts a date string or list of ints to a DateTime object.
//   DateTime? _getAssetDate(dynamic date) {
//     if (date is String) {
//       try {
//         return DateTime.parse(date);
//       } catch (e) {
//         return null;
//       }
//     } else if (date is List<int> && date.length >= 3) {
//       try {
//         return DateTime(date[0], date[1], date[2]);
//       } catch (e) {
//         return null;
//       }
//     }
//     return null;
//   }
//
//   /// Toggles selected status filters and re-filters the assets.
//   void _toggleStatusFilter(String status) {
//     setState(() {
//       if (_selectedStatuses.contains(status)) {
//         _selectedStatuses.remove(status);
//       } else {
//         _selectedStatuses.add(status);
//       }
//       _log.info('SearchPage: _toggleStatusFilter - New selected statuses: $_selectedStatuses');
//       _filterAssets();
//       Navigator.pop(context); // Close the drawer after selection
//     });
//   }
//
//   /// Sets the date filter and re-filters the assets.
//   void _setDateFilter(String? filter) {
//     setState(() {
//       _selectedDateFilter = filter;
//       _log.info('SearchPage: _setDateFilter - New selected date filter: $_selectedDateFilter');
//       _filterAssets();
//       Navigator.pop(context); // Close the drawer after selection
//     });
//   }
//
//   /// Shows a standard AlertDialog.
//   void _showDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   /// Returns a color based on the asset status.
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'completed':
//         return Colors.green.shade700;
//       case 'in progress':
//         return Colors.orange.shade700;
//       case 'open':
//         return Colors.blue.shade700;
//       case 'closed':
//         return Colors.red.shade700;
//       default:
//         return Colors.grey.shade700;
//     }
//   }
//
//   /// A temporary function to test API connectivity and log asset details.
//   Future<void> _testApiCall() async {
//     _log.info('Test API Call: Initiated.');
//     final dataProvider = Provider.of<DataProvider>(context, listen: false);
//     final bearerToken = dataProvider.bearerToken;
//
//     if (bearerToken == null || bearerToken.isEmpty) {
//       _log.warning('Test API Call: Bearer token is missing. Cannot proceed with API test.');
//       _showDialog('API Test Warning', 'No authentication token available. Please ensure you are logged in.');
//       setState(() {
//         _fetchStatusMessage = 'API Test: No token.';
//       });
//       return;
//     }
//
//     setState(() {
//       _fetchStatusMessage = 'Running API Test...';
//     });
//
//     try {
//       final List<AssetDetails> testAssets = await AppApiService().fetchAllAssetDetails(bearerToken: bearerToken);
//
//       final List<AssetDetails> normalizedTestAssets = testAssets.map((asset) {
//         return AssetDetails(
//           uoc: asset.uoc,
//           outletName: asset.outletName,
//           status: _normalizeStatus(asset.status ?? ''),
//           vcSerialNo: asset.vcSerialNo,
//           outletExteriorsPhoto: asset.outletExteriorsPhoto,
//           assetPics: asset.assetPics,
//           outletOwnerIdsPics: asset.outletOwnerIdsPics,
//           outletOwnerPic: asset.outletOwnerPic,
//           serialNoPic: asset.serialNoPic,
//           vcType: asset.vcType,
//           contactPerson: asset.contactPerson,
//           mobileNumber: asset.mobileNumber,
//           address: asset.address,
//           state: asset.state,
//           postalCode: asset.postalCode,
//           latitude: asset.latitude,
//           longitude: asset.longitude,
//           createDate: asset.createDate,
//           updateDate: asset.updateDate,
//         );
//       }).toList();
//
//       _log.info('Test API Call: Successfully received ${normalizedTestAssets.length} assets.');
//       setState(() {
//         _fetchStatusMessage = 'API Test: Fetched ${normalizedTestAssets.length} assets.';
//       });
//
//       if (normalizedTestAssets.isNotEmpty) {
//         _log.info('Test API Call: First 5 normalized assets for debug:');
//         for (int i = 0; i < normalizedTestAssets.length && i < 5; i++) {
//           _log.info('  ${i + 1}. Outlet: ${normalizedTestAssets[i].outletName}, UOC: ${normalizedTestAssets[i].uoc}, Status: ${normalizedTestAssets[i].status}');
//         }
//       } else {
//         _log.info('Test API Call: API returned an empty list of assets.');
//       }
//       _showDialog('API Test Result', 'Successfully fetched ${normalizedTestAssets.length} assets. Check Logcat for details.');
//     } catch (e, stackTrace) {
//       _log.severe('Test API Call: Error during API test: $e', e, stackTrace);
//       _showDialog('API Test Error', 'An error occurred during API call. Check Logcat. Error: ${e.toString().split(':')[0]}');
//       setState(() {
//         _fetchStatusMessage = 'API Test: Error: ${e.toString().split(':')[0]}';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _log.info('SearchPage: build method entered.');
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAF6EF),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFAF6EF),
//         elevation: 0,
//         leading: Builder(
//           builder: (BuildContext context) {
//             return IconButton(
//               icon: const Icon(Icons.menu, color: Colors.brown),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             );
//           },
//         ),
//         centerTitle: true,
//       ),
//       drawer: Drawer(
//         backgroundColor: const Color(0xFFFAF6EF),
//         child: Column(
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.brown,
//               ),
//               child: Container(
//                 alignment: Alignment.centerLeft,
//                 child: const Text(
//                   'Filters',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     child: Text('Filter by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
//                   ),
//                   ..._allPossibleStatuses.map((status) {
//                     return CheckboxListTile(
//                       title: Text(status),
//                       value: _selectedStatuses.contains(status),
//                       onChanged: (bool? value) {
//                         if (value != null) {
//                           _toggleStatusFilter(status);
//                         }
//                       },
//                       activeColor: Colors.brown,
//                       checkColor: Colors.white,
//                     );
//                   }).toList(),
//                   const Divider(),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     child: Text('Filter by Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
//                   ),
//                   RadioListTile<String>(
//                     title: const Text('Past 6 Months'),
//                     value: '6_months',
//                     groupValue: _selectedDateFilter,
//                     onChanged: (String? value) => _setDateFilter(value),
//                     activeColor: Colors.brown,
//                   ),
//                   RadioListTile<String>(
//                     title: const Text('Past 1 Year'),
//                     value: '1_year',
//                     groupValue: _selectedDateFilter,
//                     onChanged: (String? value) => _setDateFilter(value),
//                     activeColor: Colors.brown,
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedStatuses.clear();
//                     _selectedDateFilter = null;
//                     _filterAssets();
//                   });
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red.shade700,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 40),
//                 ),
//                 child: const Text('Clear All Filters'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     image: const DecorationImage(
//                       image: AssetImage('assets/rect1.png'),
//                       fit: BoxFit.cover,
//                       repeat: ImageRepeat.repeat,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     style: const TextStyle(color: Colors.white, fontSize: 18),
//                     decoration: const InputDecoration(
//                       hintText: 'Search by Outlet Name or UOC',
//                       hintStyle: TextStyle(color: Colors.white70, fontSize: 18),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       prefixIcon: Icon(Icons.search, color: Colors.white70),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _testApiCall,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueGrey,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                     ),
//                     child: const Text('Run API Test'),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Center(
//                   child: Text(
//                     _fetchStatusMessage,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: _fetchStatusMessage.contains('Error') ? Colors.red : Colors.brown,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: _fetchAssets,
//               child: _filteredAssets.isEmpty && !_fetchStatusMessage.contains('Loading') && !_fetchStatusMessage.contains('Fetching')
//                   ? ListView(
//                 children: [
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.4,
//                     child: Center(
//                       child: Text(
//                         _fetchStatusMessage.contains('Error')
//                             ? _fetchStatusMessage
//                             : (_searchController.text.isNotEmpty || _selectedStatuses.isNotEmpty || _selectedDateFilter != null
//                             ? 'No assets match your search/filters.'
//                             : 'No assets found. Pull down to refresh.'),
//                         style: const TextStyle(fontSize: 16, color: Colors.grey),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//                   : ListView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//                 itemCount: _filteredAssets.length,
//                 itemBuilder: (context, index) {
//                   final AssetDetails asset = _filteredAssets[index];
//                   Color? statusColor = _getStatusColor(asset.status ?? 'unknown');
//
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ConsentFormPage(
//                               assetDetails: asset,
//                               username: widget.username,
//                             ),
//                           ),
//                         ).then((_) => _fetchAssets());
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     '${index + 1}. ${asset.outletName ?? 'Unknown Outlet'}',
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.brown,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                 ),
//                                 Text(
//                                   (asset.status ?? 'Unknown').toUpperCase(),
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     color: statusColor,
//                                   ),
//                                   textAlign: TextAlign.right,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'UOC: ${asset.uoc ?? 'N/A'}',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.normal,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:ferrero_asset_management/models/asset_details_model.dart';
// import 'package:ferrero_asset_management/services/app_api_service.dart';
// import 'package:provider/provider.dart';
// import 'package:ferrero_asset_management/provider/data_provider.dart';
// import 'package:logging/logging.dart';
// import 'package:ferrero_asset_management/screens/shops/consent_form_page.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
//
// class SearchPage extends StatefulWidget {
//   final String username;
//
//   const SearchPage({super.key, required this.username});
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//
//   late Future<List<AssetDetails>> _assetsFuture;
//   List<AssetDetails> _allAssets = [];
//   List<AssetDetails> _filteredAssets = [];
//   Set<String> _selectedStatuses = {};
//   final List<String> _allPossibleStatuses = [
//     'completed',
//     'In Progress',
//     'Open',
//     'Closed',
//   ];
//   String? _selectedDateFilter;
//   DateTime? _selectedStartDate;
//   DateTime? _selectedEndDate;
//
//   static final Logger _log = Logger('SearchPage');
//
//   @override
//   void initState() {
//     super.initState();
//     _assetsFuture = Future.value([]);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchAssets();
//     });
//     _searchController.addListener(_filterAssets);
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_filterAssets);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   /// Fetches all asset details from the API.
//   Future<void> _fetchAssets() async {
//     final dataProvider = Provider.of<DataProvider>(context, listen: false);
//     final bearerToken = dataProvider.bearerToken;
//
//     if (bearerToken == null || bearerToken.isEmpty) {
//       _showDialog('Authentication Error', 'Bearer token missing. Please log in again.');
//       setState(() {
//         _allAssets = [];
//         _filteredAssets = [];
//         _assetsFuture = Future.value([]);
//       });
//       return;
//     }
//
//     try {
//       final List<AssetDetails> assets = await AppApiService().fetchAllAssetDetails(bearerToken: bearerToken);
//
//       setState(() {
//         _allAssets = assets.map((asset) {
//           return AssetDetails(
//             uoc: asset.uoc,
//             outletName: asset.outletName,
//             status: _normalizeStatus(asset.status ?? ''),
//             vcSerialNo: asset.vcSerialNo,
//             outletExteriorsPhoto: asset.outletExteriorsPhoto,
//             assetPics: asset.assetPics,
//             outletOwnerIdsPics: asset.outletOwnerIdsPics,
//             outletOwnerPic: asset.outletOwnerPic,
//             serialNoPic: asset.serialNoPic,
//             vcType: asset.vcType,
//             contactPerson: asset.contactPerson,
//             mobileNumber: asset.mobileNumber,
//             address: asset.address,
//             state: asset.state,
//             postalCode: asset.postalCode,
//             latitude: asset.latitude,
//             longitude: asset.longitude,
//             createDate: asset.createDate,
//             updateDate: asset.updateDate,
//           );
//         }).toList();
//
//         _filterAssets();
//         _assetsFuture = Future.value(_filteredAssets);
//       });
//     } catch (error, stackTrace) {
//       _log.severe('SearchPage: _fetchAssets - Error fetching assets: $error', error, stackTrace);
//       _showDialog('Error', 'Failed to load assets: ${error.toString().split(':')[0]}. Please try again.');
//       setState(() {
//         _allAssets = [];
//         _filteredAssets = [];
//         _assetsFuture = Future.error(error);
//       });
//     }
//   }
//
//   /// Normalizes status strings from the API to a consistent display format.
//   String _normalizeStatus(String status) {
//     switch (status.toLowerCase().replaceAll(' ', '_')) {
//       case 'in_progress':
//         return 'In Progress';
//       case 'completed':
//         return 'completed';
//       case 'open':
//         return 'Open';
//       case 'closed':
//         return 'Closed';
//       default:
//         _log.warning('SearchPage: _normalizeStatus - Unrecognized status: "$status"');
//         return status;
//     }
//   }
//
//   /// Filters assets based on search query, selected statuses, and date range.
//   void _filterAssets() {
//     String query = _searchController.text.toLowerCase().trim();
//
//     setState(() {
//       _filteredAssets = _allAssets.where((asset) {
//         final matchesSearch = asset.outletName?.toLowerCase().contains(query) == true ||
//             asset.uoc?.toLowerCase().contains(query) == true;
//         final matchesStatus = _selectedStatuses.isEmpty || _selectedStatuses.contains(asset.status);
//         final matchesDate = _applyDateFilter(asset);
//         return matchesSearch && matchesStatus && matchesDate;
//       }).toList();
//     });
//   }
//
//   /// Applies the date filter based on the selected option.
//   bool _applyDateFilter(AssetDetails asset) {
//     if (_selectedDateFilter == null && _selectedStartDate == null && _selectedEndDate == null) {
//       return true;
//     }
//
//     if (asset.createDate == null) {
//       return false;
//     }
//
//     try {
//       final DateTime? assetDate = _getAssetDate(asset.createDate);
//
//       if (assetDate == null) {
//         return false;
//       }
//
//       final DateTime now = DateTime.now();
//
//       if (_selectedDateFilter == '6_months') {
//         final DateTime sixMonthsAgo = now.subtract(const Duration(days: 182));
//         return assetDate.isAfter(sixMonthsAgo);
//       } else if (_selectedDateFilter == '1_year') {
//         final DateTime oneYearAgo = now.subtract(const Duration(days: 365));
//         return assetDate.isAfter(oneYearAgo);
//       }
//
//       if (_selectedStartDate != null && _selectedEndDate != null) {
//         final normalizedAssetDate = DateTime(assetDate.year, assetDate.month, assetDate.day);
//         final normalizedStartDate = DateTime(_selectedStartDate!.year, _selectedStartDate!.month, _selectedStartDate!.day);
//         final normalizedEndDate = DateTime(_selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day);
//
//         return normalizedAssetDate.isAfter(normalizedStartDate.subtract(const Duration(days: 1))) &&
//             normalizedAssetDate.isBefore(normalizedEndDate.add(const Duration(days: 1)));
//       } else if (_selectedStartDate != null) {
//         final normalizedAssetDate = DateTime(assetDate.year, assetDate.month, assetDate.day);
//         final normalizedStartDate = DateTime(_selectedStartDate!.year, _selectedStartDate!.month, _selectedStartDate!.day);
//         return normalizedAssetDate.isAfter(normalizedStartDate.subtract(const Duration(days: 1)));
//       } else if (_selectedEndDate != null) {
//         final normalizedAssetDate = DateTime(assetDate.year, assetDate.month, assetDate.day);
//         final normalizedEndDate = DateTime(_selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day);
//         return normalizedAssetDate.isBefore(normalizedEndDate.add(const Duration(days: 1)));
//       }
//
//     } catch (e) {
//       _log.severe('Error parsing date for asset: ${asset.uoc}. Error: $e');
//       return false;
//     }
//
//     return true;
//   }
//
//   /// Safely converts a date string or list of ints to a DateTime object.
//   DateTime? _getAssetDate(dynamic date) {
//     if (date is String) {
//       try {
//         return DateTime.parse(date);
//       } catch (e) {
//         return null;
//       }
//     } else if (date is List<int> && date.length >= 3) {
//       try {
//         return DateTime(date[0], date[1], date[2]);
//       } catch (e) {
//         return null;
//       }
//     }
//     return null;
//   }
//
//   /// Toggles selected status filters and re-filters the assets.
//   void _toggleStatusFilter(String status) {
//     setState(() {
//       if (_selectedStatuses.contains(status)) {
//         _selectedStatuses.remove(status);
//       } else {
//         _selectedStatuses.add(status);
//       }
//       _filterAssets();
//       Navigator.pop(context);
//     });
//   }
//
//   /// Sets the date filter and re-filters the assets.
//   void _setDateFilter(String? filter) {
//     setState(() {
//       _selectedDateFilter = filter;
//       _selectedStartDate = null;
//       _selectedEndDate = null;
//       _filterAssets();
//       Navigator.pop(context);
//     });
//   }
//
//   // Opens a date picker and updates the start date
//   Future<void> _selectStartDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedStartDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != _selectedStartDate) {
//       setState(() {
//         _selectedStartDate = picked;
//         _selectedDateFilter = null;
//         _filterAssets();
//       });
//     }
//   }
//
//   // Opens a date picker and updates the end date
//   Future<void> _selectEndDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedEndDate ?? DateTime.now(),
//       firstDate: _selectedStartDate ?? DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != _selectedEndDate) {
//       setState(() {
//         _selectedEndDate = picked;
//         _selectedDateFilter = null;
//         _filterAssets();
//       });
//     }
//   }
//
//   /// Shows a standard AlertDialog.
//   void _showDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   /// Returns a color based on the asset status.
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'completed':
//         return Colors.green.shade700;
//       case 'in progress':
//         return Colors.orange.shade700;
//       case 'open':
//         return Colors.blue.shade700;
//       case 'closed':
//         return Colors.red.shade700;
//       default:
//         return Colors.grey.shade700;
//     }
//   }
//
//   /// Launches a URL for the PDF.
//   Future<void> _launchPdfUrl(String uoc) async {
//     final Uri url = Uri.parse('https://sarsatiya.store/XJAAM-0.0.1-SNAPSHOT/getvendordata/$uoc');
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       _showDialog('Error', 'Could not launch $url');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAF6EF),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFAF6EF),
//         elevation: 0,
//         leading: Builder(
//           builder: (BuildContext context) {
//             return IconButton(
//               icon: const Icon(Icons.menu, color: Colors.brown),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             );
//           },
//         ),
//         centerTitle: true,
//       ),
//       drawer: Drawer(
//         backgroundColor: const Color(0xFFFAF6EF),
//         child: Column(
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.brown,
//               ),
//               child: Container(
//                 alignment: Alignment.centerLeft,
//                 child: const Text(
//                   'Filters',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     child: Text('Filter by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
//                   ),
//                   ..._allPossibleStatuses.map((status) {
//                     return CheckboxListTile(
//                       title: Text(status),
//                       value: _selectedStatuses.contains(status),
//                       onChanged: (bool? value) {
//                         if (value != null) {
//                           _toggleStatusFilter(status);
//                         }
//                       },
//                       activeColor: Colors.brown,
//                       checkColor: Colors.white,
//                     );
//                   }).toList(),
//                   const Divider(),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     child: Text('Filter by Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
//                   ),
//                   RadioListTile<String>(
//                     title: const Text('Past 6 Months'),
//                     value: '6_months',
//                     groupValue: _selectedDateFilter,
//                     onChanged: (String? value) => _setDateFilter(value),
//                     activeColor: Colors.brown,
//                   ),
//                   RadioListTile<String>(
//                     title: const Text('Past 1 Year'),
//                     value: '1_year',
//                     groupValue: _selectedDateFilter,
//                     onChanged: (String? value) => _setDateFilter(value),
//                     activeColor: Colors.brown,
//                   ),
//                   const Divider(),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     child: Text('Custom Date Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
//                   ),
//                   ListTile(
//                     title: const Text('From'),
//                     subtitle: Text(
//                       _selectedStartDate != null
//                           ? DateFormat('dd/MM/yyyy').format(_selectedStartDate!)
//                           : 'Select Start Date',
//                     ),
//                     trailing: const Icon(Icons.calendar_today, color: Colors.brown),
//                     onTap: () => _selectStartDate(context),
//                   ),
//                   ListTile(
//                     title: const Text('To'),
//                     subtitle: Text(
//                       _selectedEndDate != null
//                           ? DateFormat('dd/MM/yyyy').format(_selectedEndDate!)
//                           : 'Select End Date',
//                     ),
//                     trailing: const Icon(Icons.calendar_today, color: Colors.brown),
//                     onTap: () => _selectEndDate(context),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedStatuses.clear();
//                     _selectedDateFilter = null;
//                     _selectedStartDate = null;
//                     _selectedEndDate = null;
//                     _filterAssets();
//                   });
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red.shade700,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 40),
//                 ),
//                 child: const Text('Clear All Filters'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     image: const DecorationImage(
//                       image: AssetImage('assets/rect1.png'),
//                       fit: BoxFit.cover,
//                       repeat: ImageRepeat.repeat,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     style: const TextStyle(color: Colors.white, fontSize: 18),
//                     decoration: const InputDecoration(
//                       hintText: 'Search by Outlet Name or UOC',
//                       hintStyle: TextStyle(color: Colors.white70, fontSize: 18),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       prefixIcon: Icon(Icons.search, color: Colors.white70),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: _fetchAssets,
//               child: _filteredAssets.isEmpty
//                   ? ListView(
//                 children: [
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.4,
//                     child: Center(
//                       child: Text(
//                         _searchController.text.isNotEmpty || _selectedStatuses.isNotEmpty || _selectedDateFilter != null || _selectedStartDate != null || _selectedEndDate != null
//                             ? 'No assets match your search/filters.'
//                             : 'No assets found. Pull down to refresh.',
//                         style: const TextStyle(fontSize: 16, color: Colors.grey),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//                   : ListView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//                 itemCount: _filteredAssets.length,
//                 itemBuilder: (context, index) {
//                   final AssetDetails asset = _filteredAssets[index];
//                   Color? statusColor = _getStatusColor(asset.status ?? 'unknown');
//
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: InkWell(
//                       onTap: () async {
//                         if (asset.status == 'completed') {
//                           _launchPdfUrl(asset.uoc!);
//                         } else {
//                           await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ConsentFormPage(
//                                 assetDetails: asset,
//                                 username: widget.username,
//                               ),
//                             ),
//                           );
//                           // This call will be triggered when the user returns to this page
//                           _fetchAssets();
//                         }
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     '${index + 1}. ${asset.outletName ?? 'Unknown Outlet'}',
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.brown,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                 ),
//                                 Text(
//                                   (asset.status ?? 'Unknown').toUpperCase(),
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     color: statusColor,
//                                   ),
//                                   textAlign: TextAlign.right,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'UOC: ${asset.uoc ?? 'N/A'}',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.normal,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:ferrero_asset_management/models/asset_details_model.dart';
import 'package:ferrero_asset_management/services/app_api_service.dart';
import 'package:provider/provider.dart';
import 'package:ferrero_asset_management/provider/data_provider.dart';
import 'package:logging/logging.dart';
import 'package:ferrero_asset_management/screens/shops/consent_form_page.dart';
import 'package:ferrero_asset_management/screens/shops/pdf_viewer_page.dart'; // Import the new PDF viewer page
import 'package:intl/intl.dart';

class SearchPage extends StatefulWidget {
  final String username;

  const SearchPage({super.key, required this.username});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<AssetDetails> _allAssets = [];
  List<AssetDetails> _filteredAssets = [];
  Set<String> _selectedStatuses = {};
  final List<String> _allPossibleStatuses = [
    'completed',
    'In Progress',
    'Open',
    'Closed',
  ];
  String? _selectedDateFilter;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _errorMessage;

  static final Logger _log = Logger('SearchPage');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAssets();
    });
    _searchController.addListener(_filterAssets);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAssets);
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches all asset details from the API.
  Future<void> _fetchAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final bearerToken = dataProvider.bearerToken;

    print('DEBUG: Attempting to fetch assets. Bearer token is present: ${bearerToken != null && bearerToken.isNotEmpty}');
    if (bearerToken == null || bearerToken.isEmpty) {
      _showDialog('Authentication Error', 'Bearer token missing. Please log in again.');
      setState(() {
        _isLoading = false;
        _allAssets = [];
        _filteredAssets = [];
        _errorMessage = 'Authentication token is missing.';
      });
      return;
    }

    try {
      final List<AssetDetails> assets = await AppApiService().fetchAllAssetDetails(bearerToken: bearerToken);

      print('DEBUG: Successfully fetched ${assets.length} assets from the API.');

      setState(() {
        _allAssets = assets.map((asset) {
          return AssetDetails(
            uoc: asset.uoc,
            outletName: asset.outletName,
            status: _normalizeStatus(asset.status ?? ''),
            vcSerialNo: asset.vcSerialNo,
            outletExteriorsPhoto: asset.outletExteriorsPhoto,
            assetPics: asset.assetPics,
            outletOwnerIdsPics: asset.outletOwnerIdsPics,
            outletOwnerPic: asset.outletOwnerPic,
            serialNoPic: asset.serialNoPic,
            vcType: asset.vcType,
            contactPerson: asset.contactPerson,
            mobileNumber: asset.mobileNumber,
            address: asset.address,
            state: asset.state,
            postalCode: asset.postalCode,
            latitude: asset.latitude,
            longitude: asset.longitude,
            createDate: asset.createDate,
            updateDate: asset.updateDate,
          );
        }).toList();

        _filterAssets();
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      _log.severe('SearchPage: _fetchAssets - Error fetching assets: $error', error, stackTrace);
      setState(() {
        _isLoading = false;
        _allAssets = [];
        _filteredAssets = [];
        _errorMessage = 'Failed to load assets: ${error.toString().split(':')[0]}. Please try again.';
      });
      _showDialog('Error', _errorMessage!);
    }
  }

  String _normalizeStatus(String status) {
    switch (status.toLowerCase().replaceAll(' ', '_')) {
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'completed';
      case 'open':
        return 'Open';
      case 'closed':
        return 'Closed';
      default:
        _log.warning('SearchPage: _normalizeStatus - Unrecognized status: "$status"');
        return status;
    }
  }

  void _filterAssets() {
    String query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredAssets = _allAssets.where((asset) {
        final matchesSearch = asset.outletName?.toLowerCase().contains(query) == true ||
            asset.uoc?.toLowerCase().contains(query) == true;
        final matchesStatus = _selectedStatuses.isEmpty || _selectedStatuses.contains(asset.status);
        final matchesDate = _applyDateFilter(asset);
        return matchesSearch && matchesStatus && matchesDate;
      }).toList();
    });
  }

  bool _applyDateFilter(AssetDetails asset) {
    if (_selectedDateFilter == null && _selectedStartDate == null && _selectedEndDate == null) {
      return true;
    }

    if (asset.createDate == null) {
      return false;
    }

    try {
      final DateTime? assetDate = _getAssetDate(asset.createDate);

      if (assetDate == null) {
        return false;
      }

      final DateTime now = DateTime.now();

      if (_selectedDateFilter == '6_months') {
        final DateTime sixMonthsAgo = now.subtract(const Duration(days: 182));
        return assetDate.isAfter(sixMonthsAgo);
      } else if (_selectedDateFilter == '1_year') {
        final DateTime oneYearAgo = now.subtract(const Duration(days: 365));
        return assetDate.isAfter(oneYearAgo);
      }

      if (_selectedStartDate != null && _selectedEndDate != null) {
        final normalizedAssetDate = DateTime(assetDate.year, assetDate.month, assetDate.day);
        final normalizedStartDate = DateTime(_selectedStartDate!.year, _selectedStartDate!.month, _selectedStartDate!.day);
        final normalizedEndDate = DateTime(_selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day);

        return normalizedAssetDate.isAfter(normalizedStartDate.subtract(const Duration(days: 1))) &&
            normalizedAssetDate.isBefore(normalizedEndDate.add(const Duration(days: 1)));
      } else if (_selectedStartDate != null) {
        final normalizedAssetDate = DateTime(assetDate.year, assetDate.month, assetDate.day);
        final normalizedStartDate = DateTime(_selectedStartDate!.year, _selectedStartDate!.month, _selectedStartDate!.day);
        return normalizedAssetDate.isAfter(normalizedStartDate.subtract(const Duration(days: 1)));
      } else if (_selectedEndDate != null) {
        final normalizedAssetDate = DateTime(assetDate.year, assetDate.month, assetDate.day);
        final normalizedEndDate = DateTime(_selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day);
        return normalizedAssetDate.isBefore(normalizedEndDate.add(const Duration(days: 1)));
      }

    } catch (e) {
      _log.severe('Error parsing date for asset: ${asset.uoc}. Error: $e');
      return false;
    }

    return true;
  }

  DateTime? _getAssetDate(dynamic date) {
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return null;
      }
    } else if (date is List<int> && date.length >= 3) {
      try {
        return DateTime(date[0], date[1], date[2]);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void _toggleStatusFilter(String status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
      }
      _filterAssets();
      Navigator.pop(context);
    });
  }

  void _setDateFilter(String? filter) {
    setState(() {
      _selectedDateFilter = filter;
      _selectedStartDate = null;
      _selectedEndDate = null;
      _filterAssets();
      Navigator.pop(context);
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        _selectedDateFilter = null;
        _filterAssets();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? DateTime.now(),
      firstDate: _selectedStartDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
        _selectedDateFilter = null;
        _filterAssets();
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade700;
      case 'in progress':
        return Colors.orange.shade700;
      case 'open':
        return Colors.blue.shade700;
      case 'closed':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6EF),
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.brown),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFAF6EF),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.brown,
              ),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Filter by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
                  ),
                  ..._allPossibleStatuses.map((status) {
                    return CheckboxListTile(
                      title: Text(status),
                      value: _selectedStatuses.contains(status),
                      onChanged: (bool? value) {
                        if (value != null) {
                          _toggleStatusFilter(status);
                        }
                      },
                      activeColor: Colors.brown,
                      checkColor: Colors.white,
                    );
                  }).toList(),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Filter by Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
                  ),
                  RadioListTile<String>(
                    title: const Text('Past 6 Months'),
                    value: '6_months',
                    groupValue: _selectedDateFilter,
                    onChanged: (String? value) => _setDateFilter(value),
                    activeColor: Colors.brown,
                  ),
                  RadioListTile<String>(
                    title: const Text('Past 1 Year'),
                    value: '1_year',
                    groupValue: _selectedDateFilter,
                    onChanged: (String? value) => _setDateFilter(value),
                    activeColor: Colors.brown,
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Custom Date Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
                  ),
                  ListTile(
                    title: const Text('From'),
                    subtitle: Text(
                      _selectedStartDate != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedStartDate!)
                          : 'Select Start Date',
                    ),
                    trailing: const Icon(Icons.calendar_today, color: Colors.brown),
                    onTap: () => _selectStartDate(context),
                  ),
                  ListTile(
                    title: const Text('To'),
                    subtitle: Text(
                      _selectedEndDate != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedEndDate!)
                          : 'Select End Date',
                    ),
                    trailing: const Icon(Icons.calendar_today, color: Colors.brown),
                    onTap: () => _selectEndDate(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedStatuses.clear();
                    _selectedDateFilter = null;
                    _selectedStartDate = null;
                    _selectedEndDate = null;
                    _filterAssets();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Clear All Filters'),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/rect1.png'),
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeat,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Search by Outlet Name or UOC',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchAssets,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  : _filteredAssets.isEmpty
                  ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: Text(
                        _searchController.text.isNotEmpty || _selectedStatuses.isNotEmpty || _selectedDateFilter != null || _selectedStartDate != null || _selectedEndDate != null
                            ? 'No assets match your search/filters.'
                            : 'No assets found. Pull down to refresh.',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                itemCount: _filteredAssets.length,
                itemBuilder: (context, index) {
                  final AssetDetails asset = _filteredAssets[index];
                  Color? statusColor = _getStatusColor(asset.status ?? 'unknown');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () async {
                        if (asset.status == 'completed') {
                          // Navigate to the new PDF viewer page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PdfViewerPage(
                                pdfPath: 'assets/ConsentForm (2).pdf',
                              ),
                            ),
                          );
                        } else {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConsentFormPage(
                                assetDetails: asset,
                                username: widget.username,
                              ),
                            ),
                          );
                          _fetchAssets();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${index + 1}. ${asset.outletName ?? 'Unknown Outlet'}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.brown,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Text(
                                  (asset.status ?? 'Unknown').toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'UOC: ${asset.uoc ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
