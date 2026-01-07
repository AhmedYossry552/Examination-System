# Quick API Test Script
$BaseUrl = 'http://localhost:5238'

Write-Host "=== Examination System API Quick Test ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "[1] Testing Health Endpoint..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$BaseUrl/health" -TimeoutSec 5
    Write-Host "    PASS: Health = $health" -ForegroundColor Green
} catch {
    Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Views Endpoint (Public)
Write-Host "[2] Testing Views/users (Public)..." -ForegroundColor Yellow
try {
    $users = Invoke-RestMethod -Uri "$BaseUrl/api/Views/users" -TimeoutSec 10
    Write-Host "    PASS: Found $($users.Count) users" -ForegroundColor Green
} catch {
    Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Admin Login
Write-Host "[3] Testing Admin Login..." -ForegroundColor Yellow
try {
    $loginBody = @{ Username = 'admin'; Password = 'Admin@123' } | ConvertTo-Json
    $adminLogin = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method POST -ContentType 'application/json' -Body $loginBody -TimeoutSec 10
    Write-Host "    PASS: Got access token" -ForegroundColor Green
    $adminToken = $adminLogin.accessToken
} catch {
    Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $adminToken = $null
}

# Test 4: Manager Login
Write-Host "[4] Testing Manager Login..." -ForegroundColor Yellow
try {
    $loginBody = @{ Username = 'manager.training'; Password = 'Manager@123' } | ConvertTo-Json
    $managerLogin = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method POST -ContentType 'application/json' -Body $loginBody -TimeoutSec 10
    Write-Host "    PASS: Got access token" -ForegroundColor Green
    $managerToken = $managerLogin.accessToken
} catch {
    Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $managerToken = $null
}

# Test 5: Instructor Login
Write-Host "[5] Testing Instructor Login..." -ForegroundColor Yellow
try {
    $loginBody = @{ Username = 'dr.ahmed'; Password = 'Inst@123' } | ConvertTo-Json
    $instructorLogin = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method POST -ContentType 'application/json' -Body $loginBody -TimeoutSec 10
    Write-Host "    PASS: Got access token" -ForegroundColor Green
    $instructorToken = $instructorLogin.accessToken
} catch {
    Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $instructorToken = $null
}

# Test 6: Student Login
Write-Host "[6] Testing Student Login..." -ForegroundColor Yellow
try {
    $loginBody = @{ Username = 'std.youssef'; Password = 'Stud@123' } | ConvertTo-Json
    $studentLogin = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method POST -ContentType 'application/json' -Body $loginBody -TimeoutSec 10
    Write-Host "    PASS: Got access token" -ForegroundColor Green
    $studentToken = $studentLogin.accessToken
} catch {
    Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $studentToken = $null
}

Write-Host ""
Write-Host "=== Testing Protected Endpoints ===" -ForegroundColor Cyan

if ($adminToken) {
    $headers = @{ Authorization = "Bearer $adminToken" }
    
    # Admin: Get Profile
    Write-Host "[7] Admin: Get Profile..." -ForegroundColor Yellow
    try {
        $profile = Invoke-RestMethod -Uri "$BaseUrl/api/v1/profile/me" -Headers $headers -TimeoutSec 10
        Write-Host "    PASS: $($profile.fullName) ($($profile.userType))" -ForegroundColor Green
    } catch {
        Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Admin: Get Notifications
    Write-Host "[8] Admin: Get Notifications..." -ForegroundColor Yellow
    try {
        $notifications = Invoke-RestMethod -Uri "$BaseUrl/api/v1/notifications" -Headers $headers -TimeoutSec 10
        Write-Host "    PASS: $($notifications.Count) notifications" -ForegroundColor Green
    } catch {
        Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Admin: List Users
    Write-Host "[9] Admin: List Users..." -ForegroundColor Yellow
    try {
        $adminUsers = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin/users" -Headers $headers -TimeoutSec 10
        Write-Host "    PASS: $($adminUsers.Count) users" -ForegroundColor Green
    } catch {
        Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Admin: Analytics Dashboard
    Write-Host "[10] Admin: Analytics Dashboard..." -ForegroundColor Yellow
    try {
        $analytics = Invoke-RestMethod -Uri "$BaseUrl/api/v1/analytics/dashboard" -Headers $headers -TimeoutSec 10
        Write-Host "    PASS: Analytics loaded" -ForegroundColor Green
    } catch {
        Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($managerToken) {
    $headers = @{ Authorization = "Bearer $managerToken" }
    
    # Manager: Get Branches
    Write-Host "[11] Manager: Get Branches..." -ForegroundColor Yellow
    try {
        $branches = Invoke-RestMethod -Uri "$BaseUrl/api/v1/manager/branches" -Headers $headers -TimeoutSec 10
        Write-Host "    PASS: $($branches.Count) branches" -ForegroundColor Green
    } catch {
        Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Manager: Get Courses
    Write-Host "[12] Manager: Get Courses..." -ForegroundColor Yellow
    try {
        $courses = Invoke-RestMethod -Uri "$BaseUrl/api/v1/manager/courses" -Headers $headers -TimeoutSec 10
        Write-Host "    PASS: $($courses.Count) courses" -ForegroundColor Green
    } catch {
        Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($instructorToken) {
    $headers = @{ Authorization = "Bearer $instructorToken" }
    
    # Instructor: Get My Courses
    Write-Host "[13] Instructor: Get My Courses..." -ForegroundColor Yellow
    try {
        $myCourses = Invoke-RestMethod -Uri "$BaseUrl/api/v1/instructor/my-courses" -Headers $headers -TimeoutSec 10
        Write-Host "    PASS: $($myCourses.Count) courses" -ForegroundColor Green
    } catch {
        Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Instructor: Pending Grading
    Write-Host "[14] Instructor: Pending Grading..." -ForegroundColor Yellow
    try {
        $pending = Invoke-RestMethod -Uri "$BaseUrl/api/v1/instructor/grading/pending" -Headers $headers -TimeoutSec 10
        Write-Host "    PASS: $($pending.Count) pending" -ForegroundColor Green
    } catch {
        Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($studentToken) {
    $headers = @{ Authorization = "Bearer $studentToken" }
    
    # Student: Get Progress
    Write-Host "[15] Student: Get Progress..." -ForegroundColor Yellow
    try {
        $progress = Invoke-RestMethod -Uri "$BaseUrl/api/v1/student/progress" -Headers $headers -TimeoutSec 10
        Write-Host "    PASS: Progress loaded" -ForegroundColor Green
    } catch {
        Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Student: Available Exams
    Write-Host "[16] Student: Available Exams..." -ForegroundColor Yellow
    try {
        $exams = Invoke-RestMethod -Uri "$BaseUrl/api/v1/student/available-exams" -Headers $headers -TimeoutSec 10
        Write-Host "    PASS: $($exams.Count) available exams" -ForegroundColor Green
    } catch {
        Write-Host "    FAIL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
