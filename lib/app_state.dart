import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  String currency = 'ج.س';
  List<Bank> banks = [Bank(id: 'b1', name: 'بنك الخرطوم'), Bank(id: 'b2', name: 'بنك فيصل')];
  List<Person> people = [];
  List<AppTransaction> transactions = [];

  // تحميل البيانات من ذاكرة الهاتف
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('mizan_data');
    if (data != null) {
      final Map<String, dynamic> parsed = jsonDecode(data);
      currency = parsed['currency'] ?? 'ج.س';
      banks = (parsed['banks'] as List).map((e) => Bank.fromJson(e)).toList();
      people = (parsed['people'] as List).map((e) => Person.fromJson(e)).toList();
      transactions = (parsed['transactions'] as List).map((e) => AppTransaction.fromJson(e)).toList();
      notifyListeners(); // تحديث الواجهات
    }
  }

  // حفظ البيانات في ذاكرة الهاتف
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({
      'currency': currency,
      'banks': banks.map((b) => b.toJson()).toList(),
      'people': people.map((p) => p.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
    });
    await prefs.setString('mizan_data', data);
  }

  // إضافة شخص جديد
  void addPerson(String name, int iconIndex, String color, double openingBalance) {
    final p = Person(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name, 
      iconIndex: iconIndex, 
      colorHex: color, 
      wallets: {'cash': openingBalance},
    );
    people.add(p);
    
    if (openingBalance > 0) {
      transactions.insert(0, AppTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'dep', 
        amount: openingBalance, 
        note: 'رصيد افتتاحي',
        date: DateTime.now().toIso8601String(),
        toPerson: p.id, 
        toWallet: 'cash',
      ));
    }
    saveData(); 
    notifyListeners();
  }

  // تنفيذ عملية (إيداع، سحب، تحويل)
  String? executeTransaction(String type, double amount, String? fromId, String? fromWallet, String? toId, String? toWallet, String note) {
    if (amount <= 0) return 'أدخل مبلغاً صحيحاً';
    
    Person? fromP = fromId != null ? people.firstWhere((p) => p.id == fromId) : null;
    Person? toP = toId != null ? people.firstWhere((p) => p.id == toId) : null;

    // التحقق من الرصيد والخصم من المرسل
    if (fromP != null && fromWallet != null) {
      if ((fromP.wallets[fromWallet] ?? 0) < amount) return 'الرصيد غير كافٍ';
      fromP.wallets[fromWallet] = (fromP.wallets[fromWallet] ?? 0) - amount;
    }
    
    // الإضافة للمستلم
    if (toP != null && toWallet != null) {
      toP.wallets[toWallet] = (toP.wallets[toWallet] ?? 0) + amount;
    }

    // تسجيل الحركة
    transactions.insert(0, AppTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type, 
      amount: amount, 
      note: note,
      date: DateTime.now().toIso8601String(),
      fromPerson: fromP?.id, 
      fromWallet: fromWallet,
      toPerson: toP?.id, 
      toWallet: toWallet,
    ));

    saveData(); 
    notifyListeners();
    return null; // لا يوجد خطأ
  }

  // حسابات إجمالية للوحة التحكم
  double get totalCash => people.fold(0.0, (sum, p) => sum + (p.wallets['cash'] ?? 0));
  double get totalBanks => people.fold(0.0, (sum, p) => sum + p.totalBalance) - totalCash;
  double get totalOverall => people.fold(0.0, (sum, p) => sum + p.totalBalance);
}
