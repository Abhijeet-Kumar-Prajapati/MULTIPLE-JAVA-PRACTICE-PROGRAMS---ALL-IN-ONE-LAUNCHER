#Requires -Version 5.1
<#
    ALL-IN-ONE JAVA LAUNCHER
    ========================
    Poore project ke saare Java programs ek hi jagah se chalane ke liye.

    - Koi bhi .java file chhua nahi gaya hai. Sirf naye launcher files bane hain.
    - Compiled classes 'build/' folder mein jaate hain (wo .gitignore mein pehle se hai).
    - Menu se ek program chala sakte ho, ya 'A' se sab kuch ek saath run kar sakte ho.

    START:  RUN_ME.bat  (bas double-click karo)
#>

[CmdletBinding()]
param(
    [switch]$RunAll,          # menu skip karke seedha sab run kar do
    [switch]$NoPause,         # end me pause mat karo
    [int]   $TimeoutSec = 0   # 0 = script ka default use karo
)

$ErrorActionPreference = 'Continue'

# ============================================================================
#  SETTINGS  --  yahan se kuch bhi badal sakte ho, baaki code haath mat chhedna
# ============================================================================
$script:RunAllTimeout = 5        # run-all: har program par kitne second ka limit
$script:MenuTimeout   = 0        # menu:   0 = koi limit nahi (Ctrl+C se ruko)
$script:RunGuiInRunAll= $false   # run-all me GUI wale programs bhi kholein? (4 windows khulen)
$script:AutoCompile   = $true    # chalu program khud compile ho jaye
$script:OpenLogsNotepad = $false # run-all ke baad log file Notepad me khule?
if ($TimeoutSec -gt 0) { $script:RunAllTimeout = $TimeoutSec }
# ============================================================================


# ---------------------------------------------------------------- helpers ---
function Write-Title {
    param([string]$Text)
    Write-Host ""
    Write-Host "  $Text " -NoNewline -ForegroundColor Cyan
    Write-Host ("=" * [Math]::Max(4, 68 - $Text.Length)) -ForegroundColor DarkCyan
}

function Write-Sub {
    param([string]$Text)
    Write-Host "  $Text" -ForegroundColor DarkGray
}

function Get-PrettyName {
    param([string]$Name)
    $n = $Name -replace '\.java$', ''
    $n = $n -replace '[_\-]+', ' '
    $n = [regex]::Replace($n, '(?<=[a-z0-9])(?=[A-Z])', ' ')
    $n = [regex]::Replace($n, '\s+', ' ')
    return $n.Trim()
}

# Class ka naam nikalo jisme sach me `main` method hai
# (Kruskal's\Graph.java jaise cases me file ka naam aur class ka naam alag hota hai)
function Get-MainClassName {
    param([string]$Text, [string]$Fallback)

    $decls = [regex]::Matches(
        $Text,
        '(?m)^[ \t]*(?:public\s+|final\s+|abstract\s+|static\s+|strictfp\s+)*(?:class|enum|interface)\s+(\w+)')

    if ($decls.Count -gt 0) {
        for ($i = 0; $i -lt $decls.Count; $i++) {
            $start = $decls[$i].Index + $decls[$i].Length
            $end   = if ($i + 1 -lt $decls.Count) { $decls[$i + 1].Index } else { $Text.Length }
            $body  = $Text.Substring($start, $end - $start)
            if ($body -match 'public\s+static\s+void\s+main') { return $decls[$i].Groups[1].Value }
        }
    }

    $m = [regex]::Match($Text, '(?m)^[ \t]*(?:public\s+|final\s+|abstract\s+|static\s+)*(?:class|enum)\s+(\w+)')
    if ($m.Success) { return $m.Groups[1].Value }
    return $Fallback
}

function Get-ProgramKind {
    param([string]$Text)
    if ($Text -match 'javax\.swing|java\.awt') { return 'GUI' }
    if ($Text -match 'new\s+Scanner\s*\(\s*System\.in\s*\)|System\.in') { return 'INPUT' }
    return 'PLAIN'
}

function Get-TopicOf {
    param([string]$RelPath)
    # Project's\Project's\Programs\<Topic>\<file>
    if ($RelPath -match '(?i)\\Programs\\([^\\]+)\\') { return (Get-PrettyName $Matches[1]) }
    if ($RelPath -match '^([^\\]+)\\[^\\]+$')      { return (Get-PrettyName $Matches[1]) }
    return 'Standalone Projects'
}

# Bahut saare files ka naam "Main" / "Graph" hai, to dikhane ke liye topic jod do
$script:GenericNames = @('Main', 'Graph', 'Edge', 'Test', 'Program', 'Demo', 'class simple')

function Get-DisplayLabel {
    param($Item)
    if ($script:GenericNames -contains $Item.Title) {
        if ($Item.Topic -eq 'Standalone Projects') { return $Item.Title }
        return "$($Item.Topic) / $($Item.Title)"
    }
    return $Item.Title
}

# Categories ka order - jis order me dikhana hai
$script:CatOrder = @('DSA & Data Structures', 'OOP Concepts', 'Core Concepts', 'Basic Practice', 'Standalone Projects')

# Folder ka naam adhoora tha (har Programs\X alag category ban rahi thi),
# isliye asli topic se sahi category banate hain.
function Get-CategoryOf {
    param($Item)

    if ($Item.Rel -match 'Library_Management|ScientificCalculator|SnakeGame') { return 'Standalone Projects' }

    $t = "$($Item.Topic) $($Item.Title) $($Item.Rel)".ToLower()

    if ($t -match 'bubble|merge.?sort|quick.?sort|search|stack|queue|dfs|bfs|dijkstra|dijktra|kruskal|huffman|graph') {
        return 'DSA & Data Structures'
    }
    if ($t -match 'inherit|overload|overrid|class.?object|employee|static|student|dispatch|encapsul|polymorph|abstract') {
        return 'OOP Concepts'
    }
    if ($t -match 'exception|event.?handling') { return 'Core Concepts' }

    return 'Basic Practice'
}

function Get-SafeId {
    param([string]$RelPath)
    $s = $RelPath -replace '\.java$', ''
    $s = $s -replace '[\\/]', '__'
    $s = $s -replace '[^A-Za-z0-9_\-]', '_'
    return $s
}

# ------------------------------------------------------------- discovery ---
$Root     = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$BuildDir = Join-Path $Root 'build'
$LogFile  = Join-Path $BuildDir 'run-all-output.txt'

if (-not (Get-Command javac -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "  Java nahi mila. JDK install karo (Java 11+ chahiye)." -ForegroundColor Red
    Write-Host ""
    exit 1
}

if (-not (Test-Path -LiteralPath $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
}

$programs = New-Object System.Collections.ArrayList

$javaFiles = Get-ChildItem -LiteralPath $Root -Recurse -Force -Filter *.java -ErrorAction SilentlyContinue |
             Where-Object { $_.FullName -notlike "$BuildDir\*" -and
                            $_.FullName -notlike '*\.git\*' -and
                            $_.Name -ne 'launcher.ps1' } |
             Sort-Object FullName

foreach ($f in $javaFiles) {
    $raw = ''
    try { $raw = [System.IO.File]::ReadAllText($f.FullName) } catch { continue }

    if ($raw -notmatch 'public\s+static\s+void\s+main') { continue }

    $rel  = $f.FullName.Substring($Root.Length).TrimStart('\')
    $cls  = Get-MainClassName -Text $raw -Fallback ($f.BaseName)
    $pkg  = if ($raw -match '(?m)^\s*package\s+([\w\.]+)\s*;') { $Matches[1] } else { '' }
    $fqcn = if ($pkg) { "$pkg.$cls" } else { $cls }

    [void]$programs.Add([pscustomobject]@{
        Id        = Get-SafeId $rel
        Rel       = $rel
        File      = $f
        MainClass = $cls
        Package   = $pkg
        FQCN      = $fqcn
        Kind      = Get-ProgramKind $raw
        Topic     = Get-TopicOf $rel
        Title     = Get-PrettyName $f.BaseName
        OutDir    = Join-Path $BuildDir (Get-SafeId $rel)
        Compiled  = $false
        CompileErr= ''
    })
}

# har program ko sahi category do
foreach ($p in $programs) { Add-Member -InputObject $p -NotePropertyName Category -NotePropertyValue (Get-CategoryOf $p) }

if ($programs.Count -eq 0) {
    Write-Host ""
    Write-Host "  Koi Java program nahi mila." -ForegroundColor Red
    Write-Host ""
    exit 1
}

# --------------------------------------------------------------- compile ---
function Invoke-CompileOne {
    param($Item, [switch]$Quiet)

    # is session me pehle hi compile kar diya gaya hai
    if ($Item.Compiled) { return $true }

    if (-not (Test-Path -LiteralPath $Item.OutDir)) {
        New-Item -ItemType Directory -Path $Item.OutDir -Force | Out-Null
    }

    # cached? .class naye se purana .java se
    $classFile = Get-ChildItem -LiteralPath $Item.OutDir -Recurse -Filter "$($Item.MainClass).class" `
                              -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($classFile -and $classFile.LastWriteTimeUtc -ge $Item.File.LastWriteTimeUtc) {
        $Item.Compiled = $true
        return $true
    }

    try {
        if (Test-Path -LiteralPath $Item.OutDir) {
            Remove-Item -LiteralPath $Item.OutDir -Recurse -Force -ErrorAction Stop
        }
    }
    catch { }
    New-Item -ItemType Directory -Path $Item.OutDir -Force | Out-Null

    $errOut = & javac -nowarn -d $Item.OutDir $Item.File.FullName 2>&1
    if ($LASTEXITCODE -ne 0) {
        $Item.Compiled    = $false
        $Item.CompileErr  = (($errOut | Out-String).Trim())
        return $false
    }

    $Item.Compiled = $true
    return $true
}

function Invoke-CompileAll {
    param([switch]$Quiet)
    $ok = 0; $fail = 0
    foreach ($p in $programs) {
        $p.Compiled = $false   # force dobara compile
        if (Invoke-CompileOne -Item $p) { $ok++ } else { $fail++ }
    }
    return [pscustomobject]@{ Ok = $ok; Fail = $fail }
}

# ------------------------------------------------------------ sample input --
# Run-all ke liye ready-made input. Menu mein aap khud type karoge.
$SampleInput = @{
    "Project's\Project's\Programs\Factorial.java"              = "5`r`n"
    "Project's\Project's\Programs\PrimeCheck.java"             = "17`r`n"
    "Project's\Project's\Programs\SumOfNaturalNumbers.java"    = "10`r`n"
    "Project's\Project's\Programs\ReverseArray.java"           = "5`r`n10`r`n20`r`n30`r`n40`r`n50`r`n"
    "Project's\Project's\Programs\MaxMinFinder.java"           = "5`r`n12`r`n99`r`n4`r`n47`r`n3`r`n"
    "Project's\Project's\Programs\MatrixAddition.java"         = "2`r`n2`r`n1`r`n2`r`n3`r`n4`r`n5`r`n6`r`n7`r`n8`r`n"
    "Project's\Project's\Programs\MatrixMultiplication.java"   = "2`r`n2`r`n2`r`n2`r`n1`r`n2`r`n3`r`n4`r`n5`r`n6`r`n7`r`n8`r`n"
    "Project's\Project's\sandglass_pattern.java"               = "5`r`n"
    "Project's\Project's\Programs\Employee\Main.java"          = "101`r`nAbhijeet Kumar`r`nIT Department`r`n55000`r`n"
}

$GenericInput = "5`r`n1`r`n2`r`n3`r`n4`r`n5`r`nAbhijeet`r`nIT`r`n50000`r`n0`r`n"

function Get-SampleInputFor {
    param($Item)
    if ($Item.Kind -ne 'INPUT') { return '' }
    if ($SampleInput.ContainsKey($Item.Rel)) { return $SampleInput[$Item.Rel] }
    return $GenericInput
}

# ---------------------------------------------------------------- running --
function Invoke-ProgramTimed {
    param($Item, [string]$StdinText, [int]$Seconds)

    $javaExe = (Get-Command java -ErrorAction SilentlyContinue).Source
    if (-not $javaExe) { return @{ Output = 'java command not found'; TimedOut = $false; ExitCode = -1 } }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName               = $javaExe
    $psi.Arguments              = '-cp "{0}" {1}' -f $Item.OutDir, $Item.FQCN
    $psi.RedirectStandardInput  = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute        = $false
    $psi.CreateNoWindow         = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    $timedOut = $false
    $code     = -1

    try {
        [void]$proc.Start()
        $outTask = $proc.StandardOutput.ReadToEndAsync()
        $errTask = $proc.StandardError.ReadToEndAsync()

        if ($StdinText) {
            try {
                $proc.StandardInput.Write($StdinText)
                $proc.StandardInput.Flush()
            } catch { }
        }
        try { $proc.StandardInput.Close() } catch { }

        if ($Seconds -gt 0) {
            if (-not $proc.WaitForExit($Seconds * 1000)) {
                $timedOut = $true
                try { $proc.Kill() } catch { }
            }
        }
        try { $proc.WaitForExit(4000) | Out-Null } catch { }

        $out = ''
        try { $out = $outTask.Result } catch { }
        $err = ''
        try { $err = $errTask.Result } catch { }
        if ($err) { $out = $out + "`r`n" + $err }

        try { $code = $proc.ExitCode } catch { $code = -1 }
        return @{ Output = $out; TimedOut = $timedOut; ExitCode = $code }
    }
    catch {
        return @{ Output = "Launch failed: $($_.Exception.Message)"; TimedOut = $false; ExitCode = -1 }
    }
    finally {
        try { $proc.Dispose() } catch { }
    }
}

function Invoke-ProgramInteractive {
    param($Item, [int]$Seconds)
    Write-Host ""
    Write-Sub ("-" * 68)
    Write-Sub "File : $($Item.Rel)"
    Write-Sub "Class: $($Item.FQCN)"
    if ($Item.Kind -eq 'GUI') { Write-Sub "Note : ye ek window khulega, band karne ke liye usme X dabao." }
    Write-Sub ("-" * 68)
    Write-Host ""
    try {
        if ($Seconds -gt 0) {
            Invoke-ProgramTimed -Item $Item -StdinText '' -Seconds $Seconds | Out-Null
        }
        else {
            & java -cp $Item.OutDir $Item.FQCN
        }
    }
    catch { Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red }
}

# ----------------------------------------------------------------- banner --
function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "   ============================================================" -ForegroundColor Cyan
    Write-Host "        JAVA PRACTICE PROGRAMS  -  ALL IN ONE LAUNCHER" -ForegroundColor White
    Write-Host "   ============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Sub "Total programs : $($programs.Count)"
    $g = ($programs | Where-Object { $_.Kind -eq 'GUI' }).Count
    $i = ($programs | Where-Object { $_.Kind -eq 'INPUT' }).Count
    $c = ($programs | Where-Object { $_.Kind -eq 'PLAIN' }).Count
    Write-Sub "Console: $c   |   Input wale: $i   |   GUI (window): $g"
    Write-Sub "Java    : $((& java -version 2>&1) -join ' ' | Select-Object -First 1)"
    Write-Sub "Folder  : $Root"
}

# -------------------------------------------------------------- run-all ----
function Invoke-BatchRun {
    param($List, [string]$Heading = 'RUN ALL', [switch]$ShowOutput)

    Clear-Host
    Write-Title $Heading
    Write-Sub "Programs   : $($List.Count)"
    Write-Sub "Time limit : $script:RunAllTimeout second per program"
    if (-not $script:RunGuiInRunAll) { Write-Sub "GUI wale skip ho rahe hain - menu se chala sakte ho." }
    Write-Host ""

    $log = New-Object System.Collections.ArrayList
    $done = 0; $okc = 0; $errc = 0; $to = 0; $skip = 0; $pos = 0

    foreach ($p in $List) {
        $pos++
        $label = Get-DisplayLabel $p

        if ($p.Kind -eq 'GUI' -and -not $script:RunGuiInRunAll) {
            $skip++
            Write-Host ("  [{0,2}/{1}] {2,-36} " -f $pos, $List.Count, $label) -NoNewline -ForegroundColor White
            Write-Host "SKIPPED (GUI)" -ForegroundColor DarkYellow
            [void]$log.Add("=== $($label)  [$($p.Rel)]  ->  SKIPPED (GUI) ===`r`nYe ek window-based program hai. Menu se number daal kar chalao.`r`n")
            continue
        }

        if (-not (Invoke-CompileOne -Item $p)) {
            $errc++
            Write-Host ("  [{0,2}/{1}] {2,-36} " -f $pos, $List.Count, $label) -NoNewline -ForegroundColor White
            Write-Host "COMPILE ERROR" -ForegroundColor Red
            [void]$log.Add("=== $($label)  [$($p.Rel)]  ->  COMPILE ERROR ===`r`n$($p.CompileErr)`r`n")
            continue
        }

        Write-Host ("  [{0,2}/{1}] {2,-36} " -f $pos, $List.Count, $label) -NoNewline -ForegroundColor White
        Write-Host "running... " -NoNewline -ForegroundColor DarkGray

        $r = Invoke-ProgramTimed -Item $p -StdinText (Get-SampleInputFor $p) -Seconds $script:RunAllTimeout
        $done++

        $status = 'OK'
        $color  = 'Green'
        if ($r.TimedOut)          { $status = 'TIME-LIMIT';  $color = 'Yellow'; $to++ }
        elseif ($r.ExitCode -ne 0) { $status = 'RUNTIME ERROR'; $color = 'Red'; $errc++ }
        else                      { $okc++ }

        Write-Host $status.PadRight(14) -ForegroundColor $color

        $body = $r.Output
        if ($p.Kind -eq 'INPUT') {
            $body = ">>> (sample input diya gaya: " + ((Get-SampleInputFor $p) -replace '\r\n', ', ').TrimEnd(', ') + ")`r`n" + $body
        }
        if ($r.TimedOut) { $body += "`r`n[-- $script:RunAllTimeout second ka time limit lag gaya, program rok diya --]" }

        [void]$log.Add("=== $($label)  [$($p.Rel)]  ->  $status ===`r`n$body`r`n")

        if ($ShowOutput) {
            Write-Host ""
            Write-Host "        -------------- output --------------" -ForegroundColor DarkCyan
            if ($body) {
                foreach ($ln in ($body -split "`r?`n")) {
                    if ($ln.Trim()) { Write-Host "        $ln" -ForegroundColor Gray }
                }
            }
            Write-Host "        ------------------------------------" -ForegroundColor DarkCyan
            Write-Host ""
        }
    }

    $header = @(
        "JAVA PRACTICE PROGRAMS - RUN ALL LOG",
        "Generated : $(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')",
        "Programs  : $($List.Count)",
        "Success   : $okc",
        "Time-limit: $to",
        "Errors    : $errc",
        "Skipped   : $skip  (GUI programs)",
        "Time limit per program: $script:RunAllTimeout second",
        ("=" * 70)
    ) -join "`r`n"

    Set-Content -LiteralPath $LogFile -Value ($header + "`r`n`r`n" + ($log -join "`r`n")) -Encoding UTF8

    Write-Title 'SUMMARY'
    Write-Sub "Success        : $okc"
    if ($to   -gt 0) { Write-Sub "Time limit hit : $to"    -ForegroundColor Yellow }
    if ($errc -gt 0) { Write-Sub "Runtime errors  : $errc" -ForegroundColor Red }
    if ($skip -gt 0) { Write-Sub "Skipped (GUI)   : $skip" -ForegroundColor Yellow }
    Write-Host ""
    Write-Sub "Poora output yahan hai :"
    Write-Host "    $LogFile" -ForegroundColor White
    Write-Host ""

    if ($script:OpenLogsNotepad) {
        try { Start-Process notepad.exe -ArgumentList "`"$LogFile`"" } catch { }
    }
}

# ------------------------------------------------------------------ menus ---
function Get-SortedPrograms {
    return @($programs | Sort-Object @{e={ $script:CatOrder.IndexOf($_.Category) }}, Title, Rel)
}

function Show-ProgramList {
    param($List)
    $i = 0
    $lastCat = ''
    foreach ($p in $List) {
        if ($p.Category -ne $lastCat) {
            if ($lastCat -ne '') { Write-Host "" }
            Write-Host "  $($p.Category)" -ForegroundColor Yellow
            $lastCat = $p.Category
        }
        $i++
        $badge = switch ($p.Kind) {
            'GUI'   { '[GUI]   ' }
            'INPUT' { '[input] ' }
            default { '         ' }
        }
        Write-Host ("  {0,3}. " -f $i) -NoNewline -ForegroundColor Green
        Write-Host $badge -NoNewline -ForegroundColor DarkGray
        Write-Host ((Get-DisplayLabel $p).PadRight(32)) -NoNewline -ForegroundColor White
        Write-Host $p.Rel -ForegroundColor DarkGray
    }
}

# "3", "1,3,5", "5-9", "2,5-8", "all"  -- sab samajhta hai
function Resolve-Selection {
    param([string]$Text, $List)

    $sel = New-Object System.Collections.ArrayList
    $t = "$Text".Trim().ToLower()

    if ($t -eq 'all' -or $t -eq '*') {
        foreach ($p in $List) { [void]$sel.Add($p) }
        return $sel
    }

    foreach ($part in ($t -split '[,\s]+')) {
        if (-not $part) { continue }
        if ($part -match '^(\d+)\s*-\s*(\d+)$') {
            $a = [int]$Matches[1]; $b = [int]$Matches[2]
            if ($a -gt $b) { $x = $a; $a = $b; $b = $x }
            for ($k = $a; $k -le $b; $k++) {
                if ($k -ge 1 -and $k -le $List.Count) { [void]$sel.Add($List[$k - 1]) }
            }
        }
        elseif ($part -match '^\d+$') {
            $k = [int]$part
            if ($k -ge 1 -and $k -le $List.Count) { [void]$sel.Add($List[$k - 1]) }
        }
        else {
            Write-Host "  '$part' samajh nahi aaya - sirf number ya range daalo (jaise 3, 5-8, all)" -ForegroundColor Red
        }
    }

    $seen = @{}
    $uniq = New-Object System.Collections.ArrayList
    foreach ($p in $sel) {
        if (-not $seen.ContainsKey($p.Rel)) { $seen[$p.Rel] = $true; [void]$uniq.Add($p) }
    }
    return $uniq
}

function Show-MainMenu {
    Clear-Host
    Show-Banner
    Write-Title 'CHOOSE KYA KARNA HAI'
    Write-Host "    1 " -NoNewline -ForegroundColor Green; Write-Host "  Ek ya kai programs chalao    (number ya range: 3,7,12  |  5-9  |  all)"
    Write-Host "    2 " -NoNewline -ForegroundColor Green; Write-Host "  Category se chalao            (DSA / OOP / Core / Projects)"
    Write-Host "    3 " -NoNewline -ForegroundColor Green; Write-Host "  Naam se search               (jaise: sort, inherit, matrix)"
    Write-Host "    4 " -NoNewline -ForegroundColor Green; Write-Host "  RUN ALL - sab ek saath       (poora output ek hi jagah)"
    Write-Host "    5 " -NoNewline -ForegroundColor Green; Write-Host "  Output report kholo          (pichli run ka pura record)"
    Write-Host "    6 " -NoNewline -ForegroundColor Green; Write-Host "  Sab dobara compile karo"
    Write-Host "    7 " -NoNewline -ForegroundColor Green; Write-Host "  Project folder kholo"
    Write-Host "    0 " -NoNewline -ForegroundColor Green; Write-Host "  Exit"
    Write-Host ""
    return (Read-Host '  Apna choice do (number likho)')
}

function Invoke-RunAll {
    Invoke-BatchRun -List (Get-SortedPrograms) -Heading 'RUN ALL'
}

function Show-Menu {
    $choice = Show-MainMenu

    switch -Regex ($choice.Trim()) {

        '^[1]$' {
            $list = Get-SortedPrograms
            Clear-Host
            Show-Banner
            Write-Title 'SAARE PROGRAMS'
            Show-ProgramList $list
            Write-Host ""
            Write-Sub "Ek ya ek se zyada number daalo:  jaise  3,7,12   ya  5-9   ya  all"
            Write-Host ""
            $sel = Resolve-Selection -Text (Read-Host '  Numbers daalo') -List $list

            if ($sel.Count -eq 0) { Start-Sleep -Seconds 1; return }

            if ($sel.Count -eq 1) {
                $p = $sel[0]
                if ($script:AutoCompile) { Invoke-CompileOne -Item $p | Out-Null }
                if (-not $p.Compiled) {
                    Clear-Host
                    Write-Host "  Ye compile nahi hua:" -ForegroundColor Red
                    Write-Host "  $($p.CompileErr)" -ForegroundColor DarkRed
                    Write-Host ""
                    Read-Host '  Enter dabao' | Out-Null
                    return
                }
                Invoke-ProgramInteractive -Item $p -Seconds $script:MenuTimeout
                Write-Host ""
                Read-Host '  Wapas menu ke liye Enter dabao' | Out-Null
            }
            else {
                Invoke-BatchRun -List $sel -Heading 'CHOSEN PROGRAMS' -ShowOutput
                Write-Host ""
                Read-Host '  Wapas menu ke liye Enter dabao' | Out-Null
            }
            return
        }

        '^[2]$' {
            $groups = @(Get-SortedPrograms | Group-Object Category | Sort-Object { $script:CatOrder.IndexOf($_.Name) })
            Clear-Host
            Write-Title 'CATEGORY KEHTAR'
            $i = 0
            foreach ($g in $groups) {
                $i++
                Write-Host ("  {0,2}. " -f $i) -NoNewline -ForegroundColor Green
                Write-Host ($g.Name.PadRight(36)) -NoNewline -ForegroundColor White
                Write-Host "$($g.Count) programs" -ForegroundColor DarkGray
            }
            Write-Host ""
            $c = (Read-Host '  Category number (0 = wapas)').Trim()
            if ($c -notmatch '^\d+$' -or [int]$c -lt 1 -or [int]$c -gt $groups.Count) { Start-Sleep -Seconds 1; return }

            $cat = @($groups[[int]$c - 1].Group | Sort-Object Title, Rel)
            Clear-Host
            Show-Banner
            Write-Title "CATEGORY: $($groups[[int]$c - 1].Name)"
            Show-ProgramList $cat
            Write-Host ""
            Write-Sub "Kaun se chalane hain? (number, 3,5 ya poore category ke liye 'all')"
            Write-Host ""
            $sel = Resolve-Selection -Text (Read-Host '  Numbers daalo') -List $cat
            if ($sel.Count -eq 0) { Start-Sleep -Seconds 1; return }

            Invoke-BatchRun -List $sel -Heading "CATEGORY RUN - $($groups[[int]$c - 1].Name)" -ShowOutput
            Write-Host ""
            Read-Host '  Wapas menu ke liye Enter dabao' | Out-Null
            return
        }

        '^[3]$' {
            Clear-Host
            Write-Title 'SEARCH'
            $kw = (Read-Host '  Kya dhoondhna hai? (jaise: sort, inherit, matrix, queue)').Trim()
            if (-not $kw) { return }

            $res = @(Get-SortedPrograms | Where-Object {
                $_.Rel -match [regex]::Escape($kw) -or $_.Title -match [regex]::Escape($kw) -or $_.Topic -match [regex]::Escape($kw)
            })

            if ($res.Count -eq 0) {
                Clear-Host
                Write-Host "  '$kw' se kuch nahi mila. Dusra word try karo." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
                return
            }

            Clear-Host
            Show-Banner
            Write-Title "SEARCH RESULT: '$kw'  ($($res.Count) mile)"
            Show-ProgramList $res
            Write-Host ""
            Write-Sub "Kaun se chalane hain? (number, ya 'all')"
            Write-Host ""
            $sel = Resolve-Selection -Text (Read-Host '  Numbers daalo') -List $res
            if ($sel.Count -eq 0) { Start-Sleep -Seconds 1; return }

            Invoke-BatchRun -List $sel -Heading "SEARCH: $kw" -ShowOutput
            Write-Host ""
            Read-Host '  Wapas menu ke liye Enter dabao' | Out-Null
            return
        }

        '^[4]$' {
            Invoke-BatchRun -List (Get-SortedPrograms) -Heading 'RUN ALL'
            Write-Host ""
            Read-Host '  Wapas menu ke liye Enter dabao' | Out-Null
            return
        }

        '^[5]$' {
            if (Test-Path -LiteralPath $LogFile) {
                try { Start-Process notepad.exe -ArgumentList "`"$LogFile`"" } catch { }
            }
            else {
                Clear-Host
                Write-Sub "Abhi koi report nahi bani. Pehle option 4 (RUN ALL) dabao." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
            return
        }

        '^[6]$' {
            Clear-Host
            Write-Title 'RECOMPILE'
            Write-Sub "Sab programs dobara compile ho rahe hain..."
            $r = Invoke-CompileAll
            Write-Sub "Compiled: $($r.Ok)   Failed: $($r.Fail)"
            foreach ($p in ($programs | Where-Object { -not $_.Compiled })) {
                Write-Host "   $($p.Rel)" -ForegroundColor Red
                Write-Host "     $($p.CompileErr)" -ForegroundColor DarkRed
            }
            Write-Host ""
            Read-Host '  Wapas menu ke liye Enter dabao' | Out-Null
            return
        }

        '^[7]$' { try { Start-Process explorer.exe -ArgumentList "`"$Root`"" } catch { }; return }

        '^[0]$' { exit 0 }

        default {
            Clear-Host
            Write-Host "  '$choice' samajh nahi aaya. 0 se 7 ke beech koi number daalo." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}

# ------------------------------------------------------------------ start --
Show-Banner
Write-Host ""
Write-Sub "Pehli baar sab compile ho rahe hain..."
$compileResult = Invoke-CompileAll
Write-Sub "Compiled: $($compileResult.Ok)   Failed: $($compileResult.Fail)"
Write-Host ""

if ($RunAll) {
    Invoke-RunAll
    if (-not $NoPause) { Write-Host ""; Read-Host '  Band karne ke liye Enter dabao' | Out-Null }
    exit 0
}

# unattended headless call (e.g. -RunAll -NoPause)
if ([Environment]::UserInteractive -eq $false) {
    Invoke-RunAll
    exit 0
}

while ($true) { Show-Menu }