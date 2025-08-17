
// lib/models/asset_details_model.dart

class AssetDetails {
  final String vcType;
  final String vcSerialNo;
  final String uoc;
  final String outletName;
  final String address;
  final String state;
  final String postalCode;
  final String contactPerson;
  final String mobileNumber;
  final String status;
  // Make sure these are nullable (String?) if they can be null in JSON
  final String? latitude;
  final String? longitude;
  final String? outletExteriorsPhoto;
  final String? assetPics;
  final String? outletOwnerIdsPics;
  final String? outletOwnerPic;
  final String? serialNoPic;
  final String? mobfield;
  // createDate and updateDate are arrays in your JSON, need custom parsing
  final List<int>? createDate;
  final List<int>? updateDate;
  final String? firstName;
  final String? lastName;

  AssetDetails({
    required this.vcType,
    required this.vcSerialNo,
    required this.uoc,
    required this.outletName,
    required this.address,
    required this.state,
    required this.postalCode,
    required this.contactPerson,
    required this.mobileNumber,
    required this.status,
    this.latitude,
    this.longitude,
    this.outletExteriorsPhoto,
    this.assetPics,
    this.outletOwnerIdsPics,
    this.outletOwnerPic,
    this.serialNoPic,
    this.mobfield,
    this.createDate,
    this.updateDate,
    this.firstName,
    this.lastName,
  });

  factory AssetDetails.fromJson(Map<String, dynamic> json) {
    return AssetDetails(
      vcType: json['vcType'] as String,
      vcSerialNo: json['vcSerialNo'] as String,
      uoc: json['uoc'] as String,
      outletName: json['outletName'] as String,
      address: json['address'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      contactPerson: json['contactPerson'] as String,
      mobileNumber: json['mobileNumber'] as String,
      status: json['status'] as String,
      // Handle nullable fields
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      outletExteriorsPhoto: json['outletExteriorsPhoto'] as String?,
      assetPics: json['assetPics'] as String?,
      outletOwnerIdsPics: json['outletOwnerIdsPics'] as String?,
      outletOwnerPic: json['outletOwnerPic'] as String?,
      serialNoPic: json['serialNoPic'] as String?,
      mobfield: json['mobfield'] as String?,
      // Parse dates as List<int>
      createDate: (json['createDate'] as List?)?.cast<int>(),
      updateDate: (json['updateDate'] as List?)?.cast<int>(),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }
}