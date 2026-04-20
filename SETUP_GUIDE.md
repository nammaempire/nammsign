# SignageAds Flutter App – Setup Guide

## Project Structure

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp + Splash Router
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # All colors (purple brand palette)
│   │   ├── app_theme.dart             # Dark & Light ThemeData
│   │   └── app_strings.dart           # All text constants
│   ├── services/
│   │   ├── api_service.dart           # All REST API calls (HTTP)
│   │   └── auth_service.dart          # OTP + Google auth logic
│   └── utils/
│       └── validators.dart            # Phone, OTP, Aadhar, GST validators
├── models/
│   ├── ad_slot_model.dart             # AdSlot model + mock data
│   └── advertisement_model.dart       # Advertisement model + mock data
├── providers/
│   ├── theme_provider.dart            # Dark/Light theme toggle
│   ├── auth_provider.dart             # Auth state management
│   └── advertisement_provider.dart    # Ad slots & history state
└── features/
    ├── auth/screens/
    │   ├── login_screen.dart           # Phone OTP + Google Sign-In
    │   └── otp_screen.dart             # 6-digit OTP input (auto verify)
    ├── onboarding/screens/
    │   └── onboarding_screen.dart      # Corporate / Individual flow
    ├── home/
    │   ├── screens/home_screen.dart    # Bottom nav + TabBar host
    │   └── widgets/
    │       ├── local_tab.dart          # Local ad slots list
    │       ├── premium_tab.dart        # Coming Soon screen
    │       └── ad_card.dart            # Slot card component
    ├── advertisement/
    │   ├── screens/
    │   │   ├── detail_screen.dart      # Upload + Signage preview
    │   │   ├── payment_screen.dart     # Razorpay payment
    │   │   └── success_screen.dart     # Post-payment confirmation
    │   └── widgets/
    │       └── signage_preview.dart    # Digital board mockup
    ├── history/screens/
    │   └── history_screen.dart         # My ads + status tracking
    └── profile/screens/
        └── profile_screen.dart         # Profile, settings, theme, logout
```

---

## Step 1 – Install Dependencies

```bash
flutter pub get
```

---

## Step 2 – Configure API Base URL

Open `lib/core/services/api_service.dart` and replace:
```dart
static const String _baseUrl = 'https://your-api.com/api/v1';
```
With your actual backend URL.

---

## Step 3 – Configure Google Sign-In

### Android
Add your `google-services.json` to `android/app/`

Edit `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### iOS
Add `GoogleService-Info.plist` to `ios/Runner/`

---

## Step 4 – Configure Razorpay

Open `lib/features/advertisement/screens/payment_screen.dart` and replace:
```dart
'key': 'rzp_test_XXXXXXXXXXXXXX',
```
With your Razorpay Test/Live key.

**Required Android manifest permissions** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

---

## Step 5 – Expected API Endpoints

| Method | Endpoint                   | Description                   |
|--------|----------------------------|-------------------------------|
| POST   | /auth/send-otp             | Send OTP to phone             |
| POST   | /auth/verify-otp           | Verify OTP → return JWT token |
| POST   | /auth/google               | Google ID token → JWT         |
| POST   | /onboarding/submit         | Submit verification docs      |
| GET    | /slots/local               | List local ad slots           |
| POST   | /advertisements            | Create ad (multipart)         |
| GET    | /advertisements/mine       | My advertisement history      |
| POST   | /payments/create-order     | Create Razorpay order         |
| POST   | /payments/verify           | Verify Razorpay signature     |
| GET    | /user/profile              | Get user profile              |

---

## Step 6 – Run the App

```bash
# Debug
flutter run

# Release APK
flutter build apk --release

# iOS
flutter build ios --release
```

---

## User Flow

```
Splash → Auth Check
         ├── Not logged in → Login Screen
         │    ├── Phone Number → OTP → Verify
         │    └── Google Sign-In
         │
         └── Logged in
              ├── Onboarding needed → Corporate / Individual form
              └── Onboarding done → Home Screen
                   ├── Local Tab → Slot Cards → Detail Screen
                   │    ├── Fill ad details + duration
                   │    ├── Upload Image / Video
                   │    ├── Preview on Signage Board
                   │    └── Proceed to Payment → Razorpay
                   │         └── Success → Pending Approval
                   ├── Premium Tab → Coming Soon
                   ├── History Tab → My Ads + Status badges
                   └── Profile Tab → Theme toggle, settings, logout
```

---

## Features Checklist

- [x] Phone OTP login with 6-digit input boxes
- [x] Google Sign-In
- [x] Corporate / Individual onboarding with document upload
- [x] Home screen with Tab bar (Local + Premium)
- [x] Ad slot cards with pricing, location, availability
- [x] Ad detail screen with form validation
- [x] Image & Video upload with thumbnail preview
- [x] **Digital signage board mockup** preview
- [x] Duration selector (1, 3, 7, 14, 30 days) with price calc
- [x] Razorpay payment integration
- [x] Payment success screen with pending status
- [x] Advertisement history with status badges
- [x] Profile screen with stats
- [x] Dark/Light theme toggle (persisted)
- [x] Mock data fallback (works without API)
- [x] Clean Provider state management
- [x] Input validation (Aadhar, GST, phone)
