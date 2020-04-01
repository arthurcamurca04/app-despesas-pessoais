import 'dart:io';
import 'package:despesas_pessoais/components/chart.dart';
import 'package:despesas_pessoais/components/transaction_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:despesas_pessoais/components/transaction_list.dart';
import 'package:despesas_pessoais/models/transaction.dart';

void main() => runApp(ExpenseApp());

class ExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExpensesApp',
      theme: ThemeData(
          textTheme: ThemeData.light().textTheme.copyWith(
              title: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
              button: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
          primaryColor: Colors.black,
          fontFamily: "Quicksand",
          appBarTheme: AppBarTheme(
              textTheme: TextTheme(
            title: TextStyle(
                fontFamily: "Quicksand",
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ))),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [
    Transaction(
      id: 't1',
      title: 'Internet',
      value: 60,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't2',
      title: 'Água',
      value: 37.90,
      date: DateTime.now().subtract(Duration(days: 10)),
    ),
    Transaction(
      id: 't3',
      title: 'Energia',
      value: 113.85,
      date: DateTime.now().subtract(Duration(days: 2)),
    ),
    Transaction(
      id: 't4',
      title: 'Telefone',
      value: 40,
      date: DateTime.now().subtract(Duration(days: 3)),
    ),
    Transaction(
      id: 't5',
      title: 'Cartão de Crédito',
      value: 150,
      date: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];
  bool _showChart = false;

  List<Transaction> get _recentTransaction {
    return _transactions.where((tr) {
      return tr.date.isAfter(
        DateTime.now().subtract(Duration(days: 7)),
      );
    }).toList();
  }

  _addNewTransaction(String title, double value, DateTime selectedDate) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: selectedDate,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) {
        return tr.id == id;
      });
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return TransactionForm(_addNewTransaction);
      },
    );
  }

  Widget _getIconButton(IconData icon, Function fn) {
    return Platform.isIOS
        ? GestureDetector(
            onTap: fn,
            child: Icon(icon),
          )
        : IconButton(
            icon: Icon(icon),
            onPressed: fn,
          );
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    bool isLandScape = mediaquery.orientation == Orientation.landscape;

    final actions = <Widget>[
      if (isLandScape)
        _getIconButton(
          _showChart ? Icons.list : Icons.show_chart,
          () {
            setState(() {
              _showChart = !_showChart;
            });
          },
        ),
      _getIconButton(
        Platform.isIOS ? CupertinoIcons.add : Icons.add,
        () => _openTransactionFormModal(context),
      ),
    ];

    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('Despesas Pessoais'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
          )
        : AppBar(
            title: Text('Despesas Pessoais'),
            actions: actions,
          );
    final availableHeight = mediaquery.size.height -
        appBar.preferredSize.height -
        mediaquery.padding.top;

    final bodyPage = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_showChart || !isLandScape)
              Container(
                height: availableHeight * (isLandScape ? 0.7 : 0.3),
                child: Chart(_recentTransaction),
              ),
            if (!_showChart || !isLandScape)
              Container(
                height: availableHeight * 0.7,
                child: TransactionList(_transactions, _removeTransaction),
              ),
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: appBar,
            child: bodyPage,
          )
        : Scaffold(
            appBar: appBar,
            body: bodyPage,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    onPressed: () => _openTransactionFormModal(context),
                    child: Icon(Icons.add),
                    backgroundColor: Colors.amber,
                  ),
          );
  }
}
