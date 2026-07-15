class IslamicNudge {
  const IslamicNudge({
    required this.arabic,
    required this.translation,
    required this.reflection,
    this.source = '',
  });

  final String arabic;
  final String translation;
  final String reflection;
  final String source;
}

const List<IslamicNudge> kIslamicNudges = [
  IslamicNudge(
    arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    translation: 'Truly, it is in the remembrance of Allah that hearts find rest.',
    reflection:
        'When your heart feels unseen, Allah still sees you. Sit for one minute and say SubhanAllah. Your heart is allowed to rest with Him.',
    source: 'Qur’an 13:28',
  ),
  IslamicNudge(
    arabic: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    translation: 'Indeed, with hardship comes ease.',
    reflection:
        'Not after hardship — *with* it. Your heaviness and Allah’s mercy can exist in the same moment.',
    source: 'Qur’an 94:6',
  ),
  IslamicNudge(
    arabic: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا',
    translation: 'Do not weaken and do not grieve.',
    reflection:
        'Grief is human. Weakening yourself with shame is optional. You showed up today — that is strength.',
    source: 'Qur’an 3:139',
  ),
  IslamicNudge(
    arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ',
    translation: 'O Allah, I seek refuge in You from worry and grief.',
    reflection:
        'Your sadness is something the Prophet ﷺ taught us to bring straight to Allah. You do not have to perform “okay.”',
  ),
  IslamicNudge(
    arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    translation: 'Allah is sufficient for us, and He is the best Disposer of affairs.',
    reflection:
        'When life feels thin, this sentence rebuilds the foundation: Allah is enough — always near, always sufficient.',
  ),
  IslamicNudge(
    arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي',
    translation: 'My Lord, expand my chest for me.',
    reflection:
        'Musa عليه السلام asked this when he felt overwhelmed. Asking Allah to widen your capacity is worship, not weakness.',
    source: 'Qur’an 20:25',
  ),
  IslamicNudge(
    arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
    translation: 'So truly, with hardship comes ease.',
    reflection:
        'Repeat it slowly. Your childhood pain does not cancel Allah’s promise. Ease can arrive quietly.',
    source: 'Qur’an 94:5',
  ),
  IslamicNudge(
    arabic: 'وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا بِاللَّهِ',
    translation: 'Be patient — and your patience is only through Allah.',
    reflection:
        'You do not have to manufacture patience alone. Ask Him to borrow you some for this hour.',
    source: 'Qur’an 16:127',
  ),
];

const List<String> kDawahCheckIns = [
  'Assalamu alaikum. Can we pray two rakah together in intention — even if you pray later? Your heart needs oxygen.',
  'Quick deen check, not a lecture: did you say Alhamdulillah for one small thing today?',
  'Brother — make wudu if you can. Cold water on the face resets the soul more than scrolling ever will.',
  'Remember: seeking Allah when you feel empty is not “doing religion.” It is coming home.',
  'A quiet SubhanAllah reaches Allah even when the day felt silent. He heard the first one.',
  'Your worth was written by the One who created you. Hold onto that.',
  'Gratitude softens the heart. Name one small blessing from today.',
  'Bring whatever is on your heart to Allah. He already knows — and He is near.',
];

const List<String> kShortAdhkar = [
  'SubhanAllah — Glory be to Allah.',
  'Alhamdulillah — All praise is for Allah.',
  'Allahu Akbar — Allah is Greater than this feeling.',
  'Astaghfirullah — I seek Allah’s forgiveness and a cleaner heart.',
  'La ilaha illallah — There is no god but Allah.',
  'Hasbunallahu wa ni‘mal wakeel — Allah is enough for me.',
];
