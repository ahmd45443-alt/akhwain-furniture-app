
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const AkhwainApp());

const navy = Color(0xFF142C40);
const blue = Color(0xFF245675);
const pale = Color(0xFFF2F6F9);
const whatsappNumber = '9647717203122';
const supportEmail = 'ahmd45443@gmail.com';

const services = [
  'سيارة كيا',
  'هينو',
  'كنتر',
  'رافعة تادانا',
  'كرين صغير',
  'شفل',
  'حفارة',
  'نقل أثاث منزلي',
  'نقل أثاث مكتبي',
  'عمال تحميل وتنزيل',
  'تغليف الأثاث',
  'فك وتركيب سبلت',
  'نقل مع فك وتركيب'
];

const statuses = ['جديد', 'قيد التأكيد', 'تم التأكيد', 'مكتمل', 'ملغي'];

class AkhwainApp extends StatelessWidget {
  const AkhwainApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'شركة الأخوين لنقل الأثاث',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: navy),
          scaffoldBackgroundColor: pale,
        ),
        home: const BookingPage(),
      );
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _details = TextEditingController();
  final _rooms = TextEditingController();
  final _splits = TextEditingController();
  final _workers = TextEditingController();
  final _packing = TextEditingController();
  final _distance = TextEditingController();
  final _ratingComment = TextEditingController();

  String _service = services.first;
  DateTime? _date;
  int _rating = 5;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _from,
      _to,
      _details,
      _rooms,
      _splits,
      _workers,
      _packing,
      _distance,
      _ratingComment
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _openUrl(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح التطبيق المطلوب على هذا الجهاز.'),
        ),
      );
    }
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: 'اختيار موعد النقل',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );

    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _openMap(TextEditingController c) => _openUrl(
        Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(c.text.trim().isEmpty ? 'الكوت، العراق' : c.text.trim())}',
        ),
      );

  String _dateText() => _date == null
      ? 'غير محدد'
      : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';

  Future<void> _submitBooking() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final orders = (prefs.getStringList('akhwain_orders') ?? <String>[])
          .map((x) => Map<String, dynamic>.from(jsonDecode(x) as Map))
          .toList();

      final now = DateTime.now();

      final id =
          'AK-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

      final order = <String, dynamic>{
        'id': id,
        'createdAt': now.toIso8601String(),
        'status': 'جديد',
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'service': _service,
        'from': _from.text.trim(),
        'to': _to.text.trim(),
        'rooms': _rooms.text.trim(),
        'splits': _splits.text.trim(),
        'workers': _workers.text.trim(),
        'packing': _packing.text.trim(),
        'distance': _distance.text.trim(),
        'date': _dateText(),
        'details': _details.text.trim(),
      };

      orders.insert(0, order);

      await prefs.setStringList(
        'akhwain_orders',
        orders.map(jsonEncode).toList(),
      );

      final message = '''طلب تسعيرة — شركة الأخوين
رقم الطلب: $id
الاسم: ${order['name']}
هاتف الزبون: ${order['phone']}
الخدمة: $_service
الانطلاق: ${_from.text.trim()}
الوصول: ${_to.text.trim()}
الغرف: ${_rooms.text.trim().isEmpty ? 'غير محدد' : _rooms.text.trim()}
أجهزة السبلت: ${_splits.text.trim().isEmpty ? 'غير محدد' : _splits.text.trim()}
العمال: ${_workers.text.trim().isEmpty ? 'غير محدد' : _workers.text.trim()}
التغليف: ${_packing.text.trim().isEmpty ? 'غير محدد' : _packing.text.trim()}
المسافة: ${_distance.text.trim().isEmpty ? 'غير محددة' : _distance.text.trim()}
الموعد: ${_dateText()}
تفاصيل إضافية: ${_details.text.trim().isEmpty ? 'لا توجد' : _details.text.trim()}
الحالة: جديد
يرجى إرسال التسعيرة وتأكيد الموعد.''';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حُفظ الطلب محلياً برقم $id. أرسل الرسالة من واتساب لإبلاغ الشركة.',
            ),
          ),
        );
      }

      await _openUrl(
        Uri.parse(
          'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}',
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر حفظ الطلب. حاول مرة أخرى.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController c, {
    String? hint,
    int lines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: c,
        maxLines: lines,
        keyboardType: keyboard,
        validator: validator,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.edit_outlined, color: blue),
        ),
      );

  Widget _section(String title, Widget child) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1E8ED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: navy,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                  decoration: const BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(26),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.local_shipping_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'شركة الأخوين',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'لنقل الأثاث المنزلي والمكتبي',
                                    style: TextStyle(
                                      color: Color(0xFFD8E5EE),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'نقل أثاثك براحة واهتمام',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'كيا وهينو وكنتر ورافعات وآليات ثقيلة، وخدمات فك وتركيب السبلت داخل الكوت وجميع المحافظات.',
                          style: TextStyle(
                            color: Color(0xFFD8E5EE),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _ServiceChip(
                              icon: Icons.local_shipping,
                              text: 'سيارات نقل',
                            ),
                            _ServiceChip(
                              icon: Icons.construction,
                              text: 'آليات ثقيلة',
                            ),
                            _ServiceChip(
                              icon: Icons.ac_unit,
                              text: 'خدمات السبلت',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _section(
                          'طلب تسعيرة / حجز',
                          Column(
                            children: [
                              _field(
                                'اسم الزبون',
                                _name,
                                hint: 'الاسم الكامل',
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'يرجى إدخال الاسم'
                                        : null,
                              ),
                              const SizedBox(height: 10),
                              _field(
                                'رقم هاتف الزبون',
                                _phone,
                                hint: 'رقم للتواصل',
                                keyboard: TextInputType.phone,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'يرجى إدخال رقم الهاتف'
                                        : null,
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _service,
                                decoration: const InputDecoration(
                                  labelText: 'نوع الخدمة',
                                ),
                                items: services
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _service = v ?? _service),
                              ),
                              const SizedBox(height: 10),
                              _field(
                                'موقع الانطلاق',
                                _from,
                                hint: 'المحافظة والمنطقة',
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'يرجى إدخال موقع الانطلاق'
                                        : null,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => _openMap(_from),
                                  icon: const Icon(Icons.map_outlined),
                                  label: const Text('فتح الخرائط'),
                                ),
                              ),
                              _field(
                                'موقع الوصول',
                                _to,
                                hint: 'المحافظة والمنطقة',
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'يرجى إدخال موقع الوصول'
                                        : null,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => _openMap(_to),
                                  icon: const Icon(Icons.map_outlined),
                                  label: const Text('فتح الخرائط'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _field(
                                      'عدد الغرف',
                                      _rooms,
                                      keyboard: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _field(
                                      'عدد السبلت',
                                      _splits,
                                      keyboard: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _field(
                                      'عدد العمال',
                                      _workers,
                                      keyboard: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _field(
                                      'التغليف المطلوب',
                                      _packing,
                                      hint: 'نعم / لا',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _field(
                                'المسافة التقريبية',
                                _distance,
                                hint: 'مثلاً 15 كم (اختياري)',
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.calendar_month,
                                  color: blue,
                                ),
                                title: Text(
                                  _date == null
                                      ? 'اختيار موعد النقل (اختياري)'
                                      : 'موعد النقل: ${_dateText()}',
                                ),
                                trailing: const Icon(Icons.chevron_left),
                                onTap: _chooseDate,
                              ),
                              _field(
                                'تفاصيل إضافية',
                                _details,
                                hint: 'الطابق، المصعد، حجم الأثاث أو تفاصيل الشغل',
                                lines: 3,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'لا توجد أسعار ثابتة. ترسل الشركة التسعيرة وتؤكد الموعد يدوياً.',
                                style: TextStyle(color: navy),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed:
                                      _saving ? null : _submitBooking,
                                  icon: _saving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.chat),
                                  label: Text(
                                    _saving
                                        ? 'جارٍ حفظ الطلب...'
                                        : 'حفظ الطلب وإرسال واتساب',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const LocalOrdersPage(),
                                    ),
                                  ),
                                  icon: const Icon(Icons.assignment),
                                  label: const Text(
                                    'سجل الطلبات على هذا الجهاز',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _section(
                          'صور الخدمات والآليات',
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: const [
                              _ServiceChip(
                                icon: Icons.local_shipping,
                                text: 'كيا',
                              ),
                              _ServiceChip(
                                icon: Icons.local_shipping_outlined,
                                text: 'هينو',
                              ),
                              _ServiceChip(
                                icon: Icons.fire_truck_outlined,
                                text: 'كنتر',
                              ),
                              _ServiceChip(
                                icon: Icons.construction,
                                text: 'تادانا',
                              ),
                              _ServiceChip(
                                icon: Icons.precision_manufacturing,
                                text: 'كرين صغير',
                              ),
                              _ServiceChip(
                                icon: Icons.agriculture,
                                text: 'شفل',
                              ),
                              _ServiceChip(
                                icon: Icons.construction,
                                text: 'حفارة',
                              ),
                            ],
                          ),
                        ),
                        _section(
                          'الدعم والشكاوى',
                          Column(
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.email_outlined,
                                  color: blue,
                                ),
                                title: const Text('البريد الإلكتروني'),
                                subtitle: const Text(
                                  supportEmail,
                                  textDirection: TextDirection.ltr,
                                ),
                                onTap: () => _openUrl(
                                  Uri(
                                    scheme: 'mailto',
                                    path: supportEmail,
                                    queryParameters: {
                                      'subject': 'دعم تطبيق شركة الأخوين',
                                    },
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.report_problem_outlined,
                                  color: blue,
                                ),
                                title: const Text('إبلاغ عن مشكلة'),
                                subtitle: const Text(
                                  'إرسال بلاغ إلى واتساب الشركة',
                                ),
                                onTap: _reportIssue,
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.phone,
                                  color: blue,
                                ),
                                title: const Text('اتصل بالشركة'),
                                subtitle: const Text(
                                  '009647717203122',
                                  textDirection: TextDirection.ltr,
                                ),
                                onTap: () => _openUrl(
                                  Uri(
                                    scheme: 'tel',
                                    path: '+9647717203122',
                                  ),
                                ),
                              ),
                              const Text(
                                '911 للطوارئ فقط عند الخطر الفوري؛ تأكد من توفر الرقم محلياً.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.emergency,
                                  color: Colors.red,
                                ),
                                title: const Text('اتصال بالطوارئ 911'),
                                onTap: () => _openUrl(
                                  Uri(scheme: 'tel', path: '911'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _section(
                          'تقييم الخدمة',
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  5,
                                  (i) => IconButton(
                                    onPressed: () =>
                                        setState(() => _rating = i + 1),
                                    icon: Icon(
                                      i < _rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: const Color(0xFFE0A000),
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                              Text('$_rating من 5 نجوم'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _ratingComment,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'تعليق اختياري',
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _openUrl(
                                    Uri.parse(
                                      'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent('تقييم شركة الأخوين: $_rating من 5 نجوم\n${_ratingComment.text.trim()}')}',
                                    ),
                                  ),
                                  icon: const Icon(Icons.send),
                                  label: const Text(
                                    'إرسال التقييم عبر واتساب',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'شركة الأخوين لنقل الأثاث • الكوت وجميع المحافظات',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> _reportIssue() async {
    final c = TextEditingController();

    final issue = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إبلاغ عن مشكلة'),
        content: TextField(
          controller: c,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'تفاصيل المشكلة أو رقم الطلب',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text.trim()),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );

    c.dispose();

    if (issue == null || issue.isEmpty) return;

    await _openUrl(
      Uri.parse(
        'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent('بلاغ إلى دعم شركة الأخوين\nالمشكلة: $issue\nالبريد: $supportEmail')}',
      ),
    );
  }
}

class LocalOrdersPage extends StatefulWidget {
  const LocalOrdersPage({super.key});

  @override
  State<LocalOrdersPage> createState() => _LocalOrdersPageState();
}

class _LocalOrdersPageState extends State<LocalOrdersPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();

    final list = (p.getStringList('akhwain_orders') ?? <String>[])
        .map((x) => Map<String, dynamic>.from(jsonDecode(x) as Map))
        .toList();

    if (mounted) {
      setState(() {
        _orders = list
          ..sort(
            (a, b) => (b['createdAt'] as String)
                .compareTo(a['createdAt'] as String),
          );
        _loading = false;
      });
    }
  }

  Future<void> _status(int i, String value) async {
    _orders[i]['status'] = value;

    final p = await SharedPreferences.getInstance();

    await p.setStringList(
      'akhwain_orders',
      _orders.map(jsonEncode).toList(),
    );

    if (mounted) setState(() {});
  }

  Future<void> _notify(Map<String, dynamic> o) async {
    var phone = (o['phone'] as String? ?? '')
        .replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.startsWith('00')) phone = phone.substring(2);
    if (phone.startsWith('0')) phone = '964${phone.substring(1)}';

    if (phone.isEmpty) return;

    final text =
        'تحديث طلب شركة الأخوين\nرقم الطلب: ${o['id']}\nالحالة: ${o['status']}';

    await launchUrl(
      Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent(text)}',
      ),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('سجل الطلبات المحلي'),
            backgroundColor: navy,
            foregroundColor: Colors.white,
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'لا توجد طلبات محفوظة على هذا الجهاز. '
                          'هذه ليست لوحة إدارة سحابية؛ الطلبات لا تتزامن '
                          'بين أجهزة مختلفة.',
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _orders.length,
                      itemBuilder: (ctx, i) {
                        final o = _orders[i];

                        return Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'رقم الطلب: ${o['id']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: navy,
                                  ),
                                ),
                                Text(
                                  'الزبون: ${o['name']} • ${o['phone']}',
                                ),
                                Text('الخدمة: ${o['service']}'),
                                Text('من: ${o['from']}'),
                                Text('إلى: ${o['to']}'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: statuses.contains(o['status'])
                                      ? o['status'] as String
                                      : 'جديد',
                                  decoration: const InputDecoration(
                                    labelText: 'الحالة',
                                  ),
                                  items: statuses
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) _status(i, v);
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () => _notify(o),
                                    icon: const Icon(Icons.message),
                                    label: const Text(
                                      'إرسال تحديث للزبون على واتساب',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      );
}

class _ServiceChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ServiceChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
}
