import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/Detail.dart';
import '../api key/apiKey.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Trending extends StatefulWidget {
  const Trending({super.key});

  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  List<dynamic> trendingMovies = []; //  list of trending movies
  List<dynamic> filteredMovies = []; // สำหรับเก็บผลลัพธ์ที่กรองแล้ว
  TextEditingController searchController = TextEditingController(); // TextEditingController เอาไว้ค้นหาข้อมูล

  @override
  void initState() { // เป็นเมธอด ซึ่งถูกเรียกในช่วงที่วิดเจ็ตถูกสร้างขึ้นมาเป็นครั้งแรก เพื่อทำการกำหนดค่าหรือเตรียมข้อมูลเบื้องต้น
    super.initState(); // เรียกใช้งาน initState() จากคลาสแม่ (State) เพื่อให้มั่นใจว่า State พื้นฐานจะถูกสร้างขึ้นและทำงานตามปกติ
    fetchTrendingMovies(); // เรียกเมธอด fetchedTrendingMovies
  }

  // ฟังก์ชันดึงข้อมูลจาก TMDB API
  Future<void> fetchTrendingMovies() async { 
    final String url = 'https://api.themoviedb.org/3/trending/movie/day?api_key=$apikey'; 

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) { //เช็ค status code
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          trendingMovies = data['results'];
          filteredMovies = trendingMovies; // เริ่มต้นให้แสดงทั้งหมด
        });
      } else {
        throw Exception('Failed to load trending movies');
      }
    } catch (e) {
      print(e);
    }
  }

  // ฟังก์ชันค้นหาภาพยนตร์จาก trendingMovies
  void filterMovies(String query) {
    setState(() {
      filteredMovies = trendingMovies.where((movie) {
        final movieTitle = movie['title']?.toLowerCase() ?? ''; // แปลงชื่อเรื่องให้เป็นตัวเล็กทั้งเพื่อง่ายต่อการค้นหา
        final input = query.toLowerCase();

        return movieTitle.contains(input); // ตรวจสอบว่าชื่อภาพยนตร์ตรงกับข้อความค้นหาหรือไม่
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Movies'),
        backgroundColor: const Color.fromARGB(66, 112, 100, 100),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Search in Trending',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                onChanged: (query) {
                  filterMovies(query); // เรียกฟังก์ชันค้นหาเมื่อมีการพิมพ์ใน TextField
                },
              ),
            ),
            Expanded(
              child: filteredMovies.isEmpty
                  ? const Center(
                      child: Text(
                        'Not found',
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Center(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: filteredMovies.map((movie) {
                            return GestureDetector(
                              onTap: () {
                                // เมื่อคลิกที่ภาพยนตร์ นำทางไปยังหน้า Detail.dart ที่ import มาแล้ว
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovieDetailsPage(movie: movie),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsetsDirectional.symmetric(vertical: 7),
                                padding: const EdgeInsetsDirectional.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: const Color.fromARGB(66, 112, 100, 100),
                                  border: Border.all(
                                    color: Colors.amber,
                                    width: 2,
                                  ),
                                ),
                                width: 170,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    movie['poster_path'] != null
                                        ? Image.network(
                                            'https://image.tmdb.org/t/p/w500${movie['poster_path']}',//แสดงรูปภาพ
                                            height: 200,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.movie, size: 200),
                                    const SizedBox(height: 10),
                                    Text(
                                      movie['title'] ?? 'No Title', // แสดงชื่อเรื่อง
                                      style: const TextStyle(fontSize: 16, color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 17),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${movie['vote_average']}',//แสดงคะแนนรีวิว
                                          style: const TextStyle(fontSize: 14, color: Colors.white),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
