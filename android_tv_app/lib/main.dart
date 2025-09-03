import 'package:flutter/material.dart';
import 'constants.dart';
import 'player.dart';
import 'epg.dart';
import 'services/auth.dart';
import 'services/jio_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = JioAuth();
  await auth.loadSavedSession();
  final api = JioApi(auth);
  runApp(JioTVApp(api: api, auth: auth));
}

class JioTVApp extends StatelessWidget {
  const JioTVApp({super.key, required this.api, required this.auth});
  final JioApi api;
  final JioAuth auth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JioTV',
      theme: ThemeData.dark(useMaterial3: true),
      home: HomeView(api: api),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.api});
  final JioApi api;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JioTV')),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(24),
        children: [
          _HomeCard(
            title: 'Featured',
            icon: Icons.star,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FeaturedView(api: api)),
              );
            },
          ),
          _HomeCard(
            title: 'Genres',
            icon: Icons.category,
            onTap: () async {
              final dict = await api.fetchDictionary();
              final genres = List<String>.from(dict['Genre'] ?? []);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryListView(
                    api: api,
                    items: genres,
                    type: 'channelCategory',
                  ),
                ),
              );
            },
          ),
          _HomeCard(
            title: 'Languages',
            icon: Icons.language,
            onTap: () async {
              final dict = await api.fetchDictionary();
              final langs = List<String>.from(dict['Language'] ?? []);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryListView(
                    api: api,
                    items: langs,
                    type: 'language',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.title, required this.icon, required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class FeaturedView extends StatefulWidget {
  const FeaturedView({super.key, required this.api});
  final JioApi api;

  @override
  State<FeaturedView> createState() => _FeaturedViewState();
}

class _FeaturedViewState extends State<FeaturedView> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchFeatured();
  }

  Color _statusColor(Map<String, dynamic> item) {
    final status = item['livestatus'];
    if (status == 'live') return Colors.red;
    if (status == 'catchup') return Colors.yellow;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Featured')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index] as Map<String, dynamic>;
              return ListTile(
                leading: Image.network(
                  JioConstants.imgPublic + (item['logoUrl'] ?? ''),
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
                title: Text(item['title'] ?? ''),
                subtitle: Text(item['channel_name'] ?? ''),
                trailing: Text(
                  item['livestatus'] ?? '',
                  style: TextStyle(color: _statusColor(item)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key, required this.api, required this.items, required this.type});
  final JioApi api;
  final List<String> items;
  final String type; // 'channelCategory' or 'language'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(type == 'language' ? 'Languages' : 'Genres')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChannelListView(api: api, type: type, value: items[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChannelListView extends StatelessWidget {
  const ChannelListView({super.key, required this.api, required this.type, required this.value});
  final JioApi api;
  final String type; // key for filtering
  final String value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(value)),
      body: FutureBuilder<List<dynamic>>(
        future: api.fetchChannelsBy(type, value),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data ?? [];
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final ch = list[index] as Map<String, dynamic>;
              return ListTile(
                leading: Image.network(
                  JioConstants.imgPublic + (ch['logoUrl'] ?? ''),
                  errorBuilder: (_, __, ___) => const Icon(Icons.tv),
                ),
                title: Text(ch['channel_name'] ?? ''),
                subtitle: Text('Channel ${ch['channel_number'] ?? ''}'),
                onTap: () async {
                  final url = await api.resolveChannelUrl(int.parse(ch['channel_id']));
                  if (url != null && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChannelPlayer(url: url)),
                    );
                  }
                },
                trailing: IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EpgView(api: api, channelId: int.parse(ch['channel_id'])),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

