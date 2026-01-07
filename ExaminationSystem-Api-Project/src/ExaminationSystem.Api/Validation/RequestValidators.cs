using System.Linq;
using FluentValidation;
using ExaminationSystem.Api.Controllers;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Validation
{
    public class LoginRequestValidator : AbstractValidator<AuthController.LoginRequest>
    {
        public LoginRequestValidator()
        {
            RuleFor(x => x.Username).NotEmpty().MinimumLength(3).MaximumLength(50);
            RuleFor(x => x.Password).NotEmpty().MinimumLength(6).MaximumLength(100);
        }
    }

    public class RefreshRequestValidator : AbstractValidator<AuthController.RefreshRequest>
    {
        public RefreshRequestValidator()
        {
            RuleFor(x => x.RefreshToken).NotEmpty();
        }
    }

    public class LogoutRequestValidator : AbstractValidator<AuthController.LogoutRequest>
    {
        public LogoutRequestValidator()
        {
            RuleFor(x => x.RefreshToken).NotEmpty();
        }
    }

    public class SubmitAnswerRequestValidator : AbstractValidator<StudentController.SubmitAnswerRequest>
    {
        public SubmitAnswerRequestValidator()
        {
            RuleFor(x => x.QuestionId).GreaterThan(0);
            RuleFor(x => x.SelectedOptionId).GreaterThan(0).When(x => x.SelectedOptionId.HasValue);
            RuleFor(x => x.AnswerText).MaximumLength(4000);
            RuleFor(x => x)
                .Must(x => !string.IsNullOrWhiteSpace(x.AnswerText) || x.SelectedOptionId.HasValue)
                .WithMessage("Either AnswerText or SelectedOptionId must be provided.");
        }
    }

    public class AddQuestionRequestValidator : AbstractValidator<InstructorController.AddQuestionRequest>
    {
        public AddQuestionRequestValidator()
        {
            RuleFor(x => x.QuestionId).GreaterThan(0);
            RuleFor(x => x.Order).GreaterThan(0);
            RuleFor(x => x.Marks).GreaterThan(0);
        }
    }

    public class AssignStudentsRequestValidator : AbstractValidator<InstructorController.AssignStudentsRequest>
    {
        public AssignStudentsRequestValidator()
        {
            RuleFor(x => x.StudentIds).NotNull().Must(s => s.Any()).WithMessage("StudentIds cannot be empty.");
            RuleForEach(x => x.StudentIds).GreaterThan(0);
            RuleFor(x => x.StudentIds)
                .Must(ids => ids.Distinct().Count() == ids.Count())
                .WithMessage("StudentIds must be unique.");
        }
    }

    public class GradeAnswerRequestValidator : AbstractValidator<InstructorController.GradeAnswerRequest>
    {
        public GradeAnswerRequestValidator()
        {
            RuleFor(x => x.MarksObtained).GreaterThanOrEqualTo(0);
            RuleFor(x => x.Comments).MaximumLength(500);
        }
    }

    public class AssignInstructorRequestValidator : AbstractValidator<ManagerController.AssignInstructorRequest>
    {
        public AssignInstructorRequestValidator()
        {
            RuleFor(x => x.InstructorId).GreaterThan(0);
            RuleFor(x => x.IntakeId).GreaterThan(0);
            RuleFor(x => x.BranchId).GreaterThan(0);
            RuleFor(x => x.TrackId).GreaterThan(0);
        }
    }

    public class CreateExamDtoValidator : AbstractValidator<CreateExamDto>
    {
        public CreateExamDtoValidator()
        {
            RuleFor(x => x.CourseID).GreaterThan(0);
            RuleFor(x => x.IntakeID).GreaterThan(0);
            RuleFor(x => x.BranchID).GreaterThan(0);
            RuleFor(x => x.TrackID).GreaterThan(0);
            RuleFor(x => x.ExamName).NotEmpty().MaximumLength(200);
            RuleFor(x => x.ExamYear).InclusiveBetween(2020, 2100);
            RuleFor(x => x.ExamType).NotEmpty()
                .Must(t => new[] { "Regular", "Corrective", "Remedial" }.Contains(t))
                .WithMessage("ExamType must be Regular, Corrective, or Remedial.");
            RuleFor(x => x.TotalMarks).GreaterThan(0);
            RuleFor(x => x.PassMarks).GreaterThanOrEqualTo(0).LessThanOrEqualTo(x => x.TotalMarks);
            RuleFor(x => x.DurationMinutes).GreaterThan(0);
            RuleFor(x => x.EndDateTime).GreaterThan(x => x.StartDateTime)
                .WithMessage("EndDateTime must be after StartDateTime.");
            RuleFor(x => x.AllowanceOptions).MaximumLength(500).When(x => x.AllowanceOptions != null);
        }
    }

    public class GenerateRandomDtoValidator : AbstractValidator<GenerateRandomDto>
    {
        public GenerateRandomDtoValidator()
        {
            RuleFor(x => x.MultipleChoiceCount).GreaterThanOrEqualTo(0);
            RuleFor(x => x.TrueFalseCount).GreaterThanOrEqualTo(0);
            RuleFor(x => x.TextCount).GreaterThanOrEqualTo(0);
            RuleFor(x => x.MarksPerMC).GreaterThan(0);
            RuleFor(x => x.MarksPerTF).GreaterThan(0);
            RuleFor(x => x.MarksPerText).GreaterThan(0);
        }
    }

    public class CreateCourseDtoValidator : AbstractValidator<CreateCourseDto>
    {
        public CreateCourseDtoValidator()
        {
            RuleFor(x => x.CourseName).NotEmpty().MaximumLength(100);
            RuleFor(x => x.CourseCode).NotEmpty().MaximumLength(20);
            RuleFor(x => x.CourseDescription).MaximumLength(1000).When(x => x.CourseDescription != null);
            RuleFor(x => x.MaxDegree).GreaterThan(0);
            RuleFor(x => x.MinDegree).GreaterThanOrEqualTo(0).LessThan(x => x.MaxDegree);
            RuleFor(x => x.TotalHours).GreaterThan(0);
        }
    }

    public class UpdateCourseDtoValidator : AbstractValidator<UpdateCourseDto>
    {
        public UpdateCourseDtoValidator()
        {
            RuleFor(x => x.CourseName).MaximumLength(100).When(x => x.CourseName != null);
            RuleFor(x => x.CourseDescription).MaximumLength(1000).When(x => x.CourseDescription != null);
            RuleFor(x => x.MaxDegree).GreaterThan(0).When(x => x.MaxDegree.HasValue);
            RuleFor(x => x.MinDegree).GreaterThanOrEqualTo(0).When(x => x.MinDegree.HasValue);
            RuleFor(x => x.TotalHours).GreaterThan(0).When(x => x.TotalHours.HasValue);
            RuleFor(x => x).Must(x => !(x.MaxDegree.HasValue && x.MinDegree.HasValue) || x.MaxDegree > x.MinDegree)
                .WithMessage("MaxDegree must be greater than MinDegree.");
        }
    }

    public class CreateBranchDtoValidator : AbstractValidator<CreateBranchDto>
    {
        public CreateBranchDtoValidator()
        {
            RuleFor(x => x.BranchName).NotEmpty().MaximumLength(100);
            RuleFor(x => x.BranchLocation).NotEmpty().MaximumLength(200);
            RuleFor(x => x.BranchManager).MaximumLength(100).When(x => x.BranchManager != null);
            RuleFor(x => x.PhoneNumber).MaximumLength(20).When(x => x.PhoneNumber != null);
            RuleFor(x => x.Email).EmailAddress().When(x => x.Email != null);
        }
    }

    public class UpdateBranchDtoValidator : AbstractValidator<UpdateBranchDto>
    {
        public UpdateBranchDtoValidator()
        {
            RuleFor(x => x.BranchName).MaximumLength(100).When(x => x.BranchName != null);
            RuleFor(x => x.BranchLocation).MaximumLength(200).When(x => x.BranchLocation != null);
            RuleFor(x => x.BranchManager).MaximumLength(100).When(x => x.BranchManager != null);
            RuleFor(x => x.PhoneNumber).MaximumLength(20).When(x => x.PhoneNumber != null);
            RuleFor(x => x.Email).EmailAddress().When(x => x.Email != null);
        }
    }

    public class CreateTrackDtoValidator : AbstractValidator<CreateTrackDto>
    {
        public CreateTrackDtoValidator()
        {
            RuleFor(x => x.TrackName).NotEmpty().MaximumLength(100);
            RuleFor(x => x.BranchID).GreaterThan(0);
            RuleFor(x => x.TrackDescription).MaximumLength(500).When(x => x.TrackDescription != null);
            RuleFor(x => x.DurationMonths).GreaterThan(0);
        }
    }

    public class UpdateTrackDtoValidator : AbstractValidator<UpdateTrackDto>
    {
        public UpdateTrackDtoValidator()
        {
            RuleFor(x => x.TrackName).MaximumLength(100).When(x => x.TrackName != null);
            RuleFor(x => x.TrackDescription).MaximumLength(500).When(x => x.TrackDescription != null);
            RuleFor(x => x.DurationMonths).GreaterThan(0).When(x => x.DurationMonths.HasValue);
        }
    }

    public class CreateIntakeDtoValidator : AbstractValidator<CreateIntakeDto>
    {
        public CreateIntakeDtoValidator()
        {
            RuleFor(x => x.IntakeName).NotEmpty().MaximumLength(50);
            RuleFor(x => x.IntakeYear).InclusiveBetween(2000, 2100);
            RuleFor(x => x.IntakeNumber).GreaterThan(0);
            RuleFor(x => x.EndDate).GreaterThan(x => x.StartDate);
        }
    }

    public class UpdateIntakeDtoValidator : AbstractValidator<UpdateIntakeDto>
    {
        public UpdateIntakeDtoValidator()
        {
            RuleFor(x => x.IntakeName).MaximumLength(50).When(x => x.IntakeName != null);
            RuleFor(x => x.IntakeYear).InclusiveBetween(2000, 2100).When(x => x.IntakeYear.HasValue);
            RuleFor(x => x.IntakeNumber).GreaterThan(0).When(x => x.IntakeNumber.HasValue);
            RuleFor(x => x)
                .Must(x => !(x.StartDate.HasValue && x.EndDate.HasValue) || x.EndDate > x.StartDate)
                .WithMessage("EndDate must be after StartDate.");
        }
    }

    // Question Pool Validators
    public class CreateQuestionDtoValidator : AbstractValidator<CreateQuestionDto>
    {
        public CreateQuestionDtoValidator()
        {
            RuleFor(x => x.CourseID).GreaterThan(0);
            RuleFor(x => x.QuestionText).NotEmpty().MaximumLength(2000);
            RuleFor(x => x.QuestionType).NotEmpty().Must(type => 
                type.Equals("MultipleChoice", StringComparison.OrdinalIgnoreCase) ||
                type.Equals("TrueFalse", StringComparison.OrdinalIgnoreCase) ||
                type.Equals("Text", StringComparison.OrdinalIgnoreCase))
                .WithMessage("QuestionType must be MultipleChoice, TrueFalse, or Text.");
            RuleFor(x => x.DifficultyLevel).Must(level => 
                level.Equals("Easy", StringComparison.OrdinalIgnoreCase) ||
                level.Equals("Medium", StringComparison.OrdinalIgnoreCase) ||
                level.Equals("Hard", StringComparison.OrdinalIgnoreCase))
                .WithMessage("DifficultyLevel must be Easy, Medium, or Hard.");
            RuleFor(x => x.Points).GreaterThan(0);
        }
    }

    public class UpdateQuestionDtoValidator : AbstractValidator<UpdateQuestionDto>
    {
        public UpdateQuestionDtoValidator()
        {
            RuleFor(x => x.QuestionText).MaximumLength(2000).When(x => x.QuestionText != null);
            RuleFor(x => x.DifficultyLevel).Must(level => 
                level != null && (
                    level.Equals("Easy", StringComparison.OrdinalIgnoreCase) ||
                    level.Equals("Medium", StringComparison.OrdinalIgnoreCase) ||
                    level.Equals("Hard", StringComparison.OrdinalIgnoreCase)))
                .When(x => x.DifficultyLevel != null)
                .WithMessage("DifficultyLevel must be Easy, Medium, or Hard.");
            RuleFor(x => x.Points).GreaterThan(0).When(x => x.Points.HasValue);
        }
    }

    public class CreateQuestionOptionDtoValidator : AbstractValidator<CreateQuestionOptionDto>
    {
        public CreateQuestionOptionDtoValidator()
        {
            RuleFor(x => x.OptionText).NotEmpty().MaximumLength(500);
            RuleFor(x => x.OptionOrder).GreaterThan(0);
        }
    }

    public class CreateQuestionAnswerDtoValidator : AbstractValidator<CreateQuestionAnswerDto>
    {
        public CreateQuestionAnswerDtoValidator()
        {
            RuleFor(x => x.CorrectAnswer).NotEmpty().MaximumLength(1000);
            RuleFor(x => x.AnswerPattern).MaximumLength(500).When(x => x.AnswerPattern != null);
        }
    }
}
