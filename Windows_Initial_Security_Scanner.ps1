Write-Host "--- Windows Server Initial Security Checker ---" -ForegroundColor Cyan

# Check for potentially dangerous/unnecessary services
$servicesToCheck = @("PrintNotify", "Spooler", "RemoteRegistry", "WBioSrvc", "Fax")
Write-Host "`n[!] Checking for unnecessary services..." -ForegroundColor Yellow

foreach ($svc in $servicesToCheck) {
    $status = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($status) {
        Write-Host "Alert: Service '$svc' is $($status.Status). Consider disabling." -ForegroundColor Red
    } else {
        Write-Host "Clean: Service '$svc' not found or already removed." -ForegroundColor Green
    }
}

# Check Windows Firewall Status
Write-Host "`n[!] Checking Windows Firewall..." -ForegroundColor Yellow
$fw = Get-NetFirewallProfile | Select-Object Name, Enabled
foreach ($profile in $fw) {
    if ($profile.Enabled -eq "True") {
        Write-Host "OK: $($profile.Name) profile is Enabled." -ForegroundColor Green
    } else {
        Write-Host "WARNING: $($profile.Name) profile is DISABLED!" -ForegroundColor Red
    }
}

# List Listening Ports
Write-Host "`n[!] Checking active listening ports..." -ForegroundColor Yellow
Get-NetTCPConnection -State Listen | 
    Select-Object LocalAddress, LocalPort, OwningProcess | 
    Sort-Object LocalPort | 
    Format-Table -AutoSize

Write-Host "--- Scan Complete ---" -ForegroundColor Cyan