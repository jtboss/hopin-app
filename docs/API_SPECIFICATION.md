# API Specification - Hopin App

## 📋 Overview

This document specifies the API endpoints and data structures for the Hopin ride-sharing application. The API is built using Firebase Cloud Functions and follows RESTful principles where applicable.

---

## 🏗️ API Architecture

### Base URL
- **Development:** `https://us-central1-hopin-dev.cloudfunctions.net/api`
- **Staging:** `https://us-central1-hopin-staging.cloudfunctions.net/api`
- **Production:** `https://us-central1-hopin-prod.cloudfunctions.net/api`

### Authentication
All API requests require Firebase authentication token in the header:
```
Authorization: Bearer <firebase-auth-token>
```

### Response Format
```json
{
  "success": true,
  "data": { ... },
  "message": "Success message",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Error Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "User-friendly error message",
    "details": { ... }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## 👤 Authentication Endpoints

### POST /auth/register
Register a new user account.

#### Request Body
```json
{
  "email": "student@sun.ac.za",
  "password": "SecurePassword123",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+27123456789",
  "studentNumber": "12345678"
}
```

#### Response
```json
{
  "success": true,
  "data": {
    "user": {
      "uid": "user123",
      "email": "student@sun.ac.za",
      "firstName": "John",
      "lastName": "Doe",
      "verificationStatus": "pending",
      "roles": ["rider"]
    },
    "token": "firebase-auth-token"
  }
}
```

### POST /auth/verify-email
Send email verification link.

#### Request Body
```json
{
  "email": "student@sun.ac.za"
}
```

### POST /auth/verify-phone
Send SMS verification code.

#### Request Body
```json
{
  "phoneNumber": "+27123456789"
}
```

### POST /auth/verify-phone-code
Verify SMS code.

#### Request Body
```json
{
  "phoneNumber": "+27123456789",
  "code": "123456"
}
```

---

## 👤 User Management Endpoints

### GET /users/profile
Get current user profile.

#### Response
```json
{
  "success": true,
  "data": {
    "uid": "user123",
    "email": "student@sun.ac.za",
    "profile": {
      "firstName": "John",
      "lastName": "Doe",
      "profileImage": "https://storage.googleapis.com/...",
      "phoneNumber": "+27123456789",
      "studentNumber": "12345678",
      "university": "stellenbosch",
      "emergencyContact": "+27987654321",
      "verificationStatus": "verified",
      "rating": 4.8,
      "totalRides": 23
    },
    "roles": ["rider", "driver"],
    "preferences": {
      "notifications": true,
      "shareLocation": true
    },
    "createdAt": "2024-01-01T00:00:00Z",
    "lastActive": "2024-01-15T10:30:00Z"
  }
}
```

### PUT /users/profile
Update user profile.

#### Request Body
```json
{
  "firstName": "John",
  "lastName": "Smith",
  "profileImage": "base64-image-data",
  "emergencyContact": "+27987654321",
  "preferences": {
    "notifications": true,
    "shareLocation": false
  }
}
```

### POST /users/verify-student
Submit student verification documents.

#### Request Body
```json
{
  "studentIdImage": "base64-image-data",
  "additionalInfo": "Third year Computer Science student"
}
```

### POST /users/add-driver-role
Add driver role to user profile.

#### Request Body
```json
{
  "carDetails": {
    "make": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "color": "White",
    "licensePlate": "CA 123-456",
    "seats": 4
  },
  "driverLicense": "base64-image-data"
}
```

---

## 🚗 Ride Management Endpoints

### GET /rides
Get available rides with filtering and pagination.

#### Query Parameters
- `origin` (optional): Origin location filter
- `destination` (optional): Destination location filter
- `date` (optional): Date filter (YYYY-MM-DD)
- `minSeats` (optional): Minimum available seats
- `maxPrice` (optional): Maximum price per seat
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

#### Response
```json
{
  "success": true,
  "data": {
    "rides": [
      {
        "id": "ride123",
        "driverId": "user456",
        "driverInfo": {
          "firstName": "Jane",
          "lastName": "Doe",
          "rating": 4.9,
          "profileImage": "https://storage.googleapis.com/..."
        },
        "route": {
          "origin": {
            "latitude": -33.9321,
            "longitude": 18.8602,
            "address": "Stellenbosch University Campus"
          },
          "destination": {
            "latitude": -33.9248,
            "longitude": 18.8731,
            "address": "Stellenbosch Central"
          },
          "estimatedDistance": 2.5,
          "estimatedDuration": 8
        },
        "schedule": {
          "departureTime": "2024-01-15T14:30:00Z",
          "estimatedArrival": "2024-01-15T14:38:00Z"
        },
        "pricing": {
          "pricePerSeat": 25,
          "currency": "ZAR"
        },
        "capacity": {
          "totalSeats": 3,
          "availableSeats": 2,
          "confirmedRiders": 1
        },
        "status": "active",
        "carDetails": {
          "make": "Toyota",
          "model": "Corolla",
          "color": "White"
        },
        "createdAt": "2024-01-15T10:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "totalPages": 3
    }
  }
}
```

### POST /rides
Create a new ride.

#### Request Body
```json
{
  "route": {
    "origin": {
      "latitude": -33.9321,
      "longitude": 18.8602,
      "address": "Stellenbosch University Campus"
    },
    "destination": {
      "latitude": -33.9248,
      "longitude": 18.8731,
      "address": "Stellenbosch Central"
    }
  },
  "schedule": {
    "departureTime": "2024-01-15T14:30:00Z"
  },
  "pricing": {
    "pricePerSeat": 25
  },
  "capacity": {
    "totalSeats": 3
  },
  "notes": "Pick up from main gate"
}
```

### GET /rides/{rideId}
Get ride details by ID.

#### Response
```json
{
  "success": true,
  "data": {
    "ride": {
      "id": "ride123",
      // ... full ride details
      "requests": [
        {
          "riderId": "user789",
          "riderInfo": {
            "firstName": "Mike",
            "lastName": "Johnson",
            "rating": 4.7
          },
          "status": "pending",
          "requestedAt": "2024-01-15T11:00:00Z"
        }
      ],
      "confirmedRiders": [
        {
          "riderId": "user101",
          "riderInfo": {
            "firstName": "Sarah",
            "lastName": "Williams",
            "rating": 4.9
          },
          "confirmedAt": "2024-01-15T10:30:00Z"
        }
      ]
    }
  }
}
```

### PUT /rides/{rideId}
Update ride details (driver only).

#### Request Body
```json
{
  "schedule": {
    "departureTime": "2024-01-15T15:00:00Z"
  },
  "pricing": {
    "pricePerSeat": 30
  },
  "notes": "Updated pickup location"
}
```

### DELETE /rides/{rideId}
Cancel a ride (driver only).

### POST /rides/{rideId}/request
Request to join a ride.

#### Request Body
```json
{
  "message": "Hi! I'd like to join your ride to campus."
}
```

### POST /rides/{rideId}/approve
Approve a ride request (driver only).

#### Request Body
```json
{
  "riderId": "user789"
}
```

### POST /rides/{rideId}/reject
Reject a ride request (driver only).

#### Request Body
```json
{
  "riderId": "user789",
  "reason": "Ride is full"
}
```

### POST /rides/{rideId}/complete
Mark ride as completed.

#### Request Body
```json
{
  "actualDuration": 10,
  "notes": "Smooth ride, thank you!"
}
```

---

## 💳 Payment Endpoints

### POST /payments/create-intent
Create payment intent for a ride.

#### Request Body
```json
{
  "rideId": "ride123",
  "amount": 25,
  "paymentMethod": "paystack"
}
```

#### Response
```json
{
  "success": true,
  "data": {
    "paymentIntentId": "pi_123456",
    "clientSecret": "pi_123456_secret",
    "amount": 25,
    "currency": "ZAR",
    "paymentUrl": "https://checkout.paystack.com/..."
  }
}
```

### POST /payments/confirm
Confirm payment completion.

#### Request Body
```json
{
  "paymentIntentId": "pi_123456",
  "rideId": "ride123"
}
```

### GET /payments/history
Get payment history.

#### Query Parameters
- `page` (optional): Page number
- `limit` (optional): Items per page
- `status` (optional): Payment status filter

#### Response
```json
{
  "success": true,
  "data": {
    "payments": [
      {
        "id": "payment123",
        "rideId": "ride123",
        "amount": 25,
        "currency": "ZAR",
        "status": "completed",
        "paymentMethod": "paystack",
        "createdAt": "2024-01-15T14:45:00Z",
        "completedAt": "2024-01-15T14:46:00Z"
      }
    ],
    "pagination": { ... }
  }
}
```

---

## 📱 Messaging Endpoints

### GET /messages/conversations
Get user's conversations.

#### Response
```json
{
  "success": true,
  "data": {
    "conversations": [
      {
        "id": "conv123",
        "rideId": "ride123",
        "participants": [
          {
            "userId": "user123",
            "firstName": "John",
            "lastName": "Doe"
          },
          {
            "userId": "user456",
            "firstName": "Jane",
            "lastName": "Smith"
          }
        ],
        "lastMessage": {
          "text": "See you at the pickup point!",
          "senderId": "user456",
          "timestamp": "2024-01-15T14:20:00Z"
        },
        "unreadCount": 2
      }
    ]
  }
}
```

### GET /messages/conversations/{conversationId}
Get messages in a conversation.

#### Response
```json
{
  "success": true,
  "data": {
    "messages": [
      {
        "id": "msg123",
        "senderId": "user123",
        "text": "Hi! What time should I be ready?",
        "timestamp": "2024-01-15T14:15:00Z"
      },
      {
        "id": "msg124",
        "senderId": "user456",
        "text": "I'll pick you up at 2:30 PM sharp!",
        "timestamp": "2024-01-15T14:16:00Z"
      }
    ]
  }
}
```

### POST /messages/conversations/{conversationId}/send
Send a message.

#### Request Body
```json
{
  "text": "Thanks! I'll be waiting outside."
}
```

---

## 🔔 Notification Endpoints

### GET /notifications
Get user notifications.

#### Query Parameters
- `unread` (optional): Filter unread notifications
- `type` (optional): Notification type filter
- `page` (optional): Page number

#### Response
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "notif123",
        "type": "ride_request",
        "title": "New Ride Request",
        "message": "John Doe requested to join your ride to Campus",
        "data": {
          "rideId": "ride123",
          "requesterId": "user789"
        },
        "read": false,
        "createdAt": "2024-01-15T14:00:00Z"
      }
    ]
  }
}
```

### PUT /notifications/{notificationId}/read
Mark notification as read.

### POST /notifications/register-token
Register FCM token for push notifications.

#### Request Body
```json
{
  "fcmToken": "fcm-device-token",
  "platform": "android"
}
```

---

## 📊 Analytics Endpoints

### GET /analytics/user-stats
Get user statistics.

#### Response
```json
{
  "success": true,
  "data": {
    "totalRides": 23,
    "totalDistance": 125.5,
    "averageRating": 4.8,
    "moneySaved": 450,
    "co2Saved": 12.3,
    "rideHistory": {
      "asDriver": 8,
      "asRider": 15
    }
  }
}
```

### POST /analytics/track-event
Track analytics event.

#### Request Body
```json
{
  "event": "ride_completed",
  "properties": {
    "rideId": "ride123",
    "duration": 10,
    "distance": 2.5
  }
}
```

---

## 🛡️ Admin Endpoints

### GET /admin/users
Get users list (admin only).

#### Query Parameters
- `status` (optional): Verification status filter
- `university` (optional): University filter
- `page` (optional): Page number

### PUT /admin/users/{userId}/verify
Verify user account (admin only).

### GET /admin/rides/reports
Get reported rides (admin only).

### PUT /admin/rides/{rideId}/moderate
Moderate a ride (admin only).

---

## 📝 Data Models

### User Model
```typescript
interface User {
  uid: string;
  email: string;
  profile: {
    firstName: string;
    lastName: string;
    profileImage?: string;
    phoneNumber: string;
    studentNumber: string;
    university: string;
    emergencyContact?: string;
    verificationStatus: 'pending' | 'verified' | 'rejected';
    rating: number;
    totalRides: number;
    carDetails?: CarDetails;
  };
  roles: ('rider' | 'driver')[];
  preferences: UserPreferences;
  createdAt: Date;
  lastActive: Date;
}
```

### Ride Model
```typescript
interface Ride {
  id: string;
  driverId: string;
  driverInfo: {
    firstName: string;
    lastName: string;
    rating: number;
    profileImage?: string;
  };
  route: {
    origin: GeoPoint;
    destination: GeoPoint;
    originAddress: string;
    destinationAddress: string;
    estimatedDistance: number;
    estimatedDuration: number;
  };
  schedule: {
    departureTime: Date;
    estimatedArrival: Date;
    actualDeparture?: Date;
    actualArrival?: Date;
  };
  pricing: {
    pricePerSeat: number;
    currency: string;
  };
  capacity: {
    totalSeats: number;
    availableSeats: number;
    confirmedRiders: number;
  };
  status: 'active' | 'full' | 'in_progress' | 'completed' | 'cancelled';
  requests: RideRequest[];
  confirmedRiders: string[];
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}
```

---

## 🔒 Security Considerations

### Authentication
- All endpoints require valid Firebase authentication
- User roles and permissions enforced at API level
- Rate limiting on all endpoints

### Data Validation
- Input validation on all request bodies
- Sanitization of user-generated content
- File upload restrictions and scanning

### Privacy
- Personal data encryption
- Minimal data exposure in responses
- POPIA compliance for South African users

---

## 📈 Rate Limits

### Standard Users
- 100 requests per minute
- 1000 requests per hour

### Verified Users
- 200 requests per minute
- 2000 requests per hour

### Premium Features
- Unlimited API access
- Priority processing

---

## 🔄 Versioning

### Current Version: v1
- Base path: `/v1/`
- Backwards compatibility maintained
- Deprecation notices for old endpoints

### Future Versions
- `/v2/` for major breaking changes
- Migration guides provided
- Gradual deprecation of old versions 