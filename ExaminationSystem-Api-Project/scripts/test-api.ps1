param(
  [string]$BaseUrl = 'http://localhost:5238/api/v1'
)

function Invoke-JsonRequest {
  param(
    [string]$Method,
    [string]$Url,
    [hashtable]$Headers = @{},
    [object]$Body = $null
  )
  try {
    if ($Body -ne $null) { $json = ($Body | ConvertTo-Json -Depth 8) } else { $json = $null }
    $resp = Invoke-WebRequest -Method $Method -Uri $Url -Headers $Headers -ContentType 'application/json' -Body $json -ErrorAction Stop
    $content = $resp.Content
    try { $parsed = $content | ConvertFrom-Json } catch { $parsed = $content }
    return [pscustomobject]@{ StatusCode = $resp.StatusCode; Url = $Url; Body = $parsed }
  } catch {
    $status = $null; $content = $null
    if ($_.Exception.Response) {
      try { $status = $_.Exception.Response.StatusCode.value__ } catch {}
      try {
        $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $content = $sr.ReadToEnd()
        $sr.Close()
      } catch {}
    }
    try { $parsed = $content | ConvertFrom-Json } catch { $parsed = $content }
    return [pscustomobject]@{ StatusCode = $status; Url = $Url; Body = $parsed }
  }
}

function Login-User {
  param([string]$Username, [string]$Password)
  $url = "$BaseUrl/Auth/login"
  $body = @{ Username = $Username; Password = $Password }
  $res = Invoke-JsonRequest -Method 'POST' -Url $url -Body $body
  return $res
}

function Test-AdminEndpoints {
  param([string]$Token)
  $auth = @{ Authorization = "Bearer $Token" }
  $results = @()
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/profile/me" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/notifications" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/notifications/unread-count" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/sessions/me/active" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/sessions/history" -Headers $auth
  $results += Invoke-JsonRequest -Method 'POST' -Url "$BaseUrl/sessions/cleanup" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/analytics/dashboard" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/analytics/questions/difficulty" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/monitoring/live-exams" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/monitoring/exam-sessions" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/monitoring/suspicious-activity" -Headers $auth
  # Events - use admin userId 1 if exists
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/events/user/1/timeline?pageNumber=1&pageSize=10" -Headers $auth
  return $results
}

function Test-ManagerEndpoints {
  param([string]$Token)
  $auth = @{ Authorization = "Bearer $Token" }
  $results = @()
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/manager/branches" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/manager/intakes" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/manager/courses?includeInactive=false" -Headers $auth
  # Optional: tracks by branch 1
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/manager/branches/1/tracks" -Headers $auth
  # Optional: students filter
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/manager/students" -Headers $auth
  return $results
}

function Test-InstructorEndpoints {
  param([string]$Token)
  $auth = @{ Authorization = "Bearer $Token" }
  $results = @()
  $myCourses = Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/instructor/my-courses" -Headers $auth
  $results += $myCourses
  $courseId = $null
  try { if ($myCourses.Body -and $myCourses.Body.Count -gt 0) { $courseId = $myCourses.Body[0].CourseId } } catch {}
  if ($courseId) {
    $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/instructor/courses/$courseId/students" -Headers $auth
    $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/instructor/courses/$courseId/questions" -Headers $auth
    $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/instructor/courses/$courseId/questions/statistics" -Headers $auth
  }
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/instructor/grading/pending" -Headers $auth
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/instructor/text-answers/analysis" -Headers $auth
  return $results
}

function Test-StudentEndpoints {
  param([string]$Token)
  $auth = @{ Authorization = "Bearer $Token" }
  $results = @()
  $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/student/progress" -Headers $auth
  $available = Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/student/available-exams" -Headers $auth
  $results += $available
  $examId = $null
  try { if ($available.Body -and $available.Body.Count -gt 0) { $examId = $available.Body[0].ExamId } } catch {}
  if ($examId) {
    $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/student/exams/$examId" -Headers $auth
    $results += Invoke-JsonRequest -Method 'GET' -Url "$BaseUrl/student/exams/$examId/results" -Headers $auth
  }
  return $results
}

Write-Host "=== Authenticating users ===" -ForegroundColor Cyan
$adminLogin = Login-User -Username 'admin' -Password 'Admin@123'
$managerLogin = Login-User -Username 'manager1' -Password 'Manager@123'
$instructorLogin = Login-User -Username 'instructor1' -Password 'Inst@123'
$studentLogin = Login-User -Username 'student1' -Password 'Stud@123'

$adminToken = $adminLogin.Body.AccessToken
$managerToken = $managerLogin.Body.AccessToken
$instructorToken = $instructorLogin.Body.AccessToken
$studentToken = $studentLogin.Body.AccessToken

Write-Host "Admin login status: $($adminLogin.StatusCode)" -ForegroundColor Green
Write-Host "Manager login status: $($managerLogin.StatusCode)" -ForegroundColor Green
Write-Host "Instructor login status: $($instructorLogin.StatusCode)" -ForegroundColor Green
Write-Host "Student login status: $($studentLogin.StatusCode)" -ForegroundColor Green

Write-Host "=== Testing Admin endpoints ===" -ForegroundColor Cyan
$adminResults = Test-AdminEndpoints -Token $adminToken
$adminResults | ForEach-Object { Write-Host ("[{0}] {1}" -f $_.StatusCode, $_.Url) ; $_.Body | ConvertTo-Json -Depth 8 | Write-Output }

Write-Host "=== Testing Manager endpoints ===" -ForegroundColor Cyan
$managerResults = Test-ManagerEndpoints -Token $managerToken
$managerResults | ForEach-Object { Write-Host ("[{0}] {1}" -f $_.StatusCode, $_.Url) ; $_.Body | ConvertTo-Json -Depth 8 | Write-Output }

Write-Host "=== Testing Instructor endpoints ===" -ForegroundColor Cyan
$instructorResults = Test-InstructorEndpoints -Token $instructorToken
$instructorResults | ForEach-Object { Write-Host ("[{0}] {1}" -f $_.StatusCode, $_.Url) ; $_.Body | ConvertTo-Json -Depth 8 | Write-Output }

Write-Host "=== Testing Student endpoints ===" -ForegroundColor Cyan
$studentResults = Test-StudentEndpoints -Token $studentToken
$studentResults | ForEach-Object { Write-Host ("[{0}] {1}" -f $_.StatusCode, $_.Url) ; $_.Body | ConvertTo-Json -Depth 8 | Write-Output }
