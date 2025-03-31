# ReliefLink

## Description
ReliefLink is a Flutter-based disaster relief and crisis response application that helps users during emergencies by providing location-based aid requests, emergency alerts, secure transactions, and real-time notifications.

---

## 📂 Project Structure
```
relieflink/
│── lib/
│   ├── main.dart                # Entry point of the app
│   ├── screens/                 # UI screens
│   │   ├── home.dart            # Main home screen
│   │   ├── login.dart           # User authentication screen
│   │   ├── register.dart        # Registration page
│   │   ├── map_screen.dart      # Google Maps implementation
│   │   ├── donation.dart        # Razorpay donation integration
│   ├── services/                # API and background services
│   │   ├── location_service.dart# Handles location tracking
│   │   ├── notification_service.dart # Manages push notifications
│   │   ├── payment_service.dart # Manages Razorpay transactions
│   ├── utils/                   # Helper functions
│   ├── widgets/                 # Reusable UI components
│── assets/                      # Static resources (icons, images)
│── pubspec.yaml                 # Dependencies and configurations
│── android/                     # Android-specific files
│── ios/                         # iOS-specific files
│── README.md                    # Project documentation
```

---

## 🛠️ Dependencies Used
- **Flutter SDK:** Latest stable version.
- **Core Libraries:** `flutter`, `cupertino_icons`, `get`.
- **Location & Maps:** `google_maps_flutter`, `geolocator`, `geocoding`, `location`.
- **Networking:** `http`, `dio`, `xml`.
- **Notifications:** `flutter_local_notifications`, `onesignal_flutter`.
- **Authentication:** `email_otp`, `pin_code_fields`.
- **Payments:** `razorpay_flutter`.
- **UI Enhancements:** `shimmer`, `flutter_countdown_timer`.
- **Storage:** `shared_preferences`.

---

## 🔥 Features
1. **User Authentication** (OTP-based verification using `email_otp` and `pin_code_fields`).
2. **Real-time Location Tracking** (Using `geolocator`, `geocoding`, and `location`).
3. **Google Maps Integration** (For mapping relief centers and emergency areas).
4. **Push Notifications** (Using `onesignal_flutter` and `flutter_local_notifications`).
5. **Secure Online Donations** (Using `razorpay_flutter` for transactions).
6. **Emergency Alerts System** (Sends critical information in real-time).
7. **Shimmer UI Loading Effects** (For smooth UI experience using `shimmer`).
8. **Data Storage & Preferences** (`shared_preferences` for local storage).
9. **Network Requests Handling** (`http` and `dio` for API communication).
10. **Countdown Timer for Critical Alerts** (Using `flutter_countdown_timer`).

---

## 🚀 Getting Started
1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/relieflink.git
   cd relieflink
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

---

## 📌 Contributions
Feel free to contribute! Fork the repository and submit a pull request with your improvements.

---

## 📞 Contact
For any queries or support, reach out to the project maintainers.

