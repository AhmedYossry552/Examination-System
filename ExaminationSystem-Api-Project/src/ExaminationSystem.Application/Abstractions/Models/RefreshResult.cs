using System;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public record RefreshResult(string AccessToken, DateTime AccessTokenExpiresAt, string RefreshToken);
}
