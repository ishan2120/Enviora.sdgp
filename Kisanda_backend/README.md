# Flutter Backend API
Node.js · Express · MongoDB · JWT

---

## 📁 Project Structure

```
backend/
 ├── controllers/
 │    └── authController.js    ← register, login, getProfile logic
 ├── models/
 │    └── User.js              ← Mongoose schema + password hashing
 ├── routes/
 │    └── authRoutes.js        ← route definitions
 ├── middleware/
 │    └── authMiddleware.js    ← JWT token verification
 ├── config/
 │    └── db.js                ← MongoDB connection
 ├── server.js                 ← app entry point
 ├── .env                      ← environment variables
 └── package.json
```

---

## ⚙️ Installation & Setup

### 1. Install dependencies
```bash
npm install
```

### 2. Configure environment variables
Edit `.env`:
```
PORT=5000
MONGO_URI=mongodb://localhost:27017/flutter_app
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRES_IN=7d
```
> 💡 For cloud MongoDB, replace MONGO_URI with your **MongoDB Atlas** connection string.

### 3. Run the server
```bash
# Development (auto-restart on changes)
npm run dev

# Production
npm start
```

Server will start at: `http://localhost:5000`

---

## 📡 API Endpoints

### POST `/api/auth/register`
Register a new user.

**Request body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "secret123"
}
```

**Success response (201):**
```json
{
  "success": true,
  "message": "Account created successfully.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "64f1a2b3c4d5e6f7a8b9c0d1",
      "name": "John Doe",
      "email": "john@example.com",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

**Error response (409):**
```json
{
  "success": false,
  "message": "An account with this email already exists."
}
```

---

### POST `/api/auth/login`
Login with email and password.

**Request body:**
```json
{
  "email": "john@example.com",
  "password": "secret123"
}
```

**Success response (200):**
```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "64f1a2b3c4d5e6f7a8b9c0d1",
      "name": "John Doe",
      "email": "john@example.com",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

**Error response (401):**
```json
{
  "success": false,
  "message": "Invalid email or password."
}
```

---

### GET `/api/user/profile` 🔒 Protected
Get the logged-in user's profile. Requires JWT token.

**Request headers:**
```
Authorization: Bearer <your_token_here>
```

**Success response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "64f1a2b3c4d5e6f7a8b9c0d1",
      "name": "John Doe",
      "email": "john@example.com",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

**Error response (401):**
```json
{
  "success": false,
  "message": "Access denied. No token provided."
}
```

---

## 📱 Flutter Integration

### 1. Add `http` package to `pubspec.yaml`
```yaml
dependencies:
  http: ^1.1.0
```

### 2. API Service class
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS/web
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // ── Register ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // ── Login ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // ── Get Profile ───────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }
}
```

### 3. Example usage in Flutter
```dart
// Login example
void handleLogin() async {
  final result = await ApiService.login(
    email: emailController.text,
    password: passwordController.text,
  );

  if (result['success'] == true) {
    final token = result['data']['token'];
    final user  = result['data']['user'];
    // Save token to SharedPreferences and navigate to home
    print('Welcome ${user['name']}!');
  } else {
    print('Error: ${result['message']}');
  }
}
```

---

## 🌐 Deploying to Production (Railway / Render)

1. Push code to GitHub
2. Connect repo to [Railway](https://railway.app) or [Render](https://render.com)
3. Add environment variables in the dashboard
4. Update Flutter's `baseUrl` to your production URL

---

## 🛡️ Security Checklist

- [x] Passwords hashed with bcrypt (12 salt rounds)
- [x] JWT tokens expire after 7 days
- [x] Passwords never returned in API responses
- [x] Input validation on all endpoints
- [x] Generic error messages for auth failures (prevents user enumeration)
- [ ] Change `JWT_SECRET` to a long random string before deploying
- [ ] Use MongoDB Atlas with IP whitelist in production
