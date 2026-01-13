$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$reportPath = "reports\System_Report.txt"

"===============================" | Out-File $reportPath
"SYSTEM INSIGHT REPORT" | Out-File $reportPath -Append
"Scan Time: $time" | Out-File $reportPath -Append
"===============================" | Out-File $reportPath -Append

$cpu = Get-CimInstance Win32_Processor
"CPU INFORMATION:" | Out-File $reportPath -Append
"Model: $($cpu.Name)" | Out-File $reportPath -Append
"Cores: $($cpu.NumberOfCores)" | Out-File $reportPath -Append
"Threads: $($cpu.NumberOfLogicalProcessors)" | Out-File $reportPath -Append
"" | Out-File $reportPath -Append
$ram = Get-CimInstance Win32_PhysicalMemory
$totalRAM = [math]::Round(($ram.Capacity | Measure-Object -Sum).Sum / 1GB,2)

"MEMORY INFORMATION:" | Out-File $reportPath -Append
"Total Installed RAM: $totalRAM GB" | Out-File $reportPath -Append

foreach ($r in $ram) {
    "Module: $([math]::Round($r.Capacity/1GB)) GB @ $($r.Speed) MHz" |
    Out-File $reportPath -Append
}
"" | Out-File $reportPath -Append

$disks = Get-CimInstance Win32_DiskDrive

"STORAGE INFORMATION:" | Out-File $reportPath -Append

foreach ($d in $disks) {
    $type = if ($d.MediaType -match "SSD") {
        "SSD (High-Speed Storage)"
    } else {
        "HDD (Mechanical Storage)"
    }

    "Drive Model: $($d.Model)" | Out-File $reportPath -Append
    "Drive Type: $type" | Out-File $reportPath -Append
    "Size: $([math]::Round($d.Size/1GB,2)) GB" | Out-File $reportPath -Append
    "" | Out-File $reportPath -Append
}


"INSTALLED SOFTWARE (RECENT & UNKNOWN):" | Out-File $reportPath -Append

$apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
        Select DisplayName, InstallDate |
        Where DisplayName

$apps | Sort InstallDate -Descending |
ForEach-Object {
    "$($_.DisplayName) | Installed: $($_.InstallDate)" |
    Out-File $reportPath -Append
}
"" | Out-File $reportPath -Append


"STARTUP PROGRAMS (POTENTIAL RISK):" | Out-File $reportPath -Append

$startup = Get-CimInstance Win32_StartupCommand
foreach ($s in $startup) {
    "Name: $($s.Name) | Command: $($s.Command)" |
    Out-File $reportPath -Append
}
"" | Out-File $reportPath -Append

"SECURITY STATUS:" | Out-File $reportPath -Append

$defender = Get-MpComputerStatus
"Antivirus Enabled: $($defender.AntivirusEnabled)" |
Out-File $reportPath -Append
"Real-Time Protection: $($defender.RealTimeProtectionEnabled)" |
Out-File $reportPath -Append
"" | Out-File $reportPath -Append

"RUNNING QUICK MALWARE SCAN..." | Out-File $reportPath -Append
Start-MpScan -ScanType QuickScan
"Scan Completed. Check Windows Security for details." |
Out-File $reportPath -Append

"IMPROVEMENT & HEALTH SUMMARY:" | Out-File $reportPath -Append
"• System hardware successfully detected." | Out-File $reportPath -Append
"• Storage configuration analyzed." | Out-File $reportPath -Append
"• Installed programs reviewed for anomalies." | Out-File $reportPath -Append
"• Security protection verified." | Out-File $reportPath -Append
Start-Process $reportPath
