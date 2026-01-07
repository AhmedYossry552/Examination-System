/*=============================================
  Examination System - Permissions Assignment
  Description: Assigns specific permissions to each role
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

PRINT 'Assigning Permissions to Roles...';
GO

-- =============================================
-- Admin Role Permissions (Full Access)
-- =============================================

-- Grant full access to all schemas
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Academic TO db_ExamAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Exam TO db_ExamAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Security TO db_ExamAdmin;
GO

-- Grant EXECUTE on all stored procedures
GRANT EXECUTE ON SCHEMA::Academic TO db_ExamAdmin;
GRANT EXECUTE ON SCHEMA::Exam TO db_ExamAdmin;
GRANT EXECUTE ON SCHEMA::Security TO db_ExamAdmin;
GO

-- Grant SELECT on all views
GRANT SELECT ON SCHEMA::Academic TO db_ExamAdmin;
GRANT SELECT ON SCHEMA::Exam TO db_ExamAdmin;
GRANT SELECT ON SCHEMA::Security TO db_ExamAdmin;
GO

PRINT 'Admin permissions granted.';
GO

-- =============================================
-- Training Manager Role Permissions
-- =============================================

-- Read access to all tables
GRANT SELECT ON SCHEMA::Academic TO db_ExamTrainingManager;
GRANT SELECT ON SCHEMA::Exam TO db_ExamTrainingManager;
GRANT SELECT ON Security.[User] TO db_ExamTrainingManager;
GRANT SELECT ON Security.VW_UserDetails TO db_ExamTrainingManager;
GO

-- Manage courses, branches, tracks, intakes
GRANT INSERT, UPDATE, DELETE ON Academic.Course TO db_ExamTrainingManager;
GRANT INSERT, UPDATE, DELETE ON Academic.Branch TO db_ExamTrainingManager;
GRANT INSERT, UPDATE, DELETE ON Academic.Track TO db_ExamTrainingManager;
GRANT INSERT, UPDATE, DELETE ON Academic.Intake TO db_ExamTrainingManager;
GRANT INSERT, UPDATE, DELETE ON Academic.CourseInstructor TO db_ExamTrainingManager;
GO

-- Manage students and instructors
GRANT INSERT, UPDATE ON Academic.Student TO db_ExamTrainingManager;
GRANT INSERT, UPDATE ON Academic.Instructor TO db_ExamTrainingManager;
GRANT INSERT, UPDATE ON Security.[User] TO db_ExamTrainingManager;
GO

-- Execute training manager procedures
GRANT EXECUTE ON Academic.SP_Course_Add TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Course_Update TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Branch_Add TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Track_Add TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Intake_Add TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Student_Add TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Student_Update TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Instructor_Add TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Instructor_AssignToCourse TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Course_GetAll TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Branch_GetAll TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Track_GetByBranch TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Intake_GetAll TO db_ExamTrainingManager;
GRANT EXECUTE ON Academic.SP_Student_GetByIntakeBranchTrack TO db_ExamTrainingManager;
GRANT EXECUTE ON Security.SP_Admin_CreateUser TO db_ExamTrainingManager;
GRANT EXECUTE ON Security.SP_Admin_UpdateUser TO db_ExamTrainingManager;
GRANT EXECUTE ON Security.SP_Admin_GetSystemStatistics TO db_ExamTrainingManager;
GO

-- Access to all views
GRANT SELECT ON Academic.VW_StudentDetails TO db_ExamTrainingManager;
GRANT SELECT ON Academic.VW_InstructorDetails TO db_ExamTrainingManager;
GRANT SELECT ON Academic.VW_CourseDetails TO db_ExamTrainingManager;
GRANT SELECT ON Exam.VW_ExamDetails TO db_ExamTrainingManager;
GRANT SELECT ON Exam.VW_ExamStatistics TO db_ExamTrainingManager;
GRANT SELECT ON Security.VW_DashboardOverview TO db_ExamTrainingManager;
GO

PRINT 'Training Manager permissions granted.';
GO

-- =============================================
-- Instructor Role Permissions
-- =============================================

-- Read access to relevant tables
GRANT SELECT ON Academic.Course TO db_ExamInstructor;
GRANT SELECT ON Academic.Student TO db_ExamInstructor;
GRANT SELECT ON Academic.StudentCourse TO db_ExamInstructor;
GRANT SELECT ON Academic.CourseInstructor TO db_ExamInstructor;
GRANT SELECT ON Academic.Intake TO db_ExamInstructor;
GRANT SELECT ON Academic.Branch TO db_ExamInstructor;
GRANT SELECT ON Academic.Track TO db_ExamInstructor;
GRANT SELECT ON Security.[User] TO db_ExamInstructor;
GO

-- Manage questions (only their own)
GRANT SELECT, INSERT, UPDATE ON Exam.Question TO db_ExamInstructor;
GRANT SELECT, INSERT, UPDATE, DELETE ON Exam.QuestionOption TO db_ExamInstructor;
GRANT SELECT, INSERT, UPDATE, DELETE ON Exam.QuestionAnswer TO db_ExamInstructor;
GO

-- Manage exams (only their own)
GRANT SELECT, INSERT, UPDATE ON Exam.Exam TO db_ExamInstructor;
GRANT SELECT, INSERT, UPDATE, DELETE ON Exam.ExamQuestion TO db_ExamInstructor;
GRANT SELECT, INSERT, UPDATE ON Exam.StudentExam TO db_ExamInstructor;
GO

-- Grade student answers
GRANT SELECT, UPDATE ON Exam.StudentAnswer TO db_ExamInstructor;
GO

-- Execute instructor procedures
GRANT EXECUTE ON Academic.SP_Instructor_GetMyCourses TO db_ExamInstructor;
GRANT EXECUTE ON Academic.SP_Instructor_GetCourseStudents TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Instructor_GetExamsToGrade TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Instructor_GradeTextAnswer TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Instructor_GetExamStatistics TO db_ExamInstructor;
GRANT EXECUTE ON Academic.SP_Instructor_UpdateCourseFinalGrades TO db_ExamInstructor;
GO

GRANT EXECUTE ON Exam.SP_Question_Add TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Question_AddOption TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Question_AddAnswer TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Question_Update TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Question_Delete TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Question_GetByCourse TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Question_GetWithOptions TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Question_GetRandomByType TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Question_GetStatistics TO db_ExamInstructor;
GO

GRANT EXECUTE ON Exam.SP_Exam_Create TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Exam_AddQuestion TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Exam_GenerateRandom TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Exam_AssignToStudents TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Exam_AssignToAllCourseStudents TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Exam_GetQuestions TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Exam_Update TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_Exam_Delete TO db_ExamInstructor;
GO

-- Access to instructor views
GRANT SELECT ON Academic.VW_InstructorDetails TO db_ExamInstructor;
GRANT SELECT ON Academic.VW_CourseDetails TO db_ExamInstructor;
GRANT SELECT ON Academic.VW_StudentDetails TO db_ExamInstructor;
GRANT SELECT ON Academic.VW_InstructorCourseAssignment TO db_ExamInstructor;
GRANT SELECT ON Exam.VW_ExamDetails TO db_ExamInstructor;
GRANT SELECT ON Exam.VW_QuestionPool TO db_ExamInstructor;
GRANT SELECT ON Exam.VW_StudentExamResults TO db_ExamInstructor;
GRANT SELECT ON Exam.VW_StudentAnswerDetails TO db_ExamInstructor;
GRANT SELECT ON Exam.VW_PendingGrading TO db_ExamInstructor;
GRANT SELECT ON Exam.VW_ExamStatistics TO db_ExamInstructor;
GO

PRINT 'Instructor permissions granted.';
GO

-- =============================================
-- Student Role Permissions
-- =============================================

-- Read access to their own data only
GRANT SELECT ON Academic.Course TO db_ExamStudent;
GRANT SELECT ON Academic.StudentCourse TO db_ExamStudent;
GRANT SELECT ON Academic.Intake TO db_ExamStudent;
GRANT SELECT ON Academic.Branch TO db_ExamStudent;
GRANT SELECT ON Academic.Track TO db_ExamStudent;
GO

-- Access to exams (limited)
GRANT SELECT ON Exam.Exam TO db_ExamStudent;
GRANT SELECT ON Exam.ExamQuestion TO db_ExamStudent;
GRANT SELECT ON Exam.Question TO db_ExamStudent;
GRANT SELECT ON Exam.QuestionOption TO db_ExamStudent;
GRANT SELECT ON Exam.StudentExam TO db_ExamStudent;
GO

-- Submit answers
GRANT SELECT, INSERT, UPDATE ON Exam.StudentAnswer TO db_ExamStudent;
GO

-- Execute student procedures
GRANT EXECUTE ON Exam.SP_Student_GetAvailableExams TO db_ExamStudent;
GRANT EXECUTE ON Exam.SP_Student_StartExam TO db_ExamStudent;
GRANT EXECUTE ON Exam.SP_Student_SubmitAnswer TO db_ExamStudent;
GRANT EXECUTE ON Exam.SP_Student_SubmitExam TO db_ExamStudent;
GRANT EXECUTE ON Exam.SP_Student_GetExamResults TO db_ExamStudent;
GRANT EXECUTE ON Academic.SP_Student_GetCourseGrades TO db_ExamStudent;
GRANT EXECUTE ON Academic.SP_Student_EnrollInCourse TO db_ExamStudent;
GRANT EXECUTE ON Security.SP_Admin_AuthenticateUser TO db_ExamStudent;
GRANT EXECUTE ON Security.SP_Admin_ChangePassword TO db_ExamStudent;
GO

GRANT EXECUTE ON Exam.SP_Exam_GetQuestions TO db_ExamStudent;
GO

-- Access to student views
GRANT SELECT ON Academic.VW_StudentDetails TO db_ExamStudent;
GRANT SELECT ON Academic.VW_CourseDetails TO db_ExamStudent;
GRANT SELECT ON Academic.VW_CourseEnrollment TO db_ExamStudent;
GRANT SELECT ON Exam.VW_ExamDetails TO db_ExamStudent;
GRANT SELECT ON Exam.VW_StudentExamResults TO db_ExamStudent;
GO

PRINT 'Student permissions granted.';
GO

-- =============================================
-- Deny Sensitive Operations
-- =============================================

-- Students cannot see other students' data
DENY SELECT ON Security.[User] TO db_ExamStudent;
DENY SELECT ON Academic.Student TO db_ExamStudent;
DENY SELECT ON Academic.Instructor TO db_ExamStudent;
GO

-- Students cannot see correct answers before exam
DENY SELECT ON Exam.QuestionAnswer TO db_ExamStudent;
GO

-- Instructors cannot modify audit logs
DENY INSERT, UPDATE, DELETE ON Security.AuditLog TO db_ExamInstructor;
DENY INSERT, UPDATE, DELETE ON Security.AuditLog TO db_ExamTrainingManager;
GO

PRINT 'All permissions assigned successfully!';
GO

-- =============================================
-- Grant Permissions on Advanced Schemas
-- =============================================

-- Grant permissions on EventStore schema
GRANT SELECT, INSERT ON SCHEMA::EventStore TO db_ExamAdmin;
GRANT SELECT ON SCHEMA::EventStore TO db_ExamTrainingManager;
GRANT SELECT ON SCHEMA::EventStore TO db_ExamInstructor;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::EventStore TO db_ExamStudent;
GO

-- Grant permissions on Analytics schema
GRANT EXECUTE ON SCHEMA::Analytics TO db_ExamAdmin;
GRANT EXECUTE ON SCHEMA::Analytics TO db_ExamTrainingManager;
GRANT EXECUTE ON SCHEMA::Analytics TO db_ExamInstructor;
DENY EXECUTE ON SCHEMA::Analytics TO db_ExamStudent;
GO

-- =============================================
-- Grant Permissions on Event Sourcing Procedures
-- =============================================

-- Admin: Full access to event sourcing
GRANT EXECUTE ON EventStore.SP_AppendEvent TO db_ExamAdmin;
GRANT EXECUTE ON EventStore.SP_GetAggregateEvents TO db_ExamAdmin;
GRANT EXECUTE ON EventStore.SP_GetUserTimeline TO db_ExamAdmin;
GRANT EXECUTE ON EventStore.SP_GetSystemActivity TO db_ExamAdmin;
GRANT EXECUTE ON EventStore.SP_GetStudentExamJourney TO db_ExamAdmin;
GRANT EXECUTE ON EventStore.SP_GetCorrelatedEvents TO db_ExamAdmin;
GRANT EXECUTE ON EventStore.SP_CreateSnapshot TO db_ExamAdmin;
GRANT EXECUTE ON EventStore.SP_GetEventStatistics TO db_ExamAdmin;
GRANT EXECUTE ON EventStore.SP_ArchiveOldEvents TO db_ExamAdmin;
GO

-- Training Manager: Read-only event access
GRANT EXECUTE ON EventStore.SP_GetUserTimeline TO db_ExamTrainingManager;
GRANT EXECUTE ON EventStore.SP_GetSystemActivity TO db_ExamTrainingManager;
GRANT EXECUTE ON EventStore.SP_GetEventStatistics TO db_ExamTrainingManager;
GO

-- Instructor: Limited event access
GRANT EXECUTE ON EventStore.SP_GetStudentExamJourney TO db_ExamInstructor;
GRANT EXECUTE ON EventStore.SP_GetUserTimeline TO db_ExamInstructor;
GO

-- =============================================
-- Grant Permissions on Remedial Exam Procedures
-- =============================================

-- Instructor: Can manage remedial exams
GRANT EXECUTE ON Exam.SP_AutoAssignRemedialExams TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_GetRemedialExamCandidates TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_GetRemedialExamProgress TO db_ExamInstructor;
GRANT EXECUTE ON Exam.SP_GetStudentRemedialHistory TO db_ExamInstructor;
GO

-- Training Manager: Full access
GRANT EXECUTE ON Exam.SP_AutoAssignRemedialExams TO db_ExamTrainingManager;
GRANT EXECUTE ON Exam.SP_GetRemedialExamCandidates TO db_ExamTrainingManager;
GRANT EXECUTE ON Exam.SP_GetRemedialExamProgress TO db_ExamTrainingManager;
GRANT EXECUTE ON Exam.SP_GetStudentRemedialHistory TO db_ExamTrainingManager;
GO

-- Admin: Full access
GRANT EXECUTE ON Exam.SP_AutoAssignRemedialExams TO db_ExamAdmin;
GRANT EXECUTE ON Exam.SP_GetRemedialExamCandidates TO db_ExamAdmin;
GRANT EXECUTE ON Exam.SP_GetRemedialExamProgress TO db_ExamAdmin;
GRANT EXECUTE ON Exam.SP_GetStudentRemedialHistory TO db_ExamAdmin;
GO

-- Student: Can only view their own remedial history
GRANT EXECUTE ON Exam.SP_GetStudentRemedialHistory TO db_ExamStudent;
GO

-- =============================================
-- Grant Permissions on Smart Analytics Procedures
-- =============================================

-- Admin: Full analytics access
GRANT EXECUTE ON Analytics.SP_AnalyzeQuestionDifficulty TO db_ExamAdmin;
GRANT EXECUTE ON Analytics.SP_PredictStudentPerformance TO db_ExamAdmin;
GRANT EXECUTE ON Analytics.SP_IdentifyAtRiskStudents TO db_ExamAdmin;
GRANT EXECUTE ON Analytics.SP_GetCoursePerformanceDashboard TO db_ExamAdmin;
GO

-- Training Manager: Full analytics access
GRANT EXECUTE ON Analytics.SP_AnalyzeQuestionDifficulty TO db_ExamTrainingManager;
GRANT EXECUTE ON Analytics.SP_PredictStudentPerformance TO db_ExamTrainingManager;
GRANT EXECUTE ON Analytics.SP_IdentifyAtRiskStudents TO db_ExamTrainingManager;
GRANT EXECUTE ON Analytics.SP_GetCoursePerformanceDashboard TO db_ExamTrainingManager;
GO

-- Instructor: Analytics for their courses
GRANT EXECUTE ON Analytics.SP_AnalyzeQuestionDifficulty TO db_ExamInstructor;
GRANT EXECUTE ON Analytics.SP_PredictStudentPerformance TO db_ExamInstructor;
GRANT EXECUTE ON Analytics.SP_IdentifyAtRiskStudents TO db_ExamInstructor;
GRANT EXECUTE ON Analytics.SP_GetCoursePerformanceDashboard TO db_ExamInstructor;
GO

-- =============================================
-- Grant Permissions on Real-Time Monitoring Views
-- =============================================

-- Admin: Full monitoring access
GRANT SELECT ON Exam.VW_LiveExamMonitoring TO db_ExamAdmin;
GRANT SELECT ON Exam.VW_ExamSessionStatistics TO db_ExamAdmin;
GRANT SELECT ON Exam.VW_SuspiciousActivityMonitor TO db_ExamAdmin;
GO

-- Training Manager: Full monitoring access
GRANT SELECT ON Exam.VW_LiveExamMonitoring TO db_ExamTrainingManager;
GRANT SELECT ON Exam.VW_ExamSessionStatistics TO db_ExamTrainingManager;
GRANT SELECT ON Exam.VW_SuspiciousActivityMonitor TO db_ExamTrainingManager;
GO

-- Instructor: Monitoring for their exams
GRANT SELECT ON Exam.VW_LiveExamMonitoring TO db_ExamInstructor;
GRANT SELECT ON Exam.VW_ExamSessionStatistics TO db_ExamInstructor;
GRANT SELECT ON Exam.VW_SuspiciousActivityMonitor TO db_ExamInstructor;
GO

-- Students: No monitoring access
DENY SELECT ON Exam.VW_LiveExamMonitoring TO db_ExamStudent;
DENY SELECT ON Exam.VW_ExamSessionStatistics TO db_ExamStudent;
DENY SELECT ON Exam.VW_SuspiciousActivityMonitor TO db_ExamStudent;
GO

PRINT '✓ Advanced features permissions assigned successfully!';
GO

-- =============================================
-- Grant Permissions on Authentication Enhancement
-- =============================================

-- Refresh Tokens: Users can manage their own tokens
GRANT EXECUTE ON Security.SP_CreateRefreshToken TO PUBLIC;
GRANT EXECUTE ON Security.SP_ValidateRefreshToken TO PUBLIC;
GRANT EXECUTE ON Security.SP_RevokeRefreshToken TO PUBLIC;
GO

-- Admin: Full access to refresh tokens
GRANT EXECUTE ON Security.SP_RevokeAllUserRefreshTokens TO db_ExamAdmin;
GRANT EXECUTE ON Security.SP_CleanupExpiredRefreshTokens TO db_ExamAdmin;
GRANT EXECUTE ON Security.SP_GetUserRefreshTokens TO db_ExamAdmin;
GO

-- API Keys: Admin only
GRANT EXECUTE ON Security.SP_CreateAPIKey TO db_ExamAdmin;
GRANT EXECUTE ON Security.SP_ValidateAPIKey TO db_ExamAdmin;
GRANT EXECUTE ON Security.SP_RevokeAPIKey TO db_ExamAdmin;
GRANT EXECUTE ON Security.SP_GetAllAPIKeys TO db_ExamAdmin;
GRANT EXECUTE ON Security.SP_LogAPIRequest TO db_ExamAdmin;
GRANT EXECUTE ON Security.SP_GetAPIUsageStatistics TO db_ExamAdmin;
GRANT EXECUTE ON Security.SP_ResetAPIKeyRateLimit TO db_ExamAdmin;
GO

-- API Keys: Training Manager (read-only)
GRANT EXECUTE ON Security.SP_GetAllAPIKeys TO db_ExamTrainingManager;
GRANT EXECUTE ON Security.SP_GetAPIUsageStatistics TO db_ExamTrainingManager;
GO

PRINT '✓ Authentication enhancement permissions assigned successfully!';
GO

-- =============================================
-- Grant Authentication Procedure to Public
-- =============================================
GRANT EXECUTE ON Security.SP_Admin_AuthenticateUser TO PUBLIC;
GO

PRINT 'Security configuration completed!';
GO
