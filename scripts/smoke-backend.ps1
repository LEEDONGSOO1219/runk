Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$baseUrl = "http://127.0.0.1:8000"
$suffix = Get-Random

$health = Invoke-RestMethod "$baseUrl/health"
$signup = Invoke-RestMethod `
    -Method Post `
    -Uri "$baseUrl/auth/signup" `
    -ContentType "application/json" `
    -Body (@{
        email = "smoke$suffix@example.com"
        username = "smoke$suffix"
        password = "password123"
    } | ConvertTo-Json)

$record = Invoke-RestMethod `
    -Method Post `
    -Uri "$baseUrl/running-records" `
    -Headers @{ Authorization = "Bearer $($signup.access_token)" } `
    -ContentType "application/json" `
    -Body (@{
        distance_km = 5.0
        duration_seconds = 1800
        run_date = "2026-05-06"
        memo = "smoke test"
    } | ConvertTo-Json)

$feed = Invoke-RestMethod "$baseUrl/feed"

[PSCustomObject]@{
    health = $health.status
    username = $signup.user.username
    record_id = $record.id
    feed_count = $feed.Count
}
