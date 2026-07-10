import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/app_state.dart';
import 'hub_all_screen.dart';

// ── Public models (shared with hub_all_screen) ────────────────────────────────

/// Confirms and opens a hub resource's external link. Shared by HubScreen's
/// own cards and by other screens (e.g. Home's mood-based recommendation)
/// that surface a HubResource outside the Hub tab itself.
Future<void> openHubResource(BuildContext context, HubResource item) async {
  final go = await showDialog<bool>(
    context: context,
    builder: (c) {
      final s = MediaQuery.of(c).size.width / 430;
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * s)),
        backgroundColor: Colors.white,
        title: Text(
          'Visit External Link',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16 * s,
            color: const Color(0xFF1A2E12),
          ),
        ),
        content: Text(
          'Open "${item.title}" on ${item.platform}?',
          style: GoogleFonts.poppins(
            fontSize: 13 * s,
            color: const Color(0xFF595959),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF595959), fontSize: 14 * s)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('Visit',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF7F89E9),
                    fontWeight: FontWeight.w600,
                    fontSize: 14 * s)),
          ),
        ],
      );
    },
  );
  if (go == true) {
    final uri = Uri.parse(item.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class HubResource {
  final String title;
  final String subtitle;
  final String url;
  final String platform; // 'Goodreads' | 'Spotify' | 'TED.com'
  final Color color;
  final String imageUrl;

  const HubResource({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.platform,
    required this.color,
    this.imageUrl = '',
  });
}

class HubHabit {
  final String title;
  final IconData icon;
  final Color bg;
  final Color inner;
  final Color iconColor;
  final Color textColor;

  const HubHabit({
    required this.title,
    required this.icon,
    required this.bg,
    required this.inner,
    required this.iconColor,
    required this.textColor,
  });
}

class CommunityPost {
  final String author;
  final String initials;
  final Color avatarColor;
  final String content;

  const CommunityPost({
    required this.author,
    required this.initials,
    required this.avatarColor,
    required this.content,
  });
}

class _UserPost {
  final String content;
  final Uint8List? image;
  final bool isAnonymous;

  _UserPost({required this.content, this.image, this.isAnonymous = false});
}

// ── Data ─────────────────────────────────────────────────────────────────────

const kCommunityPosts = <CommunityPost>[
  CommunityPost(
    author: 'Anna B.',
    initials: 'AB',
    avatarColor: Color(0xFFE8A0B0),
    content: 'Proud of Myself 💛\n\nI went for a short walk this morning even though I didn\'t feel motivated. It wasn\'t long, but it helped clear my mind.\n\nWhat are you proud of today?',
  ),
  CommunityPost(
    author: 'Anonymous',
    initials: 'A',
    avatarColor: Color(0xFF8BA0B8),
    content: 'University has been overwhelming lately.\nI\'m exhausted and scared I\'m falling behind.\nAny gentle advice from people who\'ve been through this?',
  ),
  CommunityPost(
    author: 'Albert G.',
    initials: 'AG',
    avatarColor: Color(0xFF7DAEB0),
    content: 'I\'m trying to build a consistent morning routine.\nEven simple things feel hard sometimes.\nWhat\'s one small habit that made your mornings better?',
  ),
  CommunityPost(
    author: 'Yara S.',
    initials: 'YS',
    avatarColor: Color(0xFFB07EC4),
    content: 'Mini Declutter Challenge — Day 3\n\nPick one tiny thing to tidy today:\nyour desk, your bag, your photo gallery… anything.\n\nShare your before/after or describe the moment.',
  ),
  CommunityPost(
    author: 'Anonymous',
    initials: 'A',
    avatarColor: Color(0xFF7A97B0),
    content: 'I\'ve been feeling disconnected from my friends lately.\nIt\'s like I\'m there, but not really there.\nDoes anyone else feel this sometimes?',
  ),
  CommunityPost(
    author: 'Zayn M.',
    initials: 'ZM',
    avatarColor: Color(0xFF7893C7),
    content: 'Write one sentence to yourself 6 months from now.\nNot advice — but a promise.\nI\'ll start: I promise to rest when I need to, not only when I break.',
  ),
];

// Pre-seeded comments: index → [[name, text], ...]
const kSeedComments = <int, List<List<String>>>{
  0: [
    ['Maya K.', 'This is so inspiring! I struggle with motivation too 💙'],
    ['Liam T.', 'A short walk changed my whole day once. Keep it up!'],
  ],
  1: [
    ['Sara M.', 'You\'re not alone — finals hit different mentally 💙'],
    ['Ahmed R.', 'Reach out to your professor and take one thing at a time ❤️'],
    ['Jo P.', 'Same boat here. Rest is also progress.'],
  ],
  2: [
    ['Nina W.', 'Making your bed first thing! Tiny but powerful.'],
    ['Carlos B.', 'A glass of water before checking my phone helped me 🙌'],
  ],
  3: [
    ['Priya N.', 'Cleaned my desktop folder — 847 files gone! 😂'],
    ['Reem A.', 'I tackled my inbox. Felt SO good.'],
  ],
  4: [
    ['Alex H.', 'Yes. I call it being physically present but mentally somewhere else.'],
    ['Zoe C.', 'It gets better. Reaching out helps. 🤍'],
    ['Marcus L.', 'I felt this deeply. DMs open if you need to talk.'],
  ],
  5: [
    ['Emma V.', 'This is beautiful. I needed to hear this today.'],
    ['Ryan O.', 'I promise to stop comparing my pace to others 🌿'],
  ],
};

const kHubBooks = <HubResource>[
  HubResource(
    title: 'Depression, Anxiety, and Other Things We Don\'t Want to Talk About',
    subtitle: 'Ryan Casey Waller',
    url: 'https://www.goodreads.com/book/show/52611597',
    platform: 'Goodreads',
    color: Color(0xFF4A6B8A),
    imageUrl: 'https://covers.openlibrary.org/b/isbn/9781400221325-M.jpg',
  ),
  HubResource(
    title: 'Practicing Mindfulness',
    subtitle: 'Matthew Sockolov',
    url: 'https://www.goodreads.com/book/show/57048348',
    platform: 'Goodreads',
    color: Color(0xFF2E7D6E),
    imageUrl: 'https://covers.openlibrary.org/b/isbn/9781641521710-M.jpg',
  ),
  HubResource(
    title: 'The Body Keeps the Score',
    subtitle: 'Bessel van der Kolk',
    url: 'https://www.goodreads.com/book/show/18693771',
    platform: 'Goodreads',
    color: Color(0xFF7F89E9),
    imageUrl: 'https://covers.openlibrary.org/b/isbn/9780143127741-M.jpg',
  ),
  HubResource(
    title: 'Maybe You Should Talk to Someone',
    subtitle: 'Lori Gottlieb',
    url: 'https://www.goodreads.com/book/show/37570546',
    platform: 'Goodreads',
    color: Color(0xFFA87CC7),
    imageUrl: 'https://covers.openlibrary.org/b/isbn/9781328662057-M.jpg',
  ),
  HubResource(
    title: 'Lost Connections',
    subtitle: 'Johann Hari',
    url: 'https://www.goodreads.com/book/show/34921573',
    platform: 'Goodreads',
    color: Color(0xFF5A8A44),
    imageUrl: 'https://covers.openlibrary.org/b/isbn/9781632868305-M.jpg',
  ),
  HubResource(
    title: "Man's Search for Meaning",
    subtitle: 'Viktor E. Frankl',
    url: 'https://www.goodreads.com/book/show/4069',
    platform: 'Goodreads',
    color: Color(0xFF8B6914),
    imageUrl: 'https://covers.openlibrary.org/b/isbn/9780807014295-M.jpg',
  ),
  HubResource(
    title: 'The Gifts of Imperfection',
    subtitle: 'Brené Brown',
    url: 'https://www.goodreads.com/book/show/6452796',
    platform: 'Goodreads',
    color: Color(0xFFD4845A),
    imageUrl: 'https://covers.openlibrary.org/b/isbn/9781592858491-M.jpg',
  ),
  HubResource(
    title: 'Atomic Habits',
    subtitle: 'James Clear',
    url: 'https://www.goodreads.com/book/show/40121378',
    platform: 'Goodreads',
    color: Color(0xFF1A2E12),
    imageUrl: 'https://covers.openlibrary.org/b/isbn/9780735211292-M.jpg',
  ),
];

const kHubPodcasts = <HubResource>[
  // First 4 shown in Figma "Top Podcasts" grid
  HubResource(
    title: 'The Psychology Podcast',
    subtitle: 'Scott Barry Kaufman',
    url: 'https://open.spotify.com/show/4POIiQQjnQOuz0AqnLk3KZ',
    platform: 'Spotify',
    color: Color(0xFF2C5F8A),
    imageUrl: 'https://image-cdn-ak.spotifycdn.com/image/ab67656300005f1f2c960864eb3f90024074b93b',
  ),
  HubResource(
    title: 'Mental Illness Happy Hour',
    subtitle: 'Paul Gilmartin',
    url: 'https://open.spotify.com/show/1ax4naBUwDvyB1YDRugdZo',
    platform: 'Spotify',
    color: Color(0xFF8B4E1E),
    imageUrl: 'https://image-cdn-fa.spotifycdn.com/image/ab67656300005f1fc0daf8a30a3b2297b34dd2f5',
  ),
  HubResource(
    title: 'The Psychology of Your 20s',
    subtitle: 'Jemma Sbeg',
    url: 'https://open.spotify.com/show/2HGcJRYrjGnpce6bRp8UXm',
    platform: 'Spotify',
    color: Color(0xFF4E6E8A),
    imageUrl: 'https://image-cdn-fa.spotifycdn.com/image/ab67656300005f1f762eefbfe1e5eefd3a0793b8',
  ),
  HubResource(
    title: 'What Your Therapist Thinks',
    subtitle: 'Kristie Plantinga',
    url: 'https://open.spotify.com/show/2SbGdQnLmBPBydC79GjK2l',
    platform: 'Spotify',
    color: Color(0xFF5A3B7A),
    imageUrl: 'https://image-cdn-ak.spotifycdn.com/image/ab67656300005f1fd6a642d7f454dbe1008bd40f',
  ),
  // Additional podcasts (See All)
  HubResource(
    title: '10% Happier',
    subtitle: 'Dan Harris',
    url: 'https://open.spotify.com/show/1CfW319UkBMVhCXfei8huv',
    platform: 'Spotify',
    color: Color(0xFF6B4E8A),
    imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Podcasts211/v4/79/04/87/79048703-d88c-acc2-c319-a8f2534b9ae5/mza_15018160844227259170.jpg/600x600bb.jpg',
  ),
  HubResource(
    title: 'The Happiness Lab',
    subtitle: 'Dr. Laurie Santos',
    url: 'https://open.spotify.com/show/3i5TCKhc6GY42pOWkpWveG',
    platform: 'Spotify',
    color: Color(0xFFB8860B),
    imageUrl: 'https://image-cdn-ak.spotifycdn.com/image/ab67656300005f1fdc49d89a4be46c437a2282aa',
  ),
  HubResource(
    title: 'Unlocking Us',
    subtitle: 'Brené Brown',
    url: 'https://open.spotify.com/show/4P86ZzHf7EOlRG7do9LkKZ',
    platform: 'Spotify',
    color: Color(0xFFC45A5A),
    imageUrl: 'https://image-cdn-ak.spotifycdn.com/image/ab67656300005f1f567c20a4e38be7cc49d1423e',
  ),
  HubResource(
    title: 'Feel Better Live More',
    subtitle: 'Dr. Rangan Chatterjee',
    url: 'https://open.spotify.com/show/6NyPQfcSR9nj0DPDr2ixrK',
    platform: 'Spotify',
    color: Color(0xFF4A7A94),
    imageUrl: 'https://image-cdn-fa.spotifycdn.com/image/ab67656300005f1f8cca65ff678fe0bd46c56352',
  ),
];

const kHubTedTalks = <HubResource>[
  // First 2 shown in Figma "Top TED Talks" list
  HubResource(
    title: 'How to manage your mental health | Leon Taylor | TEDxClapham',
    subtitle: 'Leon Taylor',
    url: 'https://www.youtube.com/watch?v=rkZl2gsLUp4',
    platform: 'TED.com',
    color: Color(0xFFE62B1E),
    imageUrl: 'https://img.youtube.com/vi/rkZl2gsLUp4/mqdefault.jpg',
  ),
  HubResource(
    title: 'How to talk to the worst parts of yourself | Karen Faith | TEDxKC',
    subtitle: 'Karen Faith',
    url: 'https://www.youtube.com/watch?v=gUV5DJb6KGs',
    platform: 'TED.com',
    color: Color(0xFFE62B1E),
    imageUrl: 'https://img.youtube.com/vi/gUV5DJb6KGs/mqdefault.jpg',
  ),
  // Additional talks (See All)
  HubResource(
    title: 'The Power of Vulnerability',
    subtitle: 'Brené Brown',
    url: 'https://www.ted.com/talks/brene_brown_the_power_of_vulnerability',
    platform: 'TED.com',
    color: Color(0xFFE62B1E),
    imageUrl: 'https://img.youtube.com/vi/iCvmsMzlF7o/mqdefault.jpg',
  ),
  HubResource(
    title: 'No Shame in Taking Care of Your Mental Health',
    subtitle: 'Sangu Delle',
    url: 'https://www.ted.com/talks/sangu_delle_there_s_no_shame_in_taking_care_of_your_mental_health',
    platform: 'TED.com',
    color: Color(0xFFE62B1E),
    imageUrl: 'https://img.youtube.com/vi/e-BY9UEewHw/mqdefault.jpg',
  ),
  HubResource(
    title: 'What Makes a Good Life?',
    subtitle: 'Robert Waldinger',
    url: 'https://www.ted.com/talks/robert_waldinger_what_makes_a_good_life_lessons_from_the_longest_study_on_happiness',
    platform: 'TED.com',
    color: Color(0xFFE62B1E),
    imageUrl: 'https://img.youtube.com/vi/8KkKuTCFvzI/mqdefault.jpg',
  ),
  HubResource(
    title: 'How to Make Stress Your Friend',
    subtitle: 'Kelly McGonigal',
    url: 'https://www.ted.com/talks/kelly_mcgonigal_how_to_make_stress_your_friend',
    platform: 'TED.com',
    color: Color(0xFFE62B1E),
    imageUrl: 'https://img.youtube.com/vi/RcGyVTAoXEU/mqdefault.jpg',
  ),
  HubResource(
    title: 'Why We All Need Emotional First Aid',
    subtitle: 'Guy Winch',
    url: 'https://www.ted.com/talks/guy_winch_the_case_for_emotional_hygiene',
    platform: 'TED.com',
    color: Color(0xFFE62B1E),
    imageUrl: 'https://img.youtube.com/vi/F2hc2FLOdhI/mqdefault.jpg',
  ),
  HubResource(
    title: 'How Childhood Trauma Affects Health',
    subtitle: 'Nadine Burke Harris',
    url: 'https://www.ted.com/talks/nadine_burke_harris_how_childhood_trauma_affects_health_across_a_lifetime',
    platform: 'TED.com',
    color: Color(0xFFE62B1E),
    imageUrl: 'https://img.youtube.com/vi/95ovIJ3dsNk/mqdefault.jpg',
  ),
  HubResource(
    title: 'A Tale of Mental Illness — From the Inside',
    subtitle: 'Elyn Saks',
    url: 'https://www.ted.com/talks/elyn_saks_seeing_mental_illness',
    platform: 'TED.com',
    color: Color(0xFFE62B1E),
    imageUrl: 'https://img.youtube.com/vi/f6CILJA110Y/mqdefault.jpg',
  ),
];

// First 4 = "Start new good habits", last 4 = "Quit bad habits"
const kHubHabits = <HubHabit>[
  // ── Good habits ──────────────────────────────────────────────────────────
  HubHabit(
    title: 'Meditate',
    icon: Icons.self_improvement_rounded,
    bg: Color(0xFFA87CC7),
    inner: Color(0xFFCCA8E0),
    iconColor: Color(0xFF471C66),
    textColor: Color(0xFF471C66),
  ),
  HubHabit(
    title: 'Practice Gratitude',
    icon: Icons.volunteer_activism_rounded,
    bg: Color(0xFF858852),
    inner: Color(0xFFB6BD83),
    iconColor: Color(0xFF2C2E12),
    textColor: Color(0xFF2C2E12),
  ),
  HubHabit(
    title: 'Workout',
    icon: Icons.fitness_center_rounded,
    bg: Color(0xFF5A7C95),
    inner: Color(0xFF85AEC0),
    iconColor: Color(0xFF1C4466),
    textColor: Color(0xFF1C4466),
  ),
  HubHabit(
    title: 'Declutter',
    icon: Icons.cleaning_services_rounded,
    bg: Color(0xFF9E5072),
    inner: Color(0xFFDD9BB8),
    iconColor: Color(0xFF7A2B4D),
    textColor: Color(0xFF7A2B4D),
  ),
  // ── Quit habits ───────────────────────────────────────────────────────────
  HubHabit(
    title: 'Quit Smoking',
    icon: Icons.smoke_free_rounded,
    bg: Color(0xFF658852),
    inner: Color(0xC2A7CD92),
    iconColor: Color(0xFF1A2E12),
    textColor: Color(0xFF1A2E12),
  ),
  HubHabit(
    title: 'Quit Skipping Meals',
    icon: Icons.no_meals_rounded,
    bg: Color(0xFF5D5A95),
    inner: Color(0xFF9793C7),
    iconColor: Color(0xFF322F73),
    textColor: Color(0xFF322F73),
  ),
  HubHabit(
    title: 'Quit Staying up late',
    icon: Icons.bedtime_rounded,
    bg: Color(0xFF955A5A),
    inner: Color(0xFFD29797),
    iconColor: Color(0xFF6E3A3A),
    textColor: Color(0xFF6E3A3A),
  ),
  HubHabit(
    title: 'Quit negative self talk',
    icon: Icons.thumb_down_alt_rounded,
    bg: Color(0xFF95865A),
    inner: Color(0xFFC7C693),
    iconColor: Color(0xFF72643A),
    textColor: Color(0xFF72643A),
  ),
];

// ── Podcasts section data ─────────────────────────────────────────────────────

const _kPodcastOfWeek = HubResource(
  title: 'Psychology Unplugged',
  subtitle: 'Dr. Corey J. Nigro',
  url: 'https://open.spotify.com/show/7wkYuqWC8z51nfetiZCTbT',
  platform: 'Spotify',
  color: Color(0xFF5A7FC4),
  imageUrl: 'https://image-cdn-fa.spotifycdn.com/image/ab67656300005f1f83a3fe48e462c1cdb8bc474b',
);

// ── TED Talks section data ────────────────────────────────────────────────────

const _kTedOfWeek = HubResource(
  title: 'How To Protect Your Brain From Stress | Niki Korteweg | TEDxAmsterdamWomen',
  subtitle: 'Niki Korteweg',
  url: 'https://www.youtube.com/watch?v=Nz9eAaXRzGg',
  platform: 'TED.com',
  color: Color(0xFFE62B1E),
  imageUrl: 'https://img.youtube.com/vi/Nz9eAaXRzGg/mqdefault.jpg',
);

// ── Books section data ────────────────────────────────────────────────────────

const _kBookOfWeek = HubResource(
  title: 'This Book Will Change Your Mind About Mental Health',
  subtitle: 'Nathan Filer',
  url: 'https://www.goodreads.com/book/show/52992519',
  platform: 'Goodreads',
  color: Color(0xFF2D4A6B),
  imageUrl: 'https://covers.openlibrary.org/b/isbn/9780571345977-L.jpg',
);

class _FeaturedBook {
  final HubResource resource;
  final List<String> categories;
  final double rating;
  const _FeaturedBook(this.resource, this.categories, this.rating);
}

const _kFeaturedBooks = <_FeaturedBook>[
  _FeaturedBook(
    HubResource(
      title: 'The Body Keeps the Score',
      subtitle: 'Bessel van der Kolk',
      url: 'https://www.goodreads.com/book/show/18693771',
      platform: 'Goodreads',
      color: Color(0xFF7F89E9),
      imageUrl: 'https://covers.openlibrary.org/b/isbn/9780143127741-L.jpg',
    ),
    ['Trauma', 'Anxiety', 'Depression'],
    4.37,
  ),
  _FeaturedBook(
    HubResource(
      title: 'Maybe You Should Talk to Someone',
      subtitle: 'Lori Gottlieb',
      url: 'https://www.goodreads.com/book/show/37570546',
      platform: 'Goodreads',
      color: Color(0xFFA87CC7),
      imageUrl: 'https://covers.openlibrary.org/b/isbn/9781328662057-L.jpg',
    ),
    ['Therapy', 'Self-Care', 'Mental Health'],
    4.23,
  ),
  _FeaturedBook(
    HubResource(
      title: 'Lost Connections',
      subtitle: 'Johann Hari',
      url: 'https://www.goodreads.com/book/show/34921573',
      platform: 'Goodreads',
      color: Color(0xFF5A8A44),
      imageUrl: 'https://covers.openlibrary.org/b/isbn/9781632868305-L.jpg',
    ),
    ['Depression', 'Society', 'Wellbeing'],
    4.12,
  ),
  _FeaturedBook(
    HubResource(
      title: 'The Gifts of Imperfection',
      subtitle: 'Brené Brown',
      url: 'https://www.goodreads.com/book/show/6452796',
      platform: 'Goodreads',
      color: Color(0xFFD4845A),
      imageUrl: 'https://covers.openlibrary.org/b/isbn/9781592858491-L.jpg',
    ),
    ['Self-Worth', 'Mindfulness', 'Growth'],
    4.07,
  ),
];

// ── HubScreen ─────────────────────────────────────────────────────────────────

class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  // Section keys for chip → scroll-to
  final _keysMap = <String, GlobalKey>{
    'Books':        GlobalKey(),
    'Podcasts':     GlobalKey(),
    'TED Talks':    GlobalKey(),
    'Habits Lists': GlobalKey(),
  };

  // Active view: 'main' | 'books' | 'podcasts'
  String _activeView = 'main';

  // Books carousel state
  late final PageController _booksCtrl;
  int _booksPage = 0;
  final Set<int> _booksHearted = {};
  final Set<int> _likedPosts = {};
  final Set<int> _savedPosts = {};
  final Map<int, List<String>> _postComments = {};
  final List<_UserPost> _userPosts = [];

  @override
  void initState() {
    super.initState();
    _booksCtrl = PageController(viewportFraction: 283 / 430);
  }

  @override
  void dispose() {
    _booksCtrl.dispose();
    super.dispose();
  }

  // ── Link dialog ────────────────────────────────────────────────────────────

  Future<void> _openResource(HubResource item) => openHubResource(context, item);

  void _scrollToSection(String cat) {
    final ctx = _keysMap[cat]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Column(
        children: [
          // Fixed header with chips — always visible
          _buildHeader(s),
          // Switchable body — main hub OR books detail
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: switch (_activeView) {
                'books'     => _buildBooksBody(s),
                'podcasts'  => _buildPodcastsBody(s),
                'ted'       => _buildTedBody(s),
                'habits'    => _buildHabitsBody(s),
                'community' => _buildCommunityBody(s),
                _           => _buildMainBody(s),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBody(double s) {
    return SingleChildScrollView(
      key: const ValueKey('main'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 28 * s),
          _buildWhatWeOffer(s),
          SizedBox(height: 28 * s),
          // Books preview (horizontal scroll, compact)
          _buildResourceSection(
            key: _keysMap['Books']!,
            label: 'Books',
            s: s,
            items: kHubBooks,
            cardBuilder: (item) => GestureDetector(
              onTap: () => _openResource(item),
              child: Container(
                width: 168 * s,
                height: 215 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15 * s),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                      blurRadius: 11.6 * s,
                      offset: Offset(0, 4 * s),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15 * s),
                  child: Stack(children: [
                    Container(color: const Color(0xFF7F89E9).withValues(alpha: 0.3)),
                    Positioned(
                      left: 17 * s, top: 19 * s,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10 * s),
                        child: item.imageUrl.isNotEmpty
                            ? Image.network(item.imageUrl,
                                width: 133 * s, height: 177 * s, fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                    width: 133 * s, height: 177 * s, color: item.color))
                            : Container(width: 133 * s, height: 177 * s, color: item.color),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            cardHeight: 215 * s,
            onSeeAll: () => setState(() => _activeView = 'books'),
          ),
          SizedBox(height: 28 * s),
          _buildResourceSection(
            key: _keysMap['Podcasts']!,
            label: 'Podcasts',
            s: s,
            items: kHubPodcasts,
            cardBuilder: (item) => _PodcastCard(item: item, s: s, onTap: () => _openResource(item)),
            cardHeight: 215 * s,
            onSeeAll: () => setState(() => _activeView = 'podcasts'),
          ),
          SizedBox(height: 28 * s),
          _buildHabitsSection(s),
          SizedBox(height: 28 * s),
          _buildResourceSection(
            key: _keysMap['TED Talks']!,
            label: 'TED Talks',
            s: s,
            items: kHubTedTalks,
            cardBuilder: (item) => _TedCard(item: item, s: s, onTap: () => _openResource(item)),
            cardHeight: 215 * s,
            onSeeAll: () => setState(() => _activeView = 'ted'),
          ),
          SizedBox(height: 36 * s),
        ],
      ),
    );
  }

  Widget _buildBooksBody(double s) {
    return SingleChildScrollView(
      key: const ValueKey('books'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 28 * s),
          _buildBooksSection(s),
          SizedBox(height: 36 * s),
        ],
      ),
    );
  }

  Widget _buildPodcastsBody(double s) {
    return SingleChildScrollView(
      key: const ValueKey('podcasts'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 28 * s),
          _buildPodcastsSection(s),
          SizedBox(height: 36 * s),
        ],
      ),
    );
  }

  // ── Full Podcasts section ───────────────────────────────────────────────────

  Widget _buildPodcastsSection(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Podcast Of the Week ──────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(left: 35 * s),
          child: Text('Podcast Of the Week',
              style: GoogleFonts.poppins(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: -1 * s)),
        ),
        SizedBox(height: 20 * s),
        // Decorative blobs
        SizedBox(
          height: 290 * s,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Left blob
              Positioned(
                left: -40 * s,
                top: 60 * s,
                child: Container(
                  width: 140 * s,
                  height: 140 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA87CC7).withValues(alpha: 0.22),
                  ),
                ),
              ),
              // Right blob
              Positioned(
                right: -30 * s,
                top: 0,
                child: Container(
                  width: 160 * s,
                  height: 160 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7F89E9).withValues(alpha: 0.2),
                  ),
                ),
              ),
              // Bottom-right blob
              Positioned(
                right: 20 * s,
                bottom: 0,
                child: Container(
                  width: 120 * s,
                  height: 120 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF658852).withValues(alpha: 0.15),
                  ),
                ),
              ),
              // Headphones arc decorative lines (SVG-free approximation)
              Positioned(
                top: 20 * s,
                child: Container(
                  width: 200 * s,
                  height: 60 * s,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: const Color(0xFF1A2E12).withValues(alpha: 0.12),
                          width: 2 * s),
                      left: BorderSide(
                          color: const Color(0xFF1A2E12).withValues(alpha: 0.12),
                          width: 2 * s),
                      right: BorderSide(
                          color: const Color(0xFF1A2E12).withValues(alpha: 0.12),
                          width: 2 * s),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100 * s),
                      topRight: Radius.circular(100 * s),
                    ),
                  ),
                ),
              ),
              // Podcast cover
              GestureDetector(
                onTap: () => _openResource(_kPodcastOfWeek),
                child: Container(
                  width: 136 * s,
                  height: 136 * s,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15 * s),
                    color: _kPodcastOfWeek.color,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.24),
                          blurRadius: 10.2 * s,
                          offset: Offset(0, 4 * s)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15 * s),
                    child: _kPodcastOfWeek.imageUrl.isNotEmpty
                        ? Image.network(_kPodcastOfWeek.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _podcastCoverFallback(_kPodcastOfWeek, 136 * s, s))
                        : _podcastCoverFallback(_kPodcastOfWeek, 136 * s, s),
                  ),
                ),
              ),
              // Gradient label below cover
              Positioned(
                bottom: 16 * s,
                child: GestureDetector(
                  onTap: () => _openResource(_kPodcastOfWeek),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20 * s, vertical: 10 * s),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7F89E9),
                          Color(0xFFA87CC7),
                          Color(0xFF658852)
                        ],
                        stops: [0.059, 0.594, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(30 * s),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                            blurRadius: 11.6 * s,
                            offset: Offset(0, 4 * s)),
                      ],
                    ),
                    child: Text(
                      _kPodcastOfWeek.title,
                      style: GoogleFonts.poppins(
                          fontSize: 14 * s,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF0F0F0),
                          letterSpacing: -0.7 * s),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32 * s),
        // ── Top Podcasts grid ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Podcasts',
                  style: GoogleFonts.poppins(
                      fontSize: 20 * s,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      letterSpacing: -1 * s)),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => HubAllScreen.podcasts(
                            items: kHubPodcasts, onTap: _openResource))),
                child: Text('See All',
                    style: GoogleFonts.poppins(
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF292929),
                        letterSpacing: -0.55 * s)),
              ),
            ],
          ),
        ),
        SizedBox(height: 20 * s),
        // 2-column grid — 4 items
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35 * s),
          child: Wrap(
            spacing: 24 * s,
            runSpacing: 24 * s,
            children: kHubPodcasts.take(4).map((pod) {
              const cardW = 168.0;
              const cardH = 160.0;
              const innerSize = 117.0;
              return GestureDetector(
                onTap: () => _openResource(pod),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Card
                    Container(
                      width: cardW * s,
                      height: cardH * s,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(30 * s),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF1A2E12).withValues(alpha: 0.09),
                              blurRadius: 4 * s,
                              offset: Offset(0, 4 * s)),
                          BoxShadow(
                              color: const Color(0xFF7F89E9).withValues(alpha: 0.33),
                              blurRadius: 11.6 * s,
                              offset: Offset(0, 4 * s)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30 * s),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                                color: const Color(0xFF7F89E9)
                                    .withValues(alpha: 0.3)),
                            // Inner podcast cover
                            Container(
                              width: innerSize * s,
                              height: innerSize * s,
                              decoration: BoxDecoration(
                                color: pod.color,
                                borderRadius: BorderRadius.circular(15 * s),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15 * s),
                                child: pod.imageUrl.isNotEmpty
                                    ? Image.network(pod.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            _podcastCoverFallback(
                                                pod, innerSize * s, s))
                                    : _podcastCoverFallback(
                                        pod, innerSize * s, s),
                              ),
                            ),
                            // Inner glow
                            Positioned.fill(
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(30 * s),
                                    boxShadow: [
                                      BoxShadow(
                                          color: const Color(0xFFA87CC7)
                                              .withValues(alpha: 0.22),
                                          blurRadius: 13 * s,
                                          offset: Offset(-4 * s, 0),
                                          spreadRadius: 0),
                                      BoxShadow(
                                          color: const Color(0xFF7F89E9)
                                              .withValues(alpha: 0.35),
                                          blurRadius: 7.7 * s,
                                          offset: Offset(2 * s, 0),
                                          spreadRadius: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10 * s),
                    // Podcast name below card
                    SizedBox(
                      width: cardW * s,
                      child: Text(pod.title,
                          style: GoogleFonts.poppins(
                              fontSize: 12 * s,
                              color: const Color(0xFF1A2E12),
                              letterSpacing: -0.6 * s,
                              height: 1.54),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _podcastCoverFallback(HubResource pod, double size, double s) =>
      Container(
        width: size,
        height: size,
        color: pod.color,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.podcasts_rounded,
              color: Colors.white.withValues(alpha: 0.8), size: size * 0.3),
          SizedBox(height: 6 * s),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * s),
            child: Text(pod.title,
                style: GoogleFonts.poppins(
                    fontSize: 9 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      );

  // ── Community inline view ───────────────────────────────────────────────────

  Widget _buildCommunityBody(double s) {
    const cardWidth = 361.0;
    final hPad = (430 - cardWidth) / 2 * s;

    return SingleChildScrollView(
      key: const ValueKey('community'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome banner ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(35 * s, 28 * s, 20 * s, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Welcome to [gradient]Mentallico[/gradient] Community!"
                Wrap(
                  children: [
                    Text(
                      'Welcome to ',
                      style: GoogleFonts.poppins(
                        fontSize: 24 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2E12),
                        letterSpacing: -1.2 * s,
                        height: 1.283,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF7F89E9),
                          Color(0xFFA87CC7),
                          Color(0xFF658852),
                        ],
                        stops: [0.059, 0.594, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: Text(
                        'Mentallico ',
                        style: GoogleFonts.poppins(
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -1.2 * s,
                          height: 1.283,
                        ),
                      ),
                    ),
                    Text(
                      'Community!',
                      style: GoogleFonts.poppins(
                        fontSize: 24 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2E12),
                        letterSpacing: -1.2 * s,
                        height: 1.283,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16 * s),
                // Description
                SizedBox(
                  width: 364 * s,
                  child: Text(
                    'Here you can be yourself and share every little achievement. Find thousands of inspiring journeys and connect with people with the same experience!',
                    style: GoogleFonts.poppins(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF595959),
                      letterSpacing: -0.65 * s,
                      height: 1.189,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24 * s),

          // ── Posts feed (centered, 361px wide) ─────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              children: [
                // Share input box
                _buildShareBox(cardWidth * s, s),
                SizedBox(height: 13 * s),
                // User-created posts (newest first)
                for (int i = _userPosts.length - 1; i >= 0; i--)
                  Padding(
                    padding: EdgeInsets.only(bottom: 13 * s),
                    child: _buildUserPostCard(_userPosts[i], cardWidth * s, s),
                  ),
                // Seed posts
                for (int i = 0; i < kCommunityPosts.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: 13 * s),
                    child: _buildPostCard(i, kCommunityPosts[i], cardWidth * s, s),
                  ),
              ],
            ),
          ),

          SizedBox(height: 24 * s),
        ],
      ),
    );
  }

  Widget _buildShareBox(double cardW, double s) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _PostCreatorSheet(
          s: s,
          onPost: (content, image, isAnon) {
            setState(() => _userPosts.add(
                _UserPost(content: content, image: image, isAnonymous: isAnon)));
            AppState.instance.addUserPost(
                SharedUserPost(content: content, image: image, isAnonymous: isAnon));
          },
        ),
      ),
      child: Container(
        width: cardW,
        height: 88 * s,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          border: Border.all(color: const Color(0xFFD2D5DE), width: 2 * s),
          borderRadius: BorderRadius.circular(15 * s),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 22 * s,
              top: 19 * s,
              right: 22 * s,
              child: Text(
                'Share an experience to inspire others or ask for advice...',
                style: GoogleFonts.poppins(
                  fontSize: 14 * s,
                  color: const Color(0xFF595959),
                  letterSpacing: -0.28 * s,
                ),
                maxLines: 2,
              ),
            ),
            Positioned(
              right: 12 * s,
              bottom: 10 * s,
              child: Icon(Icons.attach_file_rounded,
                  size: 16 * s, color: const Color(0xFF595959)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPostCard(_UserPost post, double cardW, double s) {
    const avatarD = 48.0;
    const bottomBarH = 48.0;
    final name = post.isAnonymous ? 'Anonymous' : 'You';
    final initials = post.isAnonymous ? 'A' : 'Me';
    final avatarColor = post.isAnonymous
        ? const Color(0xFF8BA0B8)
        : const Color(0xFF7F89E9);

    return Container(
      width: cardW,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        border: Border.all(
            color: const Color(0xFF7F89E9).withValues(alpha: 0.35), width: 2 * s),
        borderRadius: BorderRadius.circular(15 * s),
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x4D000000), blurRadius: 1.5, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(14 * s, 22 * s, 8 * s, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: avatarD * s,
                  height: avatarD * s,
                  decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
                  child: Center(
                    child: Text(initials,
                        style: GoogleFonts.poppins(
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4 * s),
                      Text(name,
                          style: GoogleFonts.poppins(
                              fontSize: 20 * s,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF292929),
                              letterSpacing: -0.4 * s)),
                      Text('Just now',
                          style: GoogleFonts.poppins(
                              fontSize: 10 * s,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF595959),
                              letterSpacing: -0.2 * s)),
                    ],
                  ),
                ),
                Icon(Icons.more_vert_rounded,
                    size: 22 * s, color: const Color(0xFF595959)),
              ],
            ),
          ),
          // Image (if attached)
          if (post.image != null) ...[
            SizedBox(height: 12 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14 * s),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12 * s),
                child: Image.memory(
                  post.image!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 14 * s, 20 * s, 16 * s),
            child: Text(post.content,
                style: GoogleFonts.poppins(
                    fontSize: 14 * s,
                    color: const Color(0xFF292929),
                    letterSpacing: -0.28 * s,
                    height: 1.5)),
          ),
          // Action bar
          Container(
            height: bottomBarH * s,
            decoration: BoxDecoration(
              color: const Color(0xFFD2D5DE),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14 * s),
                  bottomRight: Radius.circular(14 * s)),
            ),
            child: Row(
              children: [
                Expanded(
                    child: Center(
                        child: Icon(Icons.thumb_up_alt_outlined,
                            size: 22 * s, color: const Color(0xFF595959)))),
                Container(width: 1 * s, height: 26 * s,
                    color: const Color(0xFFA0A5AE)),
                Expanded(
                    child: Center(
                        child: Icon(Icons.chat_bubble_outline_rounded,
                            size: 22 * s, color: const Color(0xFF595959)))),
                Container(width: 1 * s, height: 26 * s,
                    color: const Color(0xFFA0A5AE)),
                Expanded(
                    child: Center(
                        child: Icon(Icons.bookmark_border_rounded,
                            size: 22 * s, color: const Color(0xFF595959)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(int index, CommunityPost post, double cardW, double s) {
    const bottomBarH = 48.0;
    const avatarD = 48.0;
    final liked = _likedPosts.contains(index);
    final saved = _savedPosts.contains(index);
    final commentCount = (kSeedComments[index]?.length ?? 0) +
        (_postComments[index]?.length ?? 0);

    return Container(
      width: cardW,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        border: Border.all(color: const Color(0xFFD2D5DE), width: 2 * s),
        borderRadius: BorderRadius.circular(15 * s),
        boxShadow: [
          const BoxShadow(
            color: Color(0x26000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
          const BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 1.5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author header ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14 * s, 22 * s, 8 * s, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: avatarD * s,
                  height: avatarD * s,
                  decoration: BoxDecoration(
                    color: post.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      post.initials,
                      style: GoogleFonts.poppins(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4 * s),
                      Text(
                        post.author,
                        style: GoogleFonts.poppins(
                          fontSize: 20 * s,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF292929),
                          letterSpacing: -0.4 * s,
                        ),
                      ),
                      Text(
                        '12th Nov, 2025',
                        style: GoogleFonts.poppins(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF595959),
                          letterSpacing: -0.2 * s,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_vert_rounded,
                    size: 22 * s, color: const Color(0xFF595959)),
              ],
            ),
          ),

          // ── Post content ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 14 * s, 20 * s, 16 * s),
            child: Text(
              post.content,
              style: GoogleFonts.poppins(
                fontSize: 14 * s,
                color: const Color(0xFF292929),
                letterSpacing: -0.28 * s,
                height: 1.5,
              ),
            ),
          ),

          // ── Action bar ────────────────────────────────────────────────
          Container(
            height: bottomBarH * s,
            decoration: BoxDecoration(
              color: const Color(0xFFD2D5DE),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14 * s),
                bottomRight: Radius.circular(14 * s),
              ),
            ),
            child: Row(
              children: [
                // ── Like ─────────────────────────────────────────────
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (liked) { _likedPosts.remove(index); }
                        else { _likedPosts.add(index); }
                      });
                      AppState.instance.toggleLike(index);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          liked
                              ? Icons.thumb_up_alt_rounded
                              : Icons.thumb_up_alt_outlined,
                          key: ValueKey(liked),
                          size: 22 * s,
                          color: liked
                              ? const Color(0xFF7F89E9)
                              : const Color(0xFF595959),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1 * s, height: 26 * s,
                    color: const Color(0xFFA0A5AE)),
                // ── Comment ──────────────────────────────────────────
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCommentsSheet(index, post, s),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 22 * s, color: const Color(0xFF595959)),
                          if (commentCount > 0) ...[
                            SizedBox(width: 4 * s),
                            Text('$commentCount',
                                style: GoogleFonts.poppins(
                                  fontSize: 11 * s,
                                  color: const Color(0xFF595959),
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1 * s, height: 26 * s,
                    color: const Color(0xFFA0A5AE)),
                // ── Bookmark ─────────────────────────────────────────
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (saved) { _savedPosts.remove(index); }
                        else { _savedPosts.add(index); }
                      });
                      AppState.instance.toggleSave(index);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          saved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          key: ValueKey(saved),
                          size: 22 * s,
                          color: saved
                              ? const Color(0xFF7F89E9)
                              : const Color(0xFF595959),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(int index, CommunityPost post, double s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        post: post,
        seedComments: kSeedComments[index] ?? [],
        userComments: List.from(_postComments[index] ?? []),
        s: s,
        onAdd: (text) => setState(() =>
            _postComments.putIfAbsent(index, () => []).add(text)),
      ),
    );
  }

  // ── Habits Lists inline view ────────────────────────────────────────────────

  Widget _buildHabitsBody(double s) {
    return SingleChildScrollView(
      key: const ValueKey('habits'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 28 * s),
          _buildHabitsGroup(
            s: s,
            title: 'Start new good habits',
            titleSize: 16,
            habits: kHubHabits.take(4).toList(),
          ),
          SizedBox(height: 36 * s),
          _buildHabitsGroup(
            s: s,
            title: 'Quit bad habits',
            titleSize: 20,
            habits: kHubHabits.skip(4).toList(),
          ),
          SizedBox(height: 36 * s),
        ],
      ),
    );
  }

  Widget _buildHabitsGroup({
    required double s,
    required String title,
    required double titleSize,
    required List<HubHabit> habits,
  }) {
    final cardW = 168.0 * s;
    final gap = 24.0 * s;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: titleSize * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E12),
              letterSpacing: -titleSize * 0.05 * s,
            ),
          ),
          SizedBox(height: 25 * s),
          // 2-column grid built as two rows
          for (int row = 0; row < (habits.length / 2).ceil(); row++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int col = 0; col < 2; col++) ...[
                  if (col > 0) SizedBox(width: gap),
                  if (row * 2 + col < habits.length)
                    _HabitCard(habit: habits[row * 2 + col], s: s)
                  else
                    SizedBox(width: cardW),
                ],
              ],
            ),
            if (row < (habits.length / 2).ceil() - 1) SizedBox(height: 25 * s),
          ],
        ],
      ),
    );
  }

  // ── TED Talks inline view ───────────────────────────────────────────────────

  Widget _buildTedBody(double s) {
    return SingleChildScrollView(
      key: const ValueKey('ted'),
      child: Column(
        children: [
          SizedBox(height: 28 * s),
          _buildTedSection(s),
          SizedBox(height: 36 * s),
        ],
      ),
    );
  }

  Widget _buildTedSection(double s) {
    const gradient = LinearGradient(
      colors: [Color(0xFF7F89E9), Color(0xFFA87CC7), Color(0xFF658852)],
      stops: [0.059, 0.594, 1.0],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: EdgeInsets.only(left: 35 * s),
          child: Text(
            'TED talk Of the Week',
            style: GoogleFonts.poppins(
              fontSize: 18 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E12),
              letterSpacing: -0.9 * s,
            ),
          ),
        ),
        SizedBox(height: 22 * s),

        // Featured card area
        SizedBox(
          width: double.infinity,
          height: 264 * s,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Star burst decoration (right)
              Positioned(
                right: 18 * s,
                top: 30 * s,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 52 * s,
                  color: const Color(0xFFFFBB00).withValues(alpha: 0.55),
                ),
              ),

              // Main card
              Container(
                width: 290 * s,
                height: 230 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(30 * s),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A2E12).withValues(alpha: 0.08),
                      blurRadius: 4 * s,
                      offset: Offset(0, 4 * s),
                    ),
                    BoxShadow(
                      color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                      blurRadius: 11.6 * s,
                      offset: Offset(0, 4 * s),
                    ),
                    BoxShadow(
                      color: const Color(0xFFA87CC7).withValues(alpha: 0.22),
                      blurRadius: 13 * s,
                      offset: Offset(-4 * s, 0),
                    ),
                    BoxShadow(
                      color: const Color(0xFF7F89E9).withValues(alpha: 0.23),
                      blurRadius: 7.7 * s,
                      offset: Offset(2 * s, 0),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () => _openResource(_kTedOfWeek),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30 * s),
                    child: Stack(
                      children: [
                        // Thumbnail
                        Align(
                          alignment: const Alignment(0, -0.55),
                          child: Padding(
                            padding: EdgeInsets.only(top: 23 * s),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15 * s),
                              child: Image.network(
                                _kTedOfWeek.imageUrl,
                                width: 248 * s,
                                height: 139 * s,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 248 * s,
                                  height: 139 * s,
                                  color: const Color(0xFFE62B1E).withValues(alpha: 0.15),
                                  child: Icon(Icons.play_circle_outline_rounded,
                                      size: 48 * s, color: const Color(0xFFE62B1E)),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // TED badge bottom-left
                        Positioned(
                          left: 20 * s,
                          bottom: 20 * s,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8 * s, vertical: 3 * s),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE62B1E),
                              borderRadius: BorderRadius.circular(6 * s),
                            ),
                            child: Text(
                              'TED',
                              style: GoogleFonts.poppins(
                                fontSize: 10 * s,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5 * s,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Vertical film-strip lines (left of card)
              Positioned(
                left: 58 * s,
                bottom: 22 * s,
                child: Column(
                  children: List.generate(
                    5,
                    (i) => Container(
                      width: 16 * s,
                      height: 7 * s,
                      margin: EdgeInsets.only(bottom: i < 4 ? 3 * s : 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2E12).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(2 * s),
                      ),
                    ),
                  ),
                ),
              ),

              // Play button — top-right corner of card
              Positioned(
                right: 62 * s,
                top: 8 * s,
                child: GestureDetector(
                  onTap: () => _openResource(_kTedOfWeek),
                  child: Container(
                    width: 52 * s,
                    height: 52 * s,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2E12).withValues(alpha: 0.82),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A2E12).withValues(alpha: 0.25),
                          blurRadius: 10 * s,
                          offset: Offset(0, 4 * s),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 30 * s,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 14 * s),

        // Gradient banner with featured title
        Center(
          child: GestureDetector(
            onTap: () => _openResource(_kTedOfWeek),
            child: Container(
              width: 359 * s,
              constraints: BoxConstraints(minHeight: 60 * s),
              padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 14 * s),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(30 * s),
              ),
              child: Text(
                _kTedOfWeek.title,
                style: GoogleFonts.poppins(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  height: 1.4,
                  letterSpacing: -0.4 * s,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        SizedBox(height: 36 * s),

        // Top TED Talks header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top TED Talks',
                style: GoogleFonts.poppins(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2E12),
                  letterSpacing: -0.9 * s,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HubAllScreen.tedTalks(
                        items: kHubTedTalks, onTap: _openResource),
                  ),
                ),
                child: Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    fontSize: 12 * s,
                    color: const Color(0xFF7F89E9),
                    letterSpacing: -0.4 * s,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20 * s),

        // Full-width talk list (first 2)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35 * s),
          child: Column(
            children: [
              for (int i = 0; i < kHubTedTalks.length.clamp(0, 2); i++) ...[
                _buildTedListCard(kHubTedTalks[i], s),
                if (i < 1) SizedBox(height: 36 * s),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTedListCard(HubResource talk, double s) {
    return GestureDetector(
      onTap: () => _openResource(talk),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 16:9 thumbnail with purple border
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF7F89E9),
                width: 6 * s,
              ),
              borderRadius: BorderRadius.circular(15 * s),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7F89E9).withValues(alpha: 0.30),
                  blurRadius: 10 * s,
                  offset: Offset(0, 4 * s),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10 * s),
              child: AspectRatio(
                aspectRatio: 720 / 404,
                child: Image.network(
                  talk.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFFE62B1E).withValues(alpha: 0.12),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_outline_rounded,
                              size: 36 * s, color: const Color(0xFFE62B1E)),
                          SizedBox(height: 6 * s),
                          Text(talk.subtitle,
                              style: GoogleFonts.poppins(
                                  fontSize: 11 * s,
                                  color: const Color(0xFF1A2E12))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          // Title
          Text(
            talk.title,
            style: GoogleFonts.poppins(
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E12),
              letterSpacing: -0.4 * s,
              height: 1.45,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(double s) {
    const cats = ['Books', 'Podcasts', 'TED Talks', 'Habits Lists', 'Mentallico Community'];

    return Container(
      color: const Color(0xFF7F89E9),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16 * s),
            // Title row
            Row(
              children: [
                const Spacer(),
                Text(
                  'Our Hub',
                  style: GoogleFonts.poppins(
                    fontSize: 20 * s,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: -0.6 * s,
                  ),
                ),
                const Spacer(),
              ],
            ),
            SizedBox(height: 12 * s),
            Container(
              height: 1,
              color: const Color(0xFFD2D5DE).withValues(alpha: 0.5),
            ),
            SizedBox(height: 12 * s),
            // Category chips (two rows via Wrap)
            Padding(
              padding: EdgeInsets.fromLTRB(35 * s, 0, 35 * s, 18 * s),
              child: Wrap(
                spacing: 8 * s,
                runSpacing: 8 * s,
                children: cats.map((cat) {
                  final viewKey = cat == 'Books' ? 'books'
                      : cat == 'Podcasts' ? 'podcasts'
                      : cat == 'TED Talks' ? 'ted'
                      : cat == 'Habits Lists' ? 'habits'
                      : cat == 'Mentallico Community' ? 'community'
                      : null;
                  final selected = viewKey != null && _activeView == viewKey;
                  return GestureDetector(
                    onTap: () {
                      final viewMap = const {
                        'Books': 'books',
                        'Podcasts': 'podcasts',
                        'TED Talks': 'ted',
                        'Habits Lists': 'habits',
                        'Mentallico Community': 'community',
                      };
                      final target = viewMap[cat];
                      if (target != null) {
                        if (_activeView == target) {
                          // Second tap → back to main, scroll to section
                          setState(() => _activeView = 'main');
                          if (_keysMap.containsKey(cat)) {
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _scrollToSection(cat));
                          }
                        } else {
                          setState(() => _activeView = target);
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14 * s, vertical: 5 * s),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF7F89E9)
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(30 * s),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                            blurRadius: 11.6 * s,
                            offset: Offset(0, 4 * s),
                          ),
                          BoxShadow(
                            color: const Color(0xFF1A2E12).withValues(alpha: 0.10),
                            blurRadius: 4 * s,
                            offset: Offset(0, 4 * s),
                          ),
                        ],
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.inter(
                          fontSize: 14 * s,
                          color: selected
                              ? const Color(0xFFF0F0F0)
                              : const Color(0xFF7F89E9),
                          letterSpacing: -0.7 * s,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── What We Offer ──────────────────────────────────────────────────────────

  Widget _buildWhatWeOffer(double s) {
    const features = [
      (
        icon: Icons.menu_book_rounded,
        text: 'Books and articles carefully chosen to help you understand your emotions',
        purple: true,
      ),
      (
        icon: Icons.headphones_rounded,
        text: 'Podcasts, TED Talks, and VR sessions to support your healing journey',
        purple: false,
      ),
      (
        icon: Icons.track_changes_rounded,
        text: 'Habit trackers and personalized routines to build positive change',
        purple: true,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What we offer',
            style: GoogleFonts.poppins(
              fontSize: 20 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E12),
              letterSpacing: -1 * s,
            ),
          ),
          SizedBox(height: 14 * s),
          ...features.map((f) => Padding(
                padding: EdgeInsets.only(bottom: 10 * s),
                child: Container(
                  height: 40 * s,
                  decoration: BoxDecoration(
                    color: f.purple
                        ? const Color(0xFFA87CC7)
                        : const Color(0xFFD2D5DE),
                    borderRadius: BorderRadius.circular(30 * s),
                  ),
                  padding: EdgeInsets.fromLTRB(13 * s, 0, 29 * s, 0),
                  child: Row(
                    children: [
                      Icon(
                        f.icon,
                        size: 17 * s,
                        color: f.purple
                            ? const Color(0xFFD2D5DE)
                            : const Color(0xFFA87CC7),
                      ),
                      SizedBox(width: 12 * s),
                      Expanded(
                        child: Text(
                          f.text,
                          style: GoogleFonts.poppins(
                            fontSize: 11 * s,
                            color: f.purple
                                ? const Color(0xFFD2D5DE)
                                : const Color(0xFFA87CC7),
                            letterSpacing: -0.6 * s,
                            height: 1.19,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ── Generic resource section (Books / Podcasts / TED) ──────────────────────

  Widget _buildResourceSection({
    required GlobalKey key,
    required String label,
    required double s,
    required List<HubResource> items,
    required Widget Function(HubResource) cardBuilder,
    required double cardHeight,
    required VoidCallback onSeeAll,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2E12),
                  letterSpacing: -1 * s,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF292929),
                    letterSpacing: -0.55 * s,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16 * s),
        // Horizontal scroll
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 35 * s),
            itemCount: items.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i < items.length - 1 ? 23 * s : 0),
              child: cardBuilder(items[i]),
            ),
          ),
        ),
      ],
    );
  }

  // ── Habits section ─────────────────────────────────────────────────────────

  Widget _buildHabitsSection(double s) {
    return Column(
      key: _keysMap['Habits Lists'],
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Habits',
                style: GoogleFonts.poppins(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2E12),
                  letterSpacing: -1 * s,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _activeView = 'habits'),
                child: Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF292929),
                    letterSpacing: -0.55 * s,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16 * s),
        SizedBox(
          height: 204 * s, // 168 card + 10 gap + 26 text
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 35 * s),
            itemCount: kHubHabits.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i < kHubHabits.length - 1 ? 23 * s : 0),
              child: _HabitCard(habit: kHubHabits[i], s: s),
            ),
          ),
        ),
      ],
    );
  }

  // ── Full Books section ─────────────────────────────────────────────────────

  Widget _buildBooksSection(double s) {
    return Column(
      key: _keysMap['Books'],
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Book Of the Week ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(left: 35 * s),
          child: Text('Book Of the Week',
              style: GoogleFonts.poppins(
                  fontSize: 20 * s, fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2E12), letterSpacing: -1 * s)),
        ),
        SizedBox(height: 20 * s),
        // Book image centered
        GestureDetector(
          onTap: () => _openResource(_kBookOfWeek),
          child: Center(
            child: Container(
              width: 136 * s,
              height: 209 * s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6 * s),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.31),
                      blurRadius: 4.5 * s, offset: Offset(0, 10 * s)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4 * s, offset: Offset(0, 4 * s)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6 * s),
                child: Image.network(
                  _kBookOfWeek.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: _kBookOfWeek.color,
                    padding: EdgeInsets.all(12 * s),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_kBookOfWeek.title,
                            style: GoogleFonts.poppins(fontSize: 11 * s,
                                fontWeight: FontWeight.w600, color: Colors.white, height: 1.3),
                            textAlign: TextAlign.center, maxLines: 5,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 8 * s),
                        Text(_kBookOfWeek.subtitle,
                            style: GoogleFonts.poppins(fontSize: 9 * s,
                                color: Colors.white.withValues(alpha: 0.8)),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16 * s),
        // Shelf lines below book
        Container(margin: EdgeInsets.symmetric(horizontal: 33 * s),
            height: 3 * s, decoration: BoxDecoration(
              color: const Color(0xFF1A2E12).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(2 * s))),
        SizedBox(height: 4 * s),
        Container(margin: EdgeInsets.symmetric(horizontal: 33 * s),
            height: 1 * s, decoration: BoxDecoration(
              color: const Color(0xFF1A2E12).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2 * s))),
        SizedBox(height: 20 * s),
        // Gradient title banner
        GestureDetector(
          onTap: () => _openResource(_kBookOfWeek),
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 35 * s),
              padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 10 * s),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7F89E9), Color(0xFFA87CC7), Color(0xFF658852)],
                  stops: [0.059, 0.594, 1.0],
                ),
                borderRadius: BorderRadius.circular(30 * s),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                      blurRadius: 11.6 * s, offset: Offset(0, 4 * s)),
                ],
              ),
              child: Text(_kBookOfWeek.title,
                  style: GoogleFonts.poppins(fontSize: 14 * s,
                      fontStyle: FontStyle.italic, fontWeight: FontWeight.w500,
                      color: const Color(0xFFF0F0F0), letterSpacing: -0.7 * s),
                  textAlign: TextAlign.center),
            ),
          ),
        ),
        SizedBox(height: 36 * s),
        // ── Books That Understand You (carousel) ──────────────────────────────
        Padding(
          padding: EdgeInsets.only(left: 35 * s),
          child: Text('Books That Understand You',
              style: GoogleFonts.poppins(fontSize: 20 * s, fontWeight: FontWeight.w500,
                  color: Colors.black, letterSpacing: -1 * s)),
        ),
        SizedBox(height: 20 * s),
        SizedBox(
          height: (283 * s * (4 / 3) + 28 * s + 14 * s + 20 * s + 46 * s + 10 * s + 36 * s),
          child: PageView.builder(
            controller: _booksCtrl,
            onPageChanged: (i) => setState(() => _booksPage = i),
            itemCount: _kFeaturedBooks.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 6 * s),
              child: _buildFeaturedCard(_kFeaturedBooks[i], i, s),
            ),
          ),
        ),
        SizedBox(height: 18 * s),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_kFeaturedBooks.length, (i) {
            final active = i == _booksPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              margin: EdgeInsets.only(right: i < _kFeaturedBooks.length - 1 ? 8 * s : 0),
              width: active ? 64 * s : 6 * s,
              height: 6 * s,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF7F89E9) : const Color(0xFFD2D5DE),
                borderRadius: BorderRadius.circular(30 * s),
              ),
            );
          }),
        ),
        SizedBox(height: 36 * s),
        // ── Book List (2-col preview) ─────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Book List',
                  style: GoogleFonts.poppins(fontSize: 20 * s, fontWeight: FontWeight.w500,
                      color: Colors.black, letterSpacing: -1 * s)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => HubAllScreen.books(items: kHubBooks, onTap: _openResource))),
                child: Text('See All',
                    style: GoogleFonts.poppins(fontSize: 11 * s, fontWeight: FontWeight.w500,
                        color: const Color(0xFF292929), letterSpacing: -0.55 * s)),
              ),
            ],
          ),
        ),
        SizedBox(height: 20 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35 * s),
          child: Wrap(
            spacing: 24 * s,
            runSpacing: 38 * s,
            children: kHubBooks.take(4).map((book) => GestureDetector(
              onTap: () => _openResource(book),
              child: Container(
                width: 168 * s,
                height: 215 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15 * s),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF1A2E12).withValues(alpha: 0.08),
                        blurRadius: 4 * s, offset: Offset(0, 4 * s)),
                    BoxShadow(color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                        blurRadius: 11.6 * s, offset: Offset(0, 4 * s)),
                    BoxShadow(color: const Color(0xFFA87CC7).withValues(alpha: 0.22),
                        blurRadius: 13 * s, offset: Offset(-4 * s, 0)),
                    BoxShadow(color: const Color(0xFF7F89E9).withValues(alpha: 0.23),
                        blurRadius: 7.7 * s, offset: Offset(2 * s, 0)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15 * s),
                  child: Stack(
                    children: [
                      Container(color: const Color(0xFF7F89E9).withValues(alpha: 0.3)),
                      Positioned(
                        left: 17 * s, top: 19 * s,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10 * s),
                          child: book.imageUrl.isNotEmpty
                              ? Image.network(book.imageUrl,
                                  width: 133 * s, height: 177 * s, fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _listCardFallback(book, s))
                              : _listCardFallback(book, s),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _listCardFallback(HubResource book, double s) => Container(
        width: 133 * s, height: 177 * s, color: book.color,
        padding: EdgeInsets.all(12 * s),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(book.title, style: GoogleFonts.poppins(fontSize: 10 * s,
              fontWeight: FontWeight.w600, color: Colors.white, height: 1.3),
              textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis),
          SizedBox(height: 6 * s),
          Text(book.subtitle, style: GoogleFonts.poppins(fontSize: 8 * s,
              color: Colors.white.withValues(alpha: 0.8)),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]));

  Widget _buildFeaturedCard(_FeaturedBook fb, int idx, double s) {
    const hPad = 283.0 * 0.0733; // ~20.7px horizontal image padding
    const cardW = 283.0;

    Widget coverImage() {
      final placeholder = Container(
        color: fb.resource.color,
        padding: EdgeInsets.all(16 * s),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(fb.resource.title,
              style: GoogleFonts.poppins(fontSize: 15 * s,
                  fontWeight: FontWeight.w600, color: Colors.white, height: 1.3),
              textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis),
          SizedBox(height: 10 * s),
          Text(fb.resource.subtitle,
              style: GoogleFonts.poppins(fontSize: 11 * s,
                  color: Colors.white.withValues(alpha: 0.85)),
              textAlign: TextAlign.center),
        ]),
      );
      return fb.resource.imageUrl.isNotEmpty
          ? Image.network(fb.resource.imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder)
          : placeholder;
    }

    return GestureDetector(
      onTap: () => _openResource(fb.resource),
      child: Container(
        width: cardW * s,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(30 * s),
          boxShadow: [
            BoxShadow(color: const Color(0xFF1A2E12).withValues(alpha: 0.18),
                blurRadius: 4 * s, offset: Offset(0, 4 * s)),
            BoxShadow(color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                blurRadius: 11.6 * s, offset: Offset(0, 4 * s)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30 * s),
          child: Stack(
            children: [
              // Column layout — image on top, text below, no overlap
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image section (padded on all sides)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        hPad * s, 28 * s, hPad * s, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15 * s),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: coverImage(),
                      ),
                    ),
                  ),
                  // Text section — always below image
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        hPad * s, 14 * s, hPad * s, 20 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + rating on same row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(fb.resource.title,
                                  style: GoogleFonts.poppins(
                                      fontSize: 17 * s,
                                      color: const Color(0xFF1A2E12),
                                      letterSpacing: -0.85 * s,
                                      height: 1.2),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            SizedBox(width: 8 * s),
                            Padding(
                              padding: EdgeInsets.only(top: 3 * s),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.star_rounded,
                                    color: const Color(0xFFFFBB00), size: 13 * s),
                                SizedBox(width: 3 * s),
                                Text(fb.rating.toStringAsFixed(2),
                                    style: GoogleFonts.poppins(
                                        fontSize: 12 * s,
                                        color: const Color(0xFF595959),
                                        letterSpacing: -0.5 * s)),
                              ]),
                            ),
                          ],
                        ),
                        SizedBox(height: 10 * s),
                        // Category pills
                        Wrap(
                          spacing: 8 * s,
                          runSpacing: 6 * s,
                          children: fb.categories.map((cat) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10 * s, vertical: 5 * s),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA87CC7).withValues(alpha: 0.46),
                              borderRadius: BorderRadius.circular(30 * s),
                            ),
                            child: Text(cat,
                                style: GoogleFonts.poppins(
                                    fontSize: 12 * s,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -0.5 * s)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Heart button — floats over the image top-right
              Positioned(
                right: hPad * s,
                top: 36 * s,
                child: GestureDetector(
                  onTap: () => setState(() {
                    if (_booksHearted.contains(idx)) {
                      _booksHearted.remove(idx);
                    } else {
                      _booksHearted.add(idx);
                    }
                  }),
                  child: Container(
                    width: 44 * s, height: 44 * s,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF7F89E9).withValues(alpha: 0.35),
                            blurRadius: 10 * s,
                            offset: Offset(0, 4 * s)),
                      ],
                    ),
                    child: Icon(
                      _booksHearted.contains(idx)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _booksHearted.contains(idx)
                          ? Colors.red
                          : const Color(0xFF7F89E9),
                      size: 22 * s,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cards ─────────────────────────────────────────────────────────────────────

class _PodcastCard extends StatelessWidget {
  final HubResource item;
  final double s;
  final VoidCallback onTap;

  const _PodcastCard({required this.item, required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 168 * s,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Podcast artwork card
            Container(
              width: 168 * s,
              height: 160 * s,
              decoration: BoxDecoration(
                color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(30 * s),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A2E12).withValues(alpha: 0.09),
                    blurRadius: 4 * s,
                    offset: Offset(0, 4 * s),
                  ),
                  BoxShadow(
                    color: const Color(0xFF7F89E9).withValues(alpha: 0.33),
                    blurRadius: 11.6 * s,
                    offset: Offset(0, 4 * s),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 117 * s,
                  height: 117 * s,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(15 * s),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.podcasts_rounded,
                          size: 36 * s, color: Colors.white.withValues(alpha: 0.9)),
                      SizedBox(height: 6 * s),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8 * s),
                        child: Text(
                          item.title,
                          style: GoogleFonts.poppins(
                            fontSize: 9 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 14 * s),
            // Title below card
            Text(
              item.title,
              style: GoogleFonts.poppins(
                fontSize: 12 * s,
                color: const Color(0xFF1A2E12),
                letterSpacing: -0.6 * s,
                height: 1.54,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TedCard extends StatelessWidget {
  final HubResource item;
  final double s;
  final VoidCallback onTap;

  const _TedCard({required this.item, required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 168 * s,
        height: 215 * s,
        decoration: BoxDecoration(
          color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(15 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A2E12).withValues(alpha: 0.08),
              blurRadius: 4 * s,
              offset: Offset(0, 4 * s),
            ),
            BoxShadow(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
              blurRadius: 11.6 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15 * s),
          child: Stack(
            children: [
              Container(color: const Color(0xFF7F89E9).withValues(alpha: 0.3)),
              Positioned(
                left: 17 * s,
                top: 19 * s,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10 * s),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          width: 133 * s,
                          height: 177 * s,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _tedFallback(s),
                        )
                      : _tedFallback(s),
                ),
              ),
              // TED badge top-right
              Positioned(
                right: 10 * s,
                top: 10 * s,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6 * s, vertical: 2 * s),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE62B1E),
                    borderRadius: BorderRadius.circular(4 * s),
                  ),
                  child: Text(
                    'TED',
                    style: GoogleFonts.poppins(
                      fontSize: 9 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5 * s,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tedFallback(double s) => Container(
        width: 133 * s,
        height: 177 * s,
        color: const Color(0xFFE62B1E),
        padding: EdgeInsets.all(12 * s),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline_rounded,
                size: 32 * s, color: Colors.white),
            SizedBox(height: 10 * s),
            Text(
              item.title,
              style: GoogleFonts.poppins(
                fontSize: 10 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6 * s),
            Text(
              item.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 9 * s,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class _HabitCard extends StatelessWidget {
  final HubHabit habit;
  final double s;

  const _HabitCard({required this.habit, required this.s});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168 * s,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card
          Container(
            width: 168 * s,
            height: 168 * s,
            decoration: BoxDecoration(
              color: habit.bg,
              borderRadius: BorderRadius.circular(30 * s),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A2E12).withValues(alpha: 0.09),
                  blurRadius: 4 * s,
                  offset: Offset(0, 4 * s),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Inner lighter square
                Positioned(
                  left: 23 * s,
                  top: 23 * s,
                  child: Container(
                    width: 122 * s,
                    height: 122 * s,
                    decoration: BoxDecoration(
                      color: habit.inner,
                      borderRadius: BorderRadius.circular(22 * s),
                    ),
                  ),
                ),
                // Icon centered
                Positioned(
                  left: 46 * s,
                  top: 46 * s,
                  child: Icon(habit.icon, size: 76 * s, color: habit.iconColor),
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * s),
          Text(
            habit.title,
            style: GoogleFonts.poppins(
              fontSize: 13 * s,
              fontWeight: FontWeight.w500,
              color: habit.textColor,
              letterSpacing: -0.65 * s,
              height: 1.19,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Comments bottom sheet ─────────────────────────────────────────────────────

class _CommentsSheet extends StatefulWidget {
  final CommunityPost post;
  final List<List<String>> seedComments;
  final List<String> userComments;
  final double s;
  final void Function(String) onAdd;

  const _CommentsSheet({
    required this.post,
    required this.seedComments,
    required this.userComments,
    required this.s,
    required this.onAdd,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final List<String> _localUser;

  static const _avatarColors = [
    Color(0xFF7F89E9), Color(0xFFA87CC7), Color(0xFF658852),
    Color(0xFF5A7C95), Color(0xFF9E5072), Color(0xFF7DAEB0),
  ];

  @override
  void initState() {
    super.initState();
    _localUser = List.from(widget.userComments);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Color _colorFor(String name) {
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    return _avatarColors[hash % _avatarColors.length];
  }

  String _initialsFor(String name) =>
      name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    setState(() {
      _localUser.add(text);
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final seeds = widget.seedComments;
    final totalCount = seeds.length + _localUser.length;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20 * s)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            SizedBox(height: 12 * s),
            Container(
              width: 40 * s, height: 4 * s,
              decoration: BoxDecoration(
                color: const Color(0xFFD2D5DE),
                borderRadius: BorderRadius.circular(2 * s),
              ),
            ),
            SizedBox(height: 16 * s),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * s),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20 * s, color: const Color(0xFF1A2E12)),
                  ),
                  SizedBox(width: 12 * s),
                  Text(
                    totalCount > 0
                        ? 'Comments ($totalCount)'
                        : 'Comments',
                    style: GoogleFonts.poppins(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2E12),
                      letterSpacing: -0.7 * s,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * s),
            Divider(height: 1, color: const Color(0xFFD2D5DE)),

            // Comment list
            Expanded(
              child: totalCount == 0
                  ? Center(
                      child: Text(
                        'No comments yet.\nBe the first to respond!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13 * s,
                          color: const Color(0xFF595959),
                          height: 1.5,
                        ),
                      ),
                    )
                  : ListView(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.fromLTRB(
                          20 * s, 16 * s, 20 * s, 8 * s),
                      children: [
                        for (final c in seeds)
                          _CommentTile(
                            name: c[0],
                            text: c[1],
                            avatarColor: _colorFor(c[0]),
                            initials: _initialsFor(c[0]),
                            s: s,
                          ),
                        for (final text in _localUser)
                          _CommentTile(
                            name: 'You',
                            text: text,
                            avatarColor: const Color(0xFF7F89E9),
                            initials: 'Me',
                            s: s,
                            isMe: true,
                          ),
                      ],
                    ),
            ),

            // Input bar
            SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.fromLTRB(16 * s, 10 * s, 12 * s, 14 * s),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  border: Border(top: BorderSide(color: Color(0xFFD2D5DE))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46 * s,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30 * s),
                          border: Border.all(color: const Color(0xFFD2D5DE)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7F89E9)
                                  .withValues(alpha: 0.15),
                              blurRadius: 8 * s,
                              offset: Offset(0, 2 * s),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _ctrl,
                          cursorColor: const Color(0xFF7F89E9),
                          style: GoogleFonts.poppins(
                            fontSize: 14 * s,
                            color: const Color(0xFF292929),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write a comment…',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14 * s,
                              color: const Color(0xFF595959)
                                  .withValues(alpha: 0.7),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 18 * s, vertical: 12 * s),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 44 * s,
                        height: 44 * s,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.send_rounded,
                            color: Colors.white, size: 20 * s),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String name;
  final String text;
  final Color avatarColor;
  final String initials;
  final double s;
  final bool isMe;

  const _CommentTile({
    required this.name,
    required this.text,
    required this.avatarColor,
    required this.initials,
    required this.s,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36 * s,
            height: 36 * s,
            decoration:
                BoxDecoration(color: avatarColor, shape: BoxShape.circle),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.poppins(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  14 * s, 10 * s, 14 * s, 10 * s),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFF7F89E9).withValues(alpha: 0.10)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 14 * s : 4 * s),
                  topRight: Radius.circular(14 * s),
                  bottomLeft: Radius.circular(14 * s),
                  bottomRight: Radius.circular(14 * s),
                ),
                border: Border.all(
                    color: const Color(0xFFD2D5DE).withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w600,
                      color: isMe
                          ? const Color(0xFF7F89E9)
                          : const Color(0xFF292929),
                    ),
                  ),
                  SizedBox(height: 3 * s),
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 13 * s,
                      color: const Color(0xFF292929),
                      height: 1.45,
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

// ── Post creator sheet ────────────────────────────────────────────────────────

class _PostCreatorSheet extends StatefulWidget {
  final double s;
  final void Function(String content, Uint8List? image, bool isAnon) onPost;

  const _PostCreatorSheet({required this.s, required this.onPost});

  @override
  State<_PostCreatorSheet> createState() => _PostCreatorSheetState();
}

class _PostCreatorSheetState extends State<_PostCreatorSheet> {
  final _ctrl = TextEditingController();
  Uint8List? _imageBytes;
  bool _anonymous = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 82);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _imageBytes = bytes);
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onPost(text, _imageBytes, _anonymous);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final hasText = _ctrl.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20 * s)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12 * s),
            Container(
              width: 40 * s,
              height: 4 * s,
              decoration: BoxDecoration(
                  color: const Color(0xFFD2D5DE),
                  borderRadius: BorderRadius.circular(2 * s)),
            ),
            SizedBox(height: 14 * s),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * s),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close_rounded,
                        size: 22 * s, color: const Color(0xFF595959)),
                  ),
                  SizedBox(width: 12 * s),
                  Text('New Post',
                      style: GoogleFonts.poppins(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A2E12),
                          letterSpacing: -0.7 * s)),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: hasText ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: hasText ? _submit : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20 * s, vertical: 7 * s),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)]),
                          borderRadius: BorderRadius.circular(30 * s),
                        ),
                        child: Text('Post',
                            style: GoogleFonts.poppins(
                                fontSize: 14 * s,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * s),
            Divider(height: 1, color: const Color(0xFFD2D5DE)),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 8 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author preview
                    Row(
                      children: [
                        Container(
                          width: 40 * s,
                          height: 40 * s,
                          decoration: BoxDecoration(
                            color: _anonymous
                                ? const Color(0xFF8BA0B8)
                                : const Color(0xFF7F89E9),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _anonymous ? 'A' : 'Me',
                              style: GoogleFonts.poppins(
                                  fontSize: 13 * s,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * s),
                        Text(
                          _anonymous ? 'Anonymous' : 'You',
                          style: GoogleFonts.poppins(
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF292929)),
                        ),
                      ],
                    ),
                    SizedBox(height: 14 * s),
                    // Text area
                    TextField(
                      controller: _ctrl,
                      autofocus: true,
                      maxLines: null,
                      minLines: 4,
                      cursorColor: const Color(0xFF7F89E9),
                      style: GoogleFonts.poppins(
                          fontSize: 15 * s,
                          color: const Color(0xFF292929),
                          height: 1.55),
                      decoration: InputDecoration(
                        hintText:
                            'Share an experience, ask for advice, or inspire someone today…',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 15 * s,
                            color: const Color(0xFF595959)
                                .withValues(alpha: 0.6),
                            height: 1.55),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    // Image preview
                    if (_imageBytes != null) ...[
                      SizedBox(height: 14 * s),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12 * s),
                            child: Image.memory(_imageBytes!,
                                width: double.infinity, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8 * s,
                            right: 8 * s,
                            child: GestureDetector(
                              onTap: () => setState(() => _imageBytes = null),
                              child: Container(
                                padding: EdgeInsets.all(4 * s),
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle),
                                child: Icon(Icons.close_rounded,
                                    size: 16 * s, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 16 * s),
                  ],
                ),
              ),
            ),
            // Bottom toolbar
            SafeArea(
              top: false,
              child: Container(
                padding:
                    EdgeInsets.fromLTRB(16 * s, 10 * s, 16 * s, 12 * s),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  border: Border(top: BorderSide(color: Color(0xFFD2D5DE))),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16 * s, vertical: 8 * s),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F89E9)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30 * s),
                          border: Border.all(
                              color: const Color(0xFF7F89E9)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library_rounded,
                                size: 18 * s,
                                color: const Color(0xFF7F89E9)),
                            SizedBox(width: 6 * s),
                            Text('Photo',
                                style: GoogleFonts.poppins(
                                    fontSize: 13 * s,
                                    color: const Color(0xFF7F89E9),
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10 * s),
                    GestureDetector(
                      onTap: () => setState(() => _anonymous = !_anonymous),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16 * s, vertical: 8 * s),
                        decoration: BoxDecoration(
                          color: _anonymous
                              ? const Color(0xFF8BA0B8).withValues(alpha: 0.15)
                              : const Color(0xFFD2D5DE).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(30 * s),
                          border: Border.all(
                              color: _anonymous
                                  ? const Color(0xFF8BA0B8)
                                  : const Color(0xFFD2D5DE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _anonymous
                                  ? Icons.visibility_off_rounded
                                  : Icons.person_outline_rounded,
                              size: 18 * s,
                              color: _anonymous
                                  ? const Color(0xFF8BA0B8)
                                  : const Color(0xFF595959),
                            ),
                            SizedBox(width: 6 * s),
                            Text(
                              _anonymous ? 'Anonymous' : 'Public',
                              style: GoogleFonts.poppins(
                                  fontSize: 13 * s,
                                  color: _anonymous
                                      ? const Color(0xFF8BA0B8)
                                      : const Color(0xFF595959),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
