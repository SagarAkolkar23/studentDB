class Student {
  final String id; // MongoDB _id (ObjectId as String)
  final String studentId;
  final String name;
  final String email;
  final String rollNo;
  final String teacherId; // Reference to teacher's ObjectId as String
  final String? classId;  // optional class ObjectId
  final List<String>? subjects;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    required this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.rollNo,
    required this.teacherId,
    this.classId,
    this.subjects,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create Student from JSON (API response)
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'] ?? '',
      studentId: json['studentId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      rollNo: json['rollNo'] ?? '',
      teacherId: json['teacherId'] is String
          ? json['teacherId']
          : (json['teacherId']?['_id'] ?? ''),
      classId: json['classId'] is String
          ? json['classId']
          : json['classId']?['_id'],
      subjects: json['subjects'] != null
          ? List<String>.from(json['subjects'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Convert Student object to JSON (for sending data back to API)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'studentId': studentId,
      'name': name,
      'email': email,
      'rollNo': rollNo,
      'teacherId': teacherId,
      'classId': classId,
      'subjects': subjects,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
