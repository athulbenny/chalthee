# chalthee

---
# 🏃‍♂️ Chalthee – Weight Tracker & Progress App

Chalthee is a Flutter-based fitness tracking application that helps users log daily weight, visualize progress, and manage personal fitness data with a clean and intuitive UI.

---

## ✨ Features

### 📅 Calendar-Based Tracking
- Select any date to log weight
- Visual indicators for:
  - Selected date
  - Today’s date
  - Date ranges

### ⚖️ Weight Management
- Add / Edit / Delete weight entries
- Store weight data per user
- Automatically fetch:
  - Previous day weight
  - Latest available weight

### 📊 Progress Insights
- Weekly & Monthly progress tracking
- Displays:
  - Average weight
  - Weight gain/loss
  - Percentage change

### 👤 User System
- Login with:
  - Username
  - Email
- Multiple users supported
- Each user has:
  - Separate weight history
  - Independent session

### 💾 Local Storage (Cache)
- Uses `SharedPreferences`
- Stores:
  - Session data
  - Logged-in user
  - Weight map per user

### ☁️ Firebase Integration
- Sync user data to Firestore
- Fetch user data if not in local cache
- Device-based mapping for syncing

### 📱 Device Awareness
- Detect app lifecycle:
  - Foreground
  - Background
  - Exit
- Sync data when app goes to background

### 🎨 UI Highlights
- Custom gradient cards
- Calendar UI with range selection
- Profile drawer (sidebar)
- App icon (custom gym-themed)


---

## 🔄 App Flow

1. **App Start**

   * Check `isLoggedIn`
   * Route to:

     * Home (Calendar Page)
     * Login Page

2. **Login**

   * If user exists → load from Firebase / cache
   * Else → create new user

3. **Usage**

   * Add weights
   * View progress
   * Navigate calendar

4. **Background**

   * Auto sync to Firebase (if not synced)

---

## 📦 Dependencies

* `flutter`
* `shared_preferences`
* `cloud_firestore`
* `firebase_core`

---

## 🧠 Key Concepts Used

* Stateful Widgets & Lifecycle handling
* Local caching with SharedPreferences
* Firebase Firestore integration
* JSON data modeling
* Calendar UI logic
* Async programming in Flutter

---

## 🚀 Future Improvements

* Charts (graph visualization)
* Notifications / reminders
* Cloud sync optimization
* User authentication (Firebase Auth)
* Dark mode

---


