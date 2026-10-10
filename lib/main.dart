
import 'package:flutter/material.dart';

void main() {
  runApp(const AkhwainApp());
}

class AkhwainApp extends StatelessWidget {
  const AkhwainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'شركة الأخوين لنقل الأثاث',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF174A73),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, dynamic>> services = const [
    {
      'title': 'نقل الأثاث المنزلي',
      'icon': Icons.chair_alt,
      'description': 'نقل أثاث البيت بعناية واهتمام',
    },
    {
      'title': 'نقل الأثاث المكتبي',
      'icon': Icons.business,
      'description': 'نقل المكاتب والمحلات والشركات',
    },
    {
      'title': 'التغليف والحماية',
      'icon': Icons.inventory_2,
      'description': 'تغليف الأثاث للمحافظة عليه',
    },
    {
      'title': 'التحميل والتنزيل',
      'icon': Icons.local_shipping,
      'description': 'عمال للتحميل والتنزيل والترتيب',
    },
    {
      'title': 'نقل داخل وخارج الكوت',
      'icon': Icons.location_on,
      'description': 'خدمات نقل داخل المدينة وخارجها',
    },
    {
      'title': 'نقل الأجهزة المنزلية',
      'icon': Icons.kitchen,
      'description': 'نقل الأجهزة والأغراض المنزلية',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF174A73),
          foregroundColor: Colors.white,
          title: const Text(
            'شركة الأخوين',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF174A73),
                    Color(0xFF2678A8),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'شركة الأخوين لنقل الأثاث',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'نقل أثاث منزلي ومكتبي داخل الكوت وخارجها',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'خدمتكم مسؤوليتنا، وأثاثكم بأمان',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'خدماتنا',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF174A73),
              ),
            ),
            const SizedBox(height: 12),
            ...services.map(
              (service) => Card(
                elevation: 1,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 27,
                    backgroundColor: const Color(0xFFE5EFF7),
                    child: Icon(
                      service['icon'] as IconData,
                      color: const Color(0xFF174A73),
                      size: 27,
                    ),
                  ),
                  title: Text(
                    service['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      service['description'] as String,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 42,
                    color: Color(0xFF174A73),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'تحتاج خدمة نقل؟',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'تواصل معنا لحجز خدمة نقل الأثاث.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'سيُضاف رقم الهاتف والواتساب بعد تحديد أرقام الشركة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'شركة الأخوين لنقل الأثاث © 2026',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
