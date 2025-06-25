# MVP Development Context - Hopin App

## 🎯 **MVP Objective**
Build the core ride-sharing functionality for Stellenbosch University students using FlutterFlow, focusing on essential features that enable students to find and offer rides safely and efficiently.

## 📋 **MVP Phase 1 Features (Priority Order)**

### **1. Authentication & User Management**
- Student email verification (@sun.ac.za domain)
- Phone number verification
- Basic profile creation
- Student ID verification system

### **2. Core Ride Functionality**
- Create ride offers (driver side)
- Browse available rides (passenger side)
- Basic ride matching system
- Ride request and acceptance flow

### **3. Essential UI Screens**
- Splash screen and onboarding
- Login/Register flow
- Home feed with available rides
- Create ride form
- Basic profile management

### **4. Safety & Trust**
- Student verification badges
- Basic emergency contact system
- In-app messaging (ride-specific)

### **5. Payment Integration**
- Paystack integration for card payments
- Basic payment flow (post-ride)

## 🏗️ **Technical Architecture for MVP**

### **Frontend: FlutterFlow**
```
Architecture Pattern: Layered Architecture
├── Presentation Layer (FlutterFlow UI)
├── Service Layer (Business Logic)
├── Data Layer (Firebase Integration)
└── External Integration Layer (Paystack, Maps)
```

### **Backend: Firebase**
```
Services Used:
├── Firebase Authentication (Email/Phone)
├── Firestore Database (User & Ride data)
├── Cloud Functions (Business logic)
├── Firebase Storage (Profile images)
└── Cloud Messaging (Notifications)
```

### **Key Integrations**
- **Google Maps API** - Location services and mapping
- **Paystack API** - Payment processing
- **Firebase** - Complete backend solution

## 📱 **MVP Screen Priority**

### **Phase 1A (Week 1-2): Core Authentication**
1. `splash_screen` - App branding and loading
2. `onboarding` - Student-focused introduction
3. `login_register` - Student email authentication

### **Phase 1B (Week 3-4): Basic Ride Flow**
4. `home_feed` - Main dashboard with available rides
5. `create_ride` - Driver creates ride offers
6. `find_ride` - Passenger browses rides
7. `ride_details` - View ride information

### **Phase 1C (Week 5-6): User Management**
8. `profile` - Basic profile management
9. `my_rides` - Ride history and management
10. `messaging` - Basic in-app chat

## 🗄️ **MVP Database Schema**

### **Users Collection**
```javascript
{
  userId: string,
  email: string, // @sun.ac.za
  studentNumber: string,
  firstName: string,
  lastName: string,
  phoneNumber: string,
  profileImageUrl: string,
  verificationStatus: {
    email: boolean,
    phone: boolean,
    studentId: boolean
  },
  createdAt: timestamp,
  lastActive: timestamp
}
```

### **Rides Collection**
```javascript
{
  rideId: string,
  driverId: string,
  pickup: {
    address: string,
    coordinates: { lat: number, lng: number }
  },
  destination: {
    address: string,
    coordinates: { lat: number, lng: number }
  },
  departureTime: timestamp,
  availableSeats: number,
  pricePerSeat: number,
  status: "active" | "full" | "completed" | "cancelled",
  passengers: [string], // Array of user IDs
  createdAt: timestamp
}
```

### **RideRequests Collection**
```javascript
{
  requestId: string,
  rideId: string,
  passengerId: string,
  status: "pending" | "accepted" | "rejected",
  requestedAt: timestamp,
  respondedAt: timestamp
}
```

## 🎨 **UI Implementation Guide**

### **Design System**
```css
Primary Color: #2563EB (Blue)
Secondary Color: #059669 (Green)
Accent Color: #DC2626 (Red)
Surface Color: #FFFFFF (White)
Background Color: #F8FAFC (Light Gray)
```

### **Component Patterns**
- **Cards**: Elevated surfaces for ride listings
- **Bottom Navigation**: 5 tabs (Home, Map, Rides, Messages, Profile)
- **Search Bars**: Uber-style with campus suggestions
- **Action Buttons**: Primary (blue), Secondary (outline), Destructive (red)

## 🔧 **Development Setup Requirements**

### **FlutterFlow Project Setup**
1. Create new FlutterFlow project
2. Configure Firebase backend
3. Set up Google Maps integration
4. Configure Paystack payment gateway
5. Implement authentication flow

### **Firebase Configuration**
```javascript
// Required Firebase services
- Authentication (Email/Password, Phone)
- Firestore Database
- Cloud Functions
- Storage
- Cloud Messaging
```

### **API Keys Needed**
- Google Maps API key
- Paystack public/secret keys
- Firebase configuration keys

## 🧪 **MVP Testing Strategy**

### **Unit Tests (Target: 80% coverage)**
- Authentication service
- Ride creation/matching logic
- Payment processing
- Data validation

### **Integration Tests**
- User registration flow
- Ride creation to booking flow
- Payment integration
- Firebase data operations

### **User Acceptance Tests**
- Student can register with @sun.ac.za email
- Driver can create and manage ride offers
- Passenger can find and book rides
- Payment processing works correctly

## 🚀 **MVP Success Criteria**

### **Functional Requirements**
- [ ] Students can register and verify accounts
- [ ] Drivers can create ride offers
- [ ] Passengers can browse and book rides
- [ ] Basic in-app messaging works
- [ ] Payment processing is functional
- [ ] Safety features are implemented

### **Performance Requirements**
- App loads in under 3 seconds
- Real-time updates work smoothly
- Payment processing under 10 seconds
- 99% uptime for core features

### **User Experience Requirements**
- Intuitive navigation (< 3 taps to key features)
- Clear visual feedback for all actions
- Responsive design on all screen sizes
- Accessibility compliance (basic level)

## 📊 **MVP Metrics to Track**

### **User Engagement**
- Daily active users
- Ride creation rate
- Ride booking success rate
- User retention (Day 1, 7, 30)

### **Technical Metrics**
- App crash rate (< 1%)
- API response times
- Payment success rate (> 95%)
- Bug report frequency

## 🎯 **Agent Development Instructions**

### **Start Here:**
1. **Read this file completely** for context
2. **Review `hopin_complete_ui_specification.json`** for UI details
3. **Check `ARCHITECTURE_DECISIONS.md`** for technical patterns
4. **Follow `CODING_STANDARDS.md`** for implementation guidelines

### **Development Order:**
1. Set up FlutterFlow project with Firebase
2. Implement authentication screens (splash → onboarding → login)
3. Build home feed with basic ride listing
4. Create ride creation flow
5. Add basic profile management
6. Implement in-app messaging
7. Integrate payment processing

### **Key Considerations:**
- **Student-first design** - Everything should feel familiar to university students
- **Safety-focused** - Multiple verification layers and emergency features
- **Cost-effective** - Target R15-R30 per ride pricing
- **Campus-optimized** - Quick actions for common university routes
- **Mobile-first** - Optimize for smartphone usage patterns

## 📞 **Support & Resources**

### **Documentation References**
- FlutterFlow Documentation: https://docs.flutterflow.io/
- Firebase Documentation: https://firebase.google.com/docs
- Paystack Documentation: https://paystack.com/docs
- Google Maps API: https://developers.google.com/maps

### **Project Files to Reference**
- `docs/hopin_complete_ui_specification.json` - Complete UI specification
- `docs/API_SPECIFICATION.md` - Backend API endpoints
- `docs/DEVELOPMENT_SETUP.md` - Environment setup guide

---

**Ready to build the future of student transportation at Stellenbosch University! 🚗🎓** 