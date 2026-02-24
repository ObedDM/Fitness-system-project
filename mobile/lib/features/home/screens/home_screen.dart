import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/consumption/screens/intake_history_screen.dart';
import 'package:mobile/features/home/widgets/home_dishes_card.dart';
import 'package:mobile/features/home/widgets/home_ingredients_card.dart';
import 'package:mobile/features/consumption/widgets/consumption_summary_widget.dart';
import '../../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _reportData;
  int _selectedDays = 1;
  bool _isLoadingReport = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadReport();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn && mounted) {
      Navigator.pushReplacementNamed(context, '/auth/login');
    }
  }

  Future<void> _loadReport() async {
    setState(() => _isLoadingReport = true);
    final data = await _authService.getConsumptionReport(days: _selectedDays);
    setState(() {
      _reportData = data;
      _isLoadingReport = false;
    });
  }

  Future<void> _loadReportWithDays(int days) async {
    setState(() => _isLoadingReport = true);
    final data = await _authService.getConsumptionReport(days: days);
    setState(() {
      _reportData = data;
      _isLoadingReport = false;
    });
  }

  void _showDaysWithLogs() {
    final allDays = _reportData!['data'] as List;
    final daysWithLogs = allDays.where((day) => (day['logs'] as List).isNotEmpty).toList();

    if (daysWithLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logs found for this period')),
      );
      return;
    }

    if (_selectedDays == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IntakeHistoryScreen(
            logs: daysWithLogs[0]['logs'],
            date: DateTime.parse(daysWithLogs[0]['date']),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: daysWithLogs.length,
        itemBuilder: (context, index) {
          final dayData = daysWithLogs[index];
          final date = DateTime.parse(dayData['date']);
          final logsCount = (dayData['logs'] as List).length;

          return ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.blue),
            title: Text(DateFormat('MMM dd, yyyy').format(date)),
            subtitle: Text('$logsCount entries • ${dayData['total_calories'].toStringAsFixed(0)} kcal'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IntakeHistoryScreen(
                    logs: dayData['logs'],
                    date: date,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReport,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.trackpad,
            },
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('1D'), icon: Icon(Icons.today)),
                      ButtonSegment(value: 7, label: Text('7D'), icon: Icon(Icons.date_range)),
                      ButtonSegment(value: 30, label: Text('30D'), icon: Icon(Icons.calendar_month)),
                    ],
                    selected: {_selectedDays},
                    onSelectionChanged: (newSelection) {
                      final selectedDays = newSelection.first;
                      setState(() => _selectedDays = selectedDays);
                      _loadReportWithDays(selectedDays);
                    },
                  ),

                  const SizedBox(height: 24),

                  _isLoadingReport
                      ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
                      : Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                if (_reportData != null && (_reportData!['data'] as List).isNotEmpty) {
                                  _showDaysWithLogs();
                                }
                              },
                              child: ConsumptionSummaryWidget(data: _reportData, days: _selectedDays),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tap summary to view details",
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),

                  const SizedBox(height: 32),

                  const Text(
                    'Explore',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),
                  HomeIngredientsCard(onRefresh: _loadReport),
                  const SizedBox(height: 16),
                  HomeDishesCard(onRefresh: _loadReport),

                  const SizedBox(height: 40),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await _authService.logout();
                      if (mounted) Navigator.pushReplacementNamed(context, '/auth/login');
                    },
                    child: const Text('Log out', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
