import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF24232A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const StreamingApp());
}

class StreamingApp extends StatelessWidget {
  const StreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Streaming UI',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Arial',
      ),
      home: const StreamingHomePage(),
    );
  }
}

class StreamingHomePage extends StatefulWidget {
  const StreamingHomePage({super.key});

  @override
  State<StreamingHomePage> createState() => _StreamingHomePageState();
}

class _StreamingHomePageState extends State<StreamingHomePage> {
  int selectedNavigationIndex = 0;

  final List<List<Color>> posterColors = const [
    [
      Color(0xFFE8D8D3),
      Color(0xFF6E4C4A),
    ],
    [
      Color(0xFFF37424),
      Color(0xFF4E1610),
    ],
    [
      Color(0xFF79A8C9),
      Color(0xFF17263C),
    ],
    [
      Color(0xFF8B5F9D),
      Color(0xFF291B36),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final double heroHeight =
        (screenSize.height * 0.72).clamp(500.0, 620.0).toDouble();

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSection(height: heroHeight),
                _MyListSection(
                  cardWidth: screenSize.width * 0.43,
                  posterColors: posterColors,
                ),
              ],
            ),
          ),

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNavigation(
              selectedIndex: selectedNavigationIndex,
              onSelected: (index) {
                setState(() {
                  selectedNavigationIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Replace this widget with Image.asset() later.
          const _HeroImagePlaceholder(),

          // Dark overlay similar to the reference.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35, 0.72, 1.0],
                colors: [
                  Color(0x26000000),
                  Color(0x10000000),
                  Color(0xA8000000),
                  Colors.black,
                ],
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 16),

                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterPill(label: 'TV Shows'),
                        SizedBox(width: 8),
                        _FilterPill(label: 'Movies'),
                        SizedBox(width: 8),
                        _FilterPill(
                          label: 'Categories',
                          showArrow: true,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  _buildMovieInformation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'For Debbie',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          tooltip: 'Cast',
          icon: const Icon(
            Icons.cast_outlined,
            size: 25,
          ),
        ),
        IconButton(
          onPressed: () {},
          tooltip: 'Search',
          icon: const Icon(
            Icons.search,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildMovieInformation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atlas',
                style: TextStyle(
                  fontSize: 37,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Science fiction • Action',
                style: TextStyle(
                  color: Color(0xFFB8B8B8),
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'N',
                    style: TextStyle(
                      color: Color(0xFFE50914),
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'M O V I E',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _AddButton(
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        _PlayButton(
          onPressed: () {},
        ),
      ],
    );
  }
}

class _HeroImagePlaceholder extends StatelessWidget {
  const _HeroImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF342014),
            Color(0xFFB55C24),
            Color(0xFF4A2720),
            Color(0xFF161014),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 80,
            left: -60,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withAlpha(35),
              ),
            ),
          ),
          Positioned(
            top: 85,
            right: -75,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withAlpha(28),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: 150,
                color: Colors.white.withAlpha(85),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'HERO IMAGE PLACEHOLDER',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    this.showArrow = false,
  });

  final String label;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF775340).withAlpha(220),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 11,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 5),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 17,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFF6E6E6E),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Icon(
          Icons.add,
          size: 24,
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        icon: const Icon(
          Icons.play_arrow,
          size: 21,
        ),
        label: const Text(
          'Play',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MyListSection extends StatelessWidget {
  const _MyListSection({
    required this.cardWidth,
    required this.posterColors,
  });

  final double cardWidth;
  final List<List<Color>> posterColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'My List',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: posterColors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return _PosterPlaceholder(
                  width: cardWidth,
                  colors: posterColors[index],
                  number: index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({
    required this.width,
    required this.colors,
    required this.number,
  });

  final double width;
  final List<Color> colors;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.movie_outlined,
              size: 58,
              color: Colors.white.withAlpha(115),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(135),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'POSTER $number',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF25242B),
        border: Border(
          top: BorderSide(
            color: Color(0xFF34333A),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavigationItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: selectedIndex == 0,
              onPressed: () => onSelected(0),
            ),
            _NavigationItem(
              icon: Icons.link,
              label: 'Links',
              selected: selectedIndex == 1,
              onPressed: () => onSelected(1),
            ),
            _NavigationItem(
              icon: Icons.video_collection_rounded,
              label: 'Videos',
              selected: selectedIndex == 2,
              onPressed: () => onSelected(2),
            ),
            _NavigationItem(
              icon: Icons.face_rounded,
              label: 'Profile',
              selected: selectedIndex == 3,
              onPressed: () => onSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 14 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 23,
                color: selected ? Colors.black : Colors.white,
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}