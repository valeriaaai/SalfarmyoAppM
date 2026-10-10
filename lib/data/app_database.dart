import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;
  Future<Database>? _opening;

  Future<Database> get database async {
    if (_database != null) return _database!;
    return _opening ??= _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final root = await getDatabasesPath();
    _database = await openDatabase(
      p.join(root, 'salfarmyo.db'),
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await _createTables(db);
        await _seed(db);
      },
    );
    return _database!;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE admin (
        admin_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        full_name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE boarder (
        boarder_id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        contact_number TEXT NOT NULL,
        emergency_contact TEXT NOT NULL DEFAULT '',
        date_added TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE room (
        room_id INTEGER PRIMARY KEY AUTOINCREMENT,
        building INTEGER NOT NULL,
        room_number TEXT NOT NULL UNIQUE,
        room_type TEXT NOT NULL CHECK (room_type IN ('double_deck', 'solo')),
        monthly_rate REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE bed (
        bed_id INTEGER PRIMARY KEY AUTOINCREMENT,
        room_id INTEGER NOT NULL REFERENCES room(room_id) ON DELETE CASCADE,
        code TEXT NOT NULL,
        position TEXT NOT NULL,
        UNIQUE (room_id, code)
      )
    ''');
    await db.execute('''
      CREATE TABLE room_assignment (
        assignment_id INTEGER PRIMARY KEY AUTOINCREMENT,
        boarder_id INTEGER NOT NULL REFERENCES boarder(boarder_id) ON DELETE CASCADE,
        bed_id INTEGER NOT NULL REFERENCES bed(bed_id),
        date_assigned TEXT NOT NULL,
        status TEXT NOT NULL CHECK (status IN ('active', 'ended'))
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX one_active_bed_per_boarder
      ON room_assignment(boarder_id) WHERE status = 'active'
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX one_active_boarder_per_bed
      ON room_assignment(bed_id) WHERE status = 'active'
    ''');
    await db.execute('''
      CREATE TABLE rent_charge (
        charge_id INTEGER PRIMARY KEY AUTOINCREMENT,
        boarder_id INTEGER NOT NULL REFERENCES boarder(boarder_id) ON DELETE CASCADE,
        billing_month TEXT NOT NULL,
        amount_due REAL NOT NULL CHECK (amount_due > 0),
        due_date TEXT NOT NULL,
        UNIQUE (boarder_id, billing_month)
      )
    ''');
    await db.execute('''
      CREATE TABLE payment (
        payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
        charge_id INTEGER NOT NULL REFERENCES rent_charge(charge_id) ON DELETE CASCADE,
        amount REAL NOT NULL CHECK (amount > 0),
        payment_date TEXT NOT NULL,
        remarks TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE complaint (
        complaint_id INTEGER PRIMARY KEY AUTOINCREMENT,
        boarder_id INTEGER NOT NULL REFERENCES boarder(boarder_id) ON DELETE CASCADE,
        description TEXT NOT NULL,
        date_reported TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Unresolved'
          CHECK (status IN ('Unresolved', 'Being handled', 'Resolved'))
      )
    ''');
  }

  Future<void> _seed(Database db) async {
    final salt = _newSalt();
    await db.insert('admin', {
      'username': 'admin',
      'password_hash': _passwordHash('admin123', salt),
      'salt': salt,
      'full_name': 'Lydia Diaz',
    });
    const rate = 3500.0;
    for (final room in ['101', '102', '103', '104', '105']) {
      final id = await db.insert('room', {
        'building': 1,
        'room_number': room,
        'room_type': 'double_deck',
        'monthly_rate': rate,
      });
      for (final bed in [
        ['1T', 'Top'],
        ['1B', 'Bottom'],
        ['1AT', 'Top'],
        ['1AB', 'Bottom'],
      ]) {
        await db.insert('bed', {
          'room_id': id,
          'code': bed[0],
          'position': bed[1],
        });
      }
    }
    for (var number = 201; number <= 216; number++) {
      final id = await db.insert('room', {
        'building': 2,
        'room_number': '$number',
        'room_type': 'solo',
        'monthly_rate': rate,
      });
      await db.insert('bed', {
        'room_id': id,
        'code': 'SOLO',
        'position': 'Private',
      });
    }

    final now = DateTime.now();
    final thisMonth = _month(now);
    final previousMonth = _month(DateTime(now.year, now.month, 0));
    final sample = [
      [
        'Maria',
        'Santos',
        '09171230001',
        'Ana Santos 09181230001',
        '101',
        '1T',
        1.0,
      ],
      [
        'Jenny',
        'Reyes',
        '09171230002',
        'Rosa Reyes 09181230002',
        '101',
        '1B',
        0.5,
      ],
      [
        'Liza',
        'Cruz',
        '09171230003',
        'Nena Cruz 09181230003',
        '102',
        '1AT',
        0.0,
      ],
      [
        'Angela',
        'Garcia',
        '09171230004',
        'Tess Garcia 09181230004',
        '201',
        'SOLO',
        1.0,
      ],
      [
        'Katrina',
        'Lopez',
        '09171230005',
        'Mila Lopez 09181230005',
        '203',
        'SOLO',
        0.0,
      ],
      [
        'Bianca',
        'Ramos',
        '09171230006',
        'Gina Ramos 09181230006',
        '206',
        'SOLO',
        0.5,
      ],
    ];
    final boarderIds = <int>[];
    for (final person in sample) {
      final id = await db.insert('boarder', {
        'first_name': person[0],
        'last_name': person[1],
        'contact_number': person[2],
        'emergency_contact': person[3],
        'date_added': _date(now),
      });
      boarderIds.add(id);
      final bed = await db.rawQuery(
        'SELECT bd.bed_id FROM bed bd JOIN room r ON r.room_id = bd.room_id '
        'WHERE r.room_number = ? AND bd.code = ?',
        [person[4], person[5]],
      );
      await db.insert('room_assignment', {
        'boarder_id': id,
        'bed_id': bed.first['bed_id'],
        'date_assigned': _date(now),
        'status': 'active',
      });
      final previous = await db.insert('rent_charge', {
        'boarder_id': id,
        'billing_month': previousMonth,
        'amount_due': rate,
        'due_date': '$previousMonth-05',
      });
      await db.insert('payment', {
        'charge_id': previous,
        'amount': rate,
        'payment_date': '$previousMonth-05',
        'remarks': 'Paid in full',
      });
      final current = await db.insert('rent_charge', {
        'boarder_id': id,
        'billing_month': thisMonth,
        'amount_due': rate,
        'due_date': '$thisMonth-05',
      });
      final share = person[6] as double;
      if (share > 0) {
        await db.insert('payment', {
          'charge_id': current,
          'amount': rate * share,
          'payment_date': _date(now),
          'remarks': share == 1 ? 'Paid in full' : 'Partial payment',
        });
      }
    }
    await db.insert('complaint', {
      'boarder_id': boarderIds[0],
      'description': 'Leaking faucet in the bathroom.',
      'date_reported': _date(now),
      'status': 'Being handled',
    });
    await db.insert('complaint', {
      'boarder_id': boarderIds[2],
      'description': 'Wi-Fi signal is weak inside the room.',
      'date_reported': _date(now),
      'status': 'Unresolved',
    });
  }

  Future<Map<String, Object?>?> authenticate(
    String username,
    String password,
  ) async {
    final db = await database;
    final rows = await db.query(
      'admin',
      where: 'username = ?',
      whereArgs: [username.trim()],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    if (_passwordHash(password, row['salt']! as String) !=
        row['password_hash']) {
      return null;
    }
    return row;
  }

  Future<Map<String, int>> summary() async {
    final db = await database;
    final occupied = Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT COUNT(DISTINCT bd.room_id) FROM room_assignment a "
        "JOIN bed bd ON bd.bed_id = a.bed_id WHERE a.status = 'active'",
      ),
    )!;
    final available = Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT COUNT(*) FROM bed WHERE bed_id NOT IN "
        "(SELECT bed_id FROM room_assignment WHERE status = 'active')",
      ),
    )!;
    final boarders = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM boarder'),
    )!;
    final unpaid =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(DISTINCT c.boarder_id)
      FROM rent_charge c
      WHERE c.amount_due > COALESCE((
        SELECT SUM(p.amount) FROM payment p WHERE p.charge_id = c.charge_id
      ), 0)
    '''),
        ) ??
        0;
    final complaints = Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT COUNT(*) FROM complaint WHERE status != 'Resolved'",
      ),
    )!;
    return {
      'occupiedRooms': occupied,
      'availableBeds': available,
      'boarders': boarders,
      'unpaid': unpaid,
      'complaints': complaints,
    };
  }

  Future<List<Map<String, Object?>>> boarders([String search = '']) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT b.boarder_id, b.first_name, b.last_name, b.contact_number,
        b.emergency_contact, b.date_added, r.room_number, bd.code AS bed_code
      FROM boarder b
      LEFT JOIN room_assignment a ON a.boarder_id = b.boarder_id AND a.status = 'active'
      LEFT JOIN bed bd ON bd.bed_id = a.bed_id
      LEFT JOIN room r ON r.room_id = bd.room_id
      WHERE (b.first_name || ' ' || b.last_name || ' ' || b.contact_number) LIKE ?
      ORDER BY b.last_name, b.first_name
    ''',
      ['%${search.trim()}%'],
    );
  }

  Future<Map<String, Object?>?> boarder(int id) async {
    final rows = await boarders();
    for (final row in rows) {
      if (row['boarder_id'] == id) return row;
    }
    return null;
  }

  Future<int> saveBoarder({
    int? id,
    required String first,
    required String last,
    required String phone,
    String emergency = '',
  }) async {
    final db = await database;
    if (first.trim().isEmpty || last.trim().isEmpty || phone.trim().isEmpty) {
      throw Exception(
        'First name, last name, and contact number are required.',
      );
    }
    if (phone.trim().length < 7) {
      throw Exception('Enter a valid contact number.');
    }
    final duplicate = await db.query(
      'boarder',
      where:
          'lower(first_name) = lower(?) AND lower(last_name) = lower(?) '
          'AND contact_number = ? AND boarder_id != ?',
      whereArgs: [first.trim(), last.trim(), phone.trim(), id ?? 0],
    );
    if (duplicate.isNotEmpty) {
      throw Exception(
        'A boarder with the same name and number already exists.',
      );
    }
    final values = {
      'first_name': first.trim(),
      'last_name': last.trim(),
      'contact_number': phone.trim(),
      'emergency_contact': emergency.trim(),
    };
    if (id == null) {
      return db.insert('boarder', {
        ...values,
        'date_added': _date(DateTime.now()),
      });
    }
    await db.update(
      'boarder',
      values,
      where: 'boarder_id = ?',
      whereArgs: [id],
    );
    return id;
  }

  Future<void> deleteBoarder(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('complaint', where: 'boarder_id = ?', whereArgs: [id]);
      await txn.delete(
        'payment',
        where:
            'charge_id IN (SELECT charge_id FROM rent_charge WHERE boarder_id = ?)',
        whereArgs: [id],
      );
      await txn.delete('rent_charge', where: 'boarder_id = ?', whereArgs: [id]);
      await txn.update(
        'room_assignment',
        {'status': 'ended'},
        where: "boarder_id = ? AND status = 'active'",
        whereArgs: [id],
      );
      await txn.delete('boarder', where: 'boarder_id = ?', whereArgs: [id]);
    });
  }

  Future<List<Map<String, Object?>>> beds() async {
    final db = await database;
    return db.rawQuery('''
      SELECT bd.bed_id, bd.code, bd.position, r.room_number, r.building, r.monthly_rate,
        a.boarder_id, b.first_name || ' ' || b.last_name AS occupant
      FROM bed bd JOIN room r ON r.room_id = bd.room_id
      LEFT JOIN room_assignment a ON a.bed_id = bd.bed_id AND a.status = 'active'
      LEFT JOIN boarder b ON b.boarder_id = a.boarder_id
      ORDER BY r.building, r.room_number, bd.bed_id
    ''');
  }

  Future<void> assignBed(int boarderId, int bedId) async {
    final db = await database;
    await db.transaction((txn) async {
      final bed = await txn.query(
        'room_assignment',
        where: "bed_id = ? AND status = 'active'",
        whereArgs: [bedId],
      );
      if (bed.isNotEmpty) throw Exception('That bed is already occupied.');
      await txn.update(
        'room_assignment',
        {'status': 'ended'},
        where: "boarder_id = ? AND status = 'active'",
        whereArgs: [boarderId],
      );
      await txn.insert('room_assignment', {
        'boarder_id': boarderId,
        'bed_id': bedId,
        'date_assigned': _date(DateTime.now()),
        'status': 'active',
      });
    });
  }

  Future<List<Map<String, Object?>>> charges([String search = '']) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT c.charge_id, c.boarder_id, b.first_name || ' ' || b.last_name AS boarder_name,
        c.billing_month, c.amount_due, c.due_date, COALESCE(SUM(p.amount), 0) AS amount_paid
      FROM rent_charge c JOIN boarder b ON b.boarder_id = c.boarder_id
      LEFT JOIN payment p ON p.charge_id = c.charge_id
      WHERE (b.first_name || ' ' || b.last_name || ' ' || c.billing_month) LIKE ?
      GROUP BY c.charge_id ORDER BY c.due_date DESC, b.last_name
    ''',
      ['%${search.trim()}%'],
    );
  }

  Future<int> addCharge(
    int boarderId,
    String month,
    double amount,
    String dueDate,
  ) async {
    if (amount <= 0) throw Exception('Rent amount must be greater than zero.');
    final db = await database;
    final duplicate = await db.query(
      'rent_charge',
      where: 'boarder_id = ? AND billing_month = ?',
      whereArgs: [boarderId, month],
    );
    if (duplicate.isNotEmpty) {
      throw Exception('Rent for $month is already recorded for this boarder.');
    }
    return db.insert('rent_charge', {
      'boarder_id': boarderId,
      'billing_month': month,
      'amount_due': amount,
      'due_date': dueDate,
    });
  }

  Future<void> recordPayment(
    int chargeId,
    double amount,
    String remarks,
  ) async {
    if (amount <= 0) throw Exception('Payment must be greater than zero.');
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT c.amount_due - COALESCE(SUM(p.amount), 0) AS balance
      FROM rent_charge c LEFT JOIN payment p ON p.charge_id = c.charge_id
      WHERE c.charge_id = ? GROUP BY c.charge_id
    ''',
      [chargeId],
    );
    if (rows.isEmpty) throw Exception('Rent record was not found.');
    final balance = (rows.first['balance']! as num).toDouble();
    if (amount > balance + 0.001) {
      throw Exception('Payment is greater than the remaining balance.');
    }
    await db.insert('payment', {
      'charge_id': chargeId,
      'amount': amount,
      'payment_date': _date(DateTime.now()),
      'remarks': remarks.trim(),
    });
  }

  Future<List<Map<String, Object?>>> payments(int boarderId) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT p.payment_id, p.payment_date, p.amount, p.remarks, c.billing_month
      FROM payment p JOIN rent_charge c ON c.charge_id = p.charge_id
      WHERE c.boarder_id = ? ORDER BY p.payment_date DESC, p.payment_id DESC
    ''',
      [boarderId],
    );
  }

  Future<List<Map<String, Object?>>> complaints([String search = '']) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT c.complaint_id, c.boarder_id, b.first_name || ' ' || b.last_name AS boarder_name,
        c.description, c.date_reported, c.status
      FROM complaint c JOIN boarder b ON b.boarder_id = c.boarder_id
      WHERE (b.first_name || ' ' || b.last_name || ' ' || c.description || ' ' || c.status) LIKE ?
      ORDER BY c.date_reported DESC, c.complaint_id DESC
    ''',
      ['%${search.trim()}%'],
    );
  }

  Future<void> addComplaint(int boarderId, String description) async {
    if (description.trim().isEmpty) {
      throw Exception('Complaint description is required.');
    }
    final db = await database;
    await db.insert('complaint', {
      'boarder_id': boarderId,
      'description': description.trim(),
      'date_reported': _date(DateTime.now()),
      'status': 'Unresolved',
    });
  }

  Future<void> updateComplaint(int id, String status) async {
    await (await database).update(
      'complaint',
      {'status': status},
      where: 'complaint_id = ?',
      whereArgs: [id],
    );
  }

  String _newSalt() {
    final random = Random.secure();
    return List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  String _passwordHash(String password, String saltHex) {
    final salt = Uint8List.fromList(
      List.generate(
        saltHex.length ~/ 2,
        (i) => int.parse(saltHex.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );
    const iterations = 100000;
    final block = Uint8List(salt.length + 4)..setRange(0, salt.length, salt);
    block[salt.length + 3] = 1;
    final hmac = Hmac(sha256, utf8.encode(password));
    var result = List<int>.from(hmac.convert(block).bytes);
    var previous = result;
    for (var i = 1; i < iterations; i++) {
      previous = List<int>.from(hmac.convert(previous).bytes);
      for (var j = 0; j < result.length; j++) {
        result[j] ^= previous[j];
      }
    }
    return result.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _month(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
}
