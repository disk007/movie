import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/page/video.dart'; 
import '../api key/apiKey.dart';

const Map<int, String> genreMap = { // ประเภทหนังเอาไปเทียบกับ ของ api
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Science Fiction',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western'
};

class MovieDetailsPage extends StatefulWidget {
  final dynamic movie;

  MovieDetailsPage({required this.movie});//รับข้อมูลจากภายนอกเข้ามาเพื่อใช้ในวิดเจ็ต MovieDetailsPage

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  String? trailerUrl;

  @override
  void initState() { // เป็นเมธอด ซึ่งถูกเรียกในช่วงที่วิดเจ็ตถูกสร้างขึ้นมาเป็นครั้งแรก เพื่อทำการกำหนดค่าหรือเตรียมข้อมูลเบื้องต้น
    super.initState();
    fetchTrailer();
  }

  Future<void> fetchTrailer() async {
    final url =
        "https://api.themoviedb.org/3/movie/${widget.movie['id']}/videos?api_key=$apikey";//ดึงข้อมูลรายละเอียดหนังจาก api
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) { ////เช็ค status code
      final data = json.decode(response.body);

      final trailers = data['results']
          .where((video) => video['type'] == 'Trailer') //ดึง video['type'] เอาเฉพาะ Trailer
          .toList();

      if (trailers.isNotEmpty) {
        setState(() {
          trailerUrl = "https://www.youtube.com/watch?v=${trailers[0]['key']}"; //เมื่อได้ข้อมูล video จาก api แล้วเอาค้นหาใน youtube
        });
      }
    } else {
      print('Failed to load trailers');
    }
  }

  List<String> getGenreNames(List<dynamic> genreIds) { // เมธอดแสดงประเภทหนัง
    return genreIds.map((id) => genreMap[id] ?? 'Unknown').toList();
  }

  @override
  Widget build(BuildContext context) {
    List<String> genres = getGenreNames(widget.movie['genre_ids'] ?? []); // หา key ที่ตรงกับประเภทหนัง

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.movie['title'] ?? 'No Title', //แสดงชื่อหนัง
          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ภาพโปสเตอร์
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: widget.movie['poster_path'] != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w500${widget.movie['poster_path']}', // แสดงรูปภาพจาก api
                          height: 400,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.movie, size: 200, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // ชื่อภาพยนตร์
              Text(
                widget.movie['title'] ?? 'No Title', // แสดงชื่อหนัง
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // วันฉาย
              Text(
                'Release Date: ${widget.movie['release_date']}',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 10),

              // คะแนนโหวต
              Text(
                'Rating: ${widget.movie['vote_average']}',
                style: const TextStyle(fontSize: 18, color: Colors.amber),
              ),
              const SizedBox(height: 10),

              // ประเภทของหนัง
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Genres: ${genres.join(', ')}', 
                  style: const TextStyle(fontSize: 16, color: Colors.amber),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // เรื่องย่อ
              Text(
                widget.movie['overview'] ?? 'No overview available.',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // ปุ่มดูตัวอย่าง (Trailer)
              trailerUrl != null
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Video(videoURL: trailerUrl!), //เมื่อคลิกจะ นำทางไปยังหน้า video.dart ที่ import มาแล้ว
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: const Text(
                          'Watch Trailer',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    )
                  : const Text(
                      'No Trailer Available',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
