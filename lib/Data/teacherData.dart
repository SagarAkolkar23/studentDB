class Teacher {
  final String id;
  final String role;
  final String name;
  final String email;
  final String school;
  final String number;
  final List<String> students;

  Teacher({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.school,
    required this.number,
    required this.students,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['_id'],
      role: json['role'],
      name: json['name'],
      email: json['email'],
      school: json['school'],
      number: json['number'] ?? '',
      students: List<String>.from(json['students'] ?? []),
    );
  }
}
