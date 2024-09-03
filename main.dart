import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
      debugShowCheckedModeBanner: false,
      home: ConcertListScreen(),
    );
  }
}

class ConcertListScreen extends StatefulWidget {
  @override
  _ConcertListScreenState createState() => _ConcertListScreenState();
}

class _ConcertListScreenState extends State<ConcertListScreen> {
  List<Map<String, dynamic>> concerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchConcerts();
  }

  Future<void> fetchConcerts() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/codermert/image-name-changer/main/konserler.json'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        concerts = jsonData.expand((data) {
          return (data['concerts'] as List).map((concert) {
            DateTime parsedDate;
            try {
              parsedDate = DateFormat("dd MMMM EEEE, HH:mm", "tr_TR").parse(concert['dateTime']);
            } catch (e) {
              parsedDate = DateTime.now();
            }
            return {
              "date": parsedDate,
              "location": data['location'],
              "venue": concert['venue'],
              "time": concert['dateTime'],
              "title": data['title'],
              "imageUrl": data['imageUrl'],
              "link": data['link'],
              "price": concert['price'],
            };
          });
        }).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load concerts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bursa yakınında',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Bu konumun yakınında yaklaşan etkinlik yok.',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: Text('Konumu değiştir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8E2DE2),
                      Color(0xFF4A00E0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Turnede',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Madrigal  25 Ağu Paz • 21:00\nMaximum Uniq Açıkhava, İstanbul, TR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            final String? link = 'https://www.biletix.com/etkinlik/35A9J/TURKIYE/tr' as String?;
                            if (link != null) {
                              launchUrl(Uri.parse(link));
                            }
                          },
                          child: Text('Tüm etkinlikleri gör'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Diğer konumlar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: concerts.length,
                  itemBuilder: (context, index) {
                    final concert = concerts[index];
                    return ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMM', 'tr_TR').format(concert['date']).substring(0, 3),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            concert['date'].day.toString(),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      title: Text(concert['title']),
                      subtitle: Text('${concert['time']} • ${concert['venue']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ConcertDetailScreen(concert: concert)),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ConcertDetailScreen extends StatelessWidget {
  final Map<String, dynamic> concert;

  const ConcertDetailScreen({Key? key, required this.concert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime concertDate = concert['date'] as DateTime? ?? DateTime.now();
    final String formattedMonth = DateFormat('MMM', 'tr_TR').format(concertDate).substring(0, 3);
    final String formattedDay = concertDate.day.toString();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[900]!,
                  Colors.black,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(concert['imageUrl'] as String? ??
                              "https://b6s54eznn8xq.merlincdn.net/dist/assets/img/logodark.svg"),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text(
                              formattedMonth,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formattedDay,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  concert['title'] as String? ?? 'Bilinmeyen Sanatçı',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  concert['date'] != null
                      ? DateFormat('d MMMM ', 'tr_TR').format(concert['date'] as DateTime)
                      : 'Tarih mevcut değil',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                // Yeni eklenen mekan bilgileri
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        'https://i.scdn.co/image/ab6761610000e5eb06cb6902e0666278278ae1f4',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 5.0),
                          Text(
                            'Turnede',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Sibel Can',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          OutlinedButton(
                            onPressed: () {
                              final String? link = 'https://biletinial.com/tr-tr/muzik/an-epic-symphony-sibel-can-husnu-senlendirici' as String?;
                              if (link != null) {
                                launchUrl(Uri.parse(link));
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: Text(
                              'Tüm etkinlikleri gör',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 5.0),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.0),
                  ],
                ),
              ),
            ),
                const SizedBox(height: 20),
                const Text(
                  'Mekan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Konser saati: ${concert['time'] ?? 'Saat bilgisi mevcut değil'}',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            concert['venue'] as String? ?? 'Konum bilgisi mevcut değil',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('İlgilenilen'),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {},
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 55),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text('B', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Satışta', style: TextStyle(color: Colors.white)),
                          Row(
                            children: [
                              Text('biletinial.com', style: TextStyle(color: Colors.white70)),
                              SizedBox(width: 8),
                              Icon(Icons.verified, size: 18, color: Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      label: const Text('Bilet bul'),
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                        final String? link = concert['link'] as String?;
                        if (link != null) {
                          launchUrl(Uri.parse(link));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1ed760),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  concert['price'] as String? ?? 'Fiyat bilgisi mevcut değil',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}