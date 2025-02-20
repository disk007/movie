import 'package:flutter/material.dart';
import '../api key/apiKey.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './Detail.dart';
class Upcoming extends StatefulWidget {
  const Upcoming({super.key});

  @override
  _UpcomingState createState() => _UpcomingState();
}

class _UpcomingState extends State<Upcoming> {
  List<dynamic> Upcoming = []; // list upcoming
  List<dynamic> filteredUpcoming = []; //  สำหรับเก็บผลลัพธ์ที่กรองแล้ว
  TextEditingController searchController = TextEditingController();// textEditingController for search
  
  @override
  void initState() { // เป็นเมธอด ซึ่งถูกเรียกในช่วงที่วิดเจ็ตถูกสร้างขึ้นมาเป็นครั้งแรก เพื่อทำการกำหนดค่าหรือเตรียมข้อมูลเบื้องต้น
    super.initState();
    fetchUpcoming();
  }
// เมธอด แสดงรายการหนังที่กำลังจะมา
  Future<void> fetchUpcoming() async {
    final String url = 'https://api.themoviedb.org/3/movie/now_playing?api_key=$apikey'; //  API จาก TMDB API for now playing

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() { // set state for หนังกำลังจะมา
          Upcoming = data['results'];
          filteredUpcoming = Upcoming;
        });
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      print(e);
    }
  }

  void filterMovies(String query) { // เมธอดใช้สำหรับค้นหา
    setState(() {
      filteredUpcoming = Upcoming.where((movie) {
        final movieTitle = movie['title']?.toLowerCase() ?? '';
        final input = query.toLowerCase();
        return movieTitle.contains(input);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Movies'),
        backgroundColor: Color.fromARGB(66, 112, 100, 100),
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
                  labelText: 'Search in upcoming movies',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                onChanged: (query) {
                  filterMovies(query);
                },
              ),
            ),
            Expanded(
              child: filteredUpcoming.isEmpty
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
                          children: filteredUpcoming.map((movie) {
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
                                            'https://image.tmdb.org/t/p/w500${movie['poster_path']}', //แสดงรูปภาพ
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
                                        const Icon(Icons.movie, color: Colors.amber, size: 17),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${movie['release_date']}', //แสดงคะแนนรีวิว
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