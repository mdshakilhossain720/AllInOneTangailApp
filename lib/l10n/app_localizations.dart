import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Tangail All in One'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Everything Tangail, in one app'**
  String get appTagline;

  /// No description provided for @demo.
  ///
  /// In en, this message translates to:
  /// **'DEMO'**
  String get demo;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call now'**
  String get callNow;

  /// No description provided for @sms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get sms;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get grid;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @open24h.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get open24h;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @upazila.
  ///
  /// In en, this message translates to:
  /// **'Upazila'**
  String get upazila;

  /// No description provided for @selectUpazila.
  ///
  /// In en, this message translates to:
  /// **'Select upazila'**
  String get selectUpazila;

  /// No description provided for @allUpazilas.
  ///
  /// In en, this message translates to:
  /// **'All upazilas'**
  String get allUpazilas;

  /// No description provided for @comingSoonDemo.
  ///
  /// In en, this message translates to:
  /// **'This is a UI demo — no real action was taken.'**
  String get comingSoonDemo;

  /// No description provided for @callingDemo.
  ///
  /// In en, this message translates to:
  /// **'Calling {number}… (demo)'**
  String callingDemo(String number);

  /// No description provided for @smsDemo.
  ///
  /// In en, this message translates to:
  /// **'Opening SMS to {number}… (demo)'**
  String smsDemo(String number);

  /// No description provided for @mapsDemo.
  ///
  /// In en, this message translates to:
  /// **'Opening Maps… (demo)'**
  String get mapsDemo;

  /// No description provided for @sharedDemo.
  ///
  /// In en, this message translates to:
  /// **'Share sheet opened (demo)'**
  String get sharedDemo;

  /// No description provided for @callConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Call {name}?'**
  String callConfirmTitle(String name);

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHere;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @noResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or filter.'**
  String get noResultsHint;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get errorBody;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — showing saved data'**
  String get offlineBanner;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get backOnline;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get pullToRefresh;

  /// No description provided for @experienceYears.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs exp.'**
  String experienceYears(String years);

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String km(String value);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutesShort(String value);

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'{value} days'**
  String daysShort(String value);

  /// No description provided for @addedToSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get addedToSaved;

  /// No description provided for @removedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get removedFromSaved;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 11-digit number'**
  String get invalidPhone;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a time slot'**
  String get pickTime;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'All of Tangail in your pocket'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'Hospitals, doctors, transport, news and more — one app for every daily need.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Buy & sell local'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In en, this message translates to:
  /// **'From Tangail tant sarees to Porabarir chomchom — shop from local sellers.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'Help when it matters'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In en, this message translates to:
  /// **'One-tap SOS, ambulances, blood donors and police — always ready.'**
  String get onb3Body;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to continue'**
  String get loginSubtitle;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @termsNote.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms & Privacy Policy'**
  String get termsNote;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Demo: any 6 digits will work'**
  String get otpDemoHint;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendIn(String seconds);

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resend;

  /// No description provided for @otpResent.
  ///
  /// In en, this message translates to:
  /// **'A new code was sent (demo)'**
  String get otpResent;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you in Tangail?'**
  String get locationTitle;

  /// No description provided for @locationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll show services near you'**
  String get locationSubtitle;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useCurrentLocation;

  /// No description provided for @detectingLocation.
  ///
  /// In en, this message translates to:
  /// **'Detected: Tangail Sadar (demo)'**
  String get detectingLocation;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search services, products, places…'**
  String get searchHint;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get nextPrayer;

  /// No description provided for @startsIn.
  ///
  /// In en, this message translates to:
  /// **'starts in'**
  String get startsIn;

  /// No description provided for @bazarToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s bazar price'**
  String get bazarToday;

  /// No description provided for @flashSale.
  ///
  /// In en, this message translates to:
  /// **'Flash Sale'**
  String get flashSale;

  /// No description provided for @endsIn.
  ///
  /// In en, this message translates to:
  /// **'Ends in'**
  String get endsIn;

  /// No description provided for @madeInTangail.
  ///
  /// In en, this message translates to:
  /// **'Made in Tangail'**
  String get madeInTangail;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events'**
  String get upcomingEvents;

  /// No description provided for @latestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest news'**
  String get latestNews;

  /// No description provided for @weatherTangail.
  ///
  /// In en, this message translates to:
  /// **'Tangail'**
  String get weatherTangail;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity {value}%'**
  String humidity(String value);

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels {value}°'**
  String feelsLike(String value);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @weatherForecast.
  ///
  /// In en, this message translates to:
  /// **'5-day forecast (demo)'**
  String get weatherForecast;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @sosTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency help'**
  String get sosTitle;

  /// No description provided for @sosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to call. Long-press SOS for 2s to call 999 directly.'**
  String get sosSubtitle;

  /// No description provided for @nationalEmergency.
  ///
  /// In en, this message translates to:
  /// **'National Emergency'**
  String get nationalEmergency;

  /// No description provided for @ambulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulance;

  /// No description provided for @fireService.
  ///
  /// In en, this message translates to:
  /// **'Fire Service'**
  String get fireService;

  /// No description provided for @police.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get police;

  /// No description provided for @nearestHospital.
  ///
  /// In en, this message translates to:
  /// **'Nearest hospital'**
  String get nearestHospital;

  /// No description provided for @calling999.
  ///
  /// In en, this message translates to:
  /// **'Calling 999'**
  String get calling999;

  /// No description provided for @callingIn.
  ///
  /// In en, this message translates to:
  /// **'Calling in {seconds} seconds…'**
  String callingIn(String seconds);

  /// No description provided for @callCancelled.
  ///
  /// In en, this message translates to:
  /// **'Emergency call cancelled'**
  String get callCancelled;

  /// No description provided for @holdForSos.
  ///
  /// In en, this message translates to:
  /// **'Keep holding…'**
  String get holdForSos;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @trendingSearches.
  ///
  /// In en, this message translates to:
  /// **'Trending in Tangail'**
  String get trendingSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @voiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening… (demo)'**
  String get voiceListening;

  /// No description provided for @voiceHint.
  ///
  /// In en, this message translates to:
  /// **'Speak in Bangla or English'**
  String get voiceHint;

  /// No description provided for @resultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String resultsFor(String query);

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @places.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get places;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Tangail'**
  String get exploreTitle;

  /// No description provided for @exploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every local service in one place'**
  String get exploreSubtitle;

  /// No description provided for @secHealth.
  ///
  /// In en, this message translates to:
  /// **'Health & Emergency'**
  String get secHealth;

  /// No description provided for @secServices.
  ///
  /// In en, this message translates to:
  /// **'Legal & Government'**
  String get secServices;

  /// No description provided for @secTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel & Places'**
  String get secTravel;

  /// No description provided for @secDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily life'**
  String get secDaily;

  /// No description provided for @secCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get secCommunity;

  /// No description provided for @hospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get hospitals;

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @bloodDonors.
  ///
  /// In en, this message translates to:
  /// **'Blood Donors'**
  String get bloodDonors;

  /// No description provided for @govtOffices.
  ///
  /// In en, this message translates to:
  /// **'Govt Offices'**
  String get govtOffices;

  /// No description provided for @lawyers.
  ///
  /// In en, this message translates to:
  /// **'Lawyers'**
  String get lawyers;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business Directory'**
  String get business;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @tourism.
  ///
  /// In en, this message translates to:
  /// **'Tourist Places'**
  String get tourism;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @bazarPrice.
  ///
  /// In en, this message translates to:
  /// **'Bazar Price'**
  String get bazarPrice;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @beds.
  ///
  /// In en, this message translates to:
  /// **'{count} beds'**
  String beds(String count);

  /// No description provided for @emergencyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Emergency 24/7'**
  String get emergencyAvailable;

  /// No description provided for @departments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get departments;

  /// No description provided for @facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilities;

  /// No description provided for @doctorsHere.
  ///
  /// In en, this message translates to:
  /// **'Doctors at this hospital'**
  String get doctorsHere;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly schedule'**
  String get weeklySchedule;

  /// No description provided for @consultFee.
  ///
  /// In en, this message translates to:
  /// **'Consultation fee'**
  String get consultFee;

  /// No description provided for @serialCall.
  ///
  /// In en, this message translates to:
  /// **'Call for serial'**
  String get serialCall;

  /// No description provided for @chamber.
  ///
  /// In en, this message translates to:
  /// **'Chamber'**
  String get chamber;

  /// No description provided for @qualifications.
  ///
  /// In en, this message translates to:
  /// **'Qualifications'**
  String get qualifications;

  /// No description provided for @ac.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get ac;

  /// No description provided for @nonAc.
  ///
  /// In en, this message translates to:
  /// **'Non-AC'**
  String get nonAc;

  /// No description provided for @icu.
  ///
  /// In en, this message translates to:
  /// **'ICU'**
  String get icu;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get bloodGroup;

  /// No description provided for @lastDonated.
  ///
  /// In en, this message translates to:
  /// **'Last donated {when}'**
  String lastDonated(String when);

  /// No description provided for @registerDonor.
  ///
  /// In en, this message translates to:
  /// **'Register as donor'**
  String get registerDonor;

  /// No description provided for @requestBlood.
  ///
  /// In en, this message translates to:
  /// **'Request blood'**
  String get requestBlood;

  /// No description provided for @bagsNeeded.
  ///
  /// In en, this message translates to:
  /// **'Bags needed'**
  String get bagsNeeded;

  /// No description provided for @hospitalName.
  ///
  /// In en, this message translates to:
  /// **'Hospital name'**
  String get hospitalName;

  /// No description provided for @patientProblem.
  ///
  /// In en, this message translates to:
  /// **'Patient\'s condition'**
  String get patientProblem;

  /// No description provided for @neededBy.
  ///
  /// In en, this message translates to:
  /// **'Needed by'**
  String get neededBy;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @donorRegistered.
  ///
  /// In en, this message translates to:
  /// **'You\'re registered as a donor. Thank you!'**
  String get donorRegistered;

  /// No description provided for @bloodRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request posted to nearby donors (demo)'**
  String get bloodRequestSent;

  /// No description provided for @availableToDonate.
  ///
  /// In en, this message translates to:
  /// **'Available to donate'**
  String get availableToDonate;

  /// No description provided for @practiceArea.
  ///
  /// In en, this message translates to:
  /// **'Practice area'**
  String get practiceArea;

  /// No description provided for @court.
  ///
  /// In en, this message translates to:
  /// **'Court'**
  String get court;

  /// No description provided for @chamberHours.
  ///
  /// In en, this message translates to:
  /// **'Chamber hours'**
  String get chamberHours;

  /// No description provided for @bookConsultation.
  ///
  /// In en, this message translates to:
  /// **'Book consultation'**
  String get bookConsultation;

  /// No description provided for @consultationBooked.
  ///
  /// In en, this message translates to:
  /// **'Consultation requested for {when}'**
  String consultationBooked(String when);

  /// No description provided for @busRoutes.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get busRoutes;

  /// No description provided for @train.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get train;

  /// No description provided for @cngRent.
  ///
  /// In en, this message translates to:
  /// **'CNG & Rent-a-car'**
  String get cngRent;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @journeyDate.
  ///
  /// In en, this message translates to:
  /// **'Journey date'**
  String get journeyDate;

  /// No description provided for @searchBuses.
  ///
  /// In en, this message translates to:
  /// **'Search buses'**
  String get searchBuses;

  /// No description provided for @busesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} buses found'**
  String busesFound(String count);

  /// No description provided for @counter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'{count} seats left'**
  String seats(String count);

  /// No description provided for @bookSeat.
  ///
  /// In en, this message translates to:
  /// **'Book seat'**
  String get bookSeat;

  /// No description provided for @departure.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure;

  /// No description provided for @arrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrival;

  /// No description provided for @offDay.
  ///
  /// In en, this message translates to:
  /// **'Off day'**
  String get offDay;

  /// No description provided for @trainName.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get trainName;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get perDay;

  /// No description provided for @addBusiness.
  ///
  /// In en, this message translates to:
  /// **'Add your business'**
  String get addBusiness;

  /// No description provided for @stepBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get stepBasic;

  /// No description provided for @stepContact.
  ///
  /// In en, this message translates to:
  /// **'Contact & location'**
  String get stepContact;

  /// No description provided for @stepHours.
  ///
  /// In en, this message translates to:
  /// **'Hours & photos'**
  String get stepHours;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @openingTime.
  ///
  /// In en, this message translates to:
  /// **'Opening time'**
  String get openingTime;

  /// No description provided for @closingTime.
  ///
  /// In en, this message translates to:
  /// **'Closing time'**
  String get closingTime;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotos;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get pendingApproval;

  /// No description provided for @pendingApprovalBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Our team will verify your business within 24–48 hours. You\'ll get a notification once it\'s live.'**
  String get pendingApprovalBody;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get writeReview;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @college.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get college;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @coaching.
  ///
  /// In en, this message translates to:
  /// **'Coaching'**
  String get coaching;

  /// No description provided for @examResults.
  ///
  /// In en, this message translates to:
  /// **'Exam results'**
  String get examResults;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'{count} students'**
  String students(String count);

  /// No description provided for @established.
  ///
  /// In en, this message translates to:
  /// **'Est. {year}'**
  String established(String year);

  /// No description provided for @howToGo.
  ///
  /// In en, this message translates to:
  /// **'How to go'**
  String get howToGo;

  /// No description provided for @entryFee.
  ///
  /// In en, this message translates to:
  /// **'Entry fee'**
  String get entryFee;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get openingHours;

  /// No description provided for @latestJobs.
  ///
  /// In en, this message translates to:
  /// **'Latest jobs'**
  String get latestJobs;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline {date}'**
  String deadline(String date);

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply now'**
  String get applyNow;

  /// No description provided for @applicationSent.
  ///
  /// In en, this message translates to:
  /// **'Application sent to {company} (demo)'**
  String applicationSent(String company);

  /// No description provided for @coverNote.
  ///
  /// In en, this message translates to:
  /// **'Short cover note'**
  String get coverNote;

  /// No description provided for @attachCv.
  ///
  /// In en, this message translates to:
  /// **'Attach CV (PDF)'**
  String get attachCv;

  /// No description provided for @cvAttached.
  ///
  /// In en, this message translates to:
  /// **'my_cv.pdf attached'**
  String get cvAttached;

  /// No description provided for @jobType.
  ///
  /// In en, this message translates to:
  /// **'Job type'**
  String get jobType;

  /// No description provided for @fullTime.
  ///
  /// In en, this message translates to:
  /// **'Full-time'**
  String get fullTime;

  /// No description provided for @partTime.
  ///
  /// In en, this message translates to:
  /// **'Part-time'**
  String get partTime;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @sehri.
  ///
  /// In en, this message translates to:
  /// **'Sehri ends'**
  String get sehri;

  /// No description provided for @iftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get iftar;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @noticeBoard.
  ///
  /// In en, this message translates to:
  /// **'Notice board'**
  String get noticeBoard;

  /// No description provided for @lostFound.
  ///
  /// In en, this message translates to:
  /// **'Lost & Found'**
  String get lostFound;

  /// No description provided for @eventsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Events calendar'**
  String get eventsCalendar;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @postItem.
  ///
  /// In en, this message translates to:
  /// **'Post an item'**
  String get postItem;

  /// No description provided for @postPublished.
  ///
  /// In en, this message translates to:
  /// **'Your post is live (demo)'**
  String get postPublished;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @noEventsDay.
  ///
  /// In en, this message translates to:
  /// **'No events on this day'**
  String get noEventsDay;

  /// No description provided for @interested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get interested;

  /// No description provided for @markedInterested.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you before the event'**
  String get markedInterested;

  /// No description provided for @shopSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search sarees, sweets, electronics…'**
  String get shopSearchHint;

  /// No description provided for @catSaree.
  ///
  /// In en, this message translates to:
  /// **'Saree'**
  String get catSaree;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Sweets'**
  String get catFood;

  /// No description provided for @catFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get catFashion;

  /// No description provided for @catElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get catElectronics;

  /// No description provided for @catHome.
  ///
  /// In en, this message translates to:
  /// **'Home & Living'**
  String get catHome;

  /// No description provided for @catAgri.
  ///
  /// In en, this message translates to:
  /// **'Agriculture'**
  String get catAgri;

  /// No description provided for @catCraft.
  ///
  /// In en, this message translates to:
  /// **'Handicrafts'**
  String get catCraft;

  /// No description provided for @catBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get catBooks;

  /// No description provided for @topSellers.
  ///
  /// In en, this message translates to:
  /// **'Top sellers'**
  String get topSellers;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommended;

  /// No description provided for @recentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get recentlyViewed;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'{count} sold'**
  String sold(String count);

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'-{value}%'**
  String off(String value);

  /// No description provided for @sortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get sortPopular;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceHigh;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get priceRange;

  /// No description provided for @minRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum rating'**
  String get minRating;

  /// No description provided for @deliveryType.
  ///
  /// In en, this message translates to:
  /// **'Delivery type'**
  String get deliveryType;

  /// No description provided for @homeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Home delivery'**
  String get homeDelivery;

  /// No description provided for @localPickup.
  ///
  /// In en, this message translates to:
  /// **'Local pickup'**
  String get localPickup;

  /// No description provided for @inStockOnly.
  ///
  /// In en, this message translates to:
  /// **'In stock only'**
  String get inStockOnly;

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'Show {count} results'**
  String showResults(String count);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(String count);

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy now'**
  String get buyNow;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewCart;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock ({count} left)'**
  String inStock(String count);

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Only {count} left!'**
  String lowStock(String count);

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to {place}'**
  String deliverTo(String place);

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @estDelivery.
  ///
  /// In en, this message translates to:
  /// **'Est. {days} days'**
  String estDelivery(String days);

  /// No description provided for @pickupAvailable.
  ///
  /// In en, this message translates to:
  /// **'Local pickup available — free'**
  String get pickupAvailable;

  /// No description provided for @visitStore.
  ///
  /// In en, this message translates to:
  /// **'Visit store'**
  String get visitStore;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'{count} followers'**
  String followers(String count);

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @ratingsReviews.
  ///
  /// In en, this message translates to:
  /// **'Ratings & reviews'**
  String get ratingsReviews;

  /// No description provided for @photoReviews.
  ///
  /// In en, this message translates to:
  /// **'Photo reviews'**
  String get photoReviews;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions & answers'**
  String get questions;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a question'**
  String get askQuestion;

  /// No description provided for @questionPosted.
  ///
  /// In en, this message translates to:
  /// **'Question sent to seller (demo)'**
  String get questionPosted;

  /// No description provided for @similarProducts.
  ///
  /// In en, this message translates to:
  /// **'Similar products'**
  String get similarProducts;

  /// No description provided for @storeProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get storeProducts;

  /// No description provided for @storeInfo.
  ///
  /// In en, this message translates to:
  /// **'Store info'**
  String get storeInfo;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joined(String date);

  /// No description provided for @responseRate.
  ///
  /// In en, this message translates to:
  /// **'Response rate'**
  String get responseRate;

  /// No description provided for @shipOnTime.
  ///
  /// In en, this message translates to:
  /// **'Ships on time'**
  String get shipOnTime;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeMessage;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My cart'**
  String get myCart;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCart;

  /// No description provided for @emptyCartHint.
  ///
  /// In en, this message translates to:
  /// **'Browse Made in Tangail products and add your favourites.'**
  String get emptyCartHint;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get startShopping;

  /// No description provided for @voucherCode.
  ///
  /// In en, this message translates to:
  /// **'Voucher code'**
  String get voucherCode;

  /// No description provided for @voucherHint.
  ///
  /// In en, this message translates to:
  /// **'Try TANGAIL50'**
  String get voucherHint;

  /// No description provided for @voucherApplied.
  ///
  /// In en, this message translates to:
  /// **'Voucher applied: ৳50 off'**
  String get voucherApplied;

  /// No description provided for @voucherInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid voucher code'**
  String get voucherInvalid;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @voucher.
  ///
  /// In en, this message translates to:
  /// **'Voucher'**
  String get voucher;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkoutCount.
  ///
  /// In en, this message translates to:
  /// **'Checkout ({count})'**
  String checkoutCount(String count);

  /// No description provided for @itemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Item removed'**
  String get itemRemoved;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @stepAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get stepAddress;

  /// No description provided for @stepDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get stepDelivery;

  /// No description provided for @stepPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get stepPayment;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get addNewAddress;

  /// No description provided for @cod.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cod;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Credit / Debit card'**
  String get card;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed!'**
  String get orderPlaced;

  /// No description provided for @orderPlacedBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you for shopping local. You\'ll get updates as your order moves.'**
  String get orderPlacedBody;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrder;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get continueShopping;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrders;

  /// No description provided for @toPay.
  ///
  /// In en, this message translates to:
  /// **'To Pay'**
  String get toPay;

  /// No description provided for @toShip.
  ///
  /// In en, this message translates to:
  /// **'To Ship'**
  String get toShip;

  /// No description provided for @toReceive.
  ///
  /// In en, this message translates to:
  /// **'To Receive'**
  String get toReceive;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @returns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returns;

  /// No description provided for @orderDetail.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetail;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrder;

  /// No description provided for @cancelReason.
  ///
  /// In en, this message translates to:
  /// **'Why are you cancelling?'**
  String get cancelReason;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @returnRequest.
  ///
  /// In en, this message translates to:
  /// **'Return request'**
  String get returnRequest;

  /// No description provided for @returnSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Return request submitted'**
  String get returnSubmitted;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your review!'**
  String get reviewSubmitted;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get payNow;

  /// No description provided for @confirmReceived.
  ///
  /// In en, this message translates to:
  /// **'Confirm received'**
  String get confirmReceived;

  /// No description provided for @vouchersWallet.
  ///
  /// In en, this message translates to:
  /// **'Vouchers & coins'**
  String get vouchersWallet;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @coinsBalance.
  ///
  /// In en, this message translates to:
  /// **'Coin balance'**
  String get coinsBalance;

  /// No description provided for @myVouchers.
  ///
  /// In en, this message translates to:
  /// **'My vouchers'**
  String get myVouchers;

  /// No description provided for @collect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get collect;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @useNow.
  ///
  /// In en, this message translates to:
  /// **'Use now'**
  String get useNow;

  /// No description provided for @dailyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get dailyCheckIn;

  /// No description provided for @checkedIn.
  ///
  /// In en, this message translates to:
  /// **'+10 coins collected!'**
  String get checkedIn;

  /// No description provided for @minSpend.
  ///
  /// In en, this message translates to:
  /// **'Min. spend ৳{amount}'**
  String minSpend(String amount);

  /// No description provided for @validTill.
  ///
  /// In en, this message translates to:
  /// **'Valid till {date}'**
  String validTill(String date);

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @outOf5.
  ///
  /// In en, this message translates to:
  /// **'out of 5'**
  String get outOf5;

  /// No description provided for @becomeSeller.
  ///
  /// In en, this message translates to:
  /// **'Become a seller'**
  String get becomeSeller;

  /// No description provided for @sellerCenter.
  ///
  /// In en, this message translates to:
  /// **'Seller center'**
  String get sellerCenter;

  /// No description provided for @sellerOnbTitle.
  ///
  /// In en, this message translates to:
  /// **'Open your shop'**
  String get sellerOnbTitle;

  /// No description provided for @storeInfoStep.
  ///
  /// In en, this message translates to:
  /// **'Store info'**
  String get storeInfoStep;

  /// No description provided for @nidStep.
  ///
  /// In en, this message translates to:
  /// **'NID verification'**
  String get nidStep;

  /// No description provided for @payoutStep.
  ///
  /// In en, this message translates to:
  /// **'Payment account'**
  String get payoutStep;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeName;

  /// No description provided for @storeDescription.
  ///
  /// In en, this message translates to:
  /// **'About your store'**
  String get storeDescription;

  /// No description provided for @nidFront.
  ///
  /// In en, this message translates to:
  /// **'NID front side'**
  String get nidFront;

  /// No description provided for @nidBack.
  ///
  /// In en, this message translates to:
  /// **'NID back side'**
  String get nidBack;

  /// No description provided for @tapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get tapToUpload;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumber;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountType;

  /// No description provided for @sellerReady.
  ///
  /// In en, this message translates to:
  /// **'Your shop is ready!'**
  String get sellerReady;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @todaySales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s sales'**
  String get todaySales;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @salesThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Sales this week'**
  String get salesThisWeek;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent orders'**
  String get recentOrders;

  /// No description provided for @myProducts.
  ///
  /// In en, this message translates to:
  /// **'My products'**
  String get myProducts;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @variants.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get variants;

  /// No description provided for @addVariant.
  ///
  /// In en, this message translates to:
  /// **'Add variant'**
  String get addVariant;

  /// No description provided for @discountPrice.
  ///
  /// In en, this message translates to:
  /// **'Discount price'**
  String get discountPrice;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @deliveryOptions.
  ///
  /// In en, this message translates to:
  /// **'Delivery options'**
  String get deliveryOptions;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @productSaved.
  ///
  /// In en, this message translates to:
  /// **'Product saved'**
  String get productSaved;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @deleteProductQ.
  ///
  /// In en, this message translates to:
  /// **'Delete this product?'**
  String get deleteProductQ;

  /// No description provided for @photosCount.
  ///
  /// In en, this message translates to:
  /// **'Photos ({count}/6)'**
  String photosCount(String count);

  /// No description provided for @manageOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage orders'**
  String get manageOrders;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get changeStatus;

  /// No description provided for @statusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}'**
  String statusUpdated(String status);

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @storeSettings.
  ///
  /// In en, this message translates to:
  /// **'Store settings'**
  String get storeSettings;

  /// No description provided for @payouts.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get payouts;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @withdrawRequested.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal requested (demo)'**
  String get withdrawRequested;

  /// No description provided for @payoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Payout history'**
  String get payoutHistory;

  /// No description provided for @vacationMode.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode'**
  String get vacationMode;

  /// No description provided for @autoReply.
  ///
  /// In en, this message translates to:
  /// **'Chat auto-reply'**
  String get autoReply;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @emptySaved.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get emptySaved;

  /// No description provided for @emptySavedHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart or bookmark icon to save items here.'**
  String get emptySavedHint;

  /// No description provided for @businesses.
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get businesses;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get myListings;

  /// No description provided for @donorProfile.
  ///
  /// In en, this message translates to:
  /// **'Blood donor profile'**
  String get donorProfile;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @reportWrongInfo.
  ///
  /// In en, this message translates to:
  /// **'Report wrong info'**
  String get reportWrongInfo;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpSupport;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @groupShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get groupShopping;

  /// No description provided for @groupCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get groupCommunity;

  /// No description provided for @groupPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get groupPreferences;

  /// No description provided for @groupSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get groupSupport;

  /// No description provided for @offlineDemo.
  ///
  /// In en, this message translates to:
  /// **'Simulate offline'**
  String get offlineDemo;

  /// No description provided for @offlineDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Shows the offline banner (UI demo)'**
  String get offlineDemoHint;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order updates'**
  String get orderUpdates;

  /// No description provided for @offersPromos.
  ///
  /// In en, this message translates to:
  /// **'Offers & promotions'**
  String get offersPromos;

  /// No description provided for @emergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Emergency alerts'**
  String get emergencyAlerts;

  /// No description provided for @bloodRequests.
  ///
  /// In en, this message translates to:
  /// **'Blood requests near me'**
  String get bloodRequests;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent. Thank you for keeping info accurate!'**
  String get reportSent;

  /// No description provided for @whatsWrong.
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong?'**
  String get whatsWrong;

  /// No description provided for @whichListing.
  ///
  /// In en, this message translates to:
  /// **'Which listing?'**
  String get whichListing;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faq;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live chat'**
  String get liveChat;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {value}'**
  String version(String value);

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Tangail All in One is a local super app concept for Tangail district — bringing emergency services, local businesses, transport and a community marketplace together. This build is a UI demo with sample data.'**
  String get aboutBody;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAddress;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setDefault;

  /// No description provided for @addressSaved.
  ///
  /// In en, this message translates to:
  /// **'Address saved'**
  String get addressSaved;

  /// No description provided for @addressLine.
  ///
  /// In en, this message translates to:
  /// **'House, road, area'**
  String get addressLine;

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// No description provided for @donorVisible.
  ///
  /// In en, this message translates to:
  /// **'Show me in donor search'**
  String get donorVisible;

  /// No description provided for @donations.
  ///
  /// In en, this message translates to:
  /// **'{count} donations'**
  String donations(String count);

  /// No description provided for @nextEligible.
  ///
  /// In en, this message translates to:
  /// **'Next eligible: {date}'**
  String nextEligible(String date);

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {year}'**
  String memberSince(String year);

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @nidNumber.
  ///
  /// In en, this message translates to:
  /// **'NID number'**
  String get nidNumber;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @govt.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get govt;

  /// No description provided for @privateLabel.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateLabel;

  /// No description provided for @cases.
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get cases;

  /// No description provided for @describeMatter.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe your matter'**
  String get describeMatter;

  /// No description provided for @popularRoutes.
  ///
  /// In en, this message translates to:
  /// **'Popular routes'**
  String get popularRoutes;

  /// No description provided for @seatCount.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seatCount;

  /// No description provided for @scheduleNote.
  ///
  /// In en, this message translates to:
  /// **'Tangail Railway Station · times may change (demo)'**
  String get scheduleNote;

  /// No description provided for @satThu.
  ///
  /// In en, this message translates to:
  /// **'Sat – Thu'**
  String get satThu;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @bazarSource.
  ///
  /// In en, this message translates to:
  /// **'Tangail Park Bazar (demo)'**
  String get bazarSource;

  /// No description provided for @prayerSource.
  ///
  /// In en, this message translates to:
  /// **'Approximate times per Islamic Foundation (demo)'**
  String get prayerSource;

  /// No description provided for @deadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadlineLabel;

  /// No description provided for @lastDonationDate.
  ///
  /// In en, this message translates to:
  /// **'Last donation date'**
  String get lastDonationDate;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @replayOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Replay onboarding'**
  String get replayOnboarding;

  /// No description provided for @donationHistory.
  ///
  /// In en, this message translates to:
  /// **'Donation history'**
  String get donationHistory;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy;

  /// No description provided for @licences.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get licences;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ♥ for Tangail'**
  String get madeWithLove;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
