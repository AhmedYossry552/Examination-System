namespace ExaminationSystem.Application.Abstractions.Models
{
    // =============================================
    // DTOs for Database Views
    // =============================================

    #region Security Views

    /// <summary>
    /// DTO for Security.VW_UserDetails view
    /// </summary>
    public class UserDetailsViewDto
    {
        public int UserID { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string UserType { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? LastLoginDate { get; set; }
        public int? RoleID { get; set; }
    }

    #endregion

    #region Academic Views

    /// <summary>
    /// DTO for Academic.VW_StudentDetails view
    /// </summary>
    public class StudentDetailsViewDto
    {
        public int StudentID { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public DateTime EnrollmentDate { get; set; }
        public DateTime? GraduationDate { get; set; }
        public decimal? GPA { get; set; }
        public int IntakeID { get; set; }
        public string IntakeName { get; set; } = string.Empty;
        public int IntakeYear { get; set; }
        public int BranchID { get; set; }
        public string BranchName { get; set; } = string.Empty;
        public string BranchLocation { get; set; } = string.Empty;
        public int TrackID { get; set; }
        public string TrackName { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public int CoursesEnrolled { get; set; }
        public int ExamsCompleted { get; set; }
    }

    /// <summary>
    /// DTO for Academic.VW_InstructorDetails view
    /// </summary>
    public class InstructorDetailsViewDto
    {
        public int InstructorID { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? Specialization { get; set; }
        public DateTime HireDate { get; set; }
        public bool IsTrainingManager { get; set; }
        public bool IsActive { get; set; }
        public int CoursesTeaching { get; set; }
        public int ExamsCreated { get; set; }
        public int QuestionsCreated { get; set; }
    }

    /// <summary>
    /// DTO for Academic.VW_CourseDetails view
    /// </summary>
    public class CourseDetailsViewDto
    {
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public string? CourseDescription { get; set; }
        public decimal MaxDegree { get; set; }
        public decimal MinDegree { get; set; }
        public int TotalHours { get; set; }
        public bool IsActive { get; set; }
        public int InstructorCount { get; set; }
        public int StudentsEnrolled { get; set; }
        public int ExamCount { get; set; }
        public int QuestionCount { get; set; }
    }

    /// <summary>
    /// DTO for Academic.VW_CourseEnrollment view
    /// </summary>
    public class CourseEnrollmentViewDto
    {
        public int StudentCourseID { get; set; }
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public decimal MaxDegree { get; set; }
        public decimal MinDegree { get; set; }
        public DateTime EnrollmentDate { get; set; }
        public DateTime? CompletionDate { get; set; }
        public decimal? FinalGrade { get; set; }
        public bool? IsPassed { get; set; }
        public string LetterGrade { get; set; } = string.Empty;
    }

    /// <summary>
    /// DTO for Academic.VW_InstructorCourseAssignment view
    /// </summary>
    public class InstructorCourseAssignmentViewDto
    {
        public int CourseInstructorID { get; set; }
        public int InstructorID { get; set; }
        public string InstructorName { get; set; } = string.Empty;
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public int IntakeID { get; set; }
        public string IntakeName { get; set; } = string.Empty;
        public int BranchID { get; set; }
        public string BranchName { get; set; } = string.Empty;
        public int TrackID { get; set; }
        public string TrackName { get; set; } = string.Empty;
        public DateTime AssignedDate { get; set; }
        public bool IsActive { get; set; }
        public int StudentCount { get; set; }
    }

    #endregion

    #region Exam Views

    /// <summary>
    /// DTO for Exam.VW_ExamDetails view
    /// </summary>
    public class ExamDetailsViewDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public int ExamYear { get; set; }
        public string ExamType { get; set; } = string.Empty;
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public int InstructorID { get; set; }
        public string InstructorName { get; set; } = string.Empty;
        public int IntakeID { get; set; }
        public string IntakeName { get; set; } = string.Empty;
        public int BranchID { get; set; }
        public string BranchName { get; set; } = string.Empty;
        public int TrackID { get; set; }
        public string TrackName { get; set; } = string.Empty;
        public decimal TotalMarks { get; set; }
        public decimal PassMarks { get; set; }
        public int DurationMinutes { get; set; }
        public DateTime StartDateTime { get; set; }
        public DateTime EndDateTime { get; set; }
        public string? ExamWindow { get; set; }
        public string? AllowanceOptions { get; set; }
        public bool IsActive { get; set; }
        public int QuestionCount { get; set; }
        public int StudentsAssigned { get; set; }
        public int SubmissionsReceived { get; set; }
        public string ExamStatus { get; set; } = string.Empty;
    }

    /// <summary>
    /// DTO for Exam.VW_QuestionPool view
    /// </summary>
    public class QuestionPoolViewDto
    {
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public string DifficultyLevel { get; set; } = string.Empty;
        public decimal Points { get; set; }
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public int InstructorID { get; set; }
        public string CreatorName { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public int UsedInExamCount { get; set; }
    }

    /// <summary>
    /// DTO for Exam.VW_StudentExamResults view
    /// </summary>
    public class StudentExamResultsViewDto
    {
        public int StudentExamID { get; set; }
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string ExamType { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public decimal TotalMarks { get; set; }
        public decimal PassMarks { get; set; }
        public decimal? TotalScore { get; set; }
        public decimal? Percentage { get; set; }
        public bool? IsPassed { get; set; }
        public bool IsGraded { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? SubmissionTime { get; set; }
        public int? TimeTakenMinutes { get; set; }
        public string IntakeName { get; set; } = string.Empty;
        public string BranchName { get; set; } = string.Empty;
        public string TrackName { get; set; } = string.Empty;
    }

    /// <summary>
    /// DTO for Exam.VW_StudentAnswerDetails view
    /// </summary>
    public class StudentAnswerDetailsViewDto
    {
        public int StudentAnswerID { get; set; }
        public int StudentExamID { get; set; }
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public string? StudentAnswerText { get; set; }
        public string? SelectedOptionText { get; set; }
        public bool? IsCorrect { get; set; }
        public decimal MaxMarks { get; set; }
        public decimal? MarksObtained { get; set; }
        public bool NeedsManualGrading { get; set; }
        public string? InstructorComments { get; set; }
        public DateTime? AnsweredDate { get; set; }
        public DateTime? GradedDate { get; set; }
    }

    /// <summary>
    /// DTO for Exam.VW_PendingGrading view
    /// </summary>
    public class PendingGradingViewDto
    {
        public int StudentAnswerID { get; set; }
        public int InstructorID { get; set; }
        public string InstructorName { get; set; } = string.Empty;
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public string? StudentAnswerText { get; set; }
        public decimal MaxMarks { get; set; }
        public DateTime? AnsweredDate { get; set; }
        public string? ModelAnswer { get; set; }
    }

    /// <summary>
    /// DTO for Exam.VW_ExamStatistics view
    /// </summary>
    public class ExamStatisticsViewDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public decimal TotalMarks { get; set; }
        public decimal PassMarks { get; set; }
        public int TotalStudents { get; set; }
        public int CompletedCount { get; set; }
        public int PassedCount { get; set; }
        public int FailedCount { get; set; }
        public decimal? AverageScore { get; set; }
        public decimal? HighestScore { get; set; }
        public decimal? LowestScore { get; set; }
        public decimal? StandardDeviation { get; set; }
    }

    /// <summary>
    /// DTO for Exam.VW_TextAnswersAnalysis view (BONUS FEATURE)
    /// </summary>
    public class TextAnswersAnalysisViewDto
    {
        // Student Information
        public int StudentAnswerID { get; set; }
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string StudentEmail { get; set; } = string.Empty;

        // Exam Information
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public int InstructorID { get; set; }
        public string InstructorName { get; set; } = string.Empty;

        // Question Information
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public decimal MaxMarks { get; set; }

        // Answer Content
        public string? StudentAnswerText { get; set; }
        public string? ModelAnswer { get; set; }
        public string? RegexPattern { get; set; }
        public bool CaseSensitive { get; set; }

        // AI-like Similarity Analysis
        public decimal? SimilarityScore { get; set; }
        public string AnswerClassification { get; set; } = string.Empty;
        public decimal? SuggestedMarks { get; set; }

        // Grading Status
        public decimal? AssignedMarks { get; set; }
        public bool? IsCorrect { get; set; }
        public bool NeedsManualGrading { get; set; }
        public string? InstructorComments { get; set; }
        public DateTime? AnsweredDate { get; set; }
        public DateTime? GradedDate { get; set; }

        // Analysis Metrics
        public int AnswerLength { get; set; }
        public int ModelAnswerLength { get; set; }
        public int KeywordsMatched { get; set; }
        public int TotalKeywords { get; set; }

        // Time Metrics
        public int? HoursWaiting { get; set; }
        public int IsPendingGrading { get; set; }
        public int GradingPriorityScore { get; set; }
    }

    #endregion
}
