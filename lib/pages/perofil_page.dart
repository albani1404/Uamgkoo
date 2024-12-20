import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uangkoo/models/database.dart';
import 'package:uangkoo/models/transaction_with_category.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final AppDb database = AppDb();
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initial setup or logic here if needed.
  }

  Future<void> _selectMonth() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && selectedDate != currentDate) {
      setState(() {
        currentDate = DateTime(selectedDate.year, selectedDate.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectMonth,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<List<TransactionWithCategory>>(
                stream: database.getTransactionByMonthRepo(
                  currentDate.month,
                  currentDate.year,
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
                            Text(
                              DateFormat('MMMM yyyy').format(currentDate),
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildFinanceInfo(
                              Icons.download,
                              Colors.greenAccent[400]!,
                              'Income',
                              'Rp ${NumberFormat('#,##0').format(income)}',
                            ),
                            const SizedBox(height: 10),
                            _buildFinanceInfo(
                              Icons.upload,
                              Colors.redAccent[400]!,
                              'Expense',
                              'Rp ${NumberFormat('#,##0').format(expense)}',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceInfo(
      IconData icon, Color color, String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Text(title,
                  style: GoogleFonts.montserrat(
                      fontSize: 16, color: Colors.white)),
            ],
          ),
          Text(amount,
              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}
