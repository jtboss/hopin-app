# 🚗 Hopin - Student Ride-Sharing App

**Connecting Stellenbosch University students through safe, affordable ride-sharing**

![Hopin Logo](docs/assets/hopin-logo.png)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com)
[![FlutterFlow](https://img.shields.io/badge/FlutterFlow-6366F1?style=for-the-badge&logo=flutter&logoColor=white)](https://flutterflow.io)

---

## 🎯 What is Hopin?

Hopin is a **student-first ride-sharing platform** designed specifically for university students in Stellenbosch, South Africa. We make daily commuting between campus, residences, and local neighborhoods **safe, affordable, and reliable** by connecting students who need rides with those who are already driving the same route.

### Why Hopin?
- **Student-Focused:** Built by students, for students
- **Affordable:** R20-R30 per ride vs R50+ for Uber/Bolt
- **Trust-Based:** University email verification and student community
- **Convenient:** Quick booking with familiar faces
- **Safe:** Multi-layer verification and safety features

---

## 🏗️ Project Overview

### Tech Stack
- **Frontend:** FlutterFlow (Flutter-based, cross-platform)
- **Backend:** Firebase (Firestore, Authentication, Cloud Functions)
- **Payments:** Paystack, SnapScan, Yoco
- **Platform:** iOS, Android, Web

### Current Status
🚧 **In Development** - Phase 1 MVP (January 2024)

### Key Features
✅ **Core Features (Phase 1)**
- Student authentication & verification
- Ride posting and browsing
- Real-time matching system
- In-app messaging
- Payment integration
- Safety features

🔄 **Coming Soon (Phase 2)**
- Real-time location tracking
- Recurring rides
- Enhanced ratings system
- Advanced search and filtering
- Comprehensive admin dashboard

---

## 🚀 Quick Start

### For Developers
```bash
# Clone the repository
git clone https://github.com/hopin-app/hopin-flutter.git
cd hopin-flutter

# Install dependencies
flutter pub get

# Set up environment
cp .env.example .env
# Edit .env with your configuration

# Run the app
flutter run
```

### For Users
1. **Download** the app from App Store or Google Play
2. **Sign up** with your @sun.ac.za email address
3. **Verify** your student status
4. **Start** sharing rides with fellow students!

---

## 📁 Project Structure

```
hopin-flutter/
├── docs/                    # 📚 Project documentation
│   ├── PRODUCT_CONTEXT.md   # Product overview and context
│   ├── PROJECT_SCOPE.md     # Development scope and phases
│   ├── ARCHITECTURE_DECISIONS.md # Technical decisions
│   ├── CODING_STANDARDS.md  # Development guidelines
│   └── DEVELOPMENT_SETUP.md # Setup instructions
├── lib/                     # 📱 Flutter application code
│   ├── models/             # Data models
│   ├── services/           # Business logic
│   ├── repositories/       # Data access layer
│   ├── pages/             # UI pages (FlutterFlow)
│   └── widgets/           # Reusable components
├── test/                   # 🧪 Test files
│   ├── unit/              # Unit tests
│   ├── widget/            # Widget tests
│   └── integration/       # Integration tests
├── firebase/              # 🔥 Firebase configuration
│   ├── functions/         # Cloud Functions
│   ├── firestore.rules   # Database security rules
│   └── storage.rules     # Storage security rules
└── assets/               # 🎨 Images, fonts, and static files
```

---

## 📖 Documentation

### 📋 Essential Reading
- **[Product Context](docs/PRODUCT_CONTEXT.md)** - Understanding Hopin's vision and goals
- **[Project Scope](docs/PROJECT_SCOPE.md)** - Development phases and features
- **[Development Setup](docs/DEVELOPMENT_SETUP.md)** - How to set up your development environment

### 🏗️ Technical Documentation
- **[Architecture Decisions](docs/ARCHITECTURE_DECISIONS.md)** - Technical choices and rationale
- **[Coding Standards](docs/CODING_STANDARDS.md)** - Development guidelines and best practices
- **[API Documentation](docs/api/)** - Backend API reference

### 🎨 Design & UX
- **[Design System](docs/design/)** - UI components and styling guidelines
- **[User Flows](docs/user-flows/)** - Key user journey documentation

---

## 🎯 Development Phases

### Phase 1: MVP Foundation (Months 1-2) ✅
**Goal:** Core ride-sharing functionality for Stellenbosch students

**Features:**
- User authentication with student verification
- Basic ride posting and browsing
- Simple matching system
- Payment integration
- Basic safety features

**Status:** 🚧 In Development

### Phase 2: Enhanced Experience (Months 3-4)
**Goal:** Improved user experience and advanced features

**Features:**
- Real-time location tracking
- Enhanced user profiles with ratings
- Recurring ride templates
- Advanced search and filtering
- Enhanced analytics and insights

### Phase 3: Scale & Growth (Months 5-6)
**Goal:** Business features and multi-university expansion

**Features:**
- Service fee implementation
- Advanced admin dashboard
- Multi-university support
- Referral system
- Analytics and reporting

---

## 🛡️ Safety & Security

### Student Verification
- ✅ University email verification (@sun.ac.za)
- ✅ Student ID verification (manual review)
- ✅ Phone number verification via SMS

### Ride Safety
- ✅ Emergency contact sharing
- ✅ Real-time ride status updates
- ✅ User reporting system
- 🔄 Live location tracking (Phase 2)

### Data Protection
- ✅ POPIA compliance (South African data protection law)
- ✅ Minimal data collection principle
- ✅ Encrypted payment processing
- ✅ Regular security audits

---

## 💰 Pricing & Business Model

### Current Pricing
- **Typical Ride:** R20-R30 per seat
- **Service Fee:** 0% (during beta)
- **Payment Methods:** Paystack, SnapScan, Yoco

### Future Business Model
- **Service Fee:** 10% per transaction
- **Premium Features:** Advanced matching, recurring rides
- **University Partnerships:** Official campus integration

---

## 👥 Contributing

We welcome contributions from the student community! Here's how you can help:

### Ways to Contribute
- **Code:** Submit pull requests for new features or bug fixes
- **Design:** Help improve the user interface and experience
- **Testing:** Report bugs and test new features
- **Documentation:** Improve or translate documentation
- **Feedback:** Share ideas and suggestions

### Getting Started
1. Read our **[Coding Standards](docs/CODING_STANDARDS.md)**
2. Check the **[Development Setup](docs/DEVELOPMENT_SETUP.md)** guide
3. Look for issues labeled `good-first-issue`
4. Submit a pull request with your improvements

### Code of Conduct
- Be respectful and inclusive
- Focus on constructive feedback
- Help fellow students learn and grow
- Prioritize safety and user privacy

---

## 🤝 Community & Support

### Stay Connected
- **Discord:** [Join our student developer community](https://discord.gg/hopin-dev)
- **Instagram:** [@hopin_stellenbosch](https://instagram.com/hopin_stellenbosch)
- **Email:** hello@hopin.co.za

### Get Help
- **Technical Issues:** Create a GitHub issue
- **User Support:** Contact support@hopin.co.za
- **Safety Concerns:** Report via app or safety@hopin.co.za

### University Partnerships
- **Stellenbosch University:** Official partnership in discussion
- **Student Organizations:** Collaborating with student councils
- **Residence Committees:** Integration with residence systems

---

## 📊 Metrics & Success

### Current Metrics (Beta)
- **Beta Users:** 50+ active testers
- **Rides Completed:** 200+ successful rides
- **Average Rating:** 4.8/5 stars
- **Response Time:** <3 minutes average

### Growth Targets
- **Month 3:** 500 active users
- **Month 6:** 2,000 active users
- **Month 12:** Expand to UCT and Wits

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

### Special Thanks
- **Stellenbosch University IT Services** for technical support
- **Student volunteers** who helped with beta testing
- **Local businesses** supporting student transportation

### Open Source Libraries
- [Flutter](https://flutter.dev) - UI framework
- [Firebase](https://firebase.google.com) - Backend services
- [FlutterFlow](https://flutterflow.io) - Visual development platform

---

## 📞 Contact

**Hopin Team**
- **Email:** team@hopin.co.za
- **Website:** [www.hopin.co.za](https://www.hopin.co.za)
- **Address:** Stellenbosch, Western Cape, South Africa

**For Media Inquiries:** press@hopin.co.za  
**For Business Partnerships:** partnerships@hopin.co.za

---

<div align="center">

**Made with ❤️ by students, for students**

[Download on App Store](https://apps.apple.com/app/hopin) • [Get it on Google Play](https://play.google.com/store/apps/details?id=za.co.hopin)

</div> 