import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg/model/Tables.dart';
import 'package:tfg/provider/table_provider_intern.dart';

class NewOrder extends StatefulWidget {
  final String groupId;
  final List<String> tables;

  const NewOrder({super.key, required this.groupId, required this.tables});

  @override
  State<NewOrder> createState() => _NewOrderState();



}

class _NewOrderState extends State<NewOrder> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOrder();
    });
  }

  Future<void> _initializeOrder() async {
      final tablesProvider = Provider.of<TableProviderIntern>(context, listen: false);
      await tablesProvider.selectTablesOrder(widget.tables);
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider = Provider.of<TableProviderIntern>(context);
    final selectedTableNumbers = tableProvider.selectedTables.map((table) => table.tableNumber.toString()).join(', ');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Tables $selectedTableNumbers',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          
        ),
      ),
    );


  }
}
