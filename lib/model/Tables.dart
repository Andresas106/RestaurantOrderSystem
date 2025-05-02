class Tables {
  final String id;
  final int tableNumber;
  final String? groupId;
  final bool isFree;

  Tables({
    required this.id,
    required this.tableNumber,
    this.groupId,
    required this.isFree,
  });

  factory Tables.fromMap(String id, Map<String, dynamic> data) {
    return Tables(
      id: id,
      tableNumber: data['table_number'] ?? 0,
      groupId: data['group_id'],
      isFree: data['isFree'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'table_number': tableNumber,
      'group_id': groupId,
      'isFree': isFree,
    };
  }
}
