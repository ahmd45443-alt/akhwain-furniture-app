import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AkhwainApp());
}

const navy = Color(0xFF102A43);
const blue = Color(0xFF1D4E89);
const whatsappNumber = '9647717203122';
const emailAddress = 'ahmd45443@gmail.com';
const facebookName = 'شركة الأخوين للنقل داخل وخارج الكوت';

class AkhwainApp extends StatelessWidget {
  const AkhwainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'شركة الأخوين للنقل',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
          ),
        ),
      ),
home: PhoneLoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final pages = const [HomeTab(), BookingTab(), ContactTab()];
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('شركة الأخوين للنقل', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: const Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.local_shipping_rounded, color: navy),
            ),
          ),
        ),
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'احجز خدمة'),
            NavigationDestination(icon: Icon(Icons.contact_phone_outlined), selectedIcon: Icon(Icons.contact_phone), label: 'تواصل ويانه'),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    final services = [
      (Icons.chair_alt_rounded, 'نقل الأثاث المنزلي والمكتبي', 'نقل وترتيب الأثاث بعناية'),
      (Icons.inventory_2_rounded, 'تغليف الأثاث', 'حماية الأغراض أثناء النقل'),
      (Icons.handyman_rounded, 'فك وتركيب الأثاث', 'خدمة فك وتركيب حسب الطلب'),
      (Icons.electrical_services_rounded, 'نقل الأجهزة الكهربائية', 'عناية بالأجهزة أثناء التحميل'),
      (Icons.local_shipping_rounded, 'نقل داخل وخارج الكوت', 'نقل حسب الوجهة والاتفاق'),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [navy, blue], begin: Alignment.topRight, end: Alignment.bottomLeft),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.local_shipping_rounded, color: Colors.white, size: 48),
              SizedBox(height: 14),
              Text('نقل أثاثك… براحة وأمان', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('شركة الأخوين للنقل داخل وخارج الكوت', style: TextStyle(color: Colors.white, fontSize: 15)),
              SizedBox(height: 6),
              Text('نرتّب النقل من البداية إلى الوصول', style: TextStyle(color: Color(0xFFD9EAF7))),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text('خدماتنا', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 10),
        ...services.map((s) => Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFFEAF1F8), child: Icon(s.$1, color: navy)),
            title: Text(s.$2, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(s.$3),
          ),
        )),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingPage())),
          icon: const Icon(Icons.edit_calendar),
          label: const Padding(padding: EdgeInsets.all(12), child: Text('احجز خدمة هسه')),
        ),
      ],
    );
  }
}

class BookingTab extends StatelessWidget {
  const BookingTab({super.key});
  @override
  Widget build(BuildContext context) => const BookingPage(inTab: true);
}

class BookingPage extends StatefulWidget {
  final bool inTab;
  const BookingPage({super.key, this.inTab = false});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final from = TextEditingController();
  final to = TextEditingController();
  final details = TextEditingController();
  String service = 'نقل أثاث منزلي';
  String vehicle = 'سيارة نقل';
  DateTime? date;

  @override
  void dispose() {
    name.dispose(); phone.dispose(); from.dispose(); to.dispose(); details.dispose();
    super.dispose();
  }

Future<void> sendBooking() async {
  if (!formKey.currentState!.validate()) return;

  final dateText = date == null
      ? 'غير محدد'
      : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}';

  try {
    final booking = await FirebaseFirestore.instance
        .collection('bookings')
        .add({
      'name': name.text.trim(),
      'phone': phone.text.trim(),
      'service': service,
      'vehicle': vehicle,
      'from': from.text.trim(),
      'to': to.text.trim(),
      'date': dateText,
      'details': details.text.trim(),
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final message = 'طلب حجز جديد - شركة الأخوين للنقل\n'
        'رقم الطلب: ${booking.id}\n'
        'الاسم: ${name.text}\n'
        'الهاتف: ${phone.text}\n'
        'الخدمة: $service\n'
        'نوع السيارة: $vehicle\n'
        'من: ${from.text}\n'
        'إلى: ${to.text}\n'
        'التاريخ: $dateText\n'
        'تفاصيل إضافية: ${details.text}';

    final uri = Uri.https('wa.me', '/$whatsappNumber', {
      'text': message,
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر فتح واتساب.')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر حفظ الطلب: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('طلب حجز خدمة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 6),
        const Text('املأ المعلومات، وبعدها ينفتح واتساب برسالة جاهزة لإرسالها للشركة.'),
        const SizedBox(height: 16),
        Form(
          key: formKey,
          child: Column(children: [
            field(name, 'الاسم الكامل', Icons.person),
            const SizedBox(height: 12),
            field(phone, 'رقم الهاتف', Icons.phone, type: TextInputType.phone),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: service,
              decoration: const InputDecoration(labelText: 'نوع الخدمة', prefixIcon: Icon(Icons.home_repair_service)),
              items: const ['نقل أثاث منزلي', 'نقل أثاث مكتبي', 'تغليف أثاث', 'فك وتركيب', 'نقل أجهزة كهربائية', 'نقل آخر']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => service = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: vehicle,
              decoration: const InputDecoration(labelText: 'نوع السيارة/المعدات', prefixIcon: Icon(Icons.local_shipping)),
              items: const ['سيارة نقل', 'سيارة مع عمال', 'سيارة مع تغليف', 'أحتاج استشارة']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => vehicle = v!),
            ),
            const SizedBox(height: 12),
            field(from, 'منطقة الانطلاق', Icons.location_on),
            const SizedBox(height: 12),
            field(to, 'منطقة الوصول', Icons.flag),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => date = picked);
              },
              icon: const Icon(Icons.calendar_month),
              label: Text(date == null ? 'اختيار موعد النقل' : '${date!.year}/${date!.month}/${date!.day}'),
            ),
            const SizedBox(height: 12),
            field(details, 'تفاصيل إضافية (اختياري)', Icons.notes, requiredField: false, maxLines: 3),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: sendBooking,
                icon: const Icon(Icons.chat),
                label: const Padding(padding: EdgeInsets.all(13), child: Text('إرسال الطلب عبر واتساب')),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const Text('ملاحظة: الطلب يُرسل إلى واتساب بعد ضغطك على إرسال، ولا يُحفظ في قاعدة بيانات داخل التطبيق حالياً.', style: TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }

  Widget field(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text, bool requiredField = true, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (v) => requiredField && (v == null || v.trim().isEmpty) ? 'يرجى ملء هذا الحقل' : null,
    );
  }
}

class ContactTab extends StatelessWidget {
  const ContactTab({super.key});
  Future<void> openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/$whatsappNumber');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  Future<void> openEmail() async {
    final uri = Uri(scheme: 'mailto', path: emailAddress, queryParameters: {'subject': 'استفسار - شركة الأخوين للنقل'});
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('تواصل ويانه', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navy)),
      const SizedBox(height: 6),
      const Text('شركة الأخوين للنقل داخل وخارج الكوت'),
      const SizedBox(height: 18),
      contactCard(Icons.mail_rounded, const Color(0xFFD94841), 'البريد الإلكتروني', emailAddress, 'للمراسلات والاستفسارات', openEmail),
      contactCard(Icons.chat_rounded, const Color(0xFF25D366), 'واتساب', '07717203122', 'للحجز والاستفسار مباشرةً', openWhatsApp),
      contactCard(Icons.facebook_rounded, const Color(0xFF1877F2), 'فيسبوك', facebookName, 'صفحة الشركة', null),
      const SizedBox(height: 18),
      const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, color: navy),
            SizedBox(width: 10),
            Expanded(child: Text('للحجز، اكتب تفاصيل النقل من خلال صفحة «احجز خدمة»، وسيتم تجهيز رسالة واتساب لإرسالها للشركة.')),
          ]),
        ),
      ),
    ],
  );
}

Widget contactCard(IconData icon, Color color, String title, String value, String subtitle, VoidCallback? action) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      onTap: action,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text('$value\n$subtitle')),
      isThreeLine: true,
      trailing: action == null ? null : const Icon(Icons.open_in_new, color: navy),
    ),
  );
}
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();

  String verificationId = '';
  bool codeSent = false;
  bool loading = false;

  Future<void> sendCode() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم الهاتف مع رمز الدولة')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        },
        verificationFailed: (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'فشل إرسال الرمز')),
          );
        },
        codeSent: (id, resendToken) {
          if (!mounted) return;
          setState(() {
            verificationId = id;
            codeSent = true;
          });
        },
        codeAutoRetrievalTimeout: (id) {
          verificationId = id;
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> verifyCode() async {
    if (codeController.text.trim().isEmpty ||
        verificationId.isEmpty) {
      return;
    }

    setState(() => loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: codeController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرمز غير صحيح أو انتهت صلاحيته')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('شركة الأخوين لنقل الأثاث'),
        backgroundColor: const Color(0xFF102A43),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.local_shipping,
                size: 85,
                color: Color(0xFF102A43),
              ),
              const SizedBox(height: 20),
              const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text('أدخل رقم هاتفك لاستلام رمز التحقق'),
              const SizedBox(height: 24),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف مع رمز الدولة',
                  hintText: '+9647XXXXXXXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              if (codeSent) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'رمز التحقق',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF102A43),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: loading
                      ? null
                      : codeSent
                          ? verifyCode
                          : sendCode,
                  child: Text(
                    loading
                        ? 'انتظر...'
                        : codeSent
                            ? 'تأكيد الرمز'
                            : 'إرسال رمز التحقق',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
