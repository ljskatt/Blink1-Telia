$username = ""
$password = ""

$blink_delay = "500" # in milliseconds
$busy_delay = "10" # in seconds
$error_delay = "10" # in seconds
$exit_on_error = $false
$reboot_color = '40,40,40'
$blink1_tool = "/usr/local/bin/blink1-tool"

# Office Hours
$min_time = Get-Date '07:59'
$max_time = Get-Date '16:00'

#Validate
While ($validate -eq $null) {

    & $blink1_tool --yellow | Out-Null

    $session = $null
    Write-Output "Pre-check: Getting session token"
    $rtoken_raw = Invoke-WebRequest -Uri 'https://sb.telia.no/bn/login' -Method "GET" -SessionVariable session
    $rtoken = ($rtoken_raw.InputFields | Where-Object {$_.name -eq "r"}).value

    # Log in
    Write-Output "Pre-check: Logging in"
    $postParams = @{loginName=$username; loginPassword=$password; r=$rtoken}
    Invoke-RestMethod -Uri 'https://sb.telia.no/bn/login' -Method Post -Body $postParams -WebSession $session | Out-Null

    # Request to evaluate login
    Write-Output "Pre-check: Validating results"
    $req = $null
    $req = Invoke-RestMethod -Uri 'https://sb.telia.no/api/call/active' -Method "POST" -WebSession $session

    if ($req.error -eq $false){
        $validate = "1"
        Write-Host -BackgroundColor "Green" -ForegroundColor "Black" -Object " Pre-check: Login successful " -NoNewline; Write-Host -ForegroundColor "DarkGray" -Object "|"
        & $blink1_tool --magenta
    }
    else {
        Write-Host -BackgroundColor "Red" -ForegroundColor "Black" -Object " Pre-check: Failed to log in, exits script " -NoNewline; Write-Host -ForegroundColor "DarkGray" -Object "|"
        & $blink1_tool --rgb=$reboot_color | Out-Null
        if ($exit_on_error) {
            exit
        }
        Start-Sleep -Seconds "$error_delay"
    }
}

# Loop
While ($true) {
    $now_time = Get-Date
    if ($min_time.TimeOfDay -le $now_time.TimeOfDay -and $max_time.TimeOfDay -ge $now_time.TimeOfDay) {
        $req = $null
        $req = Invoke-RestMethod -Uri 'https://sb.telia.no/api/call/active' -Method "POST" -WebSession $session

        if ($req.error -eq $false){
            if ($req.activecall.agent){
                & $blink1_tool -m $blink_delay --red | Out-Null
                Write-Output "Red"
                $busy = 1
            }
            else {
                if ($busy -eq 1){
                    Write-Output "Starting delay after call"
                    Start-Sleep -Seconds "$busy_delay"
                    $busy = 0
                }
                else {
                    & $blink1_tool -m $blink_delay --green | Out-Null
                    Write-Output "Green"
                }
            }
            Start-Sleep -Seconds "3"
        }
        else {
            & $blink1_tool -m $blink_delay --yellow | Out-Null
            Write-Host -BackgroundColor "Yellow" -ForegroundColor "Black" -Object " Session timed out, logging in... " -NoNewline; Write-Host -ForegroundColor "DarkGray" -Object "|"

            # Token and session
            $rtoken_raw = Invoke-WebRequest -Uri 'https://sb.telia.no/bn/login' -Method "GET" -SessionVariable session
            $rtoken = ($rtoken_raw.InputFields | Where-Object {$_.name -eq "r"}).value

            # Login
            $postParams = @{loginName=$username; loginPassword=$password; r=$rtoken}
            Invoke-RestMethod -Uri 'https://sb.telia.no/bn/login' -Method "Post" -Body $postParams -WebSession $session | Out-Null
            Write-Output "Validating results"
            $req = $null
            $req = Invoke-RestMethod -Uri 'https://sb.telia.no/api/call/active' -Method "POST" -WebSession $session

            if ($req.error -ne $false) {
                Write-Host -BackgroundColor "Red" -ForegroundColor "Black" -Object " Failed to log in, exits script " -NoNewline; Write-Host -ForegroundColor "DarkGray" -Object "|"
                & $blink1_tool --rgb=$reboot_color | Out-Null
                if ($exit_on_error) {
                    exit
                }
                Start-Sleep -Seconds "$error_delay"
            }
        }
    }
    else {
        & $blink1_tool --off | Out-Null
        Write-Output "Out of office hours"
        Start-Sleep -Seconds "60"
    }
}
