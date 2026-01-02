# Test API Endpoints Script

$baseUrl = "http://localhost:5238/api/v1"

Write-Host "=== Testing Examination System API ===" -ForegroundColor Cyan
Write-Host ""

# Login as Manager
Write-Host "1. Manager Login..." -ForegroundColor Yellow
$body = '{"username": "manager1", "password": "Manager@123"}'
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $body -ContentType "application/json"
    $managerToken = $response.data.accessToken
    Write-Host "   ✓ Manager Login Success" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Manager Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

$managerHeaders = @{Authorization = "Bearer $managerToken"}

# Test Manager Dashboard
Write-Host ""
Write-Host "2. Manager Dashboard..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/manager/dashboard" -Headers $managerHeaders
    Write-Host "   ✓ Success - Status: $($result.success)" -ForegroundColor Green
    Write-Host "   Data: $($result.data | ConvertTo-Json -Depth 2 -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Manager Instructors
Write-Host ""
Write-Host "3. Manager Get Instructors..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/manager/instructors" -Headers $managerHeaders
    Write-Host "   ✓ Success - Count: $($result.data.Count)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Manager Enrollments
Write-Host ""
Write-Host "4. Manager Get Enrollments..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/manager/enrollments" -Headers $managerHeaders
    Write-Host "   ✓ Success - Count: $($result.data.Count)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Manager Students
Write-Host ""
Write-Host "5. Manager Get Students..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/manager/students" -Headers $managerHeaders
    Write-Host "   ✓ Success - Count: $($result.data.Count)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Manager Courses
Write-Host ""
Write-Host "6. Manager Get Courses..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/manager/courses" -Headers $managerHeaders
    Write-Host "   ✓ Success - Count: $($result.data.Count)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Login as Instructor
Write-Host ""
Write-Host "7. Instructor Login..." -ForegroundColor Yellow
$body = '{"username": "instructor1", "password": "Inst@123"}'
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $body -ContentType "application/json"
    $instructorToken = $response.data.accessToken
    Write-Host "   ✓ Instructor Login Success" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Instructor Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

$instructorHeaders = @{Authorization = "Bearer $instructorToken"}

# Test Instructor Dashboard
Write-Host ""
Write-Host "8. Instructor Dashboard..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/instructor/dashboard" -Headers $instructorHeaders
    Write-Host "   ✓ Success - Status: $($result.success)" -ForegroundColor Green
    Write-Host "   Data: $($result.data | ConvertTo-Json -Depth 2 -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Instructor Exams
Write-Host ""
Write-Host "9. Instructor Get Exams..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/instructor/exams" -Headers $instructorHeaders
    Write-Host "   ✓ Success - Count: $($result.data.Count)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Instructor Questions
Write-Host ""
Write-Host "10. Instructor Get Questions..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/instructor/questions" -Headers $instructorHeaders
    Write-Host "   ✓ Success - Count: $($result.data.Count)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Instructor Courses
Write-Host ""
Write-Host "11. Instructor Get Courses..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/instructor/courses" -Headers $instructorHeaders
    Write-Host "   ✓ Success - Count: $($result.data.Count)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Login as Student
Write-Host ""
Write-Host "12. Student Login..." -ForegroundColor Yellow
$body = '{"username": "student1", "password": "Stud@123"}'
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $body -ContentType "application/json"
    $studentToken = $response.data.accessToken
    Write-Host "   ✓ Student Login Success" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Student Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

$studentHeaders = @{Authorization = "Bearer $studentToken"}

# Test Student Dashboard
Write-Host ""
Write-Host "13. Student Dashboard..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/student/dashboard" -Headers $studentHeaders
    Write-Host "   ✓ Success - Status: $($result.success)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Student Exams
Write-Host ""
Write-Host "14. Student Get Available Exams..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/student/exams" -Headers $studentHeaders
    Write-Host "   ✓ Success - Count: $($result.data.Count)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Profile
Write-Host ""
Write-Host "15. Get Profile (Student)..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/profile/me" -Headers $studentHeaders
    Write-Host "   ✓ Success - User: $($result.data.username)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Tests Complete ===" -ForegroundColor Cyan
