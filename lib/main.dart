import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'app_state.dart';
import 'models.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..loadData(),
      child: const MizanApp(),
    ),
  );
}

class MizanApp extends StatelessWidget {
  const MizanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ميزان',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A365D),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        textTheme: GoogleFonts.tajawalTextTheme(),
        useMaterial3: true,
      ),
      // إجبار التطبيق على الاتجاه من اليمين لليسار
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const MainScreen(),
    );
  }
}

// ==================== الشاشة الرئيسية ====================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ClientsScreen(),
    const OperationsScreen(),
    const LogScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A365D),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'الحسابات'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'عملية'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'السجل'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'التقارير'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

// ==================== 1. شاشة الحسابات (لوحة التحكم) ====================
class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ميزان - الحسابات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A365D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // البطاقة الرئيسية (Hero)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2B6CB0), Color(0xFF1A365D)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF1A365D).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إجمالي الأرصدة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('${state.totalOverall.toStringAsFixed(2)} ${state.currency}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildChip('الصندوق: ${state.totalCash.toStringAsFixed(0)}'),
                      const SizedBox(width: 8),
                      _buildChip('البنوك: ${state.totalBanks.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // شبكة الحسابات
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9,
              ),
              itemCount: state.people.length + 1,
              itemBuilder: (context, index) {
                if (index == state.people.length) {
                  return _buildAddButton(context);
                }
                final p = state.people[index];
                return _buildPersonCard(context, p, state);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPersonCard(BuildContext context, Person p, AppState state) {
    return GestureDetector(
      onTap: () => _showPersonDetails(context, p),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Color(int.parse(p.colorHex.replaceAll('#', '0xFF'))),
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 12),
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('${p.totalBalance.toStringAsFixed(2)} ${state.currency}', style: const TextStyle(color: Color(0xFF1A365D), fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wallet, size: 14, color: Colors.grey[600]),
                Text(' ${(p.wallets['cash'] ?? 0).toStringAsFixed(0)} ', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                Icon(Icons.account_balance, size: 14, color: Colors.grey[600]),
                Text(' ${(p.totalBalance - (p.wallets['cash'] ?? 0)).toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddPersonModal(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400, width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade200, child: const Icon(Icons.add, color: Color(0xFF1A365D), size: 30)),
            const SizedBox(height: 12),
            const Text('حساب جديد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showAddPersonModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('إضافة حساب جديد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A365D))),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الحساب', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: balanceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'رصيد افتتاحي (اختياري)', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      context.read<AppState>().addPerson(nameCtrl.text, 0, '#3B82F6', double.tryParse(balanceCtrl.text) ?? 0);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('حفظ الحساب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showPersonDetails(BuildContext context, Person p) {
    final state = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A365D))),
              const SizedBox(height: 8),
              Text('إجمالي الرصيد: ${p.totalBalance.toStringAsFixed(2)} ${state.currency}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              ListTile(
                leading: const Icon(Icons.wallet, color: Color(0xFF10B981)),
                title: const Text('الصندوق النقدي'),
                trailing: Text('${(p.wallets['cash'] ?? 0).toStringAsFixed(2)} ${state.currency}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...state.banks.map((b) => ListTile(
                leading: const Icon(Icons.account_balance, color: Color(0xFF2B6CB0)),
                title: Text(b.name),
                trailing: Text('${(p.wallets[b.id] ?? 0).toStringAsFixed(2)} ${state.currency}', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// ==================== 2. شاشة العمليات ====================
class OperationsScreen extends StatefulWidget {
  const OperationsScreen({super.key});

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  String _opType = 'dep'; // dep, wd, tr
  String? _fromPersonId;
  String? _toPersonId;
  String _fromWallet = 'cash';
  String _toWallet = 'cash';
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.people.isEmpty) {
      return const Center(child: Text('أضف حساباً أولاً من شاشة الحسابات', style: TextStyle(color: Colors.grey)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('إجراء عملية', style: TextStyle(color: Colors.white)), centerTitle: true, backgroundColor: const Color(0xFF1A365D)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // اختيار نوع العملية
            Row(
              children: [
                _buildTypeBtn('إيداع', 'dep', Icons.arrow_downward, const Color(0xFF10B981)),
                const SizedBox(width: 10),
                _buildTypeBtn('سحب', 'wd', Icons.arrow_upward, const Color(0xFFEF4444)),
                const SizedBox(width: 10),
                _buildTypeBtn('تحويل', 'tr', Icons.swap_horiz, const Color(0xFF2B6CB0)),
              ],
            ),
            const SizedBox(height: 20),
            
            // الحساب المصدر / المستقبل
            if (_opType != 'dep') _buildPersonSelector(state, 'من حساب (خصم)', true),
            if (_opType == 'tr') const SizedBox(height: 10),
            if (_opType != 'wd') _buildPersonSelector(state, 'إلى حساب (إضافة)', false),
            
            const SizedBox(height: 20),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A365D)), textAlign: TextAlign.center, decoration: InputDecoration(hintText: '0.00', labelText: 'المبلغ (${state.currency})', border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'ملاحظة / البيان (اختياري)', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A365D), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text) ?? 0;
                  final error = context.read<AppState>().executeTransaction(
                    _opType, amount,
                    _opType != 'dep' ? _fromPersonId : null,
                    _opType != 'dep' ? _fromWallet : null,
                    _opType != 'wd' ? _toPersonId : null,
                    _opType != 'wd' ? _toWallet : null,
                    noteCtrl.text,
                  );
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت العملية بنجاح'), backgroundColor: Colors.green));
                    amountCtrl.clear(); noteCtrl.clear();
                  }
                },
                child: const Text('تنفيذ العملية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBtn(String label, String type, IconData icon, Color color) {
    final isSel = _opType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _opType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSel ? color : Colors.grey.shade300),
            boxShadow: isSel ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSel ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonSelector(AppState state, String label, bool isFrom) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A365D))),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            value: isFrom ? _fromPersonId : _toPersonId,
            hint: const Text('اختر الحساب'),
            items: state.people.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
            onChanged: (val) => setState(() { if (isFrom) { _fromPersonId = val; } else { _toPersonId = val; } }),
          ),
        ],
      ),
    );
  }
}

// ==================== 3. شاشة السجل ====================
class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('سجل الحركات', style: TextStyle(color: Colors.white)), centerTitle: true, backgroundColor: const Color(0xFF1A365D)),
      body: state.transactions.isEmpty
          ? const Center(child: Text('لا توجد حركات مسجلة', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final t = state.transactions[index];
                final isDep = t.type == 'dep';
                final isWd = t.type == 'wd';
                final color = isDep ? const Color(0xFF10B981) : isWd ? const Color(0xFFEF4444) : const Color(0xFF2B6CB0);
                final icon = isDep ? Icons.arrow_downward : isWd ? Icons.arrow_upward : Icons.swap_horiz;
                
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
                    title: Text(isDep ? 'إيداع' : isWd ? 'سحب' : 'تحويل', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(t.date))}\n${t.note}', style: const TextStyle(fontSize: 12)),
                    isThreeLine: true,
                    trailing: Text('${isDep ? '+' : isWd ? '-' : ''}${t.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                  ),
                );
              },
            ),
    );
  }
}

// ==================== 4. شاشة التقارير ====================
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    double totalDep = 0, totalWd = 0;
    for (var t in state.transactions) {
      if (t.type == 'dep') totalDep += t.amount;
      if (t.type == 'wd') totalWd += t.amount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير', style: TextStyle(color: Colors.white)), centerTitle: true, backgroundColor: const Color(0xFF1A365D)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard('إجمالي الإيداعات', totalDep, const Color(0xFF10B981))),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('إجمالي السحوبات', totalWd, const Color(0xFFEF4444))),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('توزيع الأموال الحالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A365D))),
                    const Divider(height: 24),
                    _buildProgressBar('الصندوق النقدي', state.totalCash, state.totalOverall, const Color(0xFF10B981)),
                    const SizedBox(height: 12),
                    ...state.banks.map((b) {
                      double bankTotal = state.people.fold(0.0, (sum, p) => sum + (p.wallets[b.id] ?? 0));
                      return _buildProgressBar(b.name, bankTotal, state.totalOverall, const Color(0xFF2B6CB0));
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Text(amount.toStringAsFixed(2), style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, double total, Color color) {
    double percent = total == 0 ? 0 : (value / total).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(value.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: percent, backgroundColor: Colors.grey.shade200, color: color, minHeight: 10, borderRadius: BorderRadius.circular(5)),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ==================== 5. شاشة الإعدادات ====================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات', style: TextStyle(color: Colors.white)), centerTitle: true, backgroundColor: const Color(0xFF1A365D)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.monetization_on, color: Color(0xFF2B6CB0)),
              title: const Text('العملة الافتراضية'),
              trailing: Text(state.currency, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onTap: () {
                // يمكن إضافة تغيير العملة هنا لاحقاً
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text('إدارة البنوك', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          ...state.banks.map((b) => Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.account_balance, color: Color(0xFF2B6CB0)),
              title: Text(b.name),
            ),
          )),
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
              icon: const Icon(Icons.delete_forever),
              label: const Text('مسح كل البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                showDialog(context: context, builder: (ctx) => AlertDialog(
                  title: const Text('تحذير'),
                  content: const Text('هل أنت متأكد من مسح جميع البيانات؟ لا يمكن التراجع عن هذه الخطوة.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                    TextButton(onPressed: () {
                      // كود مسح البيانات
                      Navigator.pop(ctx);
                    }, child: const Text('مسح', style: TextStyle(color: Colors.red))),
                  ],
                ));
              },
            ),
          )
        ],
      ),
    );
  }
}
