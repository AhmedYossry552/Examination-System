-- Insert Event/Audit Test Data for QA Testing
USE ExaminationSystemDB;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- Clear existing events (optional)
-- DELETE FROM EventStore.Events;

-- Insert test events
INSERT INTO EventStore.Events (EventType, AggregateType, AggregateID, EventData, OccurredAt, UserID, UserType, CorrelationID, IPAddress)
VALUES 
-- Admin login events
('UserLoggedIn', 'User', '1', '{"Username":"admin","Role":"Admin"}', DATEADD(MINUTE, -5, GETDATE()), 1, 'Admin', NEWID(), '192.168.1.100'),
('UserLoggedIn', 'User', '1', '{"Username":"admin","Role":"Admin"}', DATEADD(HOUR, -1, GETDATE()), 1, 'Admin', NEWID(), '192.168.1.100'),

-- Instructor events  
('UserLoggedIn', 'User', '2', '{"Username":"dr.ahmed","Role":"Instructor"}', DATEADD(HOUR, -2, GETDATE()), 2, 'Instructor', NEWID(), '192.168.1.101'),
('ExamCreated', 'Exam', '1', '{"ExamName":"Database Midterm","CourseID":1,"TotalMarks":50}', DATEADD(DAY, -5, GETDATE()), 2, 'Instructor', NEWID(), '192.168.1.101'),
('QuestionAdded', 'Question', '1', '{"QuestionText":"What is SQL?","ExamID":1,"Marks":5}', DATEADD(DAY, -5, GETDATE()), 2, 'Instructor', NEWID(), '192.168.1.101'),
('QuestionAdded', 'Question', '2', '{"QuestionText":"What is normalization?","ExamID":1,"Marks":5}', DATEADD(DAY, -5, GETDATE()), 2, 'Instructor', NEWID(), '192.168.1.101'),

-- Training Manager events
('StudentEnrolled', 'Student', '1', '{"StudentID":1,"CourseID":1,"IntakeID":1}', DATEADD(DAY, -10, GETDATE()), 7, 'TrainingManager', NEWID(), '192.168.1.102'),
('StudentEnrolled', 'Student', '2', '{"StudentID":2,"CourseID":1,"IntakeID":1}', DATEADD(DAY, -10, GETDATE()), 7, 'TrainingManager', NEWID(), '192.168.1.102'),
('BranchCreated', 'Branch', '4', '{"BranchName":"QA Test Branch","Location":"Test Location"}', DATEADD(MINUTE, -30, GETDATE()), 7, 'TrainingManager', NEWID(), '192.168.1.102'),

-- Student events
('UserLoggedIn', 'User', '8', '{"Username":"std.youssef","Role":"Student"}', DATEADD(HOUR, -3, GETDATE()), 8, 'Student', NEWID(), '192.168.1.103'),
('ExamStarted', 'Exam', '1', '{"StudentID":1,"ExamID":1}', DATEADD(HOUR, -3, GETDATE()), 8, 'Student', NEWID(), '192.168.1.103'),
('AnswerSubmitted', 'Answer', '1', '{"QuestionID":1,"SelectedOptionID":1}', DATEADD(HOUR, -3, GETDATE()), 8, 'Student', NEWID(), '192.168.1.103'),
('AnswerSubmitted', 'Answer', '2', '{"QuestionID":2,"SelectedOptionID":5}', DATEADD(HOUR, -3, GETDATE()), 8, 'Student', NEWID(), '192.168.1.103'),
('ExamSubmitted', 'Exam', '1', '{"StudentID":1,"ExamID":1,"Score":85}', DATEADD(HOUR, -2, GETDATE()), 8, 'Student', NEWID(), '192.168.1.103'),

-- Grading events
('GradeAssigned', 'Grade', '1', '{"StudentID":1,"ExamID":1,"Grade":"A","Score":85}', DATEADD(HOUR, -1, GETDATE()), 2, 'Instructor', NEWID(), '192.168.1.101');

-- Verify
SELECT COUNT(*) AS TotalEvents FROM EventStore.Events;
SELECT TOP 5 EventType, AggregateType, UserType, OccurredAt FROM EventStore.Events ORDER BY OccurredAt DESC;
GO
