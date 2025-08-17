import 'dart:convert'; // Required for jsonEncode/decode if needed for toString

class StudentSitting {
  final int id;
  final String? buildingName; // Maps to "vc_serial_no"
  final String? roomNumber;   // Maps to "outlet_address"
  final String? shift;
  final String? rollNumber;   // Maps to "mobile_number"
  final String? name;         // Seems to be always null in sample, but included for completeness
  final String? batch;
  final String? program;      // Maps to "postal_code"
  final String? semester;
  final String? courseName;   // Maps to "state"
  final String? courseCode;   // Maps to "outlet_name"
  final String? seatNumber;
  final String? copyNumber;   // Maps to "uoc" or another asset ID
  final String? installationStatus;
  final String? date;
  final bool? status;
  final String? owner;        // Maps to "contact_person"
  final String? identity;
  final String? complience;
  final String? outlet;
  final String? serialno;
  final String? asset;

  StudentSitting({
    required this.id,
    this.buildingName,
    this.roomNumber,
    this.shift,
    this.rollNumber,
    this.name,
    this.batch,
    this.program,
    this.semester,
    this.courseName,
    this.courseCode,
    this.seatNumber,
    this.copyNumber,
    this.installationStatus,
    this.date,
    this.status,
    this.owner,
    this.identity,
    this.complience,
    this.outlet,
    this.serialno,
    this.asset,
  });

  // Factory constructor to create a StudentSitting instance from a JSON map
  factory StudentSitting.fromJson(Map<String, dynamic> json) {
    return StudentSitting(
      id: json['id'] as int,
      buildingName: json['buildingName'] as String?,
      roomNumber: json['roomNumber'] as String?,
      shift: json['shift'] as String?,
      rollNumber: json['rollNumber'] as String?,
      name: json['name'] as String?,
      batch: json['batch'] as String?,
      program: json['program'] as String?,
      semester: json['semester'] as String?,
      courseName: json['courseName'] as String?,
      courseCode: json['courseCode'] as String?,
      seatNumber: json['seatNumber'] as String?,
      copyNumber: json['copyNumber'] as String?,
      installationStatus: json['installationStatus'] as String?,
      date: json['date'] as String?,
      status: json['status'] as bool?,
      owner: json['owner'] as String?,
      identity: json['identity'] as String?,
      complience: json['complience'] as String?,
      outlet: json['outlet'] as String?,
      serialno: json['serialno'] as String?,
      asset: json['asset'] as String?,
    );
  }

  // Override toString for better logging output of the object itself
  @override
  String toString() {
    // Convert object to a map, then to a JSON string for easy readability in logs
    return JsonEncoder.withIndent('  ').convert({
      'id': id,
      'buildingName': buildingName,
      'roomNumber': roomNumber,
      'shift': shift,
      'rollNumber': rollNumber,
      'name': name,
      'batch': batch,
      'program': program,
      'semester': semester,
      'courseName': courseName,
      'courseCode': courseCode,
      'seatNumber': seatNumber,
      'copyNumber': copyNumber,
      'installationStatus': installationStatus,
      'date': date,
      'status': status,
      'owner': owner,
      'identity': identity,
      'complience': complience,
      'outlet': outlet,
      'serialno': serialno,
      'asset': asset,
    });
  }
}