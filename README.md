# 🎓 Examination System

## Overview

**Production-Ready Enterprise Examination System** - A comprehensive full-stack application for managing educational assessments, built with modern technologies and professional architecture.

> **Technology Stack**: Angular 19 + .NET 8 Web API + SQL Server with Dapper + 132 Stored Procedures

---

## 🌟 Key Features

### 🔐 Authentication & Security
- **JWT + Refresh Tokens** with secure cookie storage
- **Session Management** with multi-device support
- **Role-Based Access Control** (4 roles: Admin, TrainingManager, Instructor, Student)
- **Password Security** with bcrypt hashing and complexity requirements
- **Guest Guard** for public routes protection

### 📊 Advanced Analytics (NEW!)
- **Question Difficulty Analysis** - AI-powered question quality assessment
- **At-Risk Student Detection** - Identify struggling students early
- **Performance Predictions** - ML-based grade predictions with confidence scores
- **Real-Time Monitoring** - Live exam session tracking

### 🎓 Academic Management
- **Multi-Branch Support** - Manage multiple training centers
- **Track System** - Specializations (.NET, Mobile, Data Science, etc.)
- **Intake Management** - Quarterly student batches
- **Course Management** - Complete catalog with prerequisites

### 📝 Examination Features
- **Multiple Question Types** - MCQ, True/False, Text responses
- **Random Question Selection** - Fair exam generation
- **Timed Exams** - Automatic submission on timeout
- **Auto-Grading** - Instant MCQ/TF grading
- **Remedial Exams** - Second chance system for failed students
- **Live Monitoring** - Real-time proctoring for instructors

### 📧 Communication
- **Email Queue System** - Async email processing
- **In-App Notifications** - Real-time alerts
- **SignalR Integration** - Live updates

### 📈 Reporting
- **Dashboard Analytics** - Role-specific statistics
- **Exam Results Reports** - Comprehensive grade analysis
- **Performance Trends** - Historical tracking
- **Audit Logs** - Complete activity tracking

---

## 🛠️ Technology Stack

### Frontend (Angular 19)
```typescript
✅ Standalone Components Architecture
✅ Angular Signals for Reactive State
✅ Lazy Loading with Route-based Code Splitting
✅ Bootstrap 5 + Custom SCSS Theming
✅ Reactive Forms with Custom Validators
✅ HTTP Interceptors for Auth & Error Handling
✅ Role-Based Guards (authGuard, roleGuard, guestGuard)
```

### Backend (.NET 8 Web API)
```csharp
✅ Clean Architecture (API → Application → Domain → Infrastructure)
✅ Dapper ORM with Stored Procedures
✅ Repository Pattern with Dependency Injection
✅ JWT Bearer Authentication
✅ Custom Middleware (Error Handling, Request Logging)
✅ SignalR for Real-Time Features
✅ API Versioning Ready
```

### Database (SQL Server)
```sql
✅ 132 Stored Procedures across 5 Schemas
✅ Event Sourcing for Audit Trail
✅ Optimized Indexes for Performance
✅ Security Schema for Auth Data
✅ Analytics Schema for Reporting
```

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ & npm
- .NET 8 SDK
- SQL Server 2019+

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd Examination_System
```

2. **Database Setup**
```bash
# Run the complete database script
sqlcmd -S localhost -d master -i Complete_Database_Script.sql
```

3. **Backend Setup**
```bash
cd ExaminationSystem-Api-Project/src/ExaminationSystem.Api
dotnet restore
dotnet run
# API runs on: https://localhost:5001
```

4. **Frontend Setup**
```bash
cd ExaminationSystem-Angular
npm install
ng serve
# App runs on: http://localhost:4200
```

---

## 🔐 Test Accounts

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | Test@123 |
| Training Manager | manager.training | Test@123 |
| Instructor | dr.ahmed | Test@123 |
| Student | std.youssef | Test@123 |

---

## 📁 Project Structure

```
Examination_System/
├── ExaminationSystem-Api-Project/
│   ├── src/
│   │   ├── ExaminationSystem.Api/          # Controllers, Hubs, Middleware
│   │   ├── ExaminationSystem.Application/  # Services, Abstractions
│   │   ├── ExaminationSystem.Domain/       # Entities, Identity
│   │   └── ExaminationSystem.Infrastructure/ # Data, Repositories
│   └── ExaminationSystem.sln
│
├── ExaminationSystem-Angular/
│   └── src/
│       ├── app/
│       │   ├── core/           # Services, Guards, Interceptors, Models
│       │   ├── features/       # Admin, Manager, Instructor, Student, Auth
│       │   └── shared/         # Layout, Components
│       └── environments/
│
└── SQl_Scripts/
    ├── 01_Database_Schema/
    ├── 02_Stored_Procedures/
    ├── 03_Functions/
    ├── 04_Views/
    ├── 05_Triggers/
    └── 08_Test_Data/
```

---

## 🎯 API Endpoints Summary

### Authentication (8 endpoints)
- POST `/api/auth/login` - User login
- POST `/api/auth/refresh` - Token refresh
- POST `/api/auth/logout` - Session logout
- GET `/api/auth/profile` - Current user profile

### Admin (15+ endpoints)
- CRUD `/api/admin/users` - User management
- GET `/api/admin/audit-logs` - Activity logs
- GET/PUT `/api/admin/settings` - System settings

### Manager (25+ endpoints)
- CRUD for Courses, Branches, Tracks, Intakes
- Student & Instructor management
- Enrollment operations
- Reports & Analytics

### Instructor (20+ endpoints)
- Question Bank management
- Exam creation & configuration
- Grading & Results
- Live monitoring

### Student (15+ endpoints)
- Available exams list
- Take exam with timer
- View results & progress
- Course information

### Analytics (5 endpoints)
- GET `/api/analytics/dashboard` - Statistics
- GET `/api/analytics/questions/difficulty` - Question analysis
- GET `/api/analytics/at-risk-students` - Risk detection
- GET `/api/analytics/students/{id}/prediction` - Performance prediction

---

## ✨ Technical Highlights

1. **Zero Hardcoded Data** - All data from database via SPs
2. **Unified Error Handling** - Global exception middleware
3. **Request/Response Logging** - Full audit trail
4. **Optimized Queries** - Indexed SPs with execution plans
5. **Secure by Default** - HTTPS, HttpOnly cookies, CORS configured
6. **Scalable Architecture** - Ready for horizontal scaling
7. **Event Sourcing** - Complete history tracking
8. **Real-Time Updates** - SignalR for live features

---

## 📄 License

This project is licensed under the MIT License.

---

## 👥 Contributors

- **Ahmed Yossry** - Lead Developer

---

> Built with ❤️ for educational excellence
