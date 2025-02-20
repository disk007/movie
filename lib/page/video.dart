import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Video extends StatefulWidget {
  final String videoURL;

  Video({required this.videoURL});//รับข้อมูลจากภายนอกเข้ามาเพื่อใช้ในวิดเจ็ต Video

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoID = YoutubePlayer.convertUrlToId(widget.videoURL);//ประกาศตัวแปร _controller ซึ่งเป็นชนิด YoutubePlayerController ที่ใช้ในการควบคุมการเล่นวิดีโอ YouTube
    if (videoID != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoID, // ทำหน้าที่ แปลง URL ของวิดีโอ YouTube (ที่ส่งมาจาก widget.videoURL) ให้กลายเป็น รหัสวิดีโอ
        flags: const YoutubePlayerFlags(
          autoPlay: true, 
          mute: false,
        ),
      );
    } else {
      // จัดการกรณีที่ videoID เป็น null
      print("Error: videoID is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player',style: TextStyle(color: Colors.amber),),
        backgroundColor: const Color.fromARGB(66, 112, 100, 100),
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
              // แสดงวิดีโอ Trailer
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                onReady: () => debugPrint('Video is ready'),
                progressIndicatorColor: Colors.amber,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
