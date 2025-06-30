import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  /// Launch Instagram profile
  static Future<void> launchInstagram(String handle) async {
    // Remove @ symbol if present
    final cleanHandle = handle.startsWith('@') ? handle.substring(1) : handle;
    
    String url;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      // Try Instagram app first on iOS, fall back to web
      url = 'instagram://user?username=$cleanHandle';
      if (!await canLaunchUrl(Uri.parse(url))) {
        url = 'https://instagram.com/$cleanHandle';
      }
    } else {
      // Android, web, and other platforms - use web URL
      url = 'https://instagram.com/$cleanHandle';
    }
    
    await _launchUrl(url);
  }
  
  /// Launch address in maps app
  static Future<void> launchMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    
    String url;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      // Try Apple Maps first on iOS, fall back to Google Maps
      url = 'http://maps.apple.com/?q=$encodedAddress';
      if (!await canLaunchUrl(Uri.parse(url))) {
        url = 'https://maps.google.com/?q=$encodedAddress';
      }
    } else {
      // Android, web, and other platforms - use Google Maps
      url = 'https://maps.google.com/?q=$encodedAddress';
    }
    
    await _launchUrl(url);
  }
  
  /// Launch website URL
  static Future<void> launchWebsite(String url) async {
    // Ensure URL has protocol
    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }
    
    await _launchUrl(finalUrl);
  }
  
  /// Launch email
  static Future<void> launchEmail(String email) async {
    final url = 'mailto:$email';
    await _launchUrl(url);
  }
  
  /// Launch phone number
  static Future<void> launchPhone(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    await _launchUrl(url);
  }
  
  /// Internal method to launch URL with error handling
  static Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      
      try {
        // Try the standard url_launcher approach first
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication);
        } else {
          throw Exception('Cannot launch URL: $url');
        }
      } on MissingPluginException catch (e) {
        debugPrint('MissingPluginException for $url: $e');
        // Handle missing plugin gracefully - likely on web or unsupported platform
        await _launchUrlFallback(url);
      } on PlatformException catch (e) {
        debugPrint('PlatformException for $url: $e');
        // Handle platform-specific issues
        await _launchUrlFallback(url);
      }
    } catch (e) {
      debugPrint('Error launching URL $url: $e');
      await _launchUrlFallback(url);
    }
  }
  
  /// Fallback URL launching for when plugins aren't available
  static Future<void> _launchUrlFallback(String url) async {
    try {
      final uri = Uri.parse(url);
      // Try a simpler launch approach
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Fallback URL launch failed for $url: $e');
      // Last resort: provide user with copyable URL
      throw Exception('Cannot open link automatically. Please copy this URL: $url');
    }
  }
}