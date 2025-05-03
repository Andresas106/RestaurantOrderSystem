class Tables {
  final String id;
  final int tableNumber;
  final String? groupId;

  Tables({
    required this.id,
    required this.tableNumber,
    required this.groupId,
  });

  factory Tables.fromMap(String id, Map<String, dynamic> data) {
    return Tables(
      id: id,
      tableNumber: data['table_number'] ?? 0,
      groupId: data['group_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'table_number': tableNumber,
      'group_id': groupId,
    };
  }
}
