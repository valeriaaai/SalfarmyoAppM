import 'package:flutter/material.dart';

import 'data/app_database.dart';

const ink = Color(0xFF3C2634);
const muted = Color(0xFF866F7A);
const canvas = Color(0xFFFFEAF1);
const rose = Color(0xFFD53E72);
const roseDark = Color(0xFFA32653);
const lilac = Color(0xFFDDECF7);
const green = Color(0xFF668A3C);
const amber = Color(0xFFC48A36);
const red = Color(0xFFBB3D61);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SalfarmyoApp());
}

class SalfarmyoApp extends StatelessWidget {
  const SalfarmyoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Salfarmyo Dormitory',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: roseDark,
        primary: roseDark,
        surface: const Color.fromARGB(255, 255, 179, 203),
      ),
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFFFDCE7),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 249, 192, 213),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 185, 108, 138),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: rose, width: 1.5),
        ),
      ),
    ),
    home: const LoginScreen(),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _username = TextEditingController();
  final _password = TextEditingController();
  late final AnimationController _controller;
  late final AnimationController _ambientController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, .12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _ambientController.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final admin = await AppDatabase.instance.authenticate(
        _username.text,
        _password.text,
      );
      if (!mounted) return;
      if (admin == null) {
        setState(() => _error = 'Incorrect username or password.');
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (_, animation, _) => FadeTransition(
              opacity: animation,
              child: HomeScreen(adminName: admin['full_name']! as String),
            ),
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not open local database: $error');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFE0E9),
                  Color(0xFFFFF4F6),
                  Color(0xFFFFEAF1),
                ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -70,
            child: AnimatedBuilder(
              animation: _ambientController,
              child: _orb(250, const Color(0x44E96791)),
              builder: (_, child) => Transform.translate(
                offset: Offset(
                  -8 + 20 * _ambientController.value,
                  12 * _ambientController.value,
                ),
                child: child,
              ),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -90,
            child: AnimatedBuilder(
              animation: _ambientController,
              child: _orb(290, const Color(0x44D53E72)),
              builder: (_, child) => Transform.translate(
                offset: Offset(
                  12 * _ambientController.value,
                  -8 + 16 * _ambientController.value,
                ),
                child: child,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: .09,
                child: Image.asset(
                  'assets/floorkineme_faded.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -.08),
                          end: Offset.zero,
                        ).animate(_fade),
                        child: FadeTransition(
                          opacity: _fade,
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/salfarmyoooo.png',
                                width: 250,
                                height: 84,
                                fit: BoxFit.contain,
                                semanticLabel: 'Salfarmyo Women’s Dormitory',
                              ),
                              SizedBox(height: height < 650 ? 22 : 38),
                            ],
                          ),
                        ),
                      ),
                      SlideTransition(
                        position: _slide,
                        child: FadeTransition(
                          opacity: _fade,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .94),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1E642940),
                                  blurRadius: 34,
                                  offset: Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                    color: ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Sign in to manage your dormitory.',
                                  style: TextStyle(color: muted, fontSize: 14),
                                ),
                                const SizedBox(height: 24),
                                const _FieldLabel('Username'),
                                TextField(
                                  controller: _username,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                    ),
                                    hintText: 'Enter your username',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const _FieldLabel('Password'),
                                TextField(
                                  controller: _password,
                                  obscureText: _hidePassword,
                                  onSubmitted: (_) => _login(),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                    ),
                                    hintText: 'Enter your password',
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _hidePassword = !_hidePassword,
                                      ),
                                      icon: Icon(
                                        _hidePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: FilledButton(
                                    onPressed: _busy ? null : _login,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: rose,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _busy
                                        ? const SizedBox.square(
                                            dimension: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'LOG IN',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Works offline • Your records stay on this device',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withValues(alpha: .05)]),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.adminName});
  final String adminName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  int _refresh = 0;

  void refresh() => setState(() => _refresh++);

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Dashboard',
      'Bedspace map',
      'Boarders',
      'Rent',
      'Complaints',
    ];
    final pages = [
      DashboardPage(
        name: widget.adminName,
        refreshKey: _refresh,
        onOpen: _go,
        onRefresh: refresh,
      ),
      RoomsPage(refreshKey: _refresh, onRefresh: refresh),
      BoardersPage(refreshKey: _refresh, onRefresh: refresh),
      RentPage(refreshKey: _refresh, onRefresh: refresh),
      ComplaintsPage(refreshKey: _refresh, onRefresh: refresh),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
              (_) => false,
            ),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() {
          _index = value;
          if (value == 3) _refresh++;
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Rooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Boarders',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'Rent',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Issues',
          ),
        ],
      ),
    );
  }

  void _go(int index) => setState(() => _index = index);
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.name,
    required this.refreshKey,
    required this.onOpen,
    required this.onRefresh,
  });
  final String name;
  final int refreshKey;
  final ValueChanged<int> onOpen;
  final VoidCallback onRefresh;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, int>? _summary;
  List<Map<String, Object?>> _people = [];
  List<Map<String, Object?>> _charges = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) _load();
  }

  Future<void> _load() async {
    try {
      final db = AppDatabase.instance;
      final results = await Future.wait([
        db.summary(),
        db.boarders(),
        db.charges(),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0] as Map<String, int>;
        _people = results[1] as List<Map<String, Object?>>;
        _charges = results[2] as List<Map<String, Object?>>;
        _loading = false;
      });
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not load dashboard: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: rose));
    }
    final stats = _summary ?? {};
    return RefreshIndicator(
      color: rose,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFD94475), Color(0xFFA32653)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33441F31),
                  blurRadius: 20,
                  offset: Offset(0, 9),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GOOD DAY,',
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Here’s your dormitory at a glance.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.home_work_rounded,
                  color: Colors.white70,
                  size: 48,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DashboardRentCard(charges: _charges, onTap: () => widget.onOpen(3)),
          const SizedBox(height: 20),
          const _SectionTitle('Overview', subtitle: 'Your property today'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.42,
            children: [
              _StatCard(
                label: 'Boarders',
                value: stats['boarders'] ?? 0,
                icon: Icons.people_alt_rounded,
                tint: const Color(0xFFDDECF7),
                onTap: () => widget.onOpen(2),
              ),
              _StatCard(
                label: 'Occupied rooms',
                value: stats['occupiedRooms'] ?? 0,
                icon: Icons.meeting_room_rounded,
                tint: const Color(0xFFFFE0E9),
                onTap: () => widget.onOpen(1),
              ),
              _StatCard(
                label: 'Open beds',
                value: stats['availableBeds'] ?? 0,
                icon: Icons.bed_rounded,
                tint: const Color(0xFFE5F0D9),
                onTap: () => widget.onOpen(1),
              ),
              _StatCard(
                label: 'Unpaid rent',
                value: stats['unpaid'] ?? 0,
                icon: Icons.receipt_long_rounded,
                tint: const Color(0xFFFFECCD),
                onTap: () => widget.onOpen(3),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => widget.onOpen(1),
            icon: const Icon(Icons.meeting_room_rounded),
            label: const Text('Go to bedspaces and assign a boarder'),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionTitle(
                'Bedspace map',
                subtitle: 'A quick occupancy preview',
              ),
              TextButton(
                onPressed: () => widget.onOpen(1),
                child: const Text('View all'),
              ),
            ],
          ),
          _BedPreview(onTap: () => widget.onOpen(1)),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionTitle(
                'Boarders',
                subtitle: 'All registered residents',
              ),
              TextButton(
                onPressed: () => widget.onOpen(2),
                child: const Text('See all'),
              ),
            ],
          ),
          ..._people.map(
            (person) => _BoarderTile(
              person: person,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      BoarderDetailsPage(id: person['boarder_id']! as int),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _QuickTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Complaints to follow up',
            subtitle: '${stats['complaints'] ?? 0} unresolved or in progress',
            onTap: () => widget.onOpen(4),
          ),
        ],
      ),
    );
  }
}

class _DashboardRentCard extends StatelessWidget {
  const _DashboardRentCard({required this.charges, required this.onTap});

  final List<Map<String, Object?>> charges;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final month = _currentMonth();
    final monthCharges = charges
        .where((charge) => charge['billing_month'] == month)
        .toList();
    final due = monthCharges.fold<double>(
      0,
      (total, charge) => total + (charge['amount_due']! as num).toDouble(),
    );
    final paid = monthCharges.fold<double>(
      0,
      (total, charge) => total + (charge['amount_paid']! as num).toDouble(),
    );
    final balance = (due - paid).clamp(0, double.infinity).toDouble();
    final paidCount = monthCharges.where((charge) {
      final amountDue = (charge['amount_due']! as num).toDouble();
      final amountPaid = (charge['amount_paid']! as num).toDouble();
      return amountPaid >= amountDue;
    }).length;
    final progress = due == 0 ? 0.0 : (paid / due).clamp(0, 1).toDouble();
    final monthDate = DateTime.parse('$month-01');
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Material(
      color: roseDark,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${monthNames[monthDate.month - 1]} rent',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View rent',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                '₱${paid.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'collected of ₱${due.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$paidCount of ${monthCharges.length} paid',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    '₱${balance.toStringAsFixed(2)} pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.onTap,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: roseDark, size: 20),
                ),
                const Icon(
                  Icons.arrow_outward_rounded,
                  color: Color(0xFFB8A4AE),
                  size: 17,
                ),
              ],
            ),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: ink,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BedPreview extends StatelessWidget {
  const _BedPreview({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<Map<String, Object?>>>(
    future: AppDatabase.instance.beds(),
    builder: (context, snapshot) {
      final beds = snapshot.data ?? [];
      final sample = beds.take(8).toList();
      return Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.apartment_rounded, size: 18, color: roseDark),
                    SizedBox(width: 8),
                    Text(
                      'Building 1 · sample rooms',
                      style: TextStyle(fontWeight: FontWeight.w800, color: ink),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sample.map((bed) {
                    final occupied = bed['boarder_id'] != null;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: occupied
                            ? const Color(0xFFFBE3E9)
                            : const Color(0xFFE7F2F9),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        '${bed['room_number']}-${bed['code']}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: occupied
                              ? roseDark
                              : const Color.fromARGB(255, 60, 72, 138),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    _LegendDot(color: rose, label: 'Occupied'),
                    SizedBox(width: 16),
                    _LegendDot(
                      color: Color.fromARGB(255, 60, 72, 138),
                      label: 'Available',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(radius: 4, backgroundColor: color),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 11, color: muted)),
    ],
  );
}

class BoardersPage extends StatefulWidget {
  const BoardersPage({
    super.key,
    required this.refreshKey,
    required this.onRefresh,
  });
  final int refreshKey;
  final VoidCallback onRefresh;

  @override
  State<BoardersPage> createState() => _BoardersPageState();
}

class _BoardersPageState extends State<BoardersPage> {
  final _search = TextEditingController();
  List<Map<String, Object?>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _search.addListener(_load);
    _load();
  }

  @override
  void didUpdateWidget(covariant BoardersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final rows = await AppDatabase.instance.boarders(_search.text);
      if (mounted) {
        setState(() {
          _rows = rows;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not load boarders: $error');
    }
  }

  Future<void> _edit([Map<String, Object?>? person]) async {
    final saved = await showDialog<int>(
      context: context,
      builder: (_) => BoarderFormDialog(person: person),
    );
    if (saved != null) {
      await _load();
      widget.onRefresh();
    }
  }

  Future<void> _delete(Map<String, Object?> person) async {
    final name = '${person['first_name']} ${person['last_name']}';
    final yes = await _confirm(
      context,
      'Delete boarder?',
      'Delete $name and their rent, payments, complaints and assignment?',
    );
    if (!yes) return;
    try {
      await AppDatabase.instance.deleteBoarder(person['boarder_id']! as int);
      await _load();
      widget.onRefresh();
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not delete boarder: $error');
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: TextField(
          controller: _search,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Search name or phone',
          ),
        ),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: rose))
            : _rows.isEmpty
            ? const _EmptyState(
                icon: Icons.people_outline_rounded,
                text: 'No boarders found',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 2, 18, 90),
                itemCount: _rows.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  return _BoarderTile(
                    person: row,
                    onTap: () => Navigator.of(context)
                        .push(
                          MaterialPageRoute<void>(
                            builder: (_) => BoarderDetailsPage(
                              id: row['boarder_id']! as int,
                            ),
                          ),
                        )
                        .then((_) {
                          _load();
                          widget.onRefresh();
                        }),
                    trailing: PopupMenuButton<String>(
                      onSelected: (choice) {
                        if (choice == 'edit') _edit(row);
                        if (choice == 'delete') _delete(row);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              ),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 20, 16),
          child: FloatingActionButton.extended(
            onPressed: () => _edit(),
            backgroundColor: rose,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add boarder'),
          ),
        ),
      ),
    ],
  );
}

class _BoarderTile extends StatelessWidget {
  const _BoarderTile({
    required this.person,
    required this.onTap,
    this.trailing,
  });
  final Map<String, Object?> person;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final name = '${person['first_name'] ?? ''} ${person['last_name'] ?? ''}'
        .trim();
    final room = person['room_number'] == null
        ? 'No bed assigned'
        : 'Room ${person['room_number']} · ${person['bed_code']}';
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: lilac,
          foregroundColor: roseDark,
          child: Text(
            name.isEmpty ? '?' : name[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w800, color: ink),
        ),
        subtitle: Text(
          '$room\n${person['contact_number'] ?? ''}',
          style: const TextStyle(color: muted, height: 1.5),
        ),
        isThreeLine: true,
        trailing:
            trailing ?? const Icon(Icons.chevron_right_rounded, color: muted),
      ),
    );
  }
}

class BoarderFormDialog extends StatefulWidget {
  const BoarderFormDialog({super.key, this.person});
  final Map<String, Object?>? person;

  @override
  State<BoarderFormDialog> createState() => _BoarderFormDialogState();
}

class _BoarderFormDialogState extends State<BoarderFormDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _phone;
  late final TextEditingController _emergency;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _first = TextEditingController(
      text: widget.person?['first_name'] as String?,
    );
    _last = TextEditingController(text: widget.person?['last_name'] as String?);
    _phone = TextEditingController(
      text: widget.person?['contact_number'] as String?,
    );
    _emergency = TextEditingController(
      text: widget.person?['emergency_contact'] as String?,
    );
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _emergency.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final id = await AppDatabase.instance.saveBoarder(
        id: widget.person?['boarder_id'] as int?,
        first: _first.text,
        last: _last.text,
        phone: _phone.text,
        emergency: _emergency.text,
      );
      if (mounted) Navigator.pop(context, id);
    } catch (error) {
      if (mounted) {
        _showMessage(context, error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.person == null ? 'Add boarder' : 'Edit boarder'),
    content: Form(
      key: _form,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _formField(_first, 'First name'),
            const SizedBox(height: 12),
            _formField(_last, 'Last name'),
            const SizedBox(height: 12),
            _formField(_phone, 'Contact number', keyboard: TextInputType.phone),
            const SizedBox(height: 12),
            _formField(_emergency, 'Emergency contact', required: false),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Saving…' : 'Save'),
      ),
    ],
  );
}

Widget _formField(
  TextEditingController controller,
  String label, {
  TextInputType? keyboard,
  bool required = true,
}) => TextFormField(
  controller: controller,
  keyboardType: keyboard,
  decoration: InputDecoration(labelText: label),
  validator: required
      ? (value) => value == null || value.trim().isEmpty ? 'Required' : null
      : null,
);

class BoarderDetailsPage extends StatefulWidget {
  const BoarderDetailsPage({super.key, required this.id});
  final int id;

  @override
  State<BoarderDetailsPage> createState() => _BoarderDetailsPageState();
}

class _BoarderDetailsPageState extends State<BoarderDetailsPage> {
  Map<String, Object?>? _person;
  List<Map<String, Object?>> _payments = [];
  Map<String, double> _rentSummary = {'due': 0, 'paid': 0};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final person = await AppDatabase.instance.boarder(widget.id);
      final payments = await AppDatabase.instance.payments(widget.id);
      final rentSummary = await AppDatabase.instance.boarderRentSummary(
        widget.id,
      );
      if (mounted) {
        setState(() {
          _person = person;
          _payments = payments;
          _rentSummary = rentSummary;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not load boarder: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Boarder summary'),
        actions: [
          if (_person != null)
            IconButton(
              tooltip: 'Edit boarder',
              onPressed: () async {
                final saved = await showDialog<int>(
                  context: context,
                  builder: (_) => BoarderFormDialog(person: _person),
                );
                if (saved != null) await _load();
              },
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: rose))
          : _person == null
          ? const _EmptyState(
              icon: Icons.person_off_outlined,
              text: 'Boarder not found',
            )
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _BoarderTile(person: _person!, onTap: () {}),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Contact information',
                  rows: [
                    ('Phone', '${_person!['contact_number']}'),
                    (
                      'Emergency contact',
                      '${_person!['emergency_contact'] ?? '—'}',
                    ),
                    ('Date added', '${_person!['date_added']}'),
                    (
                      'Bedspace',
                      _person!['room_number'] == null
                          ? 'Not assigned'
                          : 'Room ${_person!['room_number']} · ${_person!['bed_code']}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Rent summary',
                  rows: [
                    (
                      'Total due',
                      '₱${_rentSummary['due']!.toStringAsFixed(2)}',
                    ),
                    (
                      'Total paid',
                      '₱${_rentSummary['paid']!.toStringAsFixed(2)}',
                    ),
                    (
                      'Balance',
                      '₱${(_rentSummary['due']! - _rentSummary['paid']!).clamp(0, double.infinity).toStringAsFixed(2)}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle(
                      'Payment history',
                      subtitle: 'Recorded transactions',
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PaymentHistoryPage(
                            id: widget.id,
                            name:
                                '${_person!['first_name']} ${_person!['last_name']}',
                          ),
                        ),
                      ),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                if (_payments.isEmpty)
                  const _EmptyState(
                    icon: Icons.receipt_long_outlined,
                    text: 'No payments recorded',
                  )
                else
                  ..._payments
                      .take(5)
                      .map((payment) => _PaymentTile(payment: payment)),
              ],
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});
  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, color: ink),
          ),
          const SizedBox(height: 10),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      row.$1,
                      style: const TextStyle(color: muted, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2.isEmpty ? '—' : row.$2,
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key, required this.id, required this.name});
  final int id;
  final String name;

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late Future<List<Map<String, Object?>>> _payments;

  @override
  void initState() {
    super.initState();
    _payments = AppDatabase.instance.payments(widget.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('Payment history'),
    ),
    body: FutureBuilder<List<Map<String, Object?>>>(
      future: _payments,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: rose));
        }
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),
            if (snapshot.data!.isEmpty)
              const _EmptyState(
                icon: Icons.receipt_long_outlined,
                text: 'No payment records',
              )
            else
              ...snapshot.data!.map(
                (payment) => _PaymentTile(payment: payment),
              ),
          ],
        );
      },
    ),
  );
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});
  final Map<String, Object?> payment;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE1F1E9),
        child: Icon(Icons.check_rounded, color: green),
      ),
      title: Text(
        '₱${(payment['amount'] as num).toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.w800, color: ink),
      ),
      subtitle: Text(
        '${payment['billing_month']} · ${payment['payment_date']}\n${payment['remarks'] ?? ''}',
      ),
      isThreeLine: true,
    ),
  );
}

class RoomsPage extends StatefulWidget {
  const RoomsPage({
    super.key,
    required this.refreshKey,
    required this.onRefresh,
  });
  final int refreshKey;
  final VoidCallback onRefresh;

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  List<Map<String, Object?>> _beds = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RoomsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) _load();
  }

  Future<void> _load() async {
    try {
      final beds = await AppDatabase.instance.beds();
      if (mounted) setState(() => _beds = beds);
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not load bedspace map: $error');
    }
  }

  Future<void> _assign(Map<String, Object?> bed) async {
    if (bed['boarder_id'] != null) {
      final name = '${bed['occupant']}';
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room ${bed['room_number']} · ${bed['code']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text('Occupied by $name', style: const TextStyle(color: muted)),
            ],
          ),
        ),
      );
      return;
    }
    try {
      final people = await AppDatabase.instance.boarders();
      if (!mounted) return;
      if (people.isEmpty) {
        final id = await showDialog<int>(
          context: context,
          builder: (_) => const BoarderFormDialog(),
        );
        if (id == null) return;
        await AppDatabase.instance.assignBed(id, bed['bed_id']! as int);
        await _load();
        widget.onRefresh();
        return;
      }
      final id = await showModalBottomSheet<int>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .65,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Assign this bed',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ...people.map(
                        (person) => ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: lilac,
                            child: Icon(Icons.person_outline, color: roseDark),
                          ),
                          title: Text(
                            '${person['first_name']} ${person['last_name']}',
                          ),
                          subtitle: Text(
                            person['room_number'] == null
                                ? 'Not assigned'
                                : 'Currently in ${person['room_number']}',
                          ),
                          onTap: () => Navigator.pop(
                            sheetContext,
                            person['boarder_id']! as int,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: lilac,
                          child: Icon(Icons.person_add_alt_1, color: roseDark),
                        ),
                        title: const Text('Add new boarder and assign'),
                        onTap: () async {
                          final newId = await showDialog<int>(
                            context: context,
                            builder: (_) => const BoarderFormDialog(),
                          );
                          if (newId != null && sheetContext.mounted) {
                            Navigator.pop(sheetContext, newId);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (id == null) return;
      await AppDatabase.instance.assignBed(id, bed['bed_id']! as int);
      await _load();
      widget.onRefresh();
    } catch (error) {
      if (mounted) {
        _showMessage(context, error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildings = _beds.map((bed) => bed['building']).toSet().toList();
    return RefreshIndicator(
      color: rose,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        children: [
          const Text(
            'Tap an available bed to assign a boarder. Tap an occupied bed to view its resident.',
            style: TextStyle(color: muted, height: 1.4),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _LegendDot(
                color: Color.fromARGB(255, 60, 72, 138),
                label: 'Available',
              ),
              SizedBox(width: 16),
              _LegendDot(color: rose, label: 'Occupied'),
            ],
          ),
          const SizedBox(height: 18),
          for (final building in buildings) ...[
            _SectionTitle(
              'Building $building',
              subtitle: building == 1 ? 'Double-deck rooms' : 'Private rooms',
            ),
            const SizedBox(height: 10),
            ..._roomsOf(building).entries.map(
              (entry) => _RoomCard(
                room: entry.key,
                beds: entry.value,
                onBedTap: _assign,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Map<String, List<Map<String, Object?>>> _roomsOf(Object? building) {
    final result = <String, List<Map<String, Object?>>>{};
    for (final bed in _beds.where((row) => row['building'] == building)) {
      (result['${bed['room_number']}'] ??= []).add(bed);
    }
    return result;
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.beds,
    required this.onBedTap,
  });
  final String room;
  final List<Map<String, Object?>> beds;
  final ValueChanged<Map<String, Object?>> onBedTap;

  @override
  Widget build(BuildContext context) {
    final occupiedCount = beds.where((bed) => bed['boarder_id'] != null).length;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.meeting_room_outlined,
                  size: 18,
                  color: roseDark,
                ),
                const SizedBox(width: 8),
                Text(
                  'Room $room',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const Spacer(),
                Text(
                  '$occupiedCount occupied · ${beds.length - occupiedCount} available',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: beds.map((bed) {
                final occupied = bed['boarder_id'] != null;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onBedTap(bed),
                  child: Container(
                    width: 78,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: occupied
                          ? const Color(0xFFFBE4E9)
                          : const Color(0xFFE7F2F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bed_rounded,
                          color: occupied
                              ? roseDark
                              : const Color.fromARGB(255, 60, 72, 138),
                          size: 18,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${bed['code']}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: occupied
                                ? roseDark
                                : const Color.fromARGB(255, 60, 72, 138),
                          ),
                        ),
                        Text(
                          occupied
                              ? '${bed['occupant']}'.split(' ').first
                              : 'Available',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: muted),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class RentPage extends StatefulWidget {
  const RentPage({
    super.key,
    required this.refreshKey,
    required this.onRefresh,
  });
  final int refreshKey;
  final VoidCallback onRefresh;

  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  List<Map<String, Object?>> _charges = [];
  List<String> _availableMonths = [_currentMonth()];
  String _statusFilter = 'All';
  String _monthFilter = _currentMonth();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) _load();
  }

  Future<void> _load() async {
    try {
      await AppDatabase.instance.ensureCurrentMonthCharges();
      final rows = await AppDatabase.instance.charges();
      final months =
          rows
              .map((charge) => charge['billing_month']! as String)
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));
      if (!months.contains(_currentMonth())) months.insert(0, _currentMonth());
      if (_monthFilter != 'All months' && !months.contains(_monthFilter)) {
        _monthFilter = _currentMonth();
      }
      final filteredRows = rows.where((charge) {
        final monthMatches =
            _monthFilter == 'All months' ||
            charge['billing_month'] == _monthFilter;
        final due = (charge['amount_due']! as num).toDouble();
        final paid = (charge['amount_paid']! as num).toDouble();
        final statusMatches =
            _statusFilter == 'All' ||
            (_statusFilter == 'Paid' ? paid >= due : paid < due);
        return monthMatches && statusMatches;
      }).toList();
      if (mounted) {
        setState(() {
          _charges = filteredRows;
          _availableMonths = months;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not load rent records: $error');
    }
  }

  Future<void> _editRent(Map<String, Object?> charge) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => EditRentDialog(charge: charge),
    );
    if (saved == true) {
      await _load();
      widget.onRefresh();
    }
  }

  void _showHistory(Map<String, Object?> charge) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentHistoryPage(
          id: charge['boarder_id']! as int,
          name: '${charge['boarder_name']}',
        ),
      ),
    );
  }

  Future<void> _pay(Map<String, Object?> charge) async {
    final due = (charge['amount_due'] as num).toDouble();
    final paid = (charge['amount_paid'] as num).toDouble();
    final balance = due - paid;
    final amount = await showDialog<double>(
      context: context,
      builder: (_) =>
          PaymentDialog(name: '${charge['boarder_name']}', balance: balance),
    );
    if (amount == null) return;
    try {
      await AppDatabase.instance.recordPayment(
        charge['charge_id']! as int,
        amount,
        'Payment received',
      );
      await _load();
      widget.onRefresh();
    } catch (error) {
      if (mounted) {
        _showMessage(context, error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _markPaid(Map<String, Object?> charge) async {
    final due = (charge['amount_due'] as num).toDouble();
    final paid = (charge['amount_paid'] as num).toDouble();
    final balance = due - paid;
    final confirmed = await _confirm(
      context,
      'Mark rent as paid?',
      'Record the remaining ₱${balance.toStringAsFixed(2)} for '
          '${charge['boarder_name']} (${charge['billing_month']}) as a payment?',
      confirmLabel: 'Save Changes',
      confirmColor: green,
    );
    if (!confirmed) return;
    try {
      await AppDatabase.instance.recordPayment(
        charge['charge_id']! as int,
        balance,
        'Payment received',
      );
      await _load();
      widget.onRefresh();
    } catch (error) {
      if (mounted) {
        _showMessage(context, error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _monthFilter,
                decoration: const InputDecoration(labelText: 'Billing month'),
                items: [
                  const DropdownMenuItem(
                    value: 'All months',
                    child: Text('All months'),
                  ),
                  ..._availableMonths.map(
                    (month) =>
                        DropdownMenuItem(value: month, child: Text(month)),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _monthFilter = value);
                  _load();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _statusFilter,
                decoration: const InputDecoration(labelText: 'Payment status'),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                  DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _statusFilter = value);
                  _load();
                },
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: rose))
            : _charges.isEmpty
            ? const _EmptyState(
                icon: Icons.receipt_long_outlined,
                text: 'No rent records found',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 88),
                itemCount: _charges.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final charge = _charges[index];
                  final due = (charge['amount_due'] as num).toDouble();
                  final paid = (charge['amount_paid'] as num).toDouble();
                  final balance = (due - paid)
                      .clamp(0, double.infinity)
                      .toDouble();
                  final status = balance <= 0
                      ? 'Paid'
                      : paid > 0
                      ? 'Balance'
                      : 'Unpaid';
                  final color = status == 'Paid'
                      ? green
                      : status == 'Balance'
                      ? amber
                      : red;
                  return Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${charge['boarder_name']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: ink,
                                  ),
                                ),
                              ),
                              _StatusPill(status, color),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Billing month  ${charge['billing_month']}  ·  Due ${charge['due_date']}',
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _MoneyLabel('Due', due),
                              _MoneyLabel('Paid', paid),
                              _MoneyLabel('Balance', balance, emphasis: true),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _editRent(charge),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Edit rent'),
                              ),
                              if (balance > .001)
                                OutlinedButton.icon(
                                  onPressed: () => _pay(charge),
                                  icon: const Icon(
                                    Icons.add_card_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Record payment'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: roseDark,
                                    side: const BorderSide(
                                      color: Color(0xFFF0C7D2),
                                    ),
                                  ),
                                ),
                              if (balance > .001)
                                OutlinedButton.icon(
                                  onPressed: () => _markPaid(charge),
                                  icon: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Mark paid'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: green,
                                    side: const BorderSide(
                                      color: Color(0xFFB9E2D0),
                                    ),
                                  ),
                                ),
                              OutlinedButton.icon(
                                onPressed: () => _showHistory(charge),
                                icon: const Icon(
                                  Icons.history_rounded,
                                  size: 18,
                                ),
                                label: const Text('Payment history'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    ],
  );
}

class _MoneyLabel extends StatelessWidget {
  const _MoneyLabel(this.label, this.amount, {this.emphasis = false});
  final String label;
  final double amount;
  final bool emphasis;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: muted, fontSize: 11)),
      const SizedBox(height: 2),
      Text(
        '₱${amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: emphasis ? red : ink,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    ],
  );
}

class EditRentDialog extends StatefulWidget {
  const EditRentDialog({super.key, required this.charge});
  final Map<String, Object?> charge;

  @override
  State<EditRentDialog> createState() => _EditRentDialogState();
}

class _EditRentDialogState extends State<EditRentDialog> {
  late final TextEditingController _amount;
  late final TextEditingController _dueDate;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: (widget.charge['amount_due']! as num).toStringAsFixed(2),
    );
    _dueDate = TextEditingController(text: '${widget.charge['due_date']}');
  }

  @override
  void dispose() {
    _amount.dispose();
    _dueDate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text);
    if (amount == null) {
      _showMessage(context, 'Enter a valid rent amount.');
      return;
    }
    try {
      await AppDatabase.instance.updateCharge(
        widget.charge['charge_id']! as int,
        amount,
        _dueDate.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        _showMessage(context, error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit rent record'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.charge['boarder_name']} · ${widget.charge['billing_month']}',
          style: const TextStyle(fontWeight: FontWeight.w700, color: ink),
        ),
        const SizedBox(height: 14),
        _formField(
          _amount,
          'Amount due',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        _formField(_dueDate, 'Due date (YYYY-MM-DD)'),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save changes')),
    ],
  );
}

class AddRentDialog extends StatefulWidget {
  const AddRentDialog({super.key});

  @override
  State<AddRentDialog> createState() => _AddRentDialogState();
}

class _AddRentDialogState extends State<AddRentDialog> {
  List<Map<String, Object?>> _people = [];
  int? _boarderId;
  final _month = TextEditingController(text: _currentMonth());
  final _amount = TextEditingController(text: '3500');
  final _dueDate = TextEditingController(text: _today());

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _month.dispose();
    _amount.dispose();
    _dueDate.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final people = await AppDatabase.instance.boarders();
      if (mounted) setState(() => _people = people);
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not load boarders: $error');
    }
  }

  Future<void> _save() async {
    if (_boarderId == null) {
      _showMessage(context, 'Choose a boarder.');
      return;
    }
    try {
      final amount = double.parse(_amount.text);
      await AppDatabase.instance.addCharge(
        _boarderId!,
        _month.text.trim(),
        amount,
        _dueDate.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        _showMessage(context, error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add monthly rent record'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _boarderId,
            decoration: const InputDecoration(labelText: 'Boarder'),
            items: _people
                .map(
                  (person) => DropdownMenuItem<int>(
                    value: person['boarder_id']! as int,
                    child: Text(
                      '${person['first_name']} ${person['last_name']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _boarderId = value),
          ),
          const SizedBox(height: 12),
          _formField(_month, 'Billing month (YYYY-MM)'),
          const SizedBox(height: 12),
          _formField(
            _amount,
            'Amount due',
            keyboard: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          _formField(_dueDate, 'Due date (YYYY-MM-DD)'),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save rent')),
    ],
  );
}

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key, required this.name, required this.balance});
  final String name;
  final double balance;

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: widget.balance.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Record payment'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Text(
          'Remaining balance: ₱${widget.balance.toStringAsFixed(2)}',
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 14),
        _formField(
          _amount,
          'Payment amount',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final amount = double.tryParse(_amount.text);
          if (amount == null || amount <= 0 || amount > widget.balance) {
            _showMessage(
              context,
              'Enter an amount within the outstanding balance.',
            );
            return;
          }
          Navigator.pop(context, amount);
        },
        child: const Text('Record'),
      ),
    ],
  );
}

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({
    super.key,
    required this.refreshKey,
    required this.onRefresh,
  });
  final int refreshKey;
  final VoidCallback onRefresh;

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final _search = TextEditingController();
  List<Map<String, Object?>> _rows = [];
  String _statusFilter = 'All';
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(_load);
    _load();
  }

  @override
  void didUpdateWidget(covariant ComplaintsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final rows = _showHistory
          ? await AppDatabase.instance.resolvedComplaints(_search.text)
          : await AppDatabase.instance.complaints(_search.text, _statusFilter);
      if (mounted) setState(() => _rows = rows);
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not load complaints: $error');
    }
  }

  void _toggleHistory() {
    setState(() {
      _showHistory = !_showHistory;
      _statusFilter = 'All';
    });
    _load();
  }

  Future<void> _add() async {
    final people = await AppDatabase.instance.boarders();
    if (!mounted) return;
    if (people.isEmpty) {
      _showMessage(context, 'Add a boarder before recording a complaint.');
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AddComplaintDialog(people: people),
    );
    if (saved == true) {
      await _load();
      widget.onRefresh();
    }
  }

  Future<void> _changeStatus(int id, String status) async {
    try {
      await AppDatabase.instance.updateComplaint(id, status);
      await _load();
      widget.onRefresh();
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not update complaint: $error');
    }
  }

  Future<void> _deleteFromHistory(int id, String boarderName) async {
    final confirmed = await _confirm(
      context,
      'Delete resolved complaint?',
      'Permanently delete the resolved complaint from $boarderName?',
    );
    if (!confirmed) return;
    try {
      await AppDatabase.instance.deleteComplaint(id);
      await _load();
      widget.onRefresh();
    } catch (error) {
      if (mounted) {
        _showMessage(context, 'Could not delete complaint: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _toggleHistory,
            icon: Icon(
              _showHistory ? Icons.list_alt_rounded : Icons.history_rounded,
            ),
            label: Text(_showHistory ? 'Active complaints' : 'History'),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: TextField(
          controller: _search,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Search boarder or issue',
          ),
        ),
      ),
      if (!_showHistory)
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: DropdownButtonFormField<String>(
            initialValue: _statusFilter,
            decoration: const InputDecoration(labelText: 'Show complaints'),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All statuses')),
              DropdownMenuItem(value: 'Unresolved', child: Text('Unresolved')),
              DropdownMenuItem(
                value: 'Being handled',
                child: Text('Being handled'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _statusFilter = value);
              _load();
            },
          ),
        ),
      Expanded(
        child: _rows.isEmpty
            ? _EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                text: _showHistory
                    ? 'No resolved complaints in history'
                    : 'No complaints found',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 88),
                itemCount: _rows.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  final status = '${row['status']}';
                  final color = status == 'Resolved'
                      ? green
                      : status == 'Being handled'
                      ? amber
                      : red;
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${row['boarder_name']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: ink,
                                  ),
                                ),
                              ),
                              if (_showHistory)
                                IconButton(
                                  tooltip: 'Delete from history',
                                  onPressed: () => _deleteFromHistory(
                                    row['complaint_id']! as int,
                                    '${row['boarder_name']}',
                                  ),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: red,
                                  ),
                                )
                              else
                                PopupMenuButton<String>(
                                  tooltip: 'Change status',
                                  onSelected: (value) => _changeStatus(
                                    row['complaint_id']! as int,
                                    value,
                                  ),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'Unresolved',
                                      child: Text('Unresolved'),
                                    ),
                                    PopupMenuItem(
                                      value: 'Being handled',
                                      child: Text('Being handled'),
                                    ),
                                    PopupMenuItem(
                                      value: 'Resolved',
                                      child: Text('Resolved'),
                                    ),
                                  ],
                                  child: _StatusPill(status, color),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${row['description']}',
                            style: const TextStyle(color: ink, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Posted: ${row['date_reported']}',
                            style: const TextStyle(fontSize: 12, color: muted),
                          ),
                          if (_showHistory) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Resolved: ${row['resolved_at'] ?? '—'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      if (!_showHistory)
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 20, 16),
            child: FloatingActionButton.extended(
              onPressed: _add,
              backgroundColor: const Color.fromARGB(255, 62, 77, 213),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_comment_rounded),
              label: const Text('New complaint'),
            ),
          ),
        ),
    ],
  );
}

class AddComplaintDialog extends StatefulWidget {
  const AddComplaintDialog({super.key, required this.people});
  final List<Map<String, Object?>> people;

  @override
  State<AddComplaintDialog> createState() => _AddComplaintDialogState();
}

class _AddComplaintDialogState extends State<AddComplaintDialog> {
  int? _boarderId;
  final _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_boarderId == null || _description.text.trim().isEmpty) {
      _showMessage(context, 'Choose a boarder and enter a complaint.');
      return;
    }
    try {
      await AppDatabase.instance.addComplaint(_boarderId!, _description.text);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        _showMessage(context, error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New complaint'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<int>(
          initialValue: _boarderId,
          decoration: const InputDecoration(labelText: 'Boarder'),
          items: widget.people
              .map(
                (person) => DropdownMenuItem<int>(
                  value: person['boarder_id']! as int,
                  child: Text(
                    '${person['first_name']} ${person['last_name']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _boarderId = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'What happened?'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Submit')),
    ],
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
    ),
  );
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: ListTile(
      onTap: onTap,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFFEFD9),
        child: Icon(Icons.chat_bubble_outline, color: amber),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, color: ink),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: muted)),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 3),
        Text(subtitle!, style: const TextStyle(fontSize: 12, color: muted)),
      ],
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: const Color(0xFFC9B8C0)),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted),
          ),
        ],
      ),
    ),
  );
}

Future<bool> _confirm(
  BuildContext context,
  String title,
  String message, {
  String confirmLabel = 'Delete',
  Color confirmColor = red,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ) ??
    false;

void _showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
}

String _today() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _currentMonth() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
}
