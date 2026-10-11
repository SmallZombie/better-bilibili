import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MusicPlayerDemo());
}

class MusicPlayerDemo extends StatelessWidget {
  const MusicPlayerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF0F0F10),
      ),
      home: const MusicHomePage(),
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  int _selectedNav = 0;

  final List<NavigationItem> _navigation = const [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore,
      label: 'Browse',
    ),
    NavigationItem(
      icon: Icons.radio_outlined,
      selectedIcon: Icons.radio,
      label: 'Radio',
    ),
    NavigationItem(
      icon: Icons.library_music_outlined,
      selectedIcon: Icons.library_music,
      label: 'Library',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (width >= 1200) {
            return _buildDesktopLayout();
          }

          if (width >= 700) {
            return _buildTabletLayout();
          }

          return _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _SideNavigation(
          items: _navigation,
          selectedIndex: _selectedNav,
          onSelected: (index) {
            setState(() {
              _selectedNav = index;
            });
          },
        ),
        const Expanded(
          child: _MainContent(),
        ),
        const SizedBox(
          width: 340,
          child: _NowPlayingPanel(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        _SideNavigation(
          compact: true,
          items: _navigation,
          selectedIndex: _selectedNav,
          onSelected: (index) {
            setState(() {
              _selectedNav = index;
            });
          },
        ),
        const Expanded(
          child: _MainContent(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 152),
            child: _MainContent(
              mobile: true,
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 72,
            child: _MiniPlayer(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavigationBar(
              selectedIndex: _selectedNav,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedNav = index;
                });
              },
              backgroundColor: const Color(0xFF141416),
              indicatorColor: Colors.white.withOpacity(.10),
              destinations: [
                for (final item in _navigation)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _SideNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool compact;

  const _SideNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 76 : 240,
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(.06),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Logo
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 20,
            ),
            child: compact
                ? const Icon(
                    Icons.music_note_rounded,
                    size: 32,
                  )
                : Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFF5964),
                              Color(0xFFB91C3B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.music_note_rounded,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Music',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 14,
              ),
              itemCount: items.length + 2,
              separatorBuilder: (_, index) {
                if (index == 3 || index == 4) {
                  return const SizedBox(height: 12);
                }

                return const SizedBox(height: 4);
              },
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  final extraIndex = index - items.length;

                  return _SideNavigationItem(
                    icon: extraIndex == 0 ? Icons.favorite_outline : Icons.queue_music,
                    selected: false,
                    label: extraIndex == 0 ? 'Favorites' : 'Playlists',
                    compact: compact,
                    onTap: () {},
                  );
                }

                final item = items[index];

                return _SideNavigationItem(
                  icon: item.icon,
                  selectedIcon: item.selectedIcon,
                  selected: selectedIndex == index,
                  label: item.label,
                  compact: compact,
                  onTap: () => onSelected(index),
                );
              },
            ),
          ),

          // User
          Container(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: compact
                ? const CircleAvatar(
                    radius: 19,
                    child: Text('S'),
                  )
                : Row(
                    children: [
                      const CircleAvatar(
                        radius: 21,
                        child: Text('S'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Small Zombie',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Apple Music',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.more_horiz,
                        color: Colors.white54,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SideNavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final bool selected;
  final String label;
  final bool compact;
  final VoidCallback onTap;

  const _SideNavigationItem({
    required this.icon,
    required this.selected,
    required this.label,
    required this.compact,
    required this.onTap,
    this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final actualIcon = selected ? selectedIcon ?? icon : icon;

    return Material(
      color: selected ? Colors.white.withOpacity(.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: compact
              ? Center(
                  child: Icon(
                    actualIcon,
                    color: selected ? Colors.white : Colors.white60,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(
                        actualIcon,
                        color: selected ? Colors.white : Colors.white60,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        label,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontWeight: selected ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final bool mobile;

  const _MainContent({
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          toolbarHeight: mobile ? 68 : 76,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0F0F10),
          surfaceTintColor: Colors.transparent,
          titleSpacing: mobile ? 20 : 28,
          title: Text(
            'Home',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            const SizedBox(width: 12),
          ],
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            mobile ? 16 : 28,
            12,
            mobile ? 16 : 28,
            30,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildGreeting(context),
              const SizedBox(height: 28),
              _buildHero(context),
              const SizedBox(height: 36),
              const _SectionHeader(
                title: 'Recently Played',
                action: 'See All',
              ),
              const SizedBox(height: 14),
              _RecentlyPlayed(
                mobile: mobile,
              ),
              const SizedBox(height: 34),
              const _SectionHeader(
                title: 'Made For You',
                action: 'See All',
              ),
              const SizedBox(height: 14),
              _MadeForYou(
                mobile: mobile,
              ),
              const SizedBox(height: 34),
              const _SectionHeader(
                title: 'Albums',
                action: 'See All',
              ),
              const SizedBox(height: 14),
              _AlbumGrid(
                mobile: mobile,
              ),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Text(
      'Good morning',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white60,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      height: mobile ? 250 : 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3C1A29),
            Color(0xFF17171A),
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -30,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF4D6D).withOpacity(.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: 80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHILL MIX',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.8,
                      color: Colors.white60,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A little music\nfor your day.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;

  const _SectionHeader({
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            action,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentlyPlayed extends StatelessWidget {
  final bool mobile;

  const _RecentlyPlayed({
    required this.mobile,
  });

  static const songs = [
    _SongData(
      title: 'Afterglow',
      artist: 'Joji',
      gradient: [Color(0xFF6C63FF), Color(0xFF1E1B4B)],
    ),
    _SongData(
      title: 'Blue Hour',
      artist: 'TXT',
      gradient: [Color(0xFF0EA5E9), Color(0xFF164E63)],
    ),
    _SongData(
      title: 'Midnight',
      artist: 'Keshi',
      gradient: [Color(0xFFDB2777), Color(0xFF4C1D95)],
    ),
    _SongData(
      title: 'Slow Down',
      artist: 'NewJeans',
      gradient: [Color(0xFF22C55E), Color(0xFF064E3B)],
    ),
    _SongData(
      title: 'Snowfall',
      artist: 'Øneheart',
      gradient: [Color(0xFF60A5FA), Color(0xFF1E3A8A)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: mobile ? 185 : 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final song = songs[index];

          final width = mobile ? 145.0 : 165.0;

          return SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _Artwork(
                    gradient: song.gradient,
                    radius: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MadeForYou extends StatelessWidget {
  final bool mobile;

  const _MadeForYou({
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    final playlists = [
      const _PlaylistData(
        title: 'Chill Mix',
        subtitle: 'For your quiet moments.',
        icon: Icons.nightlight_round,
        colors: [
          Color(0xFF1D4ED8),
          Color(0xFF312E81),
        ],
      ),
      const _PlaylistData(
        title: 'Focus Flow',
        subtitle: 'Stay focused.',
        icon: Icons.blur_on,
        colors: [
          Color(0xFF0F766E),
          Color(0xFF164E63),
        ],
      ),
      const _PlaylistData(
        title: 'Energy',
        subtitle: 'Turn it up.',
        icon: Icons.bolt_rounded,
        colors: [
          Color(0xFFEA580C),
          Color(0xFF991B1B),
        ],
      ),
    ];

    return SizedBox(
      height: mobile ? 190 : 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: playlists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final playlist = playlists[index];

          return Container(
            width: mobile ? 260 : 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: playlist.colors,
              ),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  playlist.icon,
                  size: 38,
                ),
                const Spacer(),
                Text(
                  playlist.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  playlist.subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AlbumGrid extends StatelessWidget {
  final bool mobile;

  const _AlbumGrid({
    required this.mobile,
  });

  static const albums = [
    _SongData(
      title: 'Fine Line',
      artist: 'Harry Styles',
      gradient: [Color(0xFFF59E0B), Color(0xFF78350F)],
    ),
    _SongData(
      title: 'Nectar',
      artist: 'Joji',
      gradient: [Color(0xFF14B8A6), Color(0xFF134E4A)],
    ),
    _SongData(
      title: 'Get Up',
      artist: 'NewJeans',
      gradient: [Color(0xFFA855F7), Color(0xFF581C87)],
    ),
    _SongData(
      title: 'DAMN.',
      artist: 'Kendrick Lamar',
      gradient: [Color(0xFFDC2626), Color(0xFF450A0A)],
    ),
    _SongData(
      title: 'SOS',
      artist: 'SZA',
      gradient: [Color(0xFFF97316), Color(0xFF7C2D12)],
    ),
    _SongData(
      title: 'Gemini Rights',
      artist: 'Steve Lacy',
      gradient: [Color(0xFF84CC16), Color(0xFF365314)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final columns = mobile ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: albums.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 18,
        mainAxisSpacing: 24,
        childAspectRatio: .78,
      ),
      itemBuilder: (context, index) {
        final album = albums[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Artwork(
                gradient: album.gradient,
                radius: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              album.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              album.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Artwork extends StatelessWidget {
  final List<Color> gradient;
  final double radius;

  const _Artwork({
    required this.gradient,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 54,
          color: Colors.white.withOpacity(.18),
        ),
      ),
    );
  }
}

class _NowPlayingPanel extends StatelessWidget {
  const _NowPlayingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        border: Border(
          left: BorderSide(
            color: Colors.white.withOpacity(.06),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              22,
              16,
              14,
            ),
            child: Row(
              children: [
                Text(
                  'Now Playing',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                22,
                12,
                22,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AspectRatio(
                    aspectRatio: 1,
                    child: _Artwork(
                      gradient: [
                        Color(0xFF7C3AED),
                        Color(0xFF1E1B4B),
                      ],
                      radius: 22,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Afterglow',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Joji',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.favorite_border,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _PlayerProgress(),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '1:24',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '3:58',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.shuffle_rounded,
                          color: Colors.white54,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          size: 30,
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 34,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.repeat_rounded,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _QueueSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueSection extends StatelessWidget {
  const _QueueSection();

  @override
  Widget build(BuildContext context) {
    const queue = [
      ['Blue Hour', 'TXT'],
      ['Midnight', 'Keshi'],
      ['Snowfall', 'Øneheart'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Up Next',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < queue.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: _Artwork(
                    gradient: [
                      Colors.blueGrey.shade700,
                      Colors.blueGrey.shade900,
                    ],
                    radius: 8,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        queue[i][0],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        queue[i][1],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.drag_handle,
                  color: Colors.white24,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PlayerProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(
            height: 4,
            color: Colors.white.withOpacity(.10),
          ),
          FractionallySizedBox(
            widthFactor: .36,
            child: Container(
              height: 4,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF202023),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            const SizedBox(
              width: 52,
              height: 52,
              child: _Artwork(
                gradient: [
                  Color(0xFF7C3AED),
                  Color(0xFF1E1B4B),
                ],
                radius: 12,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Afterglow',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Joji',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.skip_previous_rounded,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.play_arrow_rounded,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.skip_next_rounded,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _SongData {
  final String title;
  final String artist;
  final List<Color> gradient;

  const _SongData({
    required this.title,
    required this.artist,
    required this.gradient,
  });
}

class _PlaylistData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const _PlaylistData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}
