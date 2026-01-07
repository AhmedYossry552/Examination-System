using System;
using System.Text;
using System.Collections.Generic;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using Serilog;
using ExaminationSystem.Domain.Identity;
using ExaminationSystem.Infrastructure.Data;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Infrastructure.Services;
using ExaminationSystem.Infrastructure.Repositories;
using Microsoft.AspNetCore.Diagnostics;
using System.Text.Json;
using Microsoft.AspNetCore.Http;
using FluentValidation;
using FluentValidation.AspNetCore;
using ExaminationSystem.Application.Abstractions.Models;
using Quartz;

var builder = WebApplication.CreateBuilder(args);

Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .CreateLogger();

builder.Host.UseSerilog();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    // Resolve schema conflicts by using full type names for duplicates
    c.CustomSchemaIds(type => type.FullName?.Replace("+", "_"));
});

// FluentValidation
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<Program>();
builder.Services.AddValidatorsFromAssemblyContaining<CreateExamDto>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", p => p
        .AllowAnyOrigin()
        .AllowAnyHeader()
        .AllowAnyMethod());
});

builder.Services.Configure<JwtOptions>(builder.Configuration.GetSection("Jwt"));

var jwtSection = builder.Configuration.GetSection("Jwt");
var key = Encoding.UTF8.GetBytes(jwtSection["Key"] ?? "");
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSection["Issuer"],
        ValidAudience = jwtSection["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ClockSkew = TimeSpan.FromMinutes(1)
    };
});

builder.Services.AddAuthorization();

builder.Services.AddApiVersioning(o =>
{
    o.AssumeDefaultVersionWhenUnspecified = true;
});

builder.Services.AddHealthChecks()
    .AddSqlServer(builder.Configuration.GetConnectionString("Default") ?? throw new InvalidOperationException("Connection string 'Default' not found"));

builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("fixed", opts =>
    {
        opts.PermitLimit = 100;
        opts.Window = TimeSpan.FromMinutes(1);
        opts.QueueLimit = 0;
    });
});

builder.Services.AddOutputCache();
builder.Services.AddSignalR();
builder.Services.AddQuartz(q =>
{
    var jobKey = new Quartz.JobKey("EmailQueueJob");
    q.AddJob<ExaminationSystem.Infrastructure.Jobs.EmailQueueJob>(opts => opts.WithIdentity(jobKey));
    q.AddTrigger(t => t
        .ForJob(jobKey)
        .WithIdentity("EmailQueueJob-trigger")
        .WithSimpleSchedule(x => x.WithInterval(TimeSpan.FromMinutes(1)).RepeatForever()));
});
builder.Services.AddQuartzHostedService(options =>
{
    options.WaitForJobsToComplete = true;
});

builder.Services.AddScoped<IDbConnectionFactory, SqlConnectionFactory>();
builder.Services.AddScoped<IAuthRepository, AuthRepository>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IStudentRepository, StudentRepository>();
builder.Services.AddScoped<IStudentService, StudentService>();
builder.Services.AddScoped<IInstructorRepository, InstructorRepository>();
builder.Services.AddScoped<IInstructorService, InstructorService>();
builder.Services.AddScoped<IManagerRepository, ManagerRepository>();
builder.Services.AddScoped<IManagerService, ManagerService>();
builder.Services.AddScoped<IAdminRepository, AdminRepository>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<IProfileRepository, ProfileRepository>();
builder.Services.AddScoped<IProfileService, ProfileService>();
builder.Services.AddScoped<INotificationRepository, NotificationRepository>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IAnalyticsRepository, AnalyticsRepository>();
builder.Services.AddScoped<IAnalyticsService, AnalyticsService>();
builder.Services.AddScoped<IMonitoringRepository, MonitoringRepository>();
builder.Services.AddScoped<IMonitoringService, MonitoringService>();
builder.Services.AddScoped<ISessionRepository, SessionRepository>();
builder.Services.AddScoped<ISessionService, SessionService>();
builder.Services.AddScoped<IEventRepository, EventRepository>();
builder.Services.AddScoped<IEventService, EventService>();
builder.Services.AddScoped<IAdvancedFeaturesRepository, AdvancedFeaturesRepository>();
builder.Services.AddScoped<IAdvancedFeaturesService, AdvancedFeaturesService>();
builder.Services.AddScoped<IViewsRepository, ViewsRepository>();
builder.Services.AddScoped<IViewsService, ViewsService>();
builder.Services.AddSingleton<IExamMonitorNotifier, ExaminationSystem.Api.Hubs.ExamMonitorNotifier>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseSerilogRequestLogging();

app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        var feature = context.Features.Get<IExceptionHandlerFeature>();
        var exception = feature?.Error;
        
        // Map exception types to appropriate HTTP status codes
        // Handle SqlException with error 50000 (RAISERROR for auth failures) as 401
        var (status, title) = exception switch
        {
            Microsoft.Data.SqlClient.SqlException sqlEx when sqlEx.Number == 50000 
                && (sqlEx.Message.Contains("Invalid username") || sqlEx.Message.Contains("Invalid password") || sqlEx.Message.Contains("Invalid refresh token"))
                => (401, "Unauthorized"),
            UnauthorizedAccessException => (401, "Unauthorized"),
            KeyNotFoundException => (404, "Not Found"),
            ArgumentException => (400, "Bad Request"),
            InvalidOperationException => (400, "Bad Request"),
            _ => (500, "An unexpected error occurred.")
        };
        
        var problem = new
        {
            title = title,
            status = status,
            detail = app.Environment.IsDevelopment() ? exception?.Message : (status == 500 ? null : exception?.Message),
            traceId = context.TraceIdentifier
        };
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = status;
        await context.Response.WriteAsync(JsonSerializer.Serialize(problem));
    });
});

app.UseCors("AllowAll");
app.UseRateLimiter();
app.UseOutputCache();

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");
app.MapHub<ExaminationSystem.Api.Hubs.ExamMonitorHub>("/hubs/monitor");

app.Run();
