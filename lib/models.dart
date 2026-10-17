class Bank {
  final String id;
  final String name;
  Bank({required this.id, required this.name});
  
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  
  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
    id: json['id'], 
    name: json['name']
  );
}

class Person {
  final String id;
  final String name;
  final int iconIndex;
  final String colorHex;
  Map<String, double> wallets; // 'cash' أو 'bank_id' : الرصيد
  
  Person({
    required this.id, 
    required this.name, 
    required this.iconIndex, 
    required this.colorHex, 
    required this.wallets
  });
  
  double get totalBalance => wallets.values.fold(0.0, (a, b) => a + b);
  
  Map<String, dynamic> toJson() => {
    'id': id, 
    'name': name, 
    'iconIndex': iconIndex, 
    'colorHex': colorHex, 
    'wallets': wallets
  };
  
  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'], 
    name: json['name'], 
    iconIndex: json['iconIndex'], 
    colorHex: json['colorHex'],
    wallets: Map<String, double>.from(json['wallets'].map((k, v) => MapEntry(k, v.toDouble()))),
  );
}

class AppTransaction {
  final String id;
  final String type; // 'dep' للإيداع, 'wd' للسحب, 'tr' للتحويل
  final double amount;
  final String note;
  final String date;
  final String? fromPerson;
  final String? fromWallet;
  final String? toPerson;
  final String? toWallet;
  
  AppTransaction({
    required this.id, 
    required this.type, 
    required this.amount, 
    required this.note, 
    required this.date, 
    this.fromPerson, 
    this.fromWallet, 
    this.toPerson, 
    this.toWallet
  });
  
  Map<String, dynamic> toJson() => {
    'id': id, 
    'type': type, 
    'amount': amount, 
    'note': note, 
    'date': date, 
    'fromPerson': fromPerson, 
    'fromWallet': fromWallet, 
    'toPerson': toPerson, 
    'toWallet': toWallet
  };
  
  factory AppTransaction.fromJson(Map<String, dynamic> json) => AppTransaction(
    id: json['id'], 
    type: json['type'], 
    amount: json['amount'].toDouble(), 
    note: json['note'], 
    date: json['date'], 
    fromPerson: json['fromPerson'], 
    fromWallet: json['fromWallet'], 
    toPerson: json['toPerson'], 
    toWallet: json['toWallet'],
  );
}
