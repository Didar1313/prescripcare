# PrescripCare

PrescripCare is a comprehensive Flutter mobile app designed to help users manage medical prescriptions, reports, medicine reminders, appointments, and medical history—all in one place. Additionally, users can search for doctors, hospitals, and nearby essential services like restaurants and pharmacies, with detailed info and locations, making health management easier and more connected.

---

## Table of Contents

* [About](#about)
* [Features](#features)
* [Screenshots](#screenshots)
* [Technologies Used](#technologies-used)
* [Installation](#installation)
* [Firebase Setup](#firebase-setup)
* [Usage](#usage)
* [Project Structure](#project-structure)
* [Contact](#contact)

---

## About

Managing health can be complex. PrescripCare helps by offering a single app where users can:

* Upload and organize prescriptions and medical reports
* Set medicine and appointment reminders
* Track medical history
* Search for doctors and hospitals with detailed information and location
* Find nearby essential services like restaurants, pharmacies, and emergency services
* Manage profiles and emergency contacts
* Upload documents and PDFs for easy access

---

## Features

* **User Registration & Login:** Secure authentication with Firebase.
* **Medicine & Appointment Reminders:** Add and get notifications for medicines and appointments.
* **Prescription & Report Upload:** Upload images and PDFs of prescriptions and reports.
* **Medical History:** Maintain a detailed log of your medical records.
* **Doctor & Hospital Search:** Search doctors and hospitals with their details, locations, and contact info.
* **Nearby Services:** Find nearby restaurants, pharmacies, and emergency ambulance services.
* **Emergency Services:** Quick access to ambulance details and emergency contacts.
* **User Profile:** Manage your personal and medical information.
* **Offline Access:** Access saved info without internet connectivity.

---

## Screenshots
<img width="200" alt="Screenshot 2025-06-23 at 3 10 50 AM" src="https://github.com/user-attachments/assets/d31fa03a-7ea7-42ae-aa98-de374248ea9e" />


---

## Technologies Used

* Flutter (Dart)
* Firebase Authentication
* Firebase Firestore & Storage
* Flutter Local Notifications
* Location Services (for nearby places)
* Responsive UI with Flutter ScreenUtil

---

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Didar1313/prescripcare.git
   cd prescripcare
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Setup Firebase (see below).

4. Run the app:

   ```bash
   flutter run
   ```

---

## Firebase Setup

1. Create a Firebase project and add Android/iOS apps.
2. Download and add configuration files (`google-services.json` and `GoogleService-Info.plist`).
3. Enable Email/Password Authentication.
4. Setup Firestore collections and Storage buckets:

   * Users (with email as document ID)
   * Medicines, Appointments, Prescriptions, Reports, Doctors, Hospitals, EmergencyServices, etc.
5. Configure Firebase Storage for images and PDF uploads.

---

## Usage

* Register or login with email.
* Add medicines and set reminders.
* Upload prescriptions and reports.
* Search for doctors or hospitals, view their details and locations.
* Access nearby restaurants, pharmacies, and emergency ambulances.
* Manage your profile and emergency services quickly.
* Receive local notifications for medicines and appointments.

---

## Project Structure

```
/lib
 ├── Authenticate
 │    ├── loginPage.dart
 │    ├── userRegistration.dart
 │
 ├── bottomNavigationBar
 │    ├── bottomNavigationBar.dart
 │    ├── bottomNavigationBarItem.dart
 │    ├── bookMark.dart
 │    ├── home.dart
 │    ├── profile.dart
 │
 ├── emergencyServices
 │    ├── ambulanceDetailScreen.dart
 │    ├── searchAmbulance.dart
 │    ├── uploadAmbulanceToFirestore.dart
 │
 ├── featuressDetails
 │    ├── addPills.dart
 │    ├── appointmentReminder.dart
 │    ├── doctor_upload_service.dart
 │    ├── emergency_services.dart
 │    ├── medicalHistory.dart
 │    ├── medicineReminder.dart
 │
 ├── findDoctor
 │    ├── doctorDetailScreen.dart
 │    ├── doctorSearchScreen.dart
 │    ├── uploadDoctorsToFirestore.dart
 │
 ├── findHospital
 │    ├── hospitalDetailsScreen.dart
 │    ├── hospitalSearchScreen.dart
 │    ├── uploadHospitalToFirestore.dart
 │
 ├── pdfUpload
 │    ├── uploadPdf.dart
 │
 ├── reportPrescription
 │    ├── imageGallery.dart
 │    ├── reportPresDetailsScreen.dart
 │
 ├── splashScreen
 │    ├── splashScreen.dart
 │
 ├── main.dart
```



## Contact

**Didar Bhuiyan**
Email: [didarbhuiyan1313@gmail.com](mailto:didarbhuiyan1313@gmail.com)
GitHub: [github.com/Didar1313](https://github.com/Didar1313)

---
