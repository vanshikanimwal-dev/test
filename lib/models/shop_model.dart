class Shop {
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

  Shop({
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
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      vcType: json['VC Type']?.toString() ?? '',
      vcSerialNo: json['VC Serial No']?.toString() ?? '',
      uoc: json['UOC']?.toString() ?? '',
      outletName: json['OUTLET_NAME']?.toString() ?? '',
      address: json['Address']?.toString() ?? '',
      state: json['State']?.toString() ?? '',
      postalCode: json['Postal Code']?.toString() ?? '',
      contactPerson: json['Contact_Person']?.toString() ?? '',
      mobileNumber: json['Mobile Number']?.toString() ?? '',
      status: json['Status']?.toString() ?? '',
    );
  }
}
