class StudentModel {
  final String id;
  final String studentId;
  final String name;
  final String? email;
  final Teacher? teacher;
  final ClassInfo? classInfo;
  // other fields...

  StudentModel({
    required this.id,
    required this.studentId,
    required this.name,
    this.email,
    this.teacher,
    this.classInfo,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['_id'] as String,
      studentId: json['studentId'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      teacher: json['teacherId'] != null
          ? Teacher.fromJson(json['teacherId'])
          : null,
      classInfo: json['classId'] != null
          ? ClassInfo.fromJson(json['classId'])
          : null,
    );
  }
}

class Teacher {
  final String id;
  final String name;
  final String email;
  final String school;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.school,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      school: json['school'] as String,
    );
  }
}

class ClassInfo {
  final String id;
  final String name;

  ClassInfo({
    required this.id,
    required this.name,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
  }
}
