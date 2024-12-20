import 'dart:math';

import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uangkoo/models/database.dart';
import 'package:uangkoo/models/transaction_with_category.dart';
import 'package:uangkoo/pages/category_page.dart';
import 'package:uangkoo/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rekap per bulan
            StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByMonthRepo(
                widget.selectedDate.month,
                widget.selectedDate.year,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData) {
                  final transactions = snapshot.data!;
                  double income = 0;
                  double expense = 0;

                  // Perhitungan income dan expense
                  for (var transaction in transactions) {
                    if (transaction.category.type == 1) {
                      income += transaction.transaction.amount ?? 0;
                    } else if (transaction.category.type == 2) {
                      expense += transaction.transaction.amount ?? 0;
                    }
                  }

                  double balance = income - expense;

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFinanceInfo(
                                Icons.account_balance_wallet,
                                Colors.blue[400]!,
                                'Sisa Uang',
                                'Rp ${NumberFormat('#,##0').format(balance)}',
                              ),
                              _buildFinanceInfo(
                                Icons.upload,
                                Colors.redAccent[400]!,
                                'Expense',
                                'Rp ${NumberFormat('#,##0').format(expense)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text("No data available"),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Transactions",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionItem(snapshot.data![index]);
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          "Belum ada transaksi",
                          style: GoogleFonts.montserrat(),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceInfo(
      IconData icon, Color color, String title, String amount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              amount,
              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionWithCategory transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 10,
        child: ListTile(
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Implement delete functionality
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                    builder: (context) =>
                        TransactionPage(transactionsWithCategory: transaction),
                  ))
                      .then((value) {
                    // Refresh data if needed
                    setState(() {});
                  });
                },
              )
            ],
          ),
          subtitle: Text(transaction.category.name),
          leading: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction.category.type == 1 ? Icons.download : Icons.upload,
              color: transaction.category.type == 1
                  ? Colors.greenAccent[400]
                  : Colors.red[400],
            ),
          ),
          title: Text(
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(transaction.transaction.amount ?? 0),
          ),
        ),
      ),
    );
  }
}
