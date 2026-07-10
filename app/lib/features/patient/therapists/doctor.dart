// Doctor model, DoctorReview model, and static data for all 8 therapists.

class DoctorReview {
  final String authorName;
  final String authorInitials;
  final double rating;
  final String text;
  final String date;

  const DoctorReview({
    required this.authorName,
    required this.authorInitials,
    required this.rating,
    required this.text,
    required this.date,
  });
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String initials;
  final String image;
  final double rating;
  final int reviewCount;
  final int yearsExperience;
  final int pricePerSession;
  final String bio;
  final List<String> credentials;
  final List<String> languages;
  final List<String> categories;
  final bool isTopDoctor;
  final List<DoctorReview> reviews;
  final List<String> availableSlots;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.initials,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.yearsExperience,
    required this.pricePerSession,
    required this.bio,
    required this.credentials,
    required this.languages,
    required this.categories,
    required this.isTopDoctor,
    required this.reviews,
    required this.availableSlots,
  });
}

const kAllDoctors = <Doctor>[
  // ── TOP CAROUSEL DOCTORS ─────────────────────────────────────────────────

  Doctor(
    id: 'ali_samir',
    name: 'Dr. Ali Samir',
    specialty: 'Psychotherapist (Anxiety & Depression)',
    initials: 'AS',
    image: 'assets/images/dr_ali_top.jpg',
    rating: 4.9,
    reviewCount: 142,
    yearsExperience: 12,
    pricePerSession: 120,
    bio: 'Dr. Ali Samir is a compassionate psychotherapist with over 12 years of clinical experience. He specializes in Cognitive Behavioral Therapy (CBT) and mindfulness-based stress reduction to help patients overcome anxiety, depression, and life transitions. His approach is warm, evidence-based, and deeply personalized — he believes in empowering patients with tools they can use long after therapy ends.',
    credentials: [
      'PhD Clinical Psychology — Cairo University',
      'MSc Clinical Psychology — American University in Cairo',
      'Certified CBT Practitioner — Beck Institute, Philadelphia',
      'Mindfulness-Based Cognitive Therapy (MBCT) Certified',
    ],
    languages: ['Arabic', 'English'],
    categories: ['General', 'Anxiety', 'Depression'],
    isTopDoctor: true,
    availableSlots: ['Mon 9:00 AM', 'Mon 2:00 PM', 'Tue 11:00 AM', 'Wed 9:00 AM', 'Thu 3:00 PM', 'Fri 10:00 AM'],
    reviews: [
      DoctorReview(
        authorName: 'Fatima H.',
        authorInitials: 'FH',
        rating: 5,
        text: 'Dr. Samir completely changed how I manage my anxiety. His CBT techniques are practical and the progress I\'ve made in 3 months is remarkable. I feel like myself again.',
        date: '2 weeks ago',
      ),
      DoctorReview(
        authorName: 'Mahmoud K.',
        authorInitials: 'MK',
        rating: 5,
        text: 'Very professional and empathetic. He always makes me feel heard and never rushes sessions. I never thought I could overcome my depression but here I am.',
        date: '1 month ago',
      ),
      DoctorReview(
        authorName: 'Nour A.',
        authorInitials: 'NA',
        rating: 4,
        text: 'Excellent therapist. The mindfulness exercises he taught me have been life-changing. Only wish sessions were longer!',
        date: '2 months ago',
      ),
    ],
  ),

  Doctor(
    id: 'sara_hany',
    name: 'Dr. Sara Hany',
    specialty: 'Clinical Counselor (Stress & Burnout)',
    initials: 'SH',
    image: 'assets/images/dr_sara_top.jpg',
    rating: 4.8,
    reviewCount: 98,
    yearsExperience: 8,
    pricePerSession: 95,
    bio: 'Dr. Sara Hany is a clinical counselor who specializes in stress management, professional burnout, and career-related mental health challenges. She uses Solution-Focused Brief Therapy (SFBT) and Acceptance and Commitment Therapy (ACT) to help clients rediscover their resilience and redefine their relationship with work and stress. Her sessions are known for being practical, goal-oriented, and deeply validating.',
    credentials: [
      'MA Clinical Mental Health Counseling — German University in Cairo',
      'BSc Psychology — American University in Cairo',
      'Certified ACT Therapist — ACBS International',
      'Burnout Recovery Specialist — Maslach Institute',
    ],
    languages: ['Arabic', 'English', 'French'],
    categories: ['General', 'Anxiety'],
    isTopDoctor: true,
    availableSlots: ['Tue 10:00 AM', 'Tue 4:00 PM', 'Wed 12:00 PM', 'Thu 9:00 AM', 'Sat 11:00 AM', 'Sat 3:00 PM'],
    reviews: [
      DoctorReview(
        authorName: 'Layla M.',
        authorInitials: 'LM',
        rating: 5,
        text: 'Sara helped me recover from a severe burnout. I returned to work with a completely new perspective on work-life balance. Her approach is so practical and empowering.',
        date: '3 weeks ago',
      ),
      DoctorReview(
        authorName: 'Ahmed T.',
        authorInitials: 'AT',
        rating: 5,
        text: 'Best counselor I\'ve worked with. She asks the right questions and helps you find your own answers rather than just giving advice.',
        date: '1 month ago',
      ),
      DoctorReview(
        authorName: 'Rania S.',
        authorInitials: 'RS',
        rating: 4,
        text: 'Very helpful sessions. Dr. Sara has a gift for making you feel less alone with your stress. Highly recommend for anyone struggling with work pressure.',
        date: '6 weeks ago',
      ),
    ],
  ),

  Doctor(
    id: 'mariah_holland',
    name: 'Dr. Mariah Holland',
    specialty: 'Couples & Family Therapist',
    initials: 'MH',
    image: 'assets/images/dr_mariah_top.jpg',
    rating: 4.7,
    reviewCount: 76,
    yearsExperience: 15,
    pricePerSession: 140,
    bio: 'Dr. Mariah Holland brings 15 years of expertise in relationship therapy to every session. She is certified in the Gottman Method and Emotionally Focused Therapy (EFT), two of the most evidence-backed approaches for couples and families. Whether navigating communication breakdowns, trust issues, or life transitions as a family, Dr. Holland creates a neutral, compassionate space where all voices are heard.',
    credentials: [
      'PhD Family Systems Therapy — UCLA',
      'MA Developmental Psychology — University of Southern California',
      'Gottman Method Couples Therapist — Level 3',
      'Emotionally Focused Therapy (EFT) Certified',
    ],
    languages: ['English', 'Spanish'],
    categories: ['General'],
    isTopDoctor: true,
    availableSlots: ['Mon 9:00 AM', 'Mon 1:00 PM', 'Wed 10:00 AM', 'Wed 3:00 PM', 'Fri 9:00 AM', 'Fri 2:00 PM'],
    reviews: [
      DoctorReview(
        authorName: 'James & Clara R.',
        authorInitials: 'JR',
        rating: 5,
        text: 'Dr. Holland saved our marriage. After 6 months of sessions, we have completely transformed how we communicate. She is gifted, patient, and incredibly insightful.',
        date: '1 month ago',
      ),
      DoctorReview(
        authorName: 'Sofia P.',
        authorInitials: 'SP',
        rating: 5,
        text: 'The family sessions helped us navigate my parents\' divorce with so much more grace. Dr. Holland is warm and never takes sides. Truly exceptional.',
        date: '2 months ago',
      ),
      DoctorReview(
        authorName: 'David L.',
        authorInitials: 'DL',
        rating: 4,
        text: 'Very professional and knowledgeable. The Gottman tools she introduced us to are something we use every day now.',
        date: '3 months ago',
      ),
    ],
  ),

  Doctor(
    id: 'xavier_roberto',
    name: 'Dr. Xavier Roberto',
    specialty: 'Psychotherapist (Anxiety & Emotional Regulation)',
    initials: 'XR',
    image: 'assets/images/dr_xavier_top.jpg',
    rating: 4.9,
    reviewCount: 115,
    yearsExperience: 10,
    pricePerSession: 110,
    bio: 'Dr. Xavier Roberto is a dual-certified psychotherapist in Dialectical Behavior Therapy (DBT) and EMDR. He works primarily with individuals experiencing intense emotions, anxiety disorders, and past trauma. His sessions blend structured skill-building with deep exploration, giving clients both immediate coping tools and long-term healing. He is especially valued by young adults navigating identity, purpose, and emotional overwhelm.',
    credentials: [
      'PhD Clinical Psychology — University of Barcelona',
      'MSc Neuropsychology — Autonomous University of Barcelona',
      'DBT Certified Therapist — Linehan Institute',
      'EMDR Practitioner — EMDR International Association',
    ],
    languages: ['English', 'Spanish', 'Portuguese'],
    categories: ['General', 'Anxiety'],
    isTopDoctor: true,
    availableSlots: ['Mon 11:00 AM', 'Mon 5:00 PM', 'Tue 12:00 PM', 'Wed 7:00 PM', 'Thu 11:00 AM', 'Thu 4:00 PM'],
    reviews: [
      DoctorReview(
        authorName: 'Elena V.',
        authorInitials: 'EV',
        rating: 5,
        text: 'Dr. Roberto\'s DBT skills literally gave me a new life. I was drowning in panic attacks and emotional dysregulation. 6 months later I feel grounded and capable.',
        date: '2 weeks ago',
      ),
      DoctorReview(
        authorName: 'Carlos M.',
        authorInitials: 'CM',
        rating: 5,
        text: 'The EMDR sessions with Dr. Roberto processed trauma I had been carrying for 10 years. I can\'t believe how different I feel. Absolutely transformative.',
        date: '1 month ago',
      ),
      DoctorReview(
        authorName: 'Aisha K.',
        authorInitials: 'AK',
        rating: 5,
        text: 'He is incredibly skilled and compassionate. Never makes you feel judged. My anxiety is finally manageable after years of struggling.',
        date: '6 weeks ago',
      ),
    ],
  ),

  // ── THERAPISTS LIST GRID DOCTORS ─────────────────────────────────────────

  Doctor(
    id: 'kareem_hadidy',
    name: 'Dr. Kareem El-Hadidy',
    specialty: 'Trauma & Recovery Specialist',
    initials: 'KH',
    image: 'assets/images/dr_kareem.jpg',
    rating: 4.8,
    reviewCount: 89,
    yearsExperience: 11,
    pricePerSession: 105,
    bio: 'Dr. Kareem El-Hadidy is an EMDR-certified trauma specialist with deep expertise in complex PTSD, adverse childhood experiences (ACE), and grief. He has worked extensively with survivors of domestic violence, war trauma, and medical trauma. His integrative approach combines somatic therapy techniques with EMDR and trauma-focused CBT, helping patients not just survive their past but reclaim a vibrant future.',
    credentials: [
      'PhD Clinical Psychology — American University in Cairo',
      'MSc Trauma Studies — King\'s College London',
      'EMDR Practitioner — EMDR International Association',
      'Somatic Experiencing Practitioner — Level 2',
    ],
    languages: ['Arabic', 'English'],
    categories: ['General', 'Depression', 'Anxiety'],
    isTopDoctor: false,
    availableSlots: ['Sun 9:00 AM', 'Sun 2:00 PM', 'Mon 10:00 AM', 'Tue 3:00 PM', 'Wed 9:00 AM', 'Thu 1:00 PM'],
    reviews: [
      DoctorReview(
        authorName: 'Youssef H.',
        authorInitials: 'YH',
        rating: 5,
        text: 'Dr. Kareem helped me process childhood trauma that I had never told anyone. His patience and skill created a space where I finally felt safe to heal.',
        date: '1 month ago',
      ),
      DoctorReview(
        authorName: 'Dina F.',
        authorInitials: 'DF',
        rating: 5,
        text: 'After years of PTSD symptoms, EMDR with Dr. Kareem has dramatically reduced my flashbacks. I am forever grateful for his expertise.',
        date: '2 months ago',
      ),
      DoctorReview(
        authorName: 'Omar S.',
        authorInitials: 'OS',
        rating: 4,
        text: 'Very knowledgeable and empathetic. He explains everything clearly so you understand the process. Made trauma work feel manageable.',
        date: '3 months ago',
      ),
    ],
  ),

  Doctor(
    id: 'monica_hernandez',
    name: 'Dr. Monica Hernandez',
    specialty: 'Adolescent & Young Adult Psychologist',
    initials: 'MH',
    image: 'assets/images/dr_monica.jpg',
    rating: 4.7,
    reviewCount: 67,
    yearsExperience: 9,
    pricePerSession: 90,
    bio: 'Dr. Monica Hernandez is passionate about supporting teenagers and young adults through the unique challenges of growing up. From academic pressure and social anxiety to body image issues and identity formation, she creates a judgment-free space where young people can finally speak freely. She integrates narrative therapy, CBT, and family systems approaches to empower the next generation.',
    credentials: [
      'PhD Developmental Psychology — UCLA',
      'MA Counseling Psychology — University of Southern California',
      'Certified Adolescent Mental Health Specialist — APA',
      'Eating Disorder Specialist Training — NEDA',
    ],
    languages: ['English', 'Spanish'],
    categories: ['General', 'Anxiety', 'Eating Disorder'],
    isTopDoctor: false,
    availableSlots: ['Mon 2:00 PM', 'Tue 3:00 PM', 'Wed 5:00 PM', 'Thu 2:00 PM', 'Fri 4:00 PM', 'Fri 7:00 PM'],
    reviews: [
      DoctorReview(
        authorName: 'Camila R.',
        authorInitials: 'CR',
        rating: 5,
        text: 'Dr. Monica is the first therapist who truly got me. As a teenager I was terrified of therapy but she made it feel like talking to a friend who actually has answers.',
        date: '3 weeks ago',
      ),
      DoctorReview(
        authorName: 'Parent of Ana T.',
        authorInitials: 'AT',
        rating: 5,
        text: 'My daughter was struggling with an eating disorder and Dr. Monica\'s approach was compassionate and evidence-based. We saw real progress within 2 months.',
        date: '2 months ago',
      ),
      DoctorReview(
        authorName: 'Luis G.',
        authorInitials: 'LG',
        rating: 4,
        text: 'Great with social anxiety. She gave me practical tools for situations I used to dread. University is now actually enjoyable.',
        date: '3 months ago',
      ),
    ],
  ),

  Doctor(
    id: 'hager_osama',
    name: 'Dr. Hager Osama',
    specialty: 'Emotional Health Counselor',
    initials: 'HO',
    image: 'assets/images/dr_hager.jpg',
    rating: 4.6,
    reviewCount: 54,
    yearsExperience: 7,
    pricePerSession: 80,
    bio: 'Dr. Hager Osama is a warm and insightful counselor who believes that emotional well-being is the foundation of a fulfilling life. Using narrative therapy and person-centered approaches, she helps clients rewrite their personal stories, build self-compassion, and develop emotional resilience. She has particular expertise in low self-esteem, self-sabotage patterns, and navigating difficult family dynamics.',
    credentials: [
      'MSc Counseling Psychology — German University in Cairo',
      'BSc Psychology — Cairo University',
      'Narrative Therapy Practitioner — Dulwich Centre',
      'Positive Psychology Coach — IPPA Certified',
    ],
    languages: ['Arabic', 'English'],
    categories: ['General', 'Depression', 'Anxiety'],
    isTopDoctor: false,
    availableSlots: ['Sat 10:00 AM', 'Sun 11:00 AM', 'Mon 12:00 PM', 'Tue 10:00 AM', 'Wed 4:00 PM', 'Wed 6:00 PM'],
    reviews: [
      DoctorReview(
        authorName: 'Salma Y.',
        authorInitials: 'SY',
        rating: 5,
        text: 'Dr. Hager helped me see my life from a completely different angle. The narrative therapy approach felt so natural and helped me find my own strength.',
        date: '1 month ago',
      ),
      DoctorReview(
        authorName: 'Karim A.',
        authorInitials: 'KA',
        rating: 4,
        text: 'She is kind, non-judgmental, and always makes me feel seen. My self-esteem has improved significantly since starting sessions with her.',
        date: '2 months ago',
      ),
      DoctorReview(
        authorName: 'Mona B.',
        authorInitials: 'MB',
        rating: 5,
        text: 'Very empathetic and professional. She helped me work through deeply rooted family patterns that were affecting all my relationships.',
        date: '3 months ago',
      ),
    ],
  ),

  Doctor(
    id: 'george_matt',
    name: 'Dr. George Matt',
    specialty: 'Mindfulness Coach & Psychotherapist',
    initials: 'GM',
    image: 'assets/images/dr_george.jpg',
    rating: 4.8,
    reviewCount: 103,
    yearsExperience: 13,
    pricePerSession: 115,
    bio: 'Dr. George Matt bridges the wisdom of contemplative traditions with the rigor of modern psychotherapy. A certified MBSR (Mindfulness-Based Stress Reduction) instructor, he has spent 13 years helping people heal depression, overcome compulsive behaviors, and navigate major life transitions through present-moment awareness. His approach is gentle, non-judgmental, and profoundly effective for those who feel traditional therapy hasn\'t been enough.',
    credentials: [
      'PhD Psychology — University of Edinburgh',
      'MA Buddhist Studies & Contemplative Psychology — Naropa University',
      'MBSR Certified Instructor — Center for Mindfulness, UMASS',
      'Advanced Mindfulness-Based Cognitive Therapy (MBCT) Practitioner',
    ],
    languages: ['English'],
    categories: ['General', 'Depression', 'Eating Disorder'],
    isTopDoctor: false,
    availableSlots: ['Tue 8:00 AM', 'Wed 9:00 AM', 'Thu 8:00 AM', 'Thu 1:00 PM', 'Sat 10:00 AM', 'Sat 2:00 PM'],
    reviews: [
      DoctorReview(
        authorName: 'Thomas B.',
        authorInitials: 'TB',
        rating: 5,
        text: 'Dr. Matt\'s mindfulness approach reached places that years of conventional therapy never could. My depression lifted gradually but surely. I am a different person.',
        date: '2 weeks ago',
      ),
      DoctorReview(
        authorName: 'Priya N.',
        authorInitials: 'PN',
        rating: 5,
        text: 'Combining psychology with mindfulness was exactly what I needed for my binge eating. He never made me feel ashamed, only empowered.',
        date: '1 month ago',
      ),
      DoctorReview(
        authorName: 'Mark D.',
        authorInitials: 'MD',
        rating: 5,
        text: 'Exceptional therapist. His sessions feel like a master class in self-understanding. The MBSR program he guided me through was transformative.',
        date: '2 months ago',
      ),
    ],
  ),

  // ── ADDITIONAL DOCTORS (visible in See All / AllDoctorsScreen) ────────────

  Doctor(
    id: 'ethan_brooks',
    name: 'Dr. Ethan Brooks',
    specialty: 'Behavioral Therapist (Addiction & Habit Recovery)',
    initials: 'EB',
    image: 'assets/images/dr_ethan.jpg',
    rating: 4.5,
    reviewCount: 41,
    yearsExperience: 6,
    pricePerSession: 85,
    bio: 'Dr. Ethan Brooks specializes in helping individuals break free from destructive habits, compulsive behaviors, and addiction. Using Cognitive Behavioral Therapy, motivational interviewing, and habit-reversal training, he creates structured, supportive treatment plans that address both the behavioral patterns and the emotional drivers behind them.',
    credentials: [
      'MSc Clinical Psychology — University of Manchester',
      'BSc Behavioral Science — University of Leeds',
      'Certified Addiction Counselor (CAC-II)',
      'Motivational Interviewing Network Trainer (MINT)',
    ],
    languages: ['English'],
    categories: ['General', 'Depression', 'Anxiety'],
    isTopDoctor: false,
    availableSlots: ['Mon 10:00 AM', 'Wed 2:00 PM', 'Thu 10:00 AM', 'Fri 3:00 PM', 'Sat 9:00 AM', 'Sat 1:00 PM'],
    reviews: [
      DoctorReview(
        authorName: 'James T.',
        authorInitials: 'JT',
        rating: 5,
        text: 'Dr. Brooks helped me overcome a 5-year smartphone addiction and anxiety disorder together. His structured approach made it feel achievable step by step.',
        date: '1 month ago',
      ),
      DoctorReview(
        authorName: 'Rachel P.',
        authorInitials: 'RP',
        rating: 4,
        text: 'Very professional. His habit-reversal techniques worked well for my compulsive behaviors. Still early days but I can already see the difference.',
        date: '2 months ago',
      ),
    ],
  ),

  Doctor(
    id: 'emily_carter',
    name: 'Dr. Emily Carter',
    specialty: 'Psychiatrist (Mood & Sleep Disorders)',
    initials: 'EC',
    image: 'assets/images/dr_emily.jpg',
    rating: 4.8,
    reviewCount: 127,
    yearsExperience: 14,
    pricePerSession: 130,
    bio: 'Dr. Emily Carter is a board-certified psychiatrist with deep expertise in mood disorders including bipolar disorder, treatment-resistant depression, and circadian rhythm disturbances. She takes a comprehensive approach that integrates psychopharmacology with therapy and lifestyle interventions, ensuring that every patient receives truly individualized care that goes beyond medication management.',
    credentials: [
      'MD Psychiatry — Johns Hopkins University School of Medicine',
      'Residency in Psychiatry — Massachusetts General Hospital',
      'Fellowship in Sleep Medicine — Stanford Sleep Center',
      'Board Certified — American Board of Psychiatry and Neurology',
    ],
    languages: ['English', 'French'],
    categories: ['General', 'Depression'],
    isTopDoctor: false,
    availableSlots: ['Tue 9:00 AM', 'Tue 1:00 PM', 'Wed 10:00 AM', 'Thu 9:00 AM', 'Fri 11:00 AM', 'Fri 3:00 PM'],
    reviews: [
      DoctorReview(
        authorName: 'Michael H.',
        authorInitials: 'MH',
        rating: 5,
        text: 'Dr. Carter finally diagnosed and properly treated my bipolar II after years of misdiagnosis. Her thoroughness and expertise are exceptional.',
        date: '3 weeks ago',
      ),
      DoctorReview(
        authorName: 'Susan L.',
        authorInitials: 'SL',
        rating: 5,
        text: 'My sleep disorder is finally under control. Dr. Carter\'s approach combining sleep hygiene education with the right medication made a world of difference.',
        date: '2 months ago',
      ),
      DoctorReview(
        authorName: 'Ali M.',
        authorInitials: 'AM',
        rating: 5,
        text: 'The most thorough psychiatric evaluation I\'ve ever had. She truly listens and her treatment plan is comprehensive and compassionate.',
        date: '3 months ago',
      ),
    ],
  ),

  Doctor(
    id: 'oliver_chen',
    name: 'Dr. Oliver Chen',
    specialty: 'Clinical Psychologist (Cognitive Behavioral Therapy)',
    initials: 'OC',
    image: 'assets/images/dr_oliver.jpg',
    rating: 4.7,
    reviewCount: 78,
    yearsExperience: 9,
    pricePerSession: 100,
    bio: 'Dr. Oliver Chen is a CBT specialist known for his structured, goal-oriented approach to treating anxiety, OCD, and phobias. Trained at world-leading institutions, he combines rigorous evidence-based practice with genuine warmth, making even the most challenging therapeutic exposures feel manageable. He is particularly experienced working with high-achieving professionals experiencing performance anxiety and perfectionism.',
    credentials: [
      'PhD Clinical Psychology — University of Oxford',
      'MSc Experimental Psychology — University of Cambridge',
      'CBT Specialist Certification — British Association for Behavioural & Cognitive Psychotherapies',
      'OCD Specialist Training — International OCD Foundation',
    ],
    languages: ['English', 'Mandarin'],
    categories: ['General', 'Anxiety', 'Depression'],
    isTopDoctor: false,
    availableSlots: ['Mon 8:00 AM', 'Mon 12:00 PM', 'Wed 9:00 AM', 'Thu 5:00 PM', 'Fri 8:00 AM', 'Sat 11:00 AM'],
    reviews: [
      DoctorReview(
        authorName: 'Nathan W.',
        authorInitials: 'NW',
        rating: 5,
        text: 'Dr. Chen\'s systematic CBT approach transformed how I handle OCD. His exposure therapy protocol was challenging but incredibly effective.',
        date: '1 month ago',
      ),
      DoctorReview(
        authorName: 'Mei L.',
        authorInitials: 'ML',
        rating: 5,
        text: 'As a perfectionist, finding Dr. Chen was life-changing. He understood my high-achieving mindset and helped me untangle perfectionism from anxiety.',
        date: '6 weeks ago',
      ),
      DoctorReview(
        authorName: 'Jordan K.',
        authorInitials: 'JK',
        rating: 4,
        text: 'Very structured and professional. The CBT worksheets he provides between sessions have been genuinely useful for tracking my progress.',
        date: '3 months ago',
      ),
    ],
  ),

  Doctor(
    id: 'jacob_miller',
    name: 'Dr. Jacob Miller',
    specialty: 'Clinical Counselor (Stress & Burnout)',
    initials: 'JM',
    image: 'assets/images/dr_jacob.jpg',
    rating: 4.4,
    reviewCount: 32,
    yearsExperience: 5,
    pricePerSession: 75,
    bio: 'Dr. Jacob Miller is an emerging counselor who brings a fresh, modern perspective to stress management and workplace burnout. He works especially well with Millennials and Gen Z clients navigating digital-age stressors, hustle culture, and the pressure to do it all. His sessions are conversational, solution-focused, and grounded in the latest research on stress resilience and sustainable productivity.',
    credentials: [
      'MA Clinical Mental Health Counseling — Fordham University',
      'BSc Psychology — New York University',
      'Certified Stress Management Consultant — ISMA',
      'Positive Psychology Practitioner — Flourishing Center',
    ],
    languages: ['English'],
    categories: ['General', 'Anxiety'],
    isTopDoctor: false,
    availableSlots: ['Mon 6:00 PM', 'Tue 7:00 PM', 'Wed 6:00 PM', 'Thu 7:00 PM', 'Sat 10:00 AM', 'Sun 2:00 PM'],
    reviews: [
      DoctorReview(
        authorName: 'Alex G.',
        authorInitials: 'AG',
        rating: 5,
        text: 'Dr. Miller actually gets what it\'s like to be a 25-year-old drowning in work stress. His sessions feel real and relevant, not textbook.',
        date: '3 weeks ago',
      ),
      DoctorReview(
        authorName: 'Sam T.',
        authorInitials: 'ST',
        rating: 4,
        text: 'Great for early-stage burnout. Very approachable and non-judgmental. I feel like I\'m talking to someone who truly understands my generation.',
        date: '2 months ago',
      ),
    ],
  ),
];
