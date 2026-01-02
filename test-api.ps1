# Test API Endpoints Script

$baseUrl = "http://localhost:5238/api/v1"

Write-Host "=== Testing Examination System API ==="
Write-Host ""

# Login as Manager
Write-Host "1. Manager Login..."
$body = '{"username": "manager1", "password": "Manager@123"}'
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $body -ContentType "application/json"
    $managerToken = $response.accessToken
    Write-Host "   OK - Manager Login Success (Token starts with: $($managerToken.Substring(0,20)))"
} catch {
    Write-Host "   FAIL - Manager Login Failed: $($_.Exception.Message)"
    exit
}

$managerHeaders = @{Authorization = "Bearer $managerToken"}

# Test Manager Dashboard
Write-Host ""
Write-Host "2. Manager Dashboard..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/manager/dashboard" -Headers $managerHeaders
    Write-Host "   OK - Success: $($result.success)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Test Manager Instructors
Write-Host ""
Write-Host "3. Manager Get Instructors..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/manager/instructors" -Headers $managerHeaders
    Write-Host "   OK - Count: $($result.data.Count)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Test Manager Enrollments
Write-Host ""
Write-Host "4. Manager Get Enrollments..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/manager/enrollments" -Headers $managerHeaders
    Write-Host "   OK - Count: $($result.data.Count)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Test Manager Students
Write-Host ""
Write-Host "5. Manager Get Students..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/manager/students" -Headers $managerHeaders
    Write-Host "   OK - Count: $($result.data.Count)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Test Manager Courses
Write-Host ""
Write-Host "6. Manager Get Courses..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/manager/courses" -Headers $managerHeaders
    Write-Host "   OK - Count: $($result.data.Count)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Login as Instructor
Write-Host ""
Write-Host "7. Instructor Login..."
$body = '{"username": "instructor1", "password": "Inst@123"}'
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $body -ContentType "application/json"
    $instructorToken = $response.accessToken
    Write-Host "   OK - Instructor Login Success"
} catch {
    Write-Host "   FAIL - Instructor Login Failed: $($_.Exception.Message)"
    exit
}

$instructorHeaders = @{Authorization = "Bearer $instructorToken"}

# Test Instructor Dashboard
Write-Host ""
Write-Host "8. Instructor Dashboard..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/instructor/dashboard" -Headers $instructorHeaders
    Write-Host "   OK - Success: $($result.success)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Test Instructor Exams
Write-Host ""
Write-Host "9. Instructor Get Exams..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/instructor/exams" -Headers $instructorHeaders
    Write-Host "   OK - Count: $($result.data.Count)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Test Instructor Questions
Write-Host ""
Write-Host "10. Instructor Get Questions..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/instructor/questions" -Headers $instructorHeaders
    Write-Host "   OK - Count: $($result.data.Count)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Test Instructor Courses
Write-Host ""
Write-Host "11. Instructor Get Courses..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/instructor/courses" -Headers $instructorHeaders
    Write-Host "   OK - Count: $($result.data.Count)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Login as Student
Write-Host ""
Write-Host "12. Student Login..."
$body = '{"username": "student1", "password": "Stud@123"}'
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $body -ContentType "application/json"
    $studentToken = $response.accessToken
    Write-Host "   OK - Student Login Success"
} catch {
    Write-Host "   FAIL - Student Login Failed: $($_.Exception.Message)"
    exit
}

$studentHeaders = @{Authorization = "Bearer $studentToken"}

# Test Student Dashboard
Write-Host ""
Write-Host "13. Student Dashboard..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/student/dashboard" -Headers $studentHeaders
    Write-Host "   OK - Success: $($result.success)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Test Student Exams
Write-Host ""
Write-Host "14. Student Get Available Exams..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/student/exams" -Headers $studentHeaders
    Write-Host "   OK - Count: $($result.data.Count)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

# Test Profile
Write-Host ""
Write-Host "15. Get Profile (Student)..."
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/profile/me" -Headers $studentHeaders
    Write-Host "   OK - User: $($result.username)"
} catch {
    Write-Host "   FAIL - $($_.Exception.Message)"
}

Write-Host ""
Write-Host "=== Tests Complete ==="
