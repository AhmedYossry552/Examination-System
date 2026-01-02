# 🎓 Examination System API

<div align="center">

![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![JWT](https://img.shields.io/badge/JWT-000000?style=for-the-badge&logo=json-web-tokens&logoColor=white)
![SignalR](https://img.shields.io/badge/SignalR-512BD4?style=for-the-badge&logo=signalr&logoColor=white)
![Swagger](https://img.shields.io/badge/Swagger-85EA2D?style=for-the-badge&logo=swagger&logoColor=black)

**Enterprise-Grade Online Examination System**

A comprehensive, production-ready examination management system built with Clean Architecture principles.

[Features](#-features) • [Architecture](#-architecture) • [Getting Started](#-getting-started) • [API Reference](#-api-reference) • [Database](#-database)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Getting Started](#-getting-started)
- [API Reference](#-api-reference)
- [Database Schema](#-database-schema)
- [Authentication](#-authentication)
- [Real-time Features](#-real-time-features)
- [Contributing](#-contributing)

---

## 🎯 Overview

The **Examination System API** is a full-featured backend solution for managing online examinations. It supports multiple user roles, various question types, automated grading, real-time monitoring, and comprehensive analytics.

### Key Highlights

- ✅ **Complete Exam Lifecycle** - Create, assign, take, grade, and analyze exams
- ✅ **Multi-Role Support** - Admin, Training Manager, Instructor, Student
- ✅ **Smart Grading** - Auto-grading for MCQ/TF + AI-assisted text analysis
- ✅ **Real-time Monitoring** - Live exam tracking with SignalR
- ✅ **Advanced Analytics** - Performance prediction & at-risk student detection
- ✅ **Enterprise Security** - JWT authentication with refresh tokens

---

## ✨ Features

### 👨‍🎓 Student Features
| Feature | Description |
|---------|-------------|
| View Available Exams | See all assigned exams with status and timing |
| Take Exams | Answer questions with auto-save functionality |
| View Results | Detailed results with correct answers and feedback |
| Track Progress | GPA, course progress, and performance trends |

### 👨‍🏫 Instructor Features
| Feature | Description |
|---------|-------------|
| Question Bank | Create MCQ, True/False, and Text questions |
| Exam Creation | Manual selection or random generation |
| Student Assignment | Assign to specific students or entire course |
| Grading | Auto-grading + AI-assisted text answer analysis |
| Reports | Detailed statistics and performance analytics |

### 👔 Manager Features
| Feature | Description |
|---------|-------------|
| Academic Structure | Manage Branches, Tracks, Intakes |
| Course Management | CRUD operations for courses |
| User Management | Create and manage Students/Instructors |
| Instructor Assignment | Assign instructors to courses |

### 🔧 Admin Features
| Feature | Description |
|---------|-------------|
| User Administration | Full CRUD for all user types |
| Password Reset | Reset passwords for any user |
| Session Management | Monitor and terminate user sessions |
| System Analytics | Dashboard with comprehensive metrics |

### 🚀 Advanced Features
| Feature | Description |
|---------|-------------|
| Real-time Monitoring | Live exam tracking via SignalR |
| Suspicious Activity Detection | Detect potential cheating |
| Event Sourcing | Complete audit trail of all actions |
| Performance Prediction | AI-based student performance prediction |
| At-Risk Detection | Identify struggling students early |
| Email Queue | Async email with retry logic |
| Multi-device Sessions | Track and manage user sessions |

---

## 🏗 Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
ExaminationSystem-Api-Project/
├── src/
│   ├── ExaminationSystem.Api/           # Presentation Layer
│   │   ├── Controllers/                 # REST API endpoints
│   │   ├── Hubs/                        # SignalR hubs
│   │   ├── Validation/                  # FluentValidation validators
│   │   └── Program.cs                   # DI & Middleware config
│   │
│   ├── ExaminationSystem.Application/   # Application Layer
│   │   └── Abstractions/
│   │       ├── Interfaces/              # Service & Repository contracts
│   │       └── Models/                  # DTOs
│   │
│   ├── ExaminationSystem.Infrastructure/# Infrastructure Layer
│   │   ├── Services/                    # Business logic implementation
│   │   ├── Repositories/                # Data access (Dapper + SPs)
│   │   ├── Jobs/                        # Background jobs (Quartz)
│   │   └── Data/                        # Database connection
│   │
│   └── ExaminationSystem.Domain/        # Domain Layer
│       └── Identity/                    # JWT configuration
```

### Design Patterns Used
- **Repository Pattern** - Data access abstraction
- **Service Pattern** - Business logic encapsulation
- **Dependency Injection** - Loose coupling
- **CQRS-lite** - Separate read/write operations via Stored Procedures

---

## 🛠 Technology Stack

| Category | Technology |
|----------|------------|
| **Framework** | .NET 8.0 |
| **Database** | SQL Server with Stored Procedures |
| **ORM** | Dapper (Micro-ORM) |
| **Authentication** | JWT Bearer Tokens |
| **Real-time** | SignalR |
| **Validation** | FluentValidation |
| **Logging** | Serilog |
| **Background Jobs** | Quartz.NET |
| **API Documentation** | Swagger/OpenAPI |
| **Rate Limiting** | ASP.NET Core Rate Limiter |

---

## 🚀 Getting Started

### Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) (LocalDB, Express, or Full)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) or [VS Code](https://code.visualstudio.com/)

### Installation

#### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/Examination_System.git
cd Examination_System
```

#### 2. Setup Database
```sql
-- In SQL Server Management Studio (SSMS)
-- Execute the complete database script
:r "Complete_Database_Script.sql"
GO
```

Or run individual scripts in order from `SQl_Scripts/` folder.

#### 3. Configure Connection String

Update `appsettings.Development.json`:
```json
{
  "ConnectionStrings": {
    "Default": "Server=.;Database=ExaminationSystemDB;Trusted_Connection=True;TrustServerCertificate=True"
  },
  "Jwt": {
    "Key": "YourSuperSecretKeyHere_AtLeast32Characters",
    "Issuer": "ExaminationSystem",
    "Audience": "ExaminationClient",
    "AccessTokenMinutes": 30
  }
}
```

#### 4. Run the API
```bash
cd ExaminationSystem-Api-Project/src/ExaminationSystem.Api
dotnet run
```

#### 5. Access the API
- **Swagger UI**: https://localhost:7066/swagger
- **Health Check**: https://localhost:7066/health

### Default Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | Admin@123 |

---

## 📡 API Reference

### Base URL
```
https://localhost:7066/api/v1
```

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login and get tokens |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | Logout and revoke token |

### Student Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/student/available-exams` | Get available exams |
| GET | `/student/progress` | Get student progress |
| POST | `/student/exams/{id}/start` | Start an exam |
| GET | `/student/exams/{id}` | Get exam questions |
| POST | `/student/exams/{id}/answers` | Submit an answer |
| POST | `/student/exams/{id}/submit` | Submit entire exam |
| GET | `/student/exams/{id}/results` | Get exam results |

### Instructor Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/instructor/my-courses` | Get assigned courses |
| POST | `/instructor/exams` | Create new exam |
| POST | `/instructor/exams/{id}/generate-random` | Generate random questions |
| POST | `/instructor/exams/{id}/assign-all` | Assign to all students |
| GET | `/instructor/grading/pending` | Get exams to grade |
| POST | `/instructor/grading/answers/{id}` | Grade text answer |
| GET | `/instructor/exams/{id}/statistics` | Get exam statistics |
| POST | `/instructor/questions` | Add question to pool |
| GET | `/instructor/text-answers/analysis` | Get AI text analysis |

### Manager Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/manager/branches` | List all branches |
| GET | `/manager/intakes` | List all intakes |
| GET | `/manager/courses` | List all courses |
| POST | `/manager/students` | Create student account |
| POST | `/manager/instructors` | Create instructor account |
| POST | `/manager/courses/{id}/assign-instructor` | Assign instructor |

### Admin Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/users` | List all users |
| POST | `/admin/users` | Create new user |
| PUT | `/admin/users/{id}` | Update user |
| DELETE | `/admin/users/{id}` | Delete user |
| POST | `/admin/users/{id}/reset-password` | Reset password |

### Analytics Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/analytics/dashboard` | System dashboard |
| GET | `/analytics/questions/difficulty` | Question analysis |
| GET | `/analytics/students/{id}/prediction` | Performance prediction |
| GET | `/analytics/at-risk-students` | At-risk students |

### Additional Endpoints

| Module | Endpoints |
|--------|-----------|
| **Profile** | GET/PUT `/profile/me`, POST `/profile/change-password` |
| **Notifications** | GET `/notifications`, POST `/notifications/{id}/read` |
| **Sessions** | GET `/sessions/me/active`, DELETE `/sessions/me` |
| **Monitoring** | GET `/monitoring/live-exams`, `/monitoring/suspicious-activity` |
| **Events** | GET `/events/user/{id}/timeline`, `/events/students/{id}/exams/{id}/journey` |

---

## 🗃 Database Schema

### Core Tables (22 Tables)

```
Security Schema:
├── User                 # All system users
├── RefreshToken         # JWT refresh tokens
├── UserSession          # Active sessions
├── Notification         # User notifications
├── EmailQueue           # Email queue for async sending
└── PasswordResetToken   # Password reset tokens

Academic Schema:
├── Branch               # Training centers
├── Track                # Specializations
├── Intake               # Student batches
├── Course               # Courses/subjects
├── Instructor           # Instructor profiles
├── Student              # Student profiles
├── InstructorCourse     # Instructor-Course mapping
└── StudentCourse        # Student-Course enrollment

Exam Schema:
├── Question             # Question bank
├── QuestionOption       # MCQ options
├── QuestionAnswer       # Correct answers
├── Exam                 # Exam definitions
├── ExamQuestion         # Exam-Question mapping
├── StudentExam          # Student exam attempts
└── StudentAnswer        # Student answers
```

### Database Objects

| Type | Count | Description |
|------|-------|-------------|
| Tables | 22 | Core + enhanced tables |
| Stored Procedures | 97+ | All CRUD + business logic |
| Functions | 15 | Business calculations |
| Views | 16 | Data access + analytics |
| Triggers | 14 | Auto-grading + validation |
| Indexes | 62+ | Performance optimization |

---

## 🔐 Authentication

### JWT Token Flow

```
┌─────────┐         ┌─────────┐         ┌─────────┐
│ Client  │         │   API   │         │   DB    │
└────┬────┘         └────┬────┘         └────┬────┘
     │   POST /login     │                   │
     │──────────────────>│                   │
     │                   │  Validate User    │
     │                   │──────────────────>│
     │                   │<──────────────────│
     │                   │                   │
     │   Access Token    │                   │
     │   + Refresh Token │                   │
     │<──────────────────│                   │
     │                   │                   │
     │  API Request      │                   │
     │  + Bearer Token   │                   │
     │──────────────────>│                   │
     │                   │                   │
```

### Token Details

| Token | Lifetime | Purpose |
|-------|----------|---------|
| Access Token | 30 minutes | API authentication |
| Refresh Token | 30 days | Get new access token |
| Session Token | 8 hours | Track active sessions |

### Roles & Permissions

| Role | Permissions |
|------|-------------|
| **Admin** | Full system access |
| **TrainingManager** | Academic management + Instructor access |
| **Instructor** | Course, exam, and grading management |
| **Student** | Take exams and view results |

---

## ⚡ Real-time Features

### SignalR Hub

Connect to the monitoring hub for real-time updates:

```javascript
const connection = new signalR.HubConnectionBuilder()
    .withUrl("/hubs/monitor", {
        accessTokenFactory: () => accessToken
    })
    .build();

connection.on("examStarted", (data) => {
    console.log("Student started exam:", data);
});

connection.on("answerSubmitted", (data) => {
    console.log("Answer submitted:", data);
});

connection.on("examSubmitted", (data) => {
    console.log("Exam submitted:", data);
});
```

### Events Broadcast

| Event | Trigger | Data |
|-------|---------|------|
| `examStarted` | Student starts exam | userId, studentId, examId |
| `answerSubmitted` | Student submits answer | userId, studentId, examId, questionId |
| `examSubmitted` | Student submits exam | userId, studentId, examId |

---

## 📊 Question Types

### 1. Multiple Choice (MCQ)
```json
{
  "questionText": "What is the capital of France?",
  "questionType": "MultipleChoice",
  "options": [
    { "optionText": "London", "isCorrect": false },
    { "optionText": "Paris", "isCorrect": true },
    { "optionText": "Berlin", "isCorrect": false },
    { "optionText": "Madrid", "isCorrect": false }
  ]
}
```

### 2. True/False
```json
{
  "questionText": "The Earth is flat.",
  "questionType": "TrueFalse",
  "options": [
    { "optionText": "True", "isCorrect": false },
    { "optionText": "False", "isCorrect": true }
  ]
}
```

### 3. Text (Essay)
```json
{
  "questionText": "Explain the concept of polymorphism in OOP.",
  "questionType": "Text",
  "answer": {
    "correctAnswer": "Polymorphism allows objects of different classes to be treated as objects of a common base class...",
    "answerPattern": "polymorphism|inheritance|override|virtual"
  }
}
```

---

## 🧪 Testing

### Using the Test Script
```powershell
cd scripts
.\test-api.ps1
```

### Sample API Requests

#### Login
```bash
curl -X POST https://localhost:7066/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "Admin@123"}'
```

#### Get Available Exams (as Student)
```bash
curl -X GET https://localhost:7066/api/v1/student/available-exams \
  -H "Authorization: Bearer {access_token}"
```

---

## 📈 Performance

### Optimizations Implemented

- ✅ **Stored Procedures** - All data access via optimized SPs
- ✅ **Strategic Indexes** - 62+ indexes for query optimization
- ✅ **Output Caching** - Response caching for read operations
- ✅ **Rate Limiting** - 100 requests/minute per client
- ✅ **Connection Pooling** - Efficient database connections
- ✅ **Async/Await** - Non-blocking I/O operations

---

## 🔒 Security Features

| Feature | Implementation |
|---------|----------------|
| Authentication | JWT Bearer Tokens |
| Authorization | Role-based Access Control (RBAC) |
| Token Rotation | Refresh token rotation on use |
| Password Hashing | Secure hashing in database |
| Rate Limiting | Fixed window rate limiter |
| Input Validation | FluentValidation on all inputs |
| SQL Injection Prevention | Parameterized Stored Procedures |
| CORS | Configurable CORS policy |

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👥 Authors

- **Your Name** - *Initial work* - [GitHub Profile](https://github.com/yourusername)

---

## 🙏 Acknowledgments

- ITI (Information Technology Institute) for project requirements
- Microsoft for .NET and SQL Server documentation
- The open-source community for amazing tools and libraries

---

<div align="center">

**⭐ Star this repository if you find it helpful! ⭐**

Made with ❤️ using .NET 8 & SQL Server

</div>
