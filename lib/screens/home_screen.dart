// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_stunting_app/screens/tabs/child_data_tab.dart';
import 'package:smart_stunting_app/screens/tabs/profile_tab.dart';
import 'package:smart_stunting_app/screens/tabs/dashboard_tab.dart';
import 'package:smart_stunting_app/services/auth_service.dart';
import 'package:smart_stunting_app/models/user.dart';
import 'package:smart_stunting_app/screens/login_screen.dart';
import 'package:smart_stunting_app/models/news.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  User? _currentUser;
  final AuthService _authService = AuthService();

  bool _isLoadingProfile = true;

  final List<News> _allNews = [
    News(
      id: '1',
      title: 'Cegah Stunting Bukan Cuma Soal Gizi, Tapi Juga Soal Air',
      imageUrl:
          'https://foto.wartaekonomi.co.id/files/arsip_foto_2025_07_24/air_bersih_220900_big.webp',
      shortDescription:
          'Pencegahan stunting tak hanya soal asupan gizi, melainkan juga terkait erat dengan ketersediaan air bersih dan sanitasi yang layak.',
      fullContent:
          'Air yang terkontaminasi adalah salah satu pemicu utama diare pada anak, yang pada gilirannya dapat menghambat penyerapan nutrisi dan menyebabkan stunting. Yayasan Jiva Svastha Nusantara dan berbagai pihak lainnya terus mengedukasi masyarakat tentang pentingnya akses air minum aman dan sanitasi yang baik sebagai bagian integral dari upaya pencegahan stunting. Kualitas air tidak hanya dinilai dari kejernihan air, melainkan juga dari bebasnya bakteri berbahaya yang dapat memengaruhi kesehatan anak.',
      url:
          'https://wartaekonomi.co.id/read576214/cegah-stunting-bukan-cuma-soal-gizi-tapi-juga-soal-air',
    ),
    News(
      id: '2',
      title:
          'Pemkab Bojonegoro Prioritaskan Pengentasan Stunting, Intervensi Program Hingga Dasawisma',
      imageUrl:
          'https://beritajatim.com/wp-content/uploads/2025/07/IMG_COM_202507241521381150.webp',
      shortDescription:
          'Pemerintah Kabupaten Bojonegoro menetapkan pengentasan stunting sebagai prioritas utama dengan menjalankan berbagai program intervensi hingga tingkat Dasawisma.',
      fullContent:
          'Bojonegoro menunjukkan komitmen kuat dalam penurunan angka stunting. Berbagai inisiatif dan program telah disusun untuk memastikan intervensi gizi dan kesehatan dapat menjangkau seluruh lapisan masyarakat, bahkan hingga unit Dasawisma terkecil. Pendekatan holistik ini diharapkan dapat mempercepat upaya pencegahan dan penanganan stunting di seluruh wilayah kabupaten.',
      url:
          'https://beritajatim.com/pemkab-bojonegoro-prioritaskan-pengentasan-stunting-intervensi-program-hingga-dasawisma',
    ),
    News(
      id: '3',
      title:
          'Fakta Mengejutkan: Kesehatan Gigi Ibu Hamil yang Buruk Meningkatkan Risiko Terhadap Stunting Bayi',
      imageUrl:
          'https://cdn1-production-images-kly.akamaized.net/ubKMg3fx9EY6b_C1oVVrO6CD5bU=/1360x1360/smart/filters:quality(75):strip_icc():format(webp)/kly-media-production/medias/5229980/original/099881100_1747978804-WhatsApp_Image_2025-05-23_at_08.05.08.jpeg',
      shortDescription:
          'Kesehatan gigi ibu hamil yang kurang terjaga berpotensi meningkatkan risiko bayi lahir stunting, sebuah fakta yang perlu diwaspadai.',
      fullContent:
          'Studi terbaru mengungkap hubungan mengejutkan antara kesehatan gigi ibu hamil dan risiko stunting pada bayi. Infeksi atau peradangan pada gigi dan gusi ibu dapat memicu respons inflamasi yang berpotensi memengaruhi nutrisi dan pertumbuhan janin. Penting bagi ibu hamil untuk menjaga kebersihan dan kesehatan gigi sebagai bagian dari upaya komprehensif mencegah stunting sejak dalam kandungan.',
      url:
          'https://www.fimela.com/health/read/6113970/fakta-mengejutkan-kesehatan-gigi-ibu-hamil-yang-buruk-meningkatkan-risiko-terhadap-stunting-bayi?utm_source=chatgpt.com',
    ),
    News(
      id: '4',
      title:
          'HUT Ikatan Bidan Indonesia Cabang Tanjabtim Garda Terdepan Kesehatan Ibu & Anak Berkomitmen Dalam Penurunan Stunting',
      imageUrl:
          'https://mapikornews.com/bank_gambar/sedeng_60img-20250724-wa0050.jpg',
      shortDescription:
          'Ikatan Bidan Indonesia (IBI) Cabang Tanjabtim menegaskan kembali komitmennya sebagai garda terdepan dalam upaya peningkatan kesehatan ibu dan anak serta penurunan angka stunting.',
      fullContent:
          'Dalam peringatan HUT-nya, IBI Cabang Tanjabtim menggarisbawahi peran krusial bidan dalam upaya pencegahan stunting. Bidan memiliki akses langsung ke masyarakat dan menjadi ujung tombak dalam edukasi gizi, pemantauan tumbuh kembang balita, serta penyuluhan kesehatan. Komitmen ini diharapkan dapat terus memberikan kontribusi nyata dalam mencapai target penurunan stunting di wilayah Tanjung Jabung Timur.',
      url:
          'https://mapikornews.com/daerah/hut-ikatan-bidan-indonesia-cabang-tanjabtim-garda-terdepan-kesehatan-ibu--anak-berkomitmen-dalam-penurunan-stunting/',
    ),
    News(
      id: '5',
      title:
          'Yayasan Jiva Svastha Nusantara Ajak Warga Cegah Stunting Mulai dari Lingkungan',
      imageUrl:
          'https://cloud.jpnn.com/photo/arsip/normal/2025/07/24/dari-kiri-ke-kanan-kabid-hukum-dan-advokasi-kebijakan-yayasa-xprd.jpg',
      shortDescription:
          'Yayasan Jiva Svastha Nusantara mengajak masyarakat untuk memulai pencegahan stunting dari lingkungan sekitar, terutama melalui akses air minum yang aman dan sanitasi yang baik.',
      fullContent:
          'Yayasan Jiva Svastha Nusantara mengedukasi masyarakat tentang pentingnya peran lingkungan dalam pencegahan stunting. Dokter Lucy Widasari menyoroti bahwa kualitas air minum yang tampak jernih belum tentu aman dan banyak mengandung bakteri berbahaya seperti E. coli, yang dapat menyebabkan infeksi dan menghambat penyerapan nutrisi. Surya Putra menambahkan bahwa air bermutu adalah pertahanan pertama. Inisiatif ini menekankan bahwa stunting bukan hanya masalah gizi, tetapi juga masalah lingkungan yang dapat diatasi dengan meningkatkan akses terhadap air minum layak dan sanitasi yang higienis.',
      url:
          'https://www.jpnn.com/news/yayasan-jiva-svastha-nusantara-ajak-warga-cegah-stunting-mulai-dari-lingkungan',
    ),
    News(
      id: '6',
      title:
          'Beri Bantuan Bagi Balita, Cantika Wahono Optimis Angka Stunting di Bojonegoro Akan Terus Turun',
      imageUrl:
          'https://bojonegorokab.go.id/storage/uploads/artikel/hbsRMIcQFKGHTDlV.jpg',
      shortDescription:
          'Ketua TP PKK Kabupaten Bojonegoro, Cantika Wahono, menyatakan optimisme terhadap penurunan angka stunting di wilayahnya melalui program-program Pemkab dan pemberian bantuan makanan tambahan bagi balita.',
      fullContent:
          'Cantika Wahono, Ketua TP PKK Kabupaten Bojonegoro, optimis angka stunting akan terus menurun berkat program-program yang dijalankan oleh Pemerintah Kabupaten Bojonegoro. Salah satu fokus utamanya adalah pemberian bantuan makanan tambahan dengan kandungan gizi tinggi bagi balita. Program ini diharapkan dapat secara signifikan memperbaiki kualitas gizi balita di Bojonegoro dan mempercepat pencapaian target penurunan stunting. Masyarakat menyambut baik bantuan tersebut dan berharap program ini berkelanjutan.',
      url:
          'https://bojonegorokab.go.id/berita/8660/beri-bantuan-bagi-balita-cantika-wahono-optimis-angka-stunting-di-bojonegoro-akan-terus-turun',
    ),
    News(
      id: '7',
      title:
          'Indonesia launches free meals program to feed children and pregnant women to fight malnutrition',
      imageUrl:
          'https://d3i6fh83elv35t.cloudfront.net/static/2025/01/2025-01-06T014359Z_64264087_RC214CA7KCJE_RTRMADP_3_INDONESIA-ECONOMY-1200x800.jpg',
      shortDescription:
          'Pemerintah baru Indonesia meluncurkan program makan gratis berskala besar untuk anak-anak dan ibu hamil sebagai bagian dari upaya nasional memerangi malnutrisi dan stunting.',
      fullContent:
          'Pemerintah baru Indonesia di bawah kepemimpinan Presiden Prabowo Subianto telah meluncurkan program makanan bergizi gratis yang ambisius untuk mengatasi malnutrisi dan stunting. Program ini menargetkan hampir 90 juta anak dan ibu hamil, dengan perkiraan biaya mencapai 28 dollar miliar hingga tahun 2029. Ini adalah bagian dari janji kampanye Subianto untuk menciptakan "Generasi Emas Indonesia" pada tahun 2045. Untuk tahun 2025, program ini menargetkan 19,5 juta anak sekolah dan ibu hamil dengan anggaran 4,3 miliar dollar, berfokus pada penyediaan satu kali makan per hari untuk memenuhi sepertiga kebutuhan kalori harian anak.',
      url:
          'https://www.pbs.org/newshour/world/indonesia-launches-free-meals-program-to-feed-children-and-pregnant-women-to-fight-malnutrition',
    ),
    News(
      id: '8',
      title: 'SSGI 2024: Prevalensi Stunting Nasional Turun Menjadi 19,8%',
      imageUrl:
          'https://www.badankebijakan.kemkes.go.id/wp-content/uploads/2025/05/web-header-SSGI-dalam-Angka-comp.png',
      shortDescription:
          'Hasil Survei Status Gizi Indonesia (SSGI) 2024 menunjukkan penurunan signifikan prevalensi stunting nasional menjadi 19,8%.',
      fullContent:
          'Kementerian Kesehatan telah merilis data terbaru dari Survei Status Gizi Indonesia (SSGI) 2024, yang mengindikasikan penurunan prevalensi stunting secara nasional menjadi 19,8%. Angka ini merupakan capaian positif berkat kerja sama lintas sektor dan various program intervensi gizi. Meskipun demikian, pemerintah terus berupaya mencapai target yang lebih rendah untuk memastikan generasi penerus Indonesia tumbuh optimal dan bebas stunting.',
      url:
          'https://kemkes.go.id/id/ssgi-2024-prevalensi-stunting-nasional-turun-menjadi-198',
    ),
    News(
      id: '9',
      title:
          'Menkes Ungkap Provinsi dengan Angka Stunting Tertinggi di Indonesia',
      imageUrl:
          'https://akcdn.detik.net.id/visual/2025/03/26/ilustrasi-anak-stunting-1742986148819_169.jpeg?w=900&q=80',
      shortDescription:
          'Menteri Kesehatan mengumumkan provinsi-provinsi dengan prevalensi stunting tertinggi di Indonesia, mendorong fokus intervensi yang lebih intensif.',
      fullContent:
          'Menteri Kesehatan RI memaparkan data mengenai provinsi-provinsi yang masih memiliki angka stunting tertinggi di Indonesia, di antaranya Jawa Barat, Jawa Tengah, dan Sulawesi Selatan. Informasi ini menjadi landasan bagi pemerintah untuk mengarahkan sumber daya dan program intervensi gizi secara lebih terfokus ke wilayah-wilayah yang membutuhkan penanganan paling mendesak. Prioritas diberikan pada 1000 hari pertama kehidupan anak, mengingat periode tersebut sangat krusial dalam pencegahan stunting.',
      url:
          'https://www.cnbcindonesia.com/lifestyle/20250701165706-33-645347/menkes-ungkap-provinsi-dengan-angka-stunting-tertinggi-di-indonesia',
    ),
    News(
      id: '10',
      title:
          '3 Bahan PMT Berbasis Pangan Lokal untuk Cegah Stunting, Mudah Dicari dan Bergizi Tinggi',
      imageUrl:
          'https://cdn1-production-images-kly.akamaized.net/V_3dsD2cIXGQvQdE0o5jB1iR9m4=/0x0:4160x2339/1280x720/filters:quality(75):strip_icc():format(webp):watermark(kly-media-production/assets/images/watermarks/liputan6/watermark-color-landscape-new.png,1180,20,0)/kly-media-production/medias/5275029/original/035760200_1751861357-da1a789c-7361-4882-9c1e-f0c01525a72d.jpg',
      shortDescription:
          'Liputan6.com merekomendasikan tiga bahan makanan tambahan (PMT) berbasis pangan lokal yang efektif, mudah ditemukan, dan kaya gizi untuk cegah stunting.',
      fullContent:
          'Untuk membantu pencegahan stunting, ada beberapa bahan pangan lokal yang sangat direkomendasikan sebagai Pemberian Makanan Tambahan (PMT) bagi balita. Bahan-bahan ini tidak hanya mudah didapat di Indonesia tetapi juga memiliki kandungan gizi yang tinggi, seperti ikan yang kaya omega-3, tempe sebagai sumber protein nabati yang sangat baik, dan daun kelor yang dikenal sebagai \'superfood\' dengan kandungan vitamin dan mineral lengkap. Pemanfaatan pangan lokal ini diharapkan dapat menjadi solusi praktis dan efektif dalam memenuhi kebutuhan gizi anak.',
      url:
          'https://www.liputan6.com/health/read/6098254/3-bahan-pmt-berbasis-pangan-lokal-untuk-cegah-stunting-mudah-dicari-dan-bergizi-tinggi',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchCurrentUser() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
    });
    try {
      final user = await _authService.getUserProfile();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Error fetching current user: $e');
      if (mounted) {
        if (e.toString().contains('Unauthorized') ||
            e.toString().contains('Invalid token')) {
          _authService.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal memuat profil: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      RefreshIndicator(
        onRefresh: () => _fetchCurrentUser(),
        child: DashboardTab(
          currentUser: _currentUser,
          allNews: _allNews,
          onItemTapped: _onItemTapped,
          isLoadingProfile: _isLoadingProfile,
        ),
      ),

      const ChildDataTab(),
      ProfileTab(
        onProfileUpdated: () {
          _fetchCurrentUser();
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Stunting'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Data Anak',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
