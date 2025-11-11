// lib/core/localization/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static AppLocalizations ofOrThrow(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    if (localizations == null) {
      throw Exception('AppLocalizations not found in context');
    }
    return localizations;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App basics
      'app_name': 'Velora',
      'welcome': 'Welcome to Velora',
      'discover_palestine': 'Discover Palestine',
      'home': 'Home',
      'paths': 'Paths',
      'sites': 'Sites',
      'explore': 'Explore',
      'map': 'Map',
      'profile': 'Profile',

      // Home screen
      'featured_paths': 'Featured Paths',
      'featured_routes': 'Featured Routes',
      'featured_sites': 'Featured Sites',
      'best_routes_desc': 'Discover the best routes and camping spots',
      'best_sites_desc': 'Explore the most beautiful tourist sites',
      'suggested_adventures': 'Suggested Adventures',
      'search_placeholder': 'Search for a path or place...',
      'view_all': 'View All',
      'show_more': 'Show More',
      'show_less': 'Show Less',

      // Path details
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'hours': 'hours',
      'km': 'km',
      'start_journey': 'Start Journey',
      'description': 'Description',
      'available_activities': 'Available Activities',
      'guide': 'Guide',
      'trip_guide': 'Trip Guide',
      'warnings_and_tips': 'Warnings and Tips',
      'rating': 'Rating',
      'reviews': 'reviews',

      // Locations
      'north': 'North',
      'center': 'Center',
      'south': 'South',

      // Activities
      'hiking': 'Hiking',
      'camping': 'Camping',
      'climbing': 'Climbing',
      'religious': 'Religious',
      'cultural': 'Cultural',
      'nature': 'Nature',
      'archaeological': 'Archaeological',

      // Profile
      'my_trips': 'My Trips',
      'saved': 'Saved',
      'achievements': 'Achievements',
      'achievement_progress': 'Achievement Progress',
      'favorites': 'Favorites',
      'language': 'Language',
      'help_support': 'Help & Support',
      'about_app': 'About App',
      'logout': 'Logout',
      'completed_trips': 'Completed Trips',
      'saved_trips': 'Saved Trips',
      'settings': 'Settings',
      'paths_loading_error': 'Error loading paths',

      // Filter and search
      'filters': 'Filters',
      'activity_type': 'Activity Type',
      'difficulty_level': 'Difficulty Level',
      'location': 'Location',
      'clear_all': 'Clear All',
      'no_paths_available': 'No paths available',

      // Common actions
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'share': 'Share',
      'close': 'Close',
      'back': 'Back',
      'previous': 'Previous',
      'next': 'Next',
      'done': 'Done',
      'undo': 'Undo',
      'loading': 'Loading...',
      'creating_account': 'Creating account...',
      'error': 'Error',
      'success': 'Success',
      'send': 'Send',
      'rate': 'Rate',
      'send_new_link': 'Send New Link',
      'back_to_login': 'Back to Login',
      'apply_filters': 'Apply Filters',
      'apply': 'Apply',

      // Settings
      'notifications': 'Notifications',
      'dark_mode': 'Dark Mode',
      'map_type': 'Map Type',
      'temperature_unit': 'Temperature Unit',
      'location_services': 'Location Services',
      'enable_location_access': 'Allow access to your location',
      'search_history': 'Search History',
      'reset_settings': 'Reset Settings',
      'account': 'Account',
      'app_settings': 'App Settings',
      'support': 'Support',
      'arabic': 'Arabic',
      'english': 'English',
      'enable_notifications': 'Enable/Disable Notifications',
      'enable_dark_mode': 'Enable/Disable Dark Mode',
      'choose_map_type': 'Choose your preferred map type',
      'change_temperature_unit': 'Change temperature measurement unit',
      'celsius': 'Celsius (°C)',
      'fahrenheit': 'Fahrenheit (°F)',
      'standard': 'Standard',
      'satellite': 'Satellite',
      'terrain': 'Terrain',
      'help_and_faq': 'Help & FAQ',
      'get_help_using_app': 'Get help on using the app',
      'report_issue': 'Report an Issue',
      'send_report_about_problem':
          'Send a report about a problem you\'re facing',
      'version': 'Version',
      'app_info': 'App info and version',
      'inquiry_subject': 'Inquiry About Velora App',
      'inquiry_body': 'Hello, I have an inquiry about the Velora app...\n',

      // Authentication
      'login': 'Login',
      'register': 'Register',
      'create_new_account': 'Create New Account',
      'account_created_failed': 'Failed to create account',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'forgot_password': 'Forgot Password?',
      'remember_me': 'Remember Me',
      'login_as_guest': 'Login as Guest',
      'create_account': 'Create Account',
      'already_have_account': 'Already have an account?',
      'dont_have_account': 'Don\'t have an account?',
      'remember_password': 'Remember your password?',
      'welcome_back': 'Welcome back',
      'enter_details_to_continue': 'Enter your details to continue',
      'enter_your_email': 'Enter your email',
      'enter_password': 'Enter your password',
      'login_as_guest_view_only': 'Login as Guest (View Only)',
      'personal_information': 'Personal Information',
      'account_information': 'Account Information',
      'confirmation': 'Confirmation',
      'enter_personal_info': 'Enter personal information',
      'enter_full_name': 'Enter your full name',
      'phone_number_optional': 'Phone Number (Optional)',
      'enter_phone_number': 'Enter your phone number',
      'enter_account_info': 'Enter account information',
      're_enter_password': 'Re-enter your password',
      'weak': 'Weak',
      'strong': 'Strong',
      'very_strong': 'Very Strong',
      'verify_info_and_complete':
          'Verify information and complete registration',
      'not_specified': 'Not specified',
      'i_agree_to': 'I agree to',
      'must_agree_to_terms':
          'You must agree to the Terms of Use and Privacy Policy',
      'please_complete_required_fields': 'Please complete all required fields',
      'password_too_weak':
          'Password is too weak, please choose a stronger password',
      'and': 'and',

      // Onboarding
      'explore_palestine_title': 'Explore Palestine',
      'explore_palestine_desc':
          'Discover the most beautiful routes and tourist areas in Palestine, in an easy and simple way.',
      'diverse_paths_title': 'Diverse Paths',
      'diverse_paths_desc':
          'A variety of paths suitable for all levels and interests, from simple walking to difficult climbing.',
      'plan_trip_title': 'Plan Your Trip',
      'plan_trip_desc':
          'Save your favorite routes, view path details and coordinates, and share your experiences with others.',
      'get_started': 'Get Started',
      'skip': 'Skip',

      // Errors and validation
      'email_required': 'Email is required',
      'invalid_email': 'Invalid email',
      'enter_email': 'Enter your email',
      'password_required': 'Password is required',
      'password_too_short': 'Password must be at least 6 characters',
      'name_required': 'Name is required',
      'name_too_short': 'Name must be at least 3 characters',
      'phone_required': 'Phone number is required',
      'invalid_phone': 'Invalid phone number',
      'passwords_dont_match': 'Passwords don\'t match',
      'login_failed': 'Login failed',
      'email_not_verified': 'Email not verified',
      'verify_email_title': 'Verify your email',
      'check_email_and_confirm':
          'Check your inbox and tap the verification link to activate your account.',
      'open_email_and_verify':
          'Open your email inbox, tap the verification link, then return to the app to sign in.',
      'resend_verification_link': 'Resend verification email',
      'verification_email_sent': 'Verification link sent',
      'verification_email_already_verified': 'Email already verified',
      'verification_email_user_not_found': 'No account found with this email',
      'go_to_login': 'Go to login',
      'registration_failed': 'Registration failed',
      'logout_failed': 'Logout failed',
      'network_error': 'Network error',
      'something_went_wrong': 'Something went wrong',

      // Success messages
      'login_successful': 'Login successful',
      'login_welcome_message': 'Welcome! You have logged in successfully',
      'registration_successful': 'Registration successful',
      'registration_welcome_message':
          'Account created successfully! Welcome to Velora',
      'profile_updated': 'Profile updated successfully',
      'path_saved': 'Path saved',
      'path_removed': 'Path removed from saved',
      'guest_login_welcome': 'Welcome as a guest! You can only view paths',
      'guest_login_failed': 'Failed to login as guest, please try again',
      'password_reset_sent': 'Password reset link has been sent to your email',
      'password_reset_loading': 'Sending link...',
      'password_reset_title': 'Forgot Password',
      'password_reset_description':
          'Don\'t worry! Enter your email and we\'ll send you a link to reset your password.',
      'password_reset_button': 'Send Reset Link',
      'password_reset_success_title': 'Link Sent!',
      'password_reset_check_email': 'Check your email to reset your password',
      'password_reset_spam_warning':
          'Check your inbox and spam folder. The link is valid for 24 hours.',
      'review_sent': 'Your review has been sent successfully!',

      // Map and location
      'your_location': 'Your Location',
      'path_start': 'Path Start',
      'path_end': 'Path End',
      'distance': 'Distance',
      'duration': 'Duration',
      'elevation': 'Elevation',
      'current_location': 'Current Location',
      'show_full_map': 'Show Full Map',

      // Time and date
      'today': 'Today',
      'yesterday': 'Yesterday',
      'days_ago': 'days ago',
      'weeks_ago': 'weeks ago',
      'months_ago': 'months ago',
      'just_now': 'Just now',
      'minutes_ago': 'minutes ago',
      'hours_ago': 'hours ago',

      // Stats and numbers
      'total_distance': 'Total Distance',
      'total_time': 'Total Time',
      'completed': 'Completed',
      'in_progress': 'In Progress',
      'not_started': 'Not Started',
      'difficulty_easy': 'Easy',
      'difficulty_medium': 'Medium',
      'difficulty_hard': 'Hard',

      // Trip Registration
      'register_for_trip': 'Register for Trip',
      'registration_info': 'Registration Information',
      'number_of_participants': 'Number of Participants',
      'number_of_people': 'Number of people (including yourself):',
      'additional_notes': 'Additional Notes',
      'notes_hint': 'You can add any notes or questions',
      'example_notes':
          'Example: I have children, are there suitable activities for them?',
      'important_note': 'Important Note',
      'reg_review_note':
          'Your request will be reviewed and you will be contacted within 24-48 hours to confirm registration and send trip details.',
      'submit_request': 'Submit Request',
      'submit': 'Submit',
      'retry': 'Retry',
      'submitting': 'Submitting...',
      'registration_success': 'Request sent successfully!',
      'reg_success_message':
          'Your request will be reviewed and you will be contacted soon via phone or email to confirm registration.',
      'trip_registrations': 'Trip Registrations',
      'registration_requests': 'Registration Requests',
      'registered_requests': 'registered requests',
      'registered_requests_count': '{count} registered request',
      'registered_requests_count_plural': '{count} registered requests',
      'registration_requests_for_path': 'Registration requests for {path}',
      'select_payment_method': 'Please select payment method',
      'send_error': 'An error occurred sending the request',
      'unexpected_error': 'An unexpected error occurred',

      // Payment
      'payment_method': 'Payment Method',
      'payment_summary': 'Payment Summary',
      'price_per_person': 'Price per person:',
      'total_amount': 'Total Amount:',
      'cash': 'Cash',
      'visa_card': 'Visa Card',
      'pay_cash': 'Pay: Cash',
      'pay_visa': 'Pay: Visa Card',
      'order_summary': 'Order Summary',
      'path_colon': 'Path:',

      // Visa Payment Screen
      'pay_with_visa': 'Pay with Visa',
      'card_number': 'Card Number',
      'card_number_placeholder': '1234 5678 9012 3456',
      'card_number_required': 'Please enter card number',
      'invalid_card_number': 'Invalid card number (must be 16 digits)',
      'card_holder_name': 'Card Holder Name',
      'card_holder_placeholder': 'John Doe',
      'card_holder_required': 'Please enter card holder name',
      'expiry_date': 'Expiry Date',
      'expiry_placeholder': 'MM/YY',
      'expiry_required': 'Required',
      'invalid_expiry': 'Invalid date',
      'cvv': 'CVV',
      'cvv_placeholder': '123',
      'cvv_required': 'Required',
      'cvv_invalid': 'Must be 3 digits',
      'zip_code': 'ZIP Code',
      'zip_placeholder': '12345',
      'zip_required': 'Please enter ZIP code',
      'payment_processing': 'Processing payment...',
      'confirm_payment': 'Confirm Payment',
      'secure_payment_note':
          'All payment information is secure and encrypted. We will not store your credit card information.',
      'payment_success': 'Payment successful!',

      // Journey Tracking
      'journey_started': 'Journey Started',
      'pause_journey': 'Pause Journey',
      'resume_journey': 'Resume Journey',
      'end_journey': 'End Journey',
      'journey_complete': 'Congratulations!',
      'journey_complete_message':
          'You have completed the journey successfully!',
      'trip_time': 'Trip Time:',
      'current_speed': 'Speed',
      'progress': 'Progress',
      'visited_checkpoints': 'Visited Checkpoints',
      'completion_percentage': '% complete',
      'share_trip': 'Share',
      'rate_trip': 'Rate',
      'how_was_experience': 'How was your experience?',
      'add_review': 'Add Review',
      'optional': '(Optional)',
      'journey_ended': 'Ended',

      // Stats
      'your_stats': 'Your Stats',
      'weekly_activity': 'Your Activity This Week',
      'no_trips_message': 'No completed trips',
      'start_first_trip': 'Start your first trip now!',
      'explore_paths': 'Explore Paths',

      // Guest Access
      'login_required': 'Login Required',
      'access_feature_desc':
          'To access this feature, you must login or create a new account.',
      'access_specific_feature_desc':
          'To access {feature}, you must login or create a new account.',
      'registered_account_features': 'Registered Account Features:',
      'save_favorite_paths': 'Save Favorite Paths',
      'track_completed_trips': 'Track Your Completed Trips',
      'collect_achievements': 'Collect Achievements and Badges',
      'share_experiences': 'Share Your Experiences',
      'access_all_features': 'Access All Features',
      'later': 'Later',
      'login_short': 'Login',
      'must_login_to_access': 'You must login to access this feature',
      'feature_not_available': 'This feature is not available in guest mode',
      'not_available': 'Not Available',
      'login_to_access': 'Login to access all features',

      // Errors
      'path_not_found': 'Path not found',
      'share_coming_soon': 'Share feature coming soon...',
      'update_error': 'Update error: {error}',
      'share_error': 'An error occurred while sharing: {error}',
      'no_coordinates': 'No coordinates for path',

      // Map
      'clear_filters': 'Clear Filters',
      'show_details': 'Show Details',

      // Reviews & Ratings
      'review_sent_successfully': 'Your review has been sent successfully!',
      'reviews_feature_coming_soon': 'Reviews feature coming soon...',
      'add_review_feature_coming_soon': 'Add review feature coming soon...',
      'request_details': 'Request Details',

      // Path Details
      'path_details': 'Path Details',
      'notes': 'Notes:',
      'status_label': 'Status:',
      'registration_date': 'Registration Date:',

      // Trip Status
      'trip_status_pending': 'Pending',
      'trip_status_approved': 'Approved',
      'trip_status_rejected': 'Rejected',
      'trip_status_cancelled': 'Cancelled',

      // Labels
      'name_label': 'Name',
      'phone_label': 'Phone',
      'email_label': 'Email',
      'number_of_participants_label': 'Number of Participants',
      'person': 'person',
      'persons': 'persons',

      // Settings dialogs
      'reset_settings_title': 'Reset Settings',
      'reset_settings_confirm':
          'Are you sure you want to reset all settings to default?',
      'reset_settings_success': 'Settings reset successfully',
      'logout_title': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      'cannot_open_link': 'Cannot open link',
      'cannot_open_email': 'Cannot open email app',
      'about_app_label': 'About App',
      'terms_conditions': 'Terms and Conditions',

      // Home & Explore
      'explore_now': 'Explore Now',
      'no_paths_empty': 'No paths available',
      'save_changes': 'Save Changes',

      // About App
      'about_app_title': 'Velora - Discover Palestine',
      'app_version': 'Version:',
      'about_app_description':
          'Velora is an app for exploring trails and tourist attractions in Palestine. The app aims to facilitate discovering beautiful and historical places in Palestine and provide detailed information about various trails.',
      'copyright': '©',
      'all_rights_reserved': 'Velora Team. All rights reserved.',
      'privacy_policy': 'Privacy Policy',

      // Profile
      'edit_profile': 'Edit Profile',
      'update_profile_info': 'Update personal info and profile picture',
      'change_password': 'Change Password',
      'update_password': 'Update your password',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'enter_current_password': 'Enter your current password',
      'enter_new_password': 'Enter your new password',
      'password_updated': 'Password updated successfully',
      'change_language': 'Change app language',

      // Greetings
      'good_morning': 'Good Morning',
      'good_day': 'Good Day',
      'good_evening': 'Good Evening',

      // Home
      'new_paths_message': 'You have a collection of new paths waiting for you',
      'trending_paths': 'Trending Paths',
      'discover_new_paths': 'Discover New Paths',
      'guest_user': 'Guest User',
      'palestine_waiting':
          'Palestine is waiting for you to discover its beauty',

      // Explore
      'filter_results': 'Filter Results',
      'paths_tab': 'Paths',
      'regions_tab': 'Regions',
      'activities_tab': 'Activities',
      'sites_tab': 'Tourist Sites',
      'routes_camping_tab': 'Paths & Camping', // المسارات هي الأساسية
      'no_sites_available': 'No tourist sites available',
      'no_routes_available': 'No routes or camping available',
      'region_north': 'Northern Region',
      'region_center': 'Central Region',
      'region_south': 'Southern Region',
      'search_paths_placeholder': 'Search for path, place or activity...',
      'paths_available': 'paths available',
      'path_available': 'path available',
      'try_changing_filters':
          'Try changing filters or search for something else',
      'filter_activity_type': 'Activity Type',
      'filter_difficulty_level': 'Difficulty Level',
      'region': 'Region',
      'region_prefix': 'Region',
      'saved_paths': 'Saved Paths',
      'no_saved_paths': 'No saved paths',
      'no_saved_paths_description':
          'Explore paths and save them for easy access later',
      'path_count_available': '{count} path available',
      'paths_count_available': '{count} paths available',

      // Search
      'search_placeholder_full': 'Search for paths, places, or activity types',
      'searching': 'Searching...',
      'no_search_results': 'No results found for "{query}"',
      'try_different_search': 'Try different words or other areas',

      // Journey Tracking
      'start_point': 'Start Point',
      'end_point': 'End Point',
      'final_destination': 'Final Destination',
      'path_info': 'Path {name}',
      'path_info_full':
          'Distance: {distance} km • Estimated time: {hours} hours',
      'start_journey_button': 'Start Journey',
      'resume': 'Resume',
      'pause': 'Pause',
      'end_journey_button': 'End Journey',
      'completion_percentage': '{percentage}% complete',
      'journey_congratulations': '🎉 Congratulations!',
      'journey_completed_success':
          'You have completed the journey successfully!',
      'path_label': 'Path:',
      'elapsed_time': 'Elapsed Time:',
      'distance_label': 'Distance:',
      'how_was_experience': 'How was your experience?',
      'add_comment_optional': 'Add a comment (optional)',
      'send_button': 'Send',
      'finish': 'Finish',
      'review_send_failed': 'Failed to send review',

      // Completed Trips
      'completed_trips_title': 'Completed Trips',
      'no_completed_trips': 'No completed trips',
      'start_first_trip_now': 'Start your first trip now!',
      'completed': 'Completed',
      'total_time': 'Total Time',
      'total_distance_label': 'Total Distance',
      'hours': 'hours',

      // Map
      'your_current_location': 'Your Current Location',
      'path_end': 'End of {path}',
      'loading_map': 'Loading map...',
      'filter_paths': 'Filter Paths',
      'difficulty_level_label': 'Difficulty Level',
      'activity_type_label': 'Activity Type',
      'map_initialization_error': 'Map initialization error',

      // Path Details
      'languages': 'Languages',
      'phone_label': 'Phone',
      'route_price': 'Route Price',
      'ils': 'ILS',
      'shekel': 'Shekel',
      'name_label': 'Name',
      'phone': 'Phone',
      'email': 'Email',
      'registration_date_label': 'Registration Date',
      'status_label': 'Status:',
      'close': 'Close',
      'undo': 'Undo',
      'path_saved_message': 'Path saved',
      'path_removed_message': 'Path removed from saved',

      // Achievements
      'achievements_title': 'Achievements',
      'completed_achievements': 'Completed Achievements',
      'keep_exploring': 'Keep exploring to earn more!',
      'paths_category': 'Paths',
      'regions_category': 'Regions',
      'contributions_category': 'Contributions',
      'challenges_category': 'Challenges',
      'special_category': 'Special',
      'beginner_explorer': 'Beginner Explorer',
      'beginner_explorer_desc': 'Complete 5 different paths',
      'intermediate_explorer': 'Intermediate Explorer',
      'intermediate_explorer_desc': 'Complete 15 different paths',
      'advanced_explorer': 'Advanced Explorer',
      'advanced_explorer_desc': 'Complete 30 different paths',
      'north_explorer': 'North Explorer',
      'north_explorer_desc': 'Visit 5 different paths in northern Palestine',
      'center_explorer': 'Center Explorer',
      'center_explorer_desc': 'Visit 5 different paths in central Palestine',
      'south_explorer': 'South Explorer',
      'south_explorer_desc': 'Visit 5 different paths in southern Palestine',
      'active_contributor': 'Active Contributor',
      'active_contributor_desc': 'Add 3 reviews for different paths',
      'path_photographer': 'Path Photographer',
      'path_photographer_desc': 'Share 5 photos for different paths',
      'height_lover': 'Height Lover',
      'height_lover_desc': 'Complete 3 paths with high difficulty',
      'night_traveler': 'Night Traveler',
      'night_traveler_desc': 'Participate in a night camping trip',
      'archaeology_enthusiast': 'Archaeology Enthusiast',
      'archaeology_enthusiast_desc': 'Visit 4 different archaeological sites',
      'dead_sea_explorer': 'Dead Sea Explorer',
      'dead_sea_explorer_desc': 'Experience floating in the Dead Sea',
      'heritage_lover': 'Heritage Lover',
      'heritage_lover_desc': 'Visit 3 Palestinian World Heritage sites',
      'desert_adventurer': 'Desert Adventurer',
      'desert_adventurer_desc': 'Spend a full night in a desert camp',
    },
    'ar': {
      // App basics
      'app_name': 'Velora',
      'welcome': 'مرحباً في Velora',
      'discover_palestine': 'اكتشف فلسطين',
      'home': 'الرئيسية',
      'paths': 'المسارات',
      'sites': 'المواقع',
      'explore': 'استكشف',
      'map': 'الخريطة',
      'profile': 'الملف',

      // Home screen
      'featured_paths': 'مسارات مميزة',
      'featured_routes': 'أبرز المسارات',
      'featured_sites': 'أبرز المواقع',
      'best_routes_desc': 'اكتشف أفضل المسارات والتخييمات',
      'best_sites_desc': 'استكشف أجمل الأماكن السياحية',
      'suggested_adventures': 'مغامرات مقترحة',
      'search_placeholder': 'ابحث عن مسار أو مكان...',
      'view_all': 'عرض الكل',
      'show_more': 'عرض المزيد',
      'show_less': 'عرض أقل',

      // Path details
      'easy': 'سهل',
      'medium': 'متوسط',
      'hard': 'صعب',
      'hours': 'ساعات',
      'km': 'كم',
      'start_journey': 'ابدأ الرحلة',
      'description': 'الوصف',
      'available_activities': 'الأنشطة المتاحة',
      'guide': 'دليل',
      'trip_guide': 'دليل الرحلة',
      'warnings_and_tips': 'تحذيرات وإرشادات',
      'rating': 'التقييم',
      'reviews': 'تقييمات',

      // Locations
      'north': 'الشمال',
      'center': 'الوسط',
      'south': 'الجنوب',

      // Activities
      'hiking': 'المشي',
      'camping': 'التخييم',
      'climbing': 'التسلق',
      'religious': 'ديني',
      'cultural': 'ثقافي',
      'nature': 'طبيعة',
      'archaeological': 'أثري',

      // Profile
      'my_trips': 'رحلاتي',
      'saved': 'المحفوظات',
      'achievements': 'الإنجازات',
      'achievement_progress': 'تقدم الإنجازات',
      'favorites': 'المفضلة',
      'language': 'اللغة',
      'help_support': 'المساعدة والدعم',
      'about_app': 'عن التطبيق',
      'logout': 'تسجيل الخروج',
      'completed_trips': 'رحلات مكتملة',
      'saved_trips': 'رحلات محفوظة',
      'settings': 'الإعدادات',
      'paths_loading_error': 'خطأ في تحميل المسارات',

      // Filter and search
      'filters': 'الفلاتر',
      'activity_type': 'نوع النشاط',
      'difficulty_level': 'مستوى الصعوبة',
      'location': 'الموقع',
      'clear_all': 'مسح الكل',
      'no_paths_available': 'لا توجد مسارات متاحة',

      // Common actions
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'share': 'مشاركة',
      'close': 'إغلاق',
      'back': 'رجوع',
      'previous': 'السابق',
      'next': 'التالي',
      'done': 'تم',
      'undo': 'تراجع',
      'loading': 'جاري التحميل...',
      'creating_account': 'جاري إنشاء الحساب...',
      'error': 'خطأ',
      'success': 'نجح',
      'send': 'إرسال',
      'rate': 'تقييم',
      'send_new_link': 'إرسال رابط جديد',
      'back_to_login': 'العودة لتسجيل الدخول',
      'apply_filters': 'تطبيق الفلترات',
      'apply': 'تطبيق',

      // Settings
      'notifications': 'الإشعارات',
      'dark_mode': 'الوضع الداكن',
      'map_type': 'نوع الخريطة',
      'temperature_unit': 'وحدة درجة الحرارة',
      'location_services': 'خدمات الموقع',
      'enable_location_access': 'السماح بالوصول إلى موقعك',
      'search_history': 'سجل البحث',
      'reset_settings': 'إعادة تعيين الإعدادات',
      'account': 'الحساب',
      'app_settings': 'إعدادات التطبيق',
      'support': 'الدعم',
      'arabic': 'العربية',
      'english': 'English',
      'enable_notifications': 'تفعيل/تعطيل الإشعارات',
      'enable_dark_mode': 'تفعيل/تعطيل الوضع الداكن',
      'choose_map_type': 'اختيار نوع الخريطة المفضل',
      'change_temperature_unit': 'تغيير وحدة قياس درجة الحرارة',
      'celsius': 'سيلسيوس (°C)',
      'fahrenheit': 'فهرنهايت (°F)',
      'standard': 'قياسية',
      'satellite': 'صناعية',
      'terrain': 'تضاريس',
      'help_and_faq': 'المساعدة والأسئلة الشائعة',
      'get_help_using_app': 'الحصول على مساعدة حول استخدام التطبيق',
      'report_issue': 'الإبلاغ عن مشكلة',
      'send_report_about_problem': 'إرسال تقرير عن مشكلة تواجهها',
      'version': 'الإصدار',
      'app_info': 'معلومات عن التطبيق والإصدار',
      'inquiry_subject': 'استفسار حول تطبيق Velora',
      'inquiry_body': 'مرحباً، لدي استفسار حول تطبيق Velora...\n',

      // Authentication
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'create_new_account': 'إنشاء حساب جديد',
      'account_created_failed': 'فشل إنشاء الحساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'full_name': 'الاسم الكامل',
      'phone_number': 'رقم الهاتف',
      'forgot_password': 'نسيت كلمة المرور؟',
      'remember_me': 'تذكرني',
      'login_as_guest': 'الدخول كضيف',
      'create_account': 'إنشاء حساب',
      'already_have_account': 'لديك حساب بالفعل؟',
      'dont_have_account': 'ليس لديك حساب؟',
      'remember_password': 'تذكرت كلمة المرور؟',
      'welcome_back': 'مرحباً بك مجدداً',
      'enter_details_to_continue': 'أدخل بياناتك للمتابعة',
      'enter_your_email': 'أدخل بريدك الإلكتروني',
      'enter_password': 'أدخل كلمة المرور',
      'login_as_guest_view_only': 'الدخول كضيف (مشاهدة فقط)',
      'personal_information': 'المعلومات الشخصية',
      'account_information': 'معلومات الحساب',
      'confirmation': 'التأكيد',
      'enter_personal_info': 'أدخل المعلومات الشخصية',
      'enter_full_name': 'أدخل اسمك الكامل',
      'phone_number_optional': 'رقم الهاتف (اختياري)',
      'enter_phone_number': 'أدخل رقم هاتفك',
      'enter_account_info': 'أدخل معلومات حسابك',
      're_enter_password': 'أعد إدخال كلمة المرور',
      'weak': 'ضعيفة',
      'strong': 'قوية',
      'very_strong': 'قوية جداً',
      'verify_info_and_complete': 'تحقق من المعلومات وأكمل التسجيل',
      'not_specified': 'غير محدد',
      'i_agree_to': 'أوافق على',
      'must_agree_to_terms': 'يجب الموافقة على شروط الاستخدام وسياسة الخصوصية',
      'please_complete_required_fields': 'الرجاء إكمال جميع الحقول المطلوبة',
      'password_too_weak':
          'كلمة المرور ضعيفة جداً، الرجاء اختيار كلمة مرور أقوى',
      'and': 'و',

      // Onboarding
      'explore_palestine_title': 'استكشف فلسطين',
      'explore_palestine_desc':
          'اكتشف أجمل المسارات والمناطق السياحية في فلسطين، بطريقة سهلة ومبسطة.',
      'diverse_paths_title': 'تنوع المسارات',
      'diverse_paths_desc':
          'مجموعة متنوعة من المسارات المناسبة لجميع المستويات والاهتمامات، من المشي البسيط إلى التسلق الصعب.',
      'plan_trip_title': 'خطط رحلتك',
      'plan_trip_desc':
          'احفظ المسارات المفضلة لديك، واطلع على تفاصيل الطرق والإحداثيات، وشارك تجاربك مع الآخرين.',
      'get_started': 'ابدأ الآن',
      'skip': 'تخطي',

      // Errors and validation
      'email_required': 'البريد الإلكتروني مطلوب',
      'invalid_email': 'البريد الإلكتروني غير صالح',
      'enter_email': 'أدخل بريدك الإلكتروني',
      'password_required': 'كلمة المرور مطلوبة',
      'password_too_short': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      'name_required': 'الاسم مطلوب',
      'name_too_short': 'الاسم يجب أن يكون 3 أحرف على الأقل',
      'phone_required': 'رقم الهاتف مطلوب',
      'invalid_phone': 'رقم الهاتف غير صالح',
      'passwords_dont_match': 'كلمات المرور غير متطابقة',
      'login_failed': 'فشل تسجيل الدخول',
      'email_not_verified': 'البريد الإلكتروني غير مُفعل',
      'verify_email_title': 'تحقق من بريدك الإلكتروني',
      'check_email_and_confirm':
          'يرجى فتح بريدك الإلكتروني والضغط على رابط التفعيل لتفعيل حسابك.',
      'open_email_and_verify':
          'افتح بريدك الإلكتروني، اضغط على رابط التفعيل، ثم عُد للتطبيق لتسجيل الدخول.',
      'resend_verification_link': 'إعادة إرسال رسالة التحقق',
      'verification_email_sent': 'تم إرسال رابط التحقق',
      'verification_email_already_verified': 'البريد الإلكتروني مُفعل بالفعل',
      'verification_email_user_not_found': 'لا يوجد حساب مرتبط بهذا البريد',
      'go_to_login': 'الانتقال لتسجيل الدخول',
      'registration_failed': 'فشل التسجيل',
      'logout_failed': 'فشل تسجيل الخروج',
      'network_error': 'خطأ في الشبكة',
      'something_went_wrong': 'حدث خطأ ما',

      // Success messages
      'login_successful': 'تم تسجيل الدخول بنجاح',
      'login_welcome_message': 'مرحباً بك! تم تسجيل الدخول بنجاح',
      'registration_successful': 'تم التسجيل بنجاح',
      'registration_welcome_message':
          'تم إنشاء الحساب بنجاح! مرحباً بك في Velora',
      'profile_updated': 'تم تحديث الملف الشخصي بنجاح',
      'path_saved': 'تم حفظ المسار',
      'path_removed': 'تم إزالة المسار من المحفوظات',
      'guest_login_welcome': 'مرحباً بك كضيف! يمكنك مشاهدة المسارات فقط',
      'guest_login_failed': 'فشل تسجيل الدخول كضيف، حاول مرة أخرى',
      'password_reset_sent':
          'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      'password_reset_loading': 'جاري إرسال الرابط...',
      'password_reset_title': 'نسيت كلمة المرور',
      'password_reset_description':
          'لا تقلق! أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.',
      'password_reset_button': 'إرسال رابط إعادة التعيين',
      'password_reset_success_title': 'تم إرسال الرابط!',
      'password_reset_check_email':
          'تحقق من بريدك الإلكتروني لإعادة تعيين كلمة المرور',
      'password_reset_spam_warning':
          'تحقق من صندوق البريد الوارد والبريد المزعج. الرابط صالح لمدة 24 ساعة.',
      'review_sent': 'تم إرسال تقييمك بنجاح!',

      // Map and location
      'your_location': 'موقعك الحالي',
      'path_start': 'بداية المسار',
      'path_end': 'نهاية المسار',
      'distance': 'المسافة',
      'duration': 'المدة',
      'elevation': 'الارتفاع',
      'current_location': 'الموقع الحالي',
      'show_full_map': 'عرض الخريطة بشكل كامل',

      // Time and date
      'today': 'اليوم',
      'yesterday': 'أمس',
      'days_ago': 'أيام مضت',
      'weeks_ago': 'أسابيع مضت',
      'months_ago': 'أشهر مضت',
      'just_now': 'الآن',
      'minutes_ago': 'دقائق مضت',
      'hours_ago': 'ساعات مضت',

      // Stats and numbers
      'total_distance': 'إجمالي المسافة',
      'total_time': 'إجمالي الوقت',
      'completed': 'مكتمل',
      'in_progress': 'قيد التنفيذ',
      'not_started': 'لم يبدأ',
      'difficulty_easy': 'سهل',
      'difficulty_medium': 'متوسط',
      'difficulty_hard': 'صعب',

      // Trip Registration
      'register_for_trip': 'تسجيل في الرحلة',
      'registration_info': 'معلومات التسجيل',
      'number_of_participants': 'عدد المشاركين',
      'number_of_people': 'عدد الأشخاص (بما فيك أنت):',
      'additional_notes': 'ملاحظات إضافية',
      'notes_hint': 'يمكنك إضافة أي ملاحظات أو استفسارات',
      'example_notes': 'مثال: لدي أطفال، هل يوجد أنشطة مناسبة لهم؟',
      'important_note': 'ملاحظة هامة',
      'reg_review_note':
          'سيتم مراجعة طلبك والتواصل معك خلال 24-48 ساعة لتأكيد التسجيل وإرسال تفاصيل الرحلة.',
      'submit_request': 'إرسال الطلب',
      'submit': 'إرسال',
      'retry': 'إعادة المحاولة',
      'submitting': 'جاري الإرسال...',
      'registration_success': 'تم إرسال طلبك بنجاح!',
      'reg_success_message':
          'سيتم مراجعة طلبك والتواصل معك قريباً عبر رقم الهاتف أو البريد الإلكتروني لتأكيد التسجيل.',
      'trip_registrations': 'طلبات التسجيل',
      'registration_requests': 'طلبات التسجيل',
      'registered_requests': 'طلب مسجل',
      'registered_requests_count': '{count} طلب مسجل',
      'registered_requests_count_plural': '{count} طلب مسجل',
      'registration_requests_for_path': 'طلبات التسجيل على {path}',
      'select_payment_method': 'الرجاء اختيار طريقة الدفع',
      'send_error': 'حدث خطأ في إرسال الطلب',
      'unexpected_error': 'حدث خطأ غير متوقع',

      // Payment
      'payment_method': 'طريقة الدفع',
      'payment_summary': 'ملخص السعر',
      'price_per_person': 'السعر للشخص الواحد:',
      'total_amount': 'المبلغ الإجمالي:',
      'cash': 'نقدي',
      'visa_card': 'بطاقة فيزا',
      'pay_cash': 'الدفع: نقدي',
      'pay_visa': 'الدفع: بطاقة فيزا',

      // Visa Payment Screen
      'pay_with_visa': 'الدفع ببطاقة فيزا',
      'card_number': 'رقم البطاقة',
      'card_number_placeholder': '1234 5678 9012 3456',
      'card_number_required': 'الرجاء إدخال رقم البطاقة',
      'invalid_card_number': 'رقم البطاقة غير صحيح (يجب أن يكون 16 رقم)',
      'card_holder_name': 'اسم حامل البطاقة',
      'card_holder_placeholder': 'John Doe',
      'card_holder_required': 'الرجاء إدخال اسم حامل البطاقة',
      'expiry_date': 'تاريخ الانتهاء',
      'expiry_placeholder': 'MM/YY',
      'expiry_required': 'مطلوب',
      'invalid_expiry': 'تاريخ غير صحيح',
      'cvv': 'CVV',
      'cvv_placeholder': '123',
      'cvv_required': 'مطلوب',
      'cvv_invalid': 'يجب أن يكون 3 أرقام',
      'zip_code': 'الرمز البريدي',
      'zip_placeholder': '12345',
      'zip_required': 'الرجاء إدخال الرمز البريدي',
      'payment_processing': 'جاري معالجة الدفع...',
      'confirm_payment': 'تأكيد الدفع',
      'secure_payment_note':
          'جميع معلومات الدفع آمنة ومشفرة. لن نقوم بتخزين بيانات بطاقتك الائتمانية.',
      'payment_success': 'تم الدفع بنجاح!',

      // Journey Tracking
      'journey_started': 'بدأت الرحلة',
      'pause_journey': 'إيقاف مؤقت',
      'resume_journey': 'استئناف الرحلة',
      'end_journey': 'إنهاء الرحلة',
      'journey_complete': 'تهانينا!',
      'journey_complete_message': 'لقد أكملت الرحلة بنجاح!',
      'trip_time': 'الوقت المستغرق:',
      'current_speed': 'السرعة',
      'progress': 'التقدم',
      'visited_checkpoints': 'التقدم',
      'completion_percentage': 'مكتمل',
      'share_trip': 'مشاركة',
      'rate_trip': 'تقييم',
      'how_was_experience': 'كيف كانت تجربتك؟',
      'add_review': 'أضف تقييمك',
      'optional': '(اختياري)',
      'journey_ended': 'إنهاء',

      // Stats
      'your_stats': 'إحصائياتك',
      'weekly_activity': 'نشاطك هذا الأسبوع',
      'no_trips_message': 'لا توجد رحلات مكتملة',
      'start_first_trip': 'ابدأ برحلتك الأولى الآن!',
      'explore_paths': 'استكشف المسارات',

      // Guest Access
      'login_required': 'تسجيل الدخول مطلوب',
      'access_feature_desc':
          'للوصول إلى هذه الميزة، يجب عليك تسجيل الدخول أو إنشاء حساب جديد.',
      'access_specific_feature_desc':
          'للوصول إلى {feature}، يجب عليك تسجيل الدخول أو إنشاء حساب جديد.',
      'registered_account_features': 'مميزات الحساب المسجل:',
      'save_favorite_paths': 'حفظ المسارات المفضلة',
      'track_completed_trips': 'تتبع رحلاتك المكتملة',
      'collect_achievements': 'جمع الإنجازات والشارات',
      'share_experiences': 'مشاركة تجاربك مع الآخرين',
      'access_all_features': 'الوصول إلى جميع الميزات',
      'later': 'لاحقاً',
      'login_short': 'تسجيل',
      'must_login_to_access': 'يجب تسجيل الدخول للوصول إلى هذه الميزة',
      'feature_not_available': 'هذه الميزة غير متاحة في وضع الضيف',
      'not_available': 'غير متاح',
      'login_to_access': 'سجل دخولك للوصول إلى جميع الميزات',

      // Errors
      'path_not_found': 'لم يتم العثور على المسار',
      'share_coming_soon': 'ميزة المشاركة قريباً...',
      'update_error': 'خطأ في التحديث: {error}',
      'share_error': 'حدث خطأ في المشاركة: {error}',
      'no_coordinates': 'لا توجد إحداثيات للمسار',

      // Map
      'clear_filters': 'مسح الفلاتر',
      'show_details': 'عرض التفاصيل',

      // Reviews & Ratings
      'review_sent_successfully': 'تم إرسال تقييمك بنجاح!',
      'reviews_feature_coming_soon': 'ميزة التقييمات قريباً...',
      'add_review_feature_coming_soon': 'ميزة إضافة التقييم قريباً...',
      'request_details': 'تفاصيل الطلب',

      // Path Details
      'path_details': 'تفاصيل المسار',
      'notes': 'ملاحظات:',
      'status_label': 'الحالة:',
      'registration_date': 'تاريخ التسجيل:',

      // Trip Status
      'trip_status_pending': 'قيد المراجعة',
      'trip_status_approved': 'تم القبول',
      'trip_status_rejected': 'تم الرفض',
      'trip_status_cancelled': 'ملغي',

      // Labels
      'name_label': 'الاسم',
      'phone_label': 'الهاتف',
      'email_label': 'البريد',
      'number_of_participants_label': 'عدد المشاركين',
      'person': 'شخص',
      'persons': 'أشخاص',

      // Settings dialogs
      'reset_settings_title': 'إعادة تعيين الإعدادات',
      'reset_settings_confirm':
          'هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى الوضع الافتراضي؟',
      'reset_settings_success': 'تم إعادة تعيين الإعدادات',
      'logout_title': 'تسجيل الخروج',
      'logout_confirm': 'هل أنت متأكد من تسجيل الخروج؟',
      'cannot_open_link': 'لا يمكن فتح الرابط',
      'cannot_open_email': 'لا يمكن فتح تطبيق البريد الإلكتروني',
      'about_app_label': 'عن التطبيق',
      'terms_conditions': 'الشروط والأحكام',

      // Home & Explore
      'explore_now': 'استكشف الآن',
      'no_paths_empty': 'لا توجد مسارات متاحة',
      'save_changes': 'حفظ التغييرات',

      // About App
      'about_app_title': 'Velora - اكتشف فلسطين',
      'app_version': 'الإصدار:',
      'about_app_description':
          'Velora هو تطبيق لاستكشاف المسارات والأماكن السياحية في فلسطين. يهدف التطبيق إلى تسهيل عملية اكتشاف الأماكن الجميلة والتاريخية في فلسطين وتوفير معلومات مفصلة عن المسارات المختلفة.',
      'copyright': '©',
      'all_rights_reserved': 'Velora Team. جميع الحقوق محفوظة.',
      'privacy_policy': 'سياسة الخصوصية',

      // Profile
      'edit_profile': 'تعديل الملف الشخصي',
      'update_profile_info': 'تحديث المعلومات الشخصية وصورة الملف',
      'change_password': 'تغيير كلمة المرور',
      'update_password': 'تحديث كلمة المرور الخاصة بك',
      'current_password': 'كلمة المرور الحالية',
      'new_password': 'كلمة المرور الجديدة',
      'confirm_new_password': 'تأكيد كلمة المرور الجديدة',
      'enter_current_password': 'أدخل كلمة المرور الحالية',
      'enter_new_password': 'أدخل كلمة المرور الجديدة',
      'password_updated': 'تم تحديث كلمة المرور بنجاح',
      'change_language': 'تغيير لغة التطبيق',

      // Greetings
      'good_morning': 'صباح الخير',
      'good_day': 'نهارك سعيد',
      'good_evening': 'مساء الخير',

      // Home
      'new_paths_message': 'لديك مجموعة من المسارات الجديدة في انتظارك',
      'trending_paths': 'المسارات الشائعة',
      'discover_new_paths': 'اكتشف مسارات جديدة',
      'guest_user': 'مستخدم ضيف',
      'palestine_waiting': 'فلسطين تنتظرك لاستكشاف جمالها',

      // Explore
      'filter_results': 'تصفية النتائج',
      'paths_tab': 'المسارات',
      'regions_tab': 'المناطق',
      'activities_tab': 'الأنشطة',
      'sites_tab': 'الأماكن السياحية',
      'routes_camping_tab': 'المسارات والتخييم', // المسارات هي الأساسية
      'no_sites_available': 'لا توجد أماكن سياحية متاحة',
      'no_routes_available': 'لا توجد مسارات أو تخييمات متاحة',
      'region_north': 'منطقة الشمال',
      'region_center': 'منطقة الوسط',
      'region_south': 'منطقة الجنوب',
      'search_paths_placeholder': 'ابحث عن مسار، مكان أو نشاط...',
      'paths_available': 'مسار متوفر',
      'path_available': 'مسار متوفر',
      'try_changing_filters': 'جرب تغيير الفلترات أو البحث عن شيء آخر',
      'filter_activity_type': 'نوع النشاط',
      'filter_difficulty_level': 'مستوى الصعوبة',
      'region': 'المنطقة',
      'region_prefix': 'منطقة',
      'saved_paths': 'المسارات المحفوظة',
      'no_saved_paths': 'لا توجد مسارات محفوظة',
      'no_saved_paths_description':
          'استكشف المسارات واحفظها للوصول إليها بسهولة لاحقًا',
      'path_count_available': '{count} مسار متوفر',
      'paths_count_available': '{count} مسار متوفر',

      // Additional translations
      'please_provide_rating': 'الرجاء إعطاء تقييم',
      'path_removed_from_saved': 'تمت إزالة {path} من المسارات المحفوظة',

      // Search
      'search_placeholder_full': 'ابحث عن مسارات، أماكن، أو أنواع الأنشطة',
      'searching': 'جاري البحث...',
      'no_search_results': 'لا توجد نتائج لـ "{query}"',
      'try_different_search': 'حاول بكلمات مختلفة أو مناطق أخرى',

      // Journey Tracking
      'start_point': 'نقطة البداية',
      'end_point': 'نقطة النهاية',
      'final_destination': 'الوجهة النهائية',
      'path_info': 'مسار {name}',
      'path_info_full': 'المسافة: {distance} كم • الوقت المتوقع: {hours} ساعات',
      'start_journey_button': 'بدء الرحلة',
      'resume': 'استئناف',
      'pause': 'إيقاف مؤقت',
      'end_journey_button': 'إنهاء الرحلة',
      'completion_percentage': '{percentage}% مكتمل',
      'journey_congratulations': '🎉 تهانينا!',
      'journey_completed_success': 'لقد أكملت الرحلة بنجاح!',
      'path_label': 'المسار:',
      'elapsed_time': 'الوقت المستغرق:',
      'distance_label': 'المسافة:',
      'how_was_experience': 'كيف كانت تجربتك؟',
      'add_comment_optional': 'أضف تعليقًا (اختياري)',
      'send_button': 'إرسال',
      'finish': 'إنهاء',
      'review_send_failed': 'فشل إرسال التقييم',

      // Completed Trips
      'completed_trips_title': 'الرحلات المكتملة',
      'no_completed_trips': 'لا توجد رحلات مكتملة',
      'start_first_trip_now': 'ابدأ برحلتك الأولى الآن!',
      'completed': 'مكتملة',
      'total_time': 'إجمالي الوقت',
      'total_distance_label': 'إجمالي المسافة',
      'hours': 'ساعات',

      // Map
      'your_current_location': 'موقعك الحالي',
      'path_end': 'نهاية {path}',
      'loading_map': 'جاري تحميل الخريطة...',
      'filter_paths': 'فلتر المسارات',
      'difficulty_level_label': 'مستوى الصعوبة',
      'activity_type_label': 'نوع النشاط',
      'map_initialization_error': 'خطأ في تهيئة الخريطة',

      // Path Details
      'languages': 'اللغات',
      'phone_label': 'الهاتف',
      'route_price': 'سعر المسار',
      'ils': 'ILS',
      'shekel': 'شيكل',
      'name_label': 'الاسم',
      'phone': 'الهاتف',
      'email': 'البريد',
      'registration_date_label': 'تاريخ التسجيل',
      'status_label': 'الحالة:',
      'close': 'إغلاق',
      'undo': 'تراجع',
      'path_saved_message': 'تم حفظ المسار',
      'path_removed_message': 'تم إزالة المسار من المحفوظات',

      // Achievements
      'achievements_title': 'الإنجازات',
      'completed_achievements': 'الإنجازات المكتملة',
      'keep_exploring': 'استمر في الاستكشاف لكسب المزيد!',
      'paths_category': 'المسارات',
      'regions_category': 'المناطق',
      'contributions_category': 'المساهمات',
      'challenges_category': 'التحديات',
      'special_category': 'متميّزة',
      'beginner_explorer': 'مستكشف مبتدئ',
      'beginner_explorer_desc': 'أكمل 5 مسارات مختلفة',
      'intermediate_explorer': 'مستكشف متوسط',
      'intermediate_explorer_desc': 'أكمل 15 مسارًا مختلفًا',
      'advanced_explorer': 'مستكشف متقدم',
      'advanced_explorer_desc': 'أكمل 30 مسارًا مختلفًا',
      'north_explorer': 'مستكشف الشمال',
      'north_explorer_desc': 'زر 5 مسارات مختلفة في شمال فلسطين',
      'center_explorer': 'مستكشف الوسط',
      'center_explorer_desc': 'زر 5 مسارات مختلفة في وسط فلسطين',
      'south_explorer': 'مستكشف الجنوب',
      'south_explorer_desc': 'زر 5 مسارات مختلفة في جنوب فلسطين',
      'active_contributor': 'مساهم نشط',
      'active_contributor_desc': 'أضف 3 تقييمات لمسارات مختلفة',
      'path_photographer': 'مصور مسارات',
      'path_photographer_desc': 'شارك 5 صور لمسارات مختلفة',
      'height_lover': 'محبّ الارتفاعات',
      'height_lover_desc': 'أكمل 3 مسارات بدرجة صعوبة عالية',
      'night_traveler': 'مسافر ليلي',
      'night_traveler_desc': 'شارك في رحلة تخييم ليلية',
      'archaeology_enthusiast': 'هاوي الآثار',
      'archaeology_enthusiast_desc': 'زر 4 مواقع أثرية مختلفة',
      'dead_sea_explorer': 'مستكشف البحر الميت',
      'dead_sea_explorer_desc': 'تجربة الطفو في البحر الميت',
      'heritage_lover': 'عاشق التراث',
      'heritage_lover_desc': 'زيارة 3 مواقع تراث عالمي فلسطينية',
      'desert_adventurer': 'مغامر الصحراء',
      'desert_adventurer_desc': 'قضاء ليلة كاملة في مخيم صحراوي',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // إضافة دعم مباشر للنصوص
  String text(String key) => get(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
