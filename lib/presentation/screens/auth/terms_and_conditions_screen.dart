// lib/presentation/screens/auth/terms_and_conditions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_app_bar.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'شروط الاستخدام والأحكام',
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.brightness == Brightness.dark
                  ? colorScheme.surface
                  : Colors.white,
              theme.brightness == Brightness.dark
                  ? colorScheme.surface
                  : Colors.grey[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(context.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.adaptive(16)),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.file_text,
                        color: AppColors.primary,
                        size: context.iconSize(isLarge: true),
                      ),
                      SizedBox(width: context.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'شروط الاستخدام والأحكام',
                              style: TextStyle(
                                fontSize: context.fontSize(20),
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: context.xs),
                            Text(
                              'آخر تحديث: ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
                              style: TextStyle(
                                fontSize: context.fontSize(12),
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.lg),

                // Introduction
                _buildSection(context, colorScheme, 'المقدمة', '''
مرحباً بك في تطبيق Velora. عند استخدامك لهذا التطبيق، فإنك توافق على الالتزام بالشروط والأحكام المذكورة أدناه. يُرجى قراءة هذه الشروط بعناية قبل استخدام التطبيق.

إذا كنت لا توافق على أي من هذه الشروط، يُرجى عدم استخدام التطبيق. نحتفظ بالحق في تحديث هذه الشروط والأحكام في أي وقت دون إشعار مسبق.
'''),

                // Acceptance
                _buildSection(context, colorScheme, 'القبول بالشروط', '''
باستخدامك لتطبيق Velora، فإنك تقر وتوافق على ما يلي:

1. أنك قرأت وفهمت هذه الشروط والأحكام بالكامل
2. أنك توافق على الالتزام بجميع الشروط المذكورة
3. أنك تمتلك الصلاحية القانونية للدخول في هذه الاتفاقية
4. أن استخدامك للتطبيق يتم وفقاً للقوانين واللوائح المعمول بها

إذا كنت تقوم بالتسجيل نيابة عن شركة أو مؤسسة، فإنك تعلن أنك مخول قانونياً للقيام بذلك.
'''),

                // Account Registration
                _buildSection(context, colorScheme, 'تسجيل الحساب', '''
للحصول على وصول كامل لميزات التطبيق، يجب عليك إنشاء حساب. عند التسجيل، توافق على:

1. تقديم معلومات دقيقة وصحيحة ومحدثة
2. الحفاظ على أمان حسابك وكلمة المرور الخاصة بك
3. إخطارنا فوراً بأي استخدام غير مصرح به لحسابك
4. أنك مسؤول عن جميع الأنشطة التي تحدث تحت حسابك
5. أنك لن تشارك بيانات حسابك مع أي شخص آخر

نحتفظ بالحق في رفض أو تعليق أي حساب يخالف هذه الشروط أو يبدو أنه ينطوي على نشاط احتيالي أو غير قانوني.
'''),

                // User Conduct
                _buildSection(context, colorScheme, 'سلوك المستخدم', '''
عند استخدام تطبيق Velora، يجب عليك:

**السلوكيات المسموحة:**
- استخدام التطبيق لأغراض قانونية ومشروعة فقط
- احترام حقوق المستخدمين الآخرين
- الحفاظ على المعلومات الشخصية آمنة ومحمية
- الإبلاغ عن أي مشاكل أو انتهاكات تشاهدها

**السلوكيات المحظورة:**
- استخدام التطبيق بأي طريقة تخالف القوانين أو اللوائح المحلية أو الدولية
- محاولة الوصول غير المصرح به إلى أنظمة التطبيق أو حسابات المستخدمين الآخرين
- نشر أو مشاركة محتوى غير قانوني أو ضار أو مسيء أو خادش للحياء
- استخدام التطبيق لنشر برامج ضارة أو فيروسات أو أي كود ضار
- محاولة تعطيل أو إتلاف أو اختراق التطبيق أو الخوادم المرتبطة به
- إنشاء حسابات متعددة بهدف الاحتيال أو إساءة الاستخدام
- استخدام التطبيق للمضايقة أو التهديد أو التنمر ضد أي مستخدم آخر
- نشر معلومات كاذبة أو مضللة

أي انتهاك لهذه القواعد قد يؤدي إلى إنهاء حسابك فوراً وبدون إشعار، وقد نتابع الإجراءات القانونية المناسبة.
'''),

                // Content and Intellectual Property
                _buildSection(
                  context,
                  colorScheme,
                  'المحتوى والملكية الفكرية',
                  '''
**محتوى التطبيق:**
جميع المحتوى الموجود في تطبيق Velora، بما في ذلك النصوص والصور والفيديوهات والتصاميم والشعارات والعلامات التجارية، محمي بحقوق الطبع والنشر والملكية الفكرية.

**حقوق المستخدم:**
1. يحق لك استخدام المحتوى المتاح في التطبيق للأغراض الشخصية وغير التجارية فقط
2. لا يحق لك نسخ أو تعديل أو توزيع أو بيع أي محتوى من التطبيق دون إذن كتابي منا
3. لا يحق لك استخدام محتوى التطبيق لإنشاء منتجات أو خدمات تنافسية

**محتوى المستخدم:**
عند رفع أو مشاركة أي محتوى (مثل الصور أو التعليقات أو المراجعات) في التطبيق، فإنك:
1. تمنحنا ترخيصاً غير حصري ودولياً لاستخدام هذا المحتوى في التطبيق
2. تضمن أن لديك جميع الحقوق اللازمة لمنحنا هذا الترخيص
3. توافق على أن المحتوى الخاص بك لا ينتهك حقوق أي طرف ثالث

نحتفظ بالحق في إزالة أي محتوى نعتقد أنه ينتهك هذه الشروط أو يخالف القانون.
''',
                ),

                // Privacy and Data
                _buildSection(
                  context,
                  colorScheme,
                  'الخصوصية وحماية البيانات',
                  '''
نحن ملتزمون بحماية خصوصيتك وبياناتك الشخصية. لمعرفة المزيد حول كيفية جمعنا واستخدامنا وحمايتنا لبياناتك، يُرجى مراجعة سياسة الخصوصية الخاصة بنا.

**البيانات التي نجمعها:**
- المعلومات الشخصية (الاسم، البريد الإلكتروني، رقم الهاتف)
- معلومات الحساب (اسم المستخدم، كلمة المرور)
- معلومات الاستخدام (المسارات التي استكشفتها، الأماكن التي زرتتها)
- معلومات الجهاز (نوع الجهاز، نظام التشغيل، عنوان IP)

**كيفية استخدام البيانات:**
- تحسين خدمات التطبيق وتجربة المستخدم
- التواصل معك حول تحديثات التطبيق أو الخدمات
- تلبية المتطلبات القانونية والتنظيمية
- منع الاحتيال وإساءة الاستخدام

**حماية البيانات:**
نستخدم تدابير أمنية متقدمة لحماية بياناتك من الوصول غير المصرح به أو التغيير أو الإفصاح أو التدمير.
''',
                ),

                // Payments and Refunds
                _buildSection(context, colorScheme, 'المدفوعات والاسترداد', '''
**الاشتراكات والمدفوعات:**
إذا كان التطبيق يقدم خدمات مدفوعة أو اشتراكات:
1. جميع الأسعار معروضة بالعملة المحلية وقد تتغير دون إشعار مسبق
2. المدفوعات تتم من خلال مزودي دفع آمنين ومعتمدين
3. أنت مسؤول عن دفع جميع الرسوم والضرائب المطبقة

**الاسترداد:**
- تُحكم سياسات الاسترداد بموجب قوانين حماية المستهلك المحلية
- بعض الخدمات قد لا تكون قابلة للاسترداد
- يُرجى التواصل معنا في غضون فترة زمنية معقولة من الشراء لطلب الاسترداد

**الإلغاء:**
يمكنك إلغاء اشتراكك في أي وقت من خلال إعدادات الحساب.
'''),

                // Disclaimers
                _buildSection(context, colorScheme, 'إخلاء المسؤولية', '''
**ضمان الخدمة:**
يوفر تطبيق Velora خدماته "كما هي" و"كما هي متاحة". لا نقدم أي ضمانات صريحة أو ضمنية فيما يتعلق بـ:
- دقة أو اكتمال المعلومات المقدمة
- عدم انقطاع الخدمة أو خلوها من الأخطاء
- أمان البيانات أو الخدمات
- ملاءمة التطبيق لأي غرض محدد

**المسؤولية:**
في أقصى حد يسمح به القانون:
1. لن نكون مسؤولين عن أي أضرار مباشرة أو غير مباشرة أو عرضية أو خاصة ناتجة عن استخدام أو عدم القدرة على استخدام التطبيق
2. لن نكون مسؤولين عن فقدان البيانات أو الأرباح أو الإيرادات أو السمعة التجارية
3. لن نكون مسؤولين عن أي أضرار ناتجة عن الاعتماد على المعلومات المقدمة في التطبيق

**المسارات والمواقع:**
المعلومات حول المسارات السياحية والأماكن المقدمة في التطبيق هي لأغراض إرشادية فقط. نحن لسنا مسؤولين عن:
- أي تغييرات في حالة أو إمكانية الوصول إلى المسارات أو المواقع
- أي حوادث أو إصابات قد تحدث أثناء استخدام المسارات
- دقة المعلومات المقدمة من قبل المستخدمين الآخرين

**التوصيات:**
ننصح المستخدمين بالحصول على معلومات محدثة من المصادر الرسمية واتخاذ جميع احتياطات السلامة اللازمة عند استكشاف المسارات.
'''),

                // Limitation of Liability
                _buildSection(context, colorScheme, 'حدود المسؤولية', '''
لا تتحمل Velora أو موظفوها أو ممثلوها أو الشركاء أو الموردون المسؤولية عن:

1. أي خسائر أو أضرار ناتجة عن استخدام أو عدم القدرة على استخدام التطبيق
2. أي أضرار ناتجة عن الأخطاء أو الأخطاء أو عدم الدقة في المحتوى
3. أي أضرار ناتجة عن انقطاع الخدمة أو فشل النظام
4. أي أضرار ناتجة عن الهجمات الإلكترونية أو اختراق البيانات
5. أي أضرار ناتجة عن فقدان أو سرقة البيانات الشخصية

يجب على المستخدمين اتخاذ احتياطاتهم الخاصة لحماية بياناتهم وأجهزتهم.
'''),

                // Indemnification
                _buildSection(context, colorScheme, 'التعويض', '''
أنت توافق على تعويض وحماية Velora وموظفيها ومديريها وممثليها من أي مطالبات أو خسائر أو التزامات أو نفقات (بما في ذلك الرسوم القانونية) الناتجة عن:

1. استخدامك للتطبيق أو انتهاكك لهذه الشروط
2. انتهاكك لأي حقوق طرف ثالث
3. محتوى تشاركه أو ترفعه في التطبيق
4. أي سلوك غير قانوني أو إساءة استخدام للتطبيق

نحتفظ بالحق في التحكم في الدفاع وتسوية أي مطالبات قد نكون مسؤولين عنها.
'''),

                // Termination
                _buildSection(context, colorScheme, 'الإنهاء', '''
**إنهاء حسابك:**
يمكنك إلغاء حسابك في أي وقت من خلال إعدادات الحساب. عند الإلغاء:
1. ستفقد الوصول الفوري إلى حسابك وجميع البيانات المرتبطة به
2. قد نحتفظ ببعض المعلومات لفترة محدودة للأغراض القانونية والتنظيمية
3. لن تكون قادراً على استعادة البيانات بعد الإلغاء

**إنهاء حسابك من قبلنا:**
نحتفظ بالحق في تعليق أو إنهاء حسابك فوراً وبدون إشعار مسبق في حالة:
- انتهاكك لأي من هذه الشروط والأحكام
- نشاط احتيالي أو غير قانوني
- الاستخدام غير المصرح به للحساب
- أي سبب آخر نعتقد أنه مبرر

**آثار الإنهاء:**
عند إنهاء حسابك، ستفقد الوصول إلى جميع الخدمات والبيانات المرتبطة بحسابك، وسنحذف جميع البيانات الشخصية وفقاً لسياسة الخصوصية الخاصة بنا.
'''),

                // Changes to Terms
                _buildSection(context, colorScheme, 'تعديلات الشروط', '''
نحتفظ بالحق في تعديل أو تحديث هذه الشروط والأحكام في أي وقت دون إشعار مسبق. التعديلات ستدخل حيز التنفيذ فور نشرها في التطبيق.

**إشعار التغييرات:**
- سنحاول إبلاغ المستخدمين بالتغييرات الجوهرية عند الإمكان
- يُنصح بمراجعة هذه الصفحة بانتظام للاطلاع على أي تحديثات
- استمرار استخدامك للتطبيق بعد نشر التعديلات يعني موافقتك على الشروط المحدثة

**رفض التغييرات:**
إذا كنت لا توافق على التعديلات، يجب عليك التوقف عن استخدام التطبيق وإلغاء حسابك.
'''),

                // Governing Law
                _buildSection(context, colorScheme, 'القانون الحاكم', '''
تُحكم هذه الشروط والأحكام وتُفسر وفقاً لقوانين دولة فلسطين، دون اعتبار لمبادئ تعارض القوانين.

**التسوية القانونية:**
أي نزاع ينشأ عن أو يتعلق بهذه الشروط سيتم حله من خلال:
1. التفاوض المباشر والحل الودي
2. إذا فشل التفاوض، عبر الوساطة
3. كملاذ أخير، عبر المحاكم المختصة في دولة فلسطين

**الاختصاص القضائي:**
أنت توافق على أن المحاكم في دولة فلسطين لديها الاختصاص الحصري للبت في أي نزاع يتعلق بهذه الشروط.
'''),

                // Contact Information
                _buildSection(context, colorScheme, 'معلومات التواصل', '''
إذا كان لديك أي أسئلة أو استفسارات حول هذه الشروط والأحكام، يُرجى التواصل معنا:

**البريد الإلكتروني:** support@velora.com
**الهاتف:** +970-XXX-XXXX
**العنوان:** فلسطين

سنحاول الرد على استفساراتك في أقرب وقت ممكن.

**ساعات العمل:**
الأحد - الخميس: 9:00 صباحاً - 5:00 مساءً
الجمعة والسبت: مغلق

**اللغة:**
توفر هذه الشروط باللغة العربية والإنجليزية. في حالة وجود أي تعارض، ستكون النسخة العربية هي الحاسمة.
'''),

                // Final Provisions
                _buildSection(context, colorScheme, 'أحكام نهائية', '''
**الاكتمال:**
تشكل هذه الشروط والأحكام الاتفاقية الكاملة بينك وبين Velora فيما يتعلق باستخدام التطبيق، وتحل محل جميع الاتفاقيات أو التفاهمات السابقة.

**القابلية للفصل:**
إذا تم اعتبار أي حكم من هذه الشروط غير قابل للتنفيذ أو غير قانوني، فسيتم تعديله أو حذفه إلى الحد الأدنى اللازم، وسيظل باقي الشروط ساري المفعول.

**التنازل:**
لا يُعتبر فشل Velora في إنفاذ أي حق أو حكم من هذه الشروط تنازلاً عن ذلك الحق.

**التفويض:**
لا يجوز لك نقل أو تفويض أي من حقوقك أو التزاماتك بموجب هذه الشروط دون موافقة خطية مسبقة من Velora.

**شروط إضافية:**
قد نقدم خدمات أو ميزات إضافية تخضع لشروط وأحكام إضافية. سيتم إخطارك بهذه الشروط الإضافية عند التسجيل لتلك الخدمات.
'''),

                SizedBox(height: context.xxl),

                // Acceptance Checkbox
                Container(
                  padding: EdgeInsets.all(context.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(context.adaptive(12)),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIcons.info,
                        color: AppColors.primary,
                        size: context.iconSize(),
                      ),
                      SizedBox(width: context.md),
                      Expanded(
                        child: Text(
                          'باستخدامك لتطبيق Velora، فإنك تقر بأنك قرأت وفهمت ووافقت على جميع الشروط والأحكام المذكورة أعلاه.',
                          style: TextStyle(
                            fontSize: context.fontSize(14),
                            color: colorScheme.onSurface.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
    String content,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: context.lg),
      padding: EdgeInsets.all(context.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(context.adaptive(12)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.adaptive(8)),
                ),
                child: Icon(
                  PhosphorIcons.file_text_fill,
                  color: AppColors.primary,
                  size: context.iconSize(),
                ),
              ),
              SizedBox(width: context.md),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: context.fontSize(18),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.md),
          Text(
            content.trim(),
            style: TextStyle(
              fontSize: context.fontSize(14),
              color: colorScheme.onSurface.withOpacity(0.9),
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
