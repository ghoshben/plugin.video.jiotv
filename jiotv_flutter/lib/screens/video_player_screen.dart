import 'package:flutter/material.dart';
import 'package:jiotv_flutter/services/channel_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerScreen extends StatefulWidget {
  final int channelId;

  const VideoPlayerScreen({super.key, required this.channelId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  final ChannelService _channelService = ChannelService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final result = await _channelService.getChannelUrl(widget.channelId);

    if (result is Map<String, dynamic>) {
      final url = result['url'];
      final headers = result['headers'] as Map<String, String>;

      await _player.open(
        Media(
          url,
          httpHeaders: headers,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _error = result.toString();
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text('Error: $_error')
                : Video(controller: _controller),
      ),
    );
  }
}
