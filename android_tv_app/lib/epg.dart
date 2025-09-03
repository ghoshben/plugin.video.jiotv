import 'package:flutter/material.dart';
import 'services/jio_api.dart';

class EpgView extends StatefulWidget {
  const EpgView({super.key, required this.api, required this.channelId});
  final JioApi api;
  final int channelId;

  @override
  State<EpgView> createState() => _EpgViewState();
}

class _EpgViewState extends State<EpgView> {
  late Future<List<dynamic>> _epgFuture;

  @override
  void initState() {
    super.initState();
    _epgFuture = widget.api.fetchEpg(widget.channelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catch-up')),
      body: FutureBuilder<List<dynamic>>(
        future: _epgFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('No catch-up data'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                title: Text(item['showname'] ?? ''),
                subtitle: Text(item['starttime'] ?? ''),
                onTap: () {
                  // This is where catch-up playback would be launched
                },
              );
            },
          );
        },
      ),
    );
  }
}

