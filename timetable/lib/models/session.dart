class Session {
  final int id;
  final int classId;
  final int subjectId;
  final int teacherId;
  final int roomId;
  final String beginTime;
  final String endTime;

  Session({
    required this.id,
    required this.classId,
    required this.subjectId,
    required this.teacherId,
    required this.roomId,
    required this.beginTime,
    required this.endTime,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      classId: json['class_id'],
      subjectId: json['subject_id'],
      teacherId: json['teacher_id'],
      roomId: json['room_id'],
      beginTime: json['beginTime'],
      endTime: json['endTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'room_id': roomId,
      'beginTime': beginTime,
      'endTime': endTime,
    };
  }
}
