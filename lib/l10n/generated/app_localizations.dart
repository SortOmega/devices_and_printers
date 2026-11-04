import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices and Printers'**
  String get appTitle;

  /// No description provided for @viewDevices.
  ///
  /// In en, this message translates to:
  /// **'View Devices'**
  String get viewDevices;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort:'**
  String get sortLabel;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sortStatus;

  /// No description provided for @sortConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get sortConnection;

  /// No description provided for @groupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group:'**
  String get groupLabel;

  /// No description provided for @groupType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get groupType;

  /// No description provided for @groupStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get groupStatus;

  /// No description provided for @groupConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get groupConnection;

  /// No description provided for @groupDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get groupDefault;

  /// No description provided for @windowsDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get windowsDevices;

  /// No description provided for @windowsPrinters.
  ///
  /// In en, this message translates to:
  /// **'Printers and plotters'**
  String get windowsPrinters;

  /// No description provided for @windowsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown devices'**
  String get windowsUnknown;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get addDevice;

  /// No description provided for @addPrinter.
  ///
  /// In en, this message translates to:
  /// **'Add Printer'**
  String get addPrinter;

  /// No description provided for @refreshDevices.
  ///
  /// In en, this message translates to:
  /// **'Refresh devices'**
  String get refreshDevices;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @unableToLoadDevices.
  ///
  /// In en, this message translates to:
  /// **'Unable to load devices'**
  String get unableToLoadDevices;

  /// No description provided for @unableToQuerySystemDevices.
  ///
  /// In en, this message translates to:
  /// **'Unable to query system devices: {error}'**
  String unableToQuerySystemDevices(Object error);

  /// No description provided for @noConnectedDevices.
  ///
  /// In en, this message translates to:
  /// **'No connected devices or printers were found.'**
  String get noConnectedDevices;

  /// No description provided for @knownDevices.
  ///
  /// In en, this message translates to:
  /// **'{count} known devices'**
  String knownDevices(int count);

  /// No description provided for @addItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{item} will be available when system configuration integration is added.'**
  String addItemUnavailable(Object item);

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A centralized Linux view for discovering and managing connected devices and printers.'**
  String get aboutDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeCupertino.
  ///
  /// In en, this message translates to:
  /// **'Cupertino'**
  String get themeCupertino;

  /// No description provided for @themeMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get themeMaterial;

  /// No description provided for @themeFluent.
  ///
  /// In en, this message translates to:
  /// **'Fluent'**
  String get themeFluent;

  /// No description provided for @colorMode.
  ///
  /// In en, this message translates to:
  /// **'Color mode'**
  String get colorMode;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @interfaceSize.
  ///
  /// In en, this message translates to:
  /// **'Interface size'**
  String get interfaceSize;

  /// No description provided for @interfaceSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get interfaceSizeLarge;

  /// No description provided for @interfaceSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get interfaceSizeNormal;

  /// No description provided for @interfaceSizeCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get interfaceSizeCompact;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @printers.
  ///
  /// In en, this message translates to:
  /// **'Printers'**
  String get printers;

  /// No description provided for @plotters.
  ///
  /// In en, this message translates to:
  /// **'Plotters'**
  String get plotters;

  /// No description provided for @monitors.
  ///
  /// In en, this message translates to:
  /// **'Monitors'**
  String get monitors;

  /// No description provided for @headsets.
  ///
  /// In en, this message translates to:
  /// **'Headsets'**
  String get headsets;

  /// No description provided for @microphones.
  ///
  /// In en, this message translates to:
  /// **'Microphones'**
  String get microphones;

  /// No description provided for @mice.
  ///
  /// In en, this message translates to:
  /// **'Mice'**
  String get mice;

  /// No description provided for @keyboards.
  ///
  /// In en, this message translates to:
  /// **'Keyboards'**
  String get keyboards;

  /// No description provided for @phones.
  ///
  /// In en, this message translates to:
  /// **'Phones'**
  String get phones;

  /// No description provided for @cameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get cameras;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @unknownDevices.
  ///
  /// In en, this message translates to:
  /// **'Unknown devices'**
  String get unknownDevices;

  /// No description provided for @bluetoothDevices.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth devices'**
  String get bluetoothDevices;

  /// No description provided for @usb.
  ///
  /// In en, this message translates to:
  /// **'USB'**
  String get usb;

  /// No description provided for @bluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// No description provided for @audioJack.
  ///
  /// In en, this message translates to:
  /// **'Audio jack'**
  String get audioJack;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @unknownConnection.
  ///
  /// In en, this message translates to:
  /// **'Unknown connection'**
  String get unknownConnection;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
