// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vibe Music';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get player => 'Player';

  @override
  String get favorites => 'Favorites';

  @override
  String get my => 'My';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get username => 'Username';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterConfirmPassword => 'Confirm your password';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get registerSuccess => 'Registration successful';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System Language';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Chinese';

  @override
  String get traditionalChinese => 'Traditional Chinese';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get autoMode => 'Auto Mode';

  @override
  String get theme => 'Theme';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get repeat => 'Repeat';

  @override
  String get volume => 'Volume';

  @override
  String get duration => 'Duration';

  @override
  String get album => 'Album';

  @override
  String get artist => 'Singer';

  @override
  String get genre => 'Genre';

  @override
  String get year => 'Year';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get share => 'Share';

  @override
  String get download => 'Download';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get noResults => 'No results found';

  @override
  String get searchHint => 'Search for songs, artists, albums...';

  @override
  String get networkError => 'Network error';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get songs => 'Songs';

  @override
  String get phone => 'Phone';

  @override
  String get introduction => 'Introduction';

  @override
  String get validEmail => 'Please enter a valid email address';

  @override
  String get validPhone => 'Please enter a valid phone number';

  @override
  String get introductionLimit => 'Introduction cannot exceed 100 characters';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get pleaseLogin => 'Please login first';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get avatarUpdateSuccess => 'Avatar updated successfully';

  @override
  String get avatarUpdateFailed => 'Failed to update avatar';

  @override
  String get imagePickFailed => 'Failed to select image';

  @override
  String confirmDeleteUser(Object username) {
    return 'Are you sure you want to delete \'$username\'?';
  }

  @override
  String confirmDeleteSong(Object songName) {
    return 'Are you sure you want to delete \'$songName\'?';
  }

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get enterVerificationCode => 'Please enter verification code';

  @override
  String get verificationCodeLength => 'Verification code must be 6 digits';

  @override
  String get sendVerificationCode => 'Send Verification Code';

  @override
  String resendVerificationCode(Object countdown) {
    return 'Resend Code (${countdown}s)';
  }

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get usernameFormat => 'Username must be 4-16 characters, letters, numbers, underscores or hyphens';

  @override
  String get passwordLength => 'Password must be at least 6 characters';

  @override
  String get passwordFormat => 'Password must be 8-18 characters, contain at least one letter and one number, and can include special characters';

  @override
  String get phoneFormat => 'Please enter a valid phone number';

  @override
  String get emailFormat => 'Please enter a valid email';

  @override
  String get usernameRequired => 'Please enter username';

  @override
  String get passwordRequired => 'Please enter password';

  @override
  String get emailRequired => 'Please enter email';

  @override
  String get verificationCodeRequired => 'Please enter verification code';

  @override
  String get confirmPasswordRequired => 'Please confirm password';

  @override
  String get confirmPasswordMatch => 'Passwords do not match';

  @override
  String get playlist => 'Playlist';

  @override
  String songsCount(Object count) {
    return '$count songs';
  }

  @override
  String get unknownSong => 'Unknown Song';

  @override
  String get unknownArtist => 'Unknown Singer';

  @override
  String get tip => 'Tip';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get playNext => 'Play Next';

  @override
  String get addedToNextPlay => 'Added to next play';

  @override
  String get searchFailed => 'Search failed, please try again';

  @override
  String get alreadyFavorited => 'Already in favorites';

  @override
  String get verificationCodeSent => 'Verification code sent!';

  @override
  String get failedToSendVerificationCode => 'Failed to send verification code';

  @override
  String get registrationSuccessful => 'Registration successful! Please login.';

  @override
  String get settingsPageComingSoon => 'Settings page will be implemented soon';

  @override
  String get confirmClose => 'Close?';

  @override
  String get closePlayback => 'Close Playback';

  @override
  String get confirmClosePlayback => 'Are you sure you want to close the current playback?';

  @override
  String get loginExpired => 'Login expired, please log in again';

  @override
  String get goToLogin => 'Go to login';

  @override
  String get recommendedPlaylists => 'Recommended Playlists';

  @override
  String get viewMore => 'View More';

  @override
  String get hotSongs => 'Hot Songs';
}
