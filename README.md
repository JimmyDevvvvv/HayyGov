# 🏛️ Neighborhood Connect - Governmental Mobile App

## 📱 Overview
**Neighborhood Connect** is a community-focused mobile application designed to streamline communication and services between citizens, local government (municipality), and advertisers. The app enhances urban life by enabling efficient issue reporting, transparent announcements, public participation in decisions, and access to verified advertisements.

---

## 👥 User Roles & Features

### 🏛️ Government/Municipality
- Post announcements with optional attachments (images, PDFs)
- Create and manage public polls
- Receive and respond to private messages from citizens
- Approve or reject submitted advertisements
- Maintain a list of official and emergency contact numbers

### 👤 Citizens
- View and comment on announcements (anonymously or publicly)
- Participate in polls (anonymous, one-time voting)
- Send private messages to the government
- Report neighborhood issues with photos and map location
- Access verified emergency and public service contacts

### 🧾 Advertisers
- Submit advertisements about local services or products
- View approved ads once verified by the government

---

## 🔐 Authentication
- Firebase Authentication with role-based access
- Government has a single admin account
- Secure login/signup system for citizens and advertisers

---

## 🔧 Technical Stack
- **Frontend:** Flutter (Dart)
- **Backend/Database:** Firebase Firestore
- **Authentication:** Firebase Auth
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **UI/UX Design:** Figma
- **Mapping:** Google Maps API
- **AI Integration:** Vulgar/offensive comment detection (Arabic & English)

---

## ✨ Out-of-Scope Features (Bonus)
- ✅ **AI Moderation:** Detects and blocks offensive/vulgar comments using an NLP model (Arabic & English)
- ✅ **Interactive Map Reports:** Citizens can drop pins and upload images when reporting issues

---

## 🚀 Key Screens
- Login / Signup
- Role-Based Dashboard (Citizens, Government, Advertisers)
- Announcements Feed with Comments
- Polls & Voting System
- Messaging Interface (Citizen ↔ Government)
- Report an Issue (Photo + Map Location)
- Emergency & Official Contact List
- Advertisement Feed (Approved Only)

---

## ❗ Error Handling
- Input validation for forms
- Connection and network error messages
- Firebase operation error handling
- Notification delivery fallbacks

---

## 🔔 Notifications
- Real-time push notifications for:
  - New announcements
  - Poll openings/closings
  - Government replies
  - Advertisement approvals

---

## 👨‍💻 Contributors & Responsibilities

| Name                 | Responsibilities                                                                 |
|----------------------|----------------------------------------------------------------------------------|
| **Mohamed Gamal (Jimmy)** | - Developed the messaging system<br>- Implemented admin approval logic<br>- Integrated Google Maps for reporting<br>- Built the problem reporting feature<br>- Managed advertisements functionality<br>- Integrated push notifications |
| **Ali**              | - Designed the UI/UX using Figma<br>- Implemented core UI components             |
| **Abdelrahman**      | - Developed the AI model for vulgar word detection (Arabic & English)           |
| **Koshty**           | - Collaborated on the AI model for vulgar word filtering                        |
| **Waleed**           | - Implemented the announcement creation, editing, and deletion system           |

---

## 📦 Deliverables
- ✅ Zipped Source Code
- ✅ Screen Recording of the App in Action
- ✅ In-Class Live Demo via Emulator or Phone Mirroring

---

## 🗓️ Project Milestones

| Milestone        | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| **Milestone 1**  | Project proposal, user stories, UI mockups (Figma), feature listing         |
| **Milestone 2**  | Final implementation, source code, demo video, and live evaluation in class |

---

