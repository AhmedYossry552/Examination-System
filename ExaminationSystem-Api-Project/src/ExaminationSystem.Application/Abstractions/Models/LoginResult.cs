using System;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public record LoginResult(int UserId, string Username, string Role, string AccessToken, DateTime AccessTokenExpiresAt, string RefreshToken);
}
