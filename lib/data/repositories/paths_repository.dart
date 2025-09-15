// lib/data/repositories/paths_repository.dart
import 'package:latlong2/latlong.dart';

import '../models/path_model.dart';
import '../services/api_service.dart';

class PathsRepository {
  final ApiService _apiService = ApiService();
  
  Future<List<PathModel>> getAllPaths() async {
    // TODO: Replace with actual API call
    // Dummy data for now
    return [
      PathModel(
        id: '1',
        name: 'Upper Galilee Trail',
        nameAr: 'مسار الجليل الأعلى',
        description: 'A beautiful trail through the Upper Galilee region, offering breathtaking views of the Mediterranean Sea and surrounding mountains. The path passes through historic Palestinian villages and ancient olive groves.',
        descriptionAr: 'مسار جميل عبر منطقة الجليل الأعلى، يوفر إطلالات خلابة على البحر المتوسط والجبال المحيطة. يمر المسار عبر قرى فلسطينية تاريخية وبساتين زيتون قديمة.',
        location: 'Upper Galilee, Northern Palestine',
        locationAr: 'الجليل الأعلى، شمال فلسطين',
        images: [
          'assets/images/galilee3.jpg',
        ],
        length: 12.5,
        estimatedDuration: const Duration(hours: 4),
        difficulty: DifficultyLevel.medium,
        activities: [
          ActivityType.hiking,
          ActivityType.nature,
          ActivityType.camping,
        ],
        coordinates: [
          LatLng(33.0479, 35.3923),
          LatLng(33.0485, 35.3930),
          LatLng(33.0490, 35.3940),
          LatLng(33.0495, 35.3950),
        ],
        rating: 4.7,
        reviewCount: 128,
        warnings: [
          'Bring plenty of water',
          'Start early in summer',
          'Some sections may be slippery after rain',
        ],
        warningsAr: [
          'احرص على أخذ كمية كافية من الماء',
          'يُنصح بالبدء في الصباح الباكر في فصل الصيف',
          'بعض المقاطع قد تكون زلقة بعد المطر',
        ],
      ),
      PathModel(
        id: '2',
        name: 'Wadi Qelt Hike',
        nameAr: 'مسار وادي القلط',
        description: 'A dramatic desert canyon hike in the wilderness east of Jerusalem. Wadi Qelt features ancient aqueducts, monasteries carved into cliffs, and lush oases in the midst of the desert.',
        descriptionAr: 'مسار مذهل في وادي صحراوي شرق القدس. يضم وادي القلط قنوات مياه قديمة وأديرة منحوتة في الصخور وواحات خضراء وسط الصحراء.',
        location: 'Jericho, West Bank',
        locationAr: 'أريحا، الضفة الغربية',
        images: [
          'assets/images/wadi_qelt1.jpg',
          'assets/images/wadi_qelt2.jpg',
          'assets/images/wadi_qelt3.jpg',
        ],
        length: 15.0,
        estimatedDuration: const Duration(hours: 6),
        difficulty: DifficultyLevel.hard,
        activities: [
          ActivityType.hiking,
          ActivityType.nature,
          ActivityType.archaeological,
          ActivityType.religious,
        ],
        coordinates: [
          LatLng(31.8389, 35.3360),
          LatLng(31.8380, 35.3370),
          LatLng(31.8375, 35.3380),
          LatLng(31.8370, 35.3390),
        ],
        rating: 4.9,
        reviewCount: 235,
        warnings: [
          'Extremely hot in summer months',
          'Carry at least 3 liters of water per person',
          'Wear sun protection',
          'Some sections require scrambling',
        ],
        warningsAr: [
          'حار جداً في أشهر الصيف',
          'احمل ما لا يقل عن 3 لترات من الماء للشخص',
          'ارتدِ واقٍ من الشمس',
          'بعض المقاطع تتطلب التسلق',
        ],
      ),
      PathModel(
        id: '3',
        name: 'Battir Terraces Trail',
        nameAr: 'مسار مدرجات بتير',
        description: 'Explore the UNESCO World Heritage ancient agricultural terraces of Battir. This trail takes you through a landscape of remarkable beauty with traditional Palestinian agricultural practices dating back thousands of years.',
        descriptionAr: 'استكشف المدرجات الزراعية القديمة في بتير المدرجة في قائمة التراث العالمي لليونسكو. يأخذك هذا المسار عبر منظر طبيعي ذي جمال استثنائي مع ممارسات زراعية فلسطينية تقليدية يعود تاريخها إلى آلاف السنين.',
        location: 'Battir, Bethlehem',
        locationAr: 'بتير، بيت لحم',
        images: [
          'assets/images/battir1.jpg',
          'assets/images/battir2.jpg',
          'assets/images/battir3.jpg',
        ],
        length: 8.0,
        estimatedDuration: const Duration(hours: 3),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.hiking,
          ActivityType.cultural,
          ActivityType.nature,
        ],
        coordinates: [
          LatLng(31.7269, 35.1399),
          LatLng(31.7260, 35.1390),
          LatLng(31.7255, 35.1385),
          LatLng(31.7250, 35.1380),
        ],
        rating: 4.6,
        reviewCount: 98,
        warnings: [
          'Respect private agricultural areas',
          'Stay on marked trails',
        ],
        warningsAr: [
          'احترم المناطق الزراعية الخاصة',
          'ابق على المسارات المحددة',
        ],
      ),
      PathModel(
        id: '4',
        name: 'Sebastia Archaeological Site',
        nameAr: 'الموقع الأثري سبسطية',
        description: 'Walk through the ancient ruins of Sebastia, a site with layers of history from Canaanite, Israelite, Hellenistic, Herodian, Roman, Byzantine, and Ottoman periods. Explore Roman colonnades, a Crusader cathedral, and an ancient theater.',
        descriptionAr: 'تجول بين أنقاض سبسطية القديمة، موقع يحتوي على طبقات من التاريخ من الفترات الكنعانية والإسرائيلية والهلنستية والهيرودية والرومانية والبيزنطية والعثمانية. استكشف الأعمدة الرومانية وكاتدرائية الصليبيين والمسرح القديم.',
        location: 'Nablus, West Bank',
        locationAr: 'نابلس، الضفة الغربية',
        images: [
          'assets/images/sebastia1.jpg',
          'assets/images/sebastia2.jpg',
          'assets/images/sebastia3.jpg',
        ],
        length: 3.5,
        estimatedDuration: const Duration(hours: 2),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.archaeological,
          ActivityType.cultural,
          ActivityType.hiking,
        ],
        coordinates: [
          LatLng(32.2761, 35.1869),
          LatLng(32.2755, 35.1865),
          LatLng(32.2750, 35.1860),
          LatLng(32.2745, 35.1855),
        ],
        rating: 4.5,
        reviewCount: 79,
        warnings: [
          'Limited shade in summer',
          'Wear comfortable shoes for uneven terrain',
        ],
        warningsAr: [
          'ظل محدود في الصيف',
          'ارتدِ أحذية مريحة للتضاريس غير المستوية',
        ],
      ),
      PathModel(
        id: '5',
        name: 'Mar Saba Monastery Trail',
        nameAr: 'مسار دير مار سابا',
        description: 'A desert hike to the spectacular Mar Saba Monastery, clinging to the cliffs of the Kidron Valley. Built in the 5th century, this Greek Orthodox monastery offers stunning architecture in a dramatic setting.',
        descriptionAr: 'رحلة صحراوية إلى دير مار سابا المذهل، المتشبث بمنحدرات وادي قدرون. بُني هذا الدير الأرثوذكسي اليوناني في القرن الخامس، ويوفر هندسة معمارية مذهلة في إطار مثير.',
        location: 'Bethlehem, West Bank',
        locationAr: 'بيت لحم، الضفة الغربية',
        images: [
          'assets/images/mar_saba1.jpg',
          'assets/images/mar_saba2.jpg',
          'assets/images/mar_saba3.jpg',
        ],
        length: 10.0,
        estimatedDuration: const Duration(hours: 4),
        difficulty: DifficultyLevel.medium,
        activities: [
          ActivityType.hiking,
          ActivityType.religious,
          ActivityType.nature,
        ],
        coordinates: [
          LatLng(31.7025, 35.3417),
          LatLng(31.7020, 35.3420),
          LatLng(31.7015, 35.3425),
          LatLng(31.7010, 35.3430),
        ],
        rating: 4.8,
        reviewCount: 112,
        warnings: [
          'Very hot in summer, start early',
          'No water sources along the trail',
          'Note: Women are not allowed inside the monastery but can view from outside',
        ],
        warningsAr: [
          'حار جداً في الصيف، ابدأ مبكراً',
          'لا توجد مصادر مياه على طول المسار',
          'ملاحظة: لا يُسمح للنساء بدخول الدير ولكن يمكنهن المشاهدة من الخارج',
        ],
      ),
      PathModel(
        id: '6',
        name: 'Jericho Oasis Walk',
        nameAr: 'مسار واحة أريحا',
        description: 'Explore the lush oasis of Jericho, one of the oldest continuously inhabited cities in the world. Visit the ancient Tel es-Sultan, Hisham\'s Palace, and walk through date palm groves and banana plantations.',
        descriptionAr: 'استكشف واحة أريحا الخصبة، إحدى أقدم المدن المأهولة باستمرار في العالم. قم بزيارة تل السلطان القديم وقصر هشام والمشي عبر بساتين النخيل وزراعات الموز.',
        location: 'Jericho, West Bank',
        locationAr: 'أريحا، الضفة الغربية',
        images: [
          'assets/images/jericho1.jpg',
          'assets/images/jericho2.jpg',
          'assets/images/jericho3.jpg',
        ],
        length: 5.0,
        estimatedDuration: const Duration(hours: 2, minutes: 30),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.cultural,
          ActivityType.archaeological,
          ActivityType.nature,
        ],
        coordinates: [
          LatLng(31.8711, 35.4444),
          LatLng(31.8715, 35.4440),
          LatLng(31.8720, 35.4435),
          LatLng(31.8725, 35.4430),
        ],
        rating: 4.4,
        reviewCount: 165,
        warnings: [
          'Extremely hot in summer (lowest elevation on Earth)',
          'Bring plenty of water',
        ],
        warningsAr: [
          'حار للغاية في الصيف (أخفض ارتفاع على الأرض)',
          'أحضر الكثير من الماء',
        ],
      ),
      PathModel(
        id: '7',
        name: 'Makhrour Valley Trail',
        nameAr: 'مسار وادي المخرور',
        description: 'A picturesque hike through Makhrour Valley near Bethlehem, featuring traditional Palestinian agricultural terraces, olive groves, and seasonal wildflowers. The valley is known for its natural springs and biodiversity.',
        descriptionAr: 'رحلة خلابة عبر وادي المخرور بالقرب من بيت لحم، تضم مدرجات زراعية فلسطينية تقليدية وبساتين زيتون وزهور برية موسمية. يشتهر الوادي بينابيعه الطبيعية وتنوعه البيولوجي.',
        location: 'Bethlehem, West Bank',
        locationAr: 'بيت لحم، الضفة الغربية',
        images: [
          'assets/images/makhrour1.jpg',
          'assets/images/makhrour2.jpg',
          'assets/images/makhrour3.jpg',
        ],
        length: 7.5,
        estimatedDuration: const Duration(hours: 3),
        difficulty: DifficultyLevel.medium,
        activities: [
          ActivityType.hiking,
          ActivityType.nature,
          ActivityType.cultural,
        ],
        coordinates: [
          LatLng(31.7172, 35.1613),
          LatLng(31.7165, 35.1620),
          LatLng(31.7160, 35.1625),
          LatLng(31.7155, 35.1630),
        ],
        rating: 4.6,
        reviewCount: 88,
        warnings: [
          'Some steep sections',
          'Trail can be overgrown in spring',
        ],
        warningsAr: [
          'بعض المقاطع الحادة',
          'يمكن أن يكون المسار مغطى بالأعشاب في الربيع',
        ],
      ),
      PathModel(
        id: '8',
        name: 'Umm Qais Ancient City',
        nameAr: 'مدينة أم قيس القديمة',
        description: 'Explore the ancient Greco-Roman city of Gadara (modern Umm Qais) with spectacular views over the Sea of Galilee, Golan Heights, and Jordan Valley. This archaeological site includes a well-preserved theater, colonnaded street, and Byzantine church.',
        descriptionAr: 'استكشف مدينة جدارا اليونانية الرومانية القديمة (أم قيس الحديثة) مع إطلالات مذهلة على بحيرة طبريا، مرتفعات الجولان، ووادي الأردن. يتضمن هذا الموقع الأثري مسرحًا جيد الحفظ وشارعًا معمدًا وكنيسة بيزنطية.',
        location: 'Northern Jordan Valley',
        locationAr: 'شمال وادي الأردن',
        images: [
          'assets/images/umm_qais1.jpg',
          'assets/images/umm_qais2.jpg',
          'assets/images/umm_qais3.jpg',
        ],
        length: 4.0,
        estimatedDuration: const Duration(hours: 2),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.archaeological,
          ActivityType.cultural,
          ActivityType.hiking,
        ],
        coordinates: [
          LatLng(32.6533, 35.6852),
          LatLng(32.6530, 35.6855),
          LatLng(32.6525, 35.6860),
          LatLng(32.6520, 35.6865),
        ],
        rating: 4.5,
        reviewCount: 76,
        warnings: [
          'Limited shade in archaeological areas',
          'Wear good walking shoes for ancient stone paths',
        ],
        warningsAr: [
          'ظل محدود في المناطق الأثرية',
          'ارتدِ أحذية مشي جيدة للمسارات الحجرية القديمة',
        ],
      ),
      PathModel(
        id: '9',
        name: 'Rashayda Desert Camp',
        nameAr: 'مخيم الرشايدة الصحراوي',
        description: 'Experience traditional Bedouin hospitality in the eastern desert near the Dead Sea. This camping trip includes cultural experiences with local communities, stargazing, and short desert hikes.',
        descriptionAr: 'جرب الضيافة البدوية التقليدية في الصحراء الشرقية بالقرب من البحر الميت. تتضمن هذه الرحلة التخييمية تجارب ثقافية مع المجتمعات المحلية ومراقبة النجوم ورحلات صحراوية قصيرة.',
        location: 'Dead Sea Region, West Bank',
        locationAr: 'منطقة البحر الميت، الضفة الغربية',
        images: [
          'assets/images/rashayda1.jpg',
          'assets/images/rashayda2.jpg',
          'assets/images/rashayda3.jpg',
        ],
        length: 6.0,
        estimatedDuration: const Duration(hours: 20), // Overnight
        difficulty: DifficultyLevel.medium,
        activities: [
          ActivityType.camping,
          ActivityType.cultural,
          ActivityType.hiking,
        ],
        coordinates: [
          LatLng(31.6100, 35.3972),
          LatLng(31.6095, 35.3975),
          LatLng(31.6090, 35.3980),
          LatLng(31.6085, 35.3985),
        ],
        rating: 4.9,
        reviewCount: 58,
        warnings: [
          'Very hot during day, cold at night',
          'No cellular service in some areas',
          'Bring sleeping bag or warm clothes for night',
        ],
        warningsAr: [
          'حار جداً خلال النهار، بارد في الليل',
          'لا توجد خدمة خلوية في بعض المناطق',
          'أحضر كيس نوم أو ملابس دافئة لليل',
        ],
      ),
      PathModel(
        id: '10',
        name: 'Hebron Old City Tour',
        nameAr: 'جولة مدينة الخليل القديمة',
        description: 'Discover the historical and cultural significance of Hebron\'s Old City, with its traditional markets, ancient architecture, and religious sites including the Ibrahimi Mosque/Cave of the Patriarchs.',
        descriptionAr: 'اكتشف الأهمية التاريخية والثقافية لمدينة الخليل القديمة، بأسواقها التقليدية وعمارتها القديمة ومواقعها الدينية بما في ذلك المسجد الإبراهيمي/مغارة البطاركة.',
        location: 'Hebron, West Bank',
        locationAr: 'الخليل، الضفة الغربية',
        images: [
          'assets/images/hebron1.jpg',
          'assets/images/hebron2.jpg',
          'assets/images/hebron3.jpg',
        ],
        length: 3.0,
        estimatedDuration: const Duration(hours: 3),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.cultural,
          ActivityType.religious,
        ],
        coordinates: [
          LatLng(31.5294, 35.1007),
          LatLng(31.5290, 35.1010),
          LatLng(31.5285, 35.1015),
          LatLng(31.5280, 35.1020),
        ],
        rating: 4.7,
        reviewCount: 105,
        warnings: [
          'Respect dress codes at religious sites',
          'Be aware of security checkpoints in the area',
        ],
        warningsAr: [
          'احترم قواعد اللباس في المواقع الدينية',
          'كن على دراية بنقاط التفتيش الأمنية في المنطقة',
        ],
      ),
      PathModel(
        id: '11',
        name: 'Gaza Beach Walk',
        nameAr: 'مشي على شاطئ غزة',
        description: 'A peaceful coastal walk along Gaza\'s Mediterranean shoreline. Experience the beauty of the sea while visiting local fishing communities and enjoying fresh seafood at beachside cafes.',
        descriptionAr: 'نزهة ساحلية هادئة على طول شاطئ غزة المتوسطي. استمتع بجمال البحر أثناء زيارة مجتمعات الصيد المحلية والاستمتاع بالمأكولات البحرية الطازجة في المقاهي الساحلية.',
        location: 'Gaza City, Gaza Strip',
        locationAr: 'مدينة غزة، قطاع غزة',
        images: [
          'assets/images/gaza1.jpg',
          'assets/images/gaza2.jpg',
          'assets/images/gaza3.jpg',
        ],
        length: 5.0,
        estimatedDuration: const Duration(hours: 2),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.nature,
          ActivityType.cultural,
        ],
        coordinates: [
          LatLng(31.5250, 34.4450),
          LatLng(31.5255, 34.4455),
          LatLng(31.5260, 34.4460),
          LatLng(31.5265, 34.4465),
        ],
        rating: 4.6,
        reviewCount: 94,
        warnings: [
          'Check current conditions before planning visit',
          'Swimming may not be safe in some areas',
        ],
        warningsAr: [
          'تحقق من الظروف الحالية قبل التخطيط للزيارة',
          'قد لا تكون السباحة آمنة في بعض المناطق',
        ],
      ),
      PathModel(
        id: '12',
        name: 'Dead Sea Floating Experience',
        nameAr: 'تجربة الطفو في البحر الميت',
        description: 'Experience the unique feeling of floating in the Dead Sea, the lowest point on Earth. Cover yourself with the famous mineral-rich mud known for its therapeutic properties.',
        descriptionAr: 'استمتع بتجربة الطفو الفريدة في البحر الميت، أخفض نقطة على الأرض. غطِ نفسك بالطين الغني بالمعادن المشهور بخصائصه العلاجية.',
        location: 'Dead Sea, West Bank',
        locationAr: 'البحر الميت، الضفة الغربية',
        images: [
          'assets/images/dead_sea1.jpg',
          'assets/images/dead_sea2.jpg',
          'assets/images/dead_sea3.jpg',
        ],
        length: 1.0,
        estimatedDuration: const Duration(hours: 3),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.nature,
        ],
        coordinates: [
          LatLng(31.5569, 35.4731),
          LatLng(31.5565, 35.4735),
          LatLng(31.5560, 35.4740),
          LatLng(31.5555, 35.4745),
        ],
        rating: 4.9,
        reviewCount: 212,
        warnings: [
          'Do not shave 24 hours before visit',
          'Avoid getting saltwater in eyes',
          'Extremely hot in summer months',
          'Bring fresh water to rinse off after swimming',
        ],
        warningsAr: [
          'لا تحلق قبل 24 ساعة من الزيارة',
          'تجنب دخول المياه المالحة في العينين',
          'حار للغاية في أشهر الصيف',
          'أحضر ماء عذب للشطف بعد السباحة',
        ],
      ),
      PathModel(
        id: '13',
        name: 'Mount Gerizim Samaritan Trail',
        nameAr: 'مسار جبل جرزيم السامري',
        description: 'Explore Mount Gerizim, home to the ancient Samaritan community. This trail offers incredible views of Nablus city and insights into one of the world\'s oldest and smallest religious communities.',
        descriptionAr: 'استكشف جبل جرزيم، موطن المجتمع السامري القديم. يوفر هذا المسار إطلالات رائعة على مدينة نابلس ونظرة عميقة على واحد من أقدم وأصغر المجتمعات الدينية في العالم.',
        location: 'Nablus, West Bank',
        locationAr: 'نابلس، الضفة الغربية',
        images: [
          'assets/imagesgerizim1.jpg',
          'assets/images/gerizim2.jpg',
          'assets/images/gerizim3.jpg',
        ],
        length: 6.0,
        estimatedDuration: const Duration(hours: 3),
        difficulty: DifficultyLevel.medium,
        activities: [
          ActivityType.hiking,
          ActivityType.cultural,
          ActivityType.religious,
        ],
        coordinates: [
          LatLng(32.2006, 35.2846),
          LatLng(32.2000, 35.2850),
          LatLng(32.1995, 35.2855),
          LatLng(32.1990, 35.2860),
        ],
        rating: 4.5,
        reviewCount: 67,
        warnings: [
          'Respect local Samaritan community',
          'Dress modestly when visiting religious sites',
        ],
        warningsAr: [
          'احترم المجتمع السامري المحلي',
          'ارتدِ ملابس محتشمة عند زيارة المواقع الدينية',
        ],
      ),
      PathModel(
        id: '14',
        name: 'Tent of Nations Farm Experience',
        nameAr: 'تجربة مزرعة خيمة الأمم',
        description: 'Visit the inspirational Tent of Nations farm, an environmental and educational peace project on a 100-acre hilltop farm near Bethlehem. Participate in olive harvesting, tree planting, or other seasonal agricultural activities.',
        descriptionAr: 'زر مزرعة خيمة الأمم الملهمة، وهي مشروع سلام بيئي وتعليمي على مزرعة تبلغ مساحتها 100 فدان على قمة تل بالقرب من بيت لحم. شارك في حصاد الزيتون، زراعة الأشجار، أو غيرها من الأنشطة الزراعية الموسمية.',
        location: 'Bethlehem, West Bank',
        locationAr: 'بيت لحم، الضفة الغربية',
        images: [
          'assets/images/tent_nations1.jpg',
          'assets/images/tent_nations2.jpg',
          'assets/images/tent_nations3.jpg',
        ],
        length: 3.0,
        estimatedDuration: const Duration(hours: 4),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.nature,
          ActivityType.cultural,
          ActivityType.camping,
        ],
        coordinates: [
          LatLng(31.6892, 35.1478),
          LatLng(31.6890, 35.1480),
          LatLng(31.6885, 35.1485),
          LatLng(31.6880, 35.1490),
        ],
        rating: 4.8,
        reviewCount: 82,
        warnings: [
          'Call ahead to arrange visit',
          'Facilities are simple and eco-friendly',
        ],
        warningsAr: [
          'اتصل مسبقاً لترتيب الزيارة',
          'المرافق بسيطة وصديقة للبيئة',
        ],
      ),
      PathModel(
        id: '15',
        name: 'Ramallah Cultural Tour',
        nameAr: 'جولة ثقافية في رام الله',
        description: 'Explore the vibrant cultural scene of Ramallah, the de facto administrative capital of Palestine. Visit museums, galleries, cafes, and the bustling old market.',
        descriptionAr: 'استكشف المشهد الثقافي النابض بالحياة في رام الله، العاصمة الإدارية الفعلية لفلسطين. زر المتاحف والمعارض والمقاهي والسوق القديم المزدحم.',
        location: 'Ramallah, West Bank',
        locationAr: 'رام الله، الضفة الغربية',
        images: [
          'assets/images/ramallah1.jpg',
          'assets/images/ramallah2.jpg',
          'assets/images/ramallah3.jpg',
        ],
        length: 4.0,
        estimatedDuration: const Duration(hours: 5),
        difficulty: DifficultyLevel.easy,
        activities: [
          ActivityType.cultural,
        ],
        coordinates: [
          LatLng(31.9031, 35.2042),
          LatLng(31.9035, 35.2045),
          LatLng(31.9040, 35.2050),
          LatLng(31.9045, 35.2055),
        ],
        rating: 4.4,
        reviewCount: 103,
        warnings: [
          'Traffic can be heavy in city center',
          'Some museums closed on Mondays',
        ],
        warningsAr: [
          'حركة المرور قد تكون كثيفة في وسط المدينة',
          'بعض المتاحف مغلقة أيام الاثنين',
        ],
      ),
    ];
  }
  
  Future<List<PathModel>> getFeaturedPaths() async {
    final allPaths = await getAllPaths();
    // Return the top 5 paths by rating
    allPaths.sort((a, b) => b.rating.compareTo(a.rating));
    return allPaths.take(5).toList();
  }
  
  Future<List<PathModel>> getPathsByActivity(ActivityType activity) async {
    final allPaths = await getAllPaths();
    return allPaths.where((path) => path.activities.contains(activity)).toList();
  }
  
  Future<List<PathModel>> getPathsByDifficulty(DifficultyLevel difficulty) async {
    final allPaths = await getAllPaths();
    return allPaths.where((path) => path.difficulty == difficulty).toList();
  }
  
  Future<List<PathModel>> searchPaths(String query) async {
    final allPaths = await getAllPaths();
    final lowerQuery = query.toLowerCase();
    
    return allPaths.where((path) {
      return path.name.toLowerCase().contains(lowerQuery) ||
             path.nameAr.contains(lowerQuery) ||
             path.description.toLowerCase().contains(lowerQuery) ||
             path.descriptionAr.contains(lowerQuery) ||
             path.location.toLowerCase().contains(lowerQuery) ||
             path.locationAr.contains(lowerQuery);
    }).toList();
  }
}
        