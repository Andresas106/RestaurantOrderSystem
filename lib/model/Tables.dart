class Tables {
  final String id;
  final int tableNumber;
  final String? groupId;
  final String? lockedBy; // Nuevo campo

  Tables({
    required this.id,
    required this.tableNumber,
    this.groupId,
    this.lockedBy,
  });

  factory Tables.fromMap(String id, Map<String, dynamic> data) {
    return Tables(
      id: id,
      tableNumber: data['table_number'] ?? 0,
      groupId: data['group_id'],
      lockedBy: data['locked_by']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'table_number': tableNumber,
      'group_id': groupId,
      'locked_by': lockedBy,
    };
  }
}
