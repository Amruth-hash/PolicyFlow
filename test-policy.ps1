
$body = @{
    client_request_id = "REQ-$((Get-Date).ToString('yyyyMMddHHmmss'))"
    agent_id = "AGENT-001"
    customer_name = Read-Host "Customer name"
    date_of_birth = Read-Host "DOB (YYYY-MM-DD)"
    destination = Read-Host "Destination (DOMESTIC/INTERNATIONAL)"
    trip_start = Read-Host "Trip start (YYYY-MM-DD)"
    trip_end = Read-Host "Trip end (YYYY-MM-DD)"
    plan_code = Read-Host "Plan (BASIC/PLUS/PREMIUM)"
    sum_insured = [int](Read-Host "Sum insured (100000/300000/500000)")
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod `
        -Uri "http://127.0.0.1:8000/api/policy-requests" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body

    $result.data | Format-List id, client_request_id, customer_name, premium, status
}
catch {
    Write-Host "Request failed:" $_.ErrorDetails.Message
}
