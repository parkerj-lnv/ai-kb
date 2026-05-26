<#
.SYNOPSIS
    Fetches a YouTube video transcript and saves it to the ai-kb raw folder
    for ingestion by Claude Code.

.DESCRIPTION
    Retrieves video metadata and transcript for a given YouTube URL, then saves
    a clean, structured markdown file to raw/ ready for Claude Code to ingest
    using the CLAUDE.md workflow.

    No Anthropic API key required -- analysis is handled interactively by
    Claude Code using your existing Claude subscription.

.PARAMETER Url
    The YouTube video URL. Supports:
      - https://youtu.be/VIDEO_ID
      - https://www.youtube.com/watch?v=VIDEO_ID
      - Short URLs with tracking params (?si=...)

.PARAMETER OutputPath
    Folder to save the transcript file. Defaults to C:\git\parkerj-lnv\ai-kb\raw

.EXAMPLE
    .\New-YouTubeTranscript.ps1 -Url "https://youtu.be/oqlrpj7eJQ8"

.EXAMPLE
    .\New-YouTubeTranscript.ps1 -Url "https://youtu.be/oqlrpj7eJQ8" -OutputPath "D:\notes\raw"

.NOTES
    Prerequisites:
      - Python 3.x available in PATH
      - youtube-transcript-api Python package (auto-installed if missing)

    After running, open your ai-kb repo in Claude Code and run:
      claude
    Then ask: "Please ingest <filename>.md from raw/"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, HelpMessage = "YouTube video URL")]
    [string]$Url,

    [string]$OutputPath = "C:\git\parkerj-lnv\ai-kb\raw"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -------------------------------------------
# HELPERS
# -------------------------------------------

function Write-Step    { param([string]$m) Write-Host "  -> $m" -ForegroundColor Cyan }
function Write-Success { param([string]$m) Write-Host "  [OK] $m" -ForegroundColor Green }
function Write-Warn    { param([string]$m) Write-Host "  [!] $m" -ForegroundColor Yellow }
function Write-Fail    { param([string]$m) Write-Host "  [X] $m" -ForegroundColor Red }

# -------------------------------------------
# STEP 1: Extract Video ID
# -------------------------------------------

Write-Host "`n[New-YouTubeTranscript]" -ForegroundColor Yellow

Write-Step "Extracting video ID..."

$videoId = $null

if      ($Url -match 'youtu\.be/([a-zA-Z0-9_-]{11})')   { $videoId = $Matches[1] }
elseif  ($Url -match '[?&]v=([a-zA-Z0-9_-]{11})')        { $videoId = $Matches[1] }
elseif  ($Url -match '/embed/([a-zA-Z0-9_-]{11})')       { $videoId = $Matches[1] }

if (-not $videoId) {
    Write-Fail "Could not extract a valid YouTube video ID from: $Url"
    exit 1
}

$canonicalUrl = "https://www.youtube.com/watch?v=$videoId"
Write-Success "Video ID: $videoId"

# -------------------------------------------
# STEP 2: Check Python
# -------------------------------------------

Write-Step "Checking Python..."

$pythonCmd = $null
foreach ($cmd in @("python", "python3")) {
    try {
        $ver = & $cmd --version 2>&1
        if ($ver -match "Python 3") { $pythonCmd = $cmd; break }
    } catch { }
}

if (-not $pythonCmd) {
    Write-Fail "Python 3 is required but not found in PATH. Install from https://python.org"
    exit 1
}

Write-Success "Python: $pythonCmd"

# Check / auto-install youtube-transcript-api
$pkgCheck = & $pythonCmd -c "import youtube_transcript_api; print('ok')" 2>&1
if ($pkgCheck -ne "ok") {
    Write-Step "Installing youtube-transcript-api..."
    & $pythonCmd -m pip install youtube-transcript-api --quiet
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Failed to install youtube-transcript-api. Run: pip install youtube-transcript-api"
        exit 1
    }
    Write-Success "youtube-transcript-api installed"
} else {
    Write-Success "youtube-transcript-api available"
}

# -------------------------------------------
# STEP 3: Fetch Video Metadata (oEmbed)
# -------------------------------------------

Write-Step "Fetching video metadata..."

$videoTitle  = $videoId
$channelName = "Unknown"

try {
    $oembedUrl = "https://www.youtube.com/oembed?url=$canonicalUrl&format=json"
    $oembed    = Invoke-RestMethod -Uri $oembedUrl -Method Get -TimeoutSec 10
    $videoTitle  = $oembed.title
    $channelName = $oembed.author_name
    Write-Success "Title  : $videoTitle"
    Write-Success "Channel: $channelName"
} catch {
    Write-Warn "Could not fetch oEmbed metadata -- using video ID as title"
}

# -------------------------------------------
# STEP 4: Fetch Transcript
# -------------------------------------------

Write-Step "Fetching transcript..."

$pythonScript = @'
import sys, json
from youtube_transcript_api import YouTubeTranscriptApi

video_id = sys.argv[1]

try:
    api = YouTubeTranscriptApi()

    # Prefer manual English, fall back to auto-generated, then any available
    transcript = None
    lang_info  = {}

    try:
        transcript_list = api.list(video_id)

        for t in transcript_list:
            if t.language_code.startswith('en') and not t.is_generated:
                transcript = t.fetch()
                lang_info  = {'language': t.language_code, 'is_generated': False}
                break

        if transcript is None:
            for t in transcript_list:
                if t.language_code.startswith('en') and t.is_generated:
                    transcript = t.fetch()
                    lang_info  = {'language': t.language_code, 'is_generated': True}
                    break

        if transcript is None:
            first      = next(iter(transcript_list))
            transcript = first.fetch()
            lang_info  = {'language': first.language_code, 'is_generated': first.is_generated}

    except Exception:
        transcript = api.fetch(video_id)
        lang_info  = {'language': 'en', 'is_generated': True}

    # Build paragraphs: treat gaps > 3 s as a new paragraph.
    # v1.x returns FetchedTranscriptSnippet objects (attribute access);
    # v0.x returned dicts (.get()). Support both defensively.
    segments  = []
    prev_end  = 0
    buffer    = []

    for entry in transcript:
        if hasattr(entry, 'start'):
            start    = entry.start or 0
            duration = entry.duration or 0
            text     = (entry.text or '').strip().replace('\n', ' ')
        else:
            start    = entry.get('start', 0)
            duration = entry.get('duration', 0)
            text     = entry.get('text', '').strip().replace('\n', ' ')

        if start - prev_end > 3.0 and buffer:
            segments.append(' '.join(buffer))
            buffer = []

        buffer.append(text)
        prev_end = start + duration

    if buffer:
        segments.append(' '.join(buffer))

    full_text = '\n\n'.join(segments)

    print(json.dumps({
        'text'        : full_text,
        'language'    : lang_info.get('language', 'en'),
        'is_generated': lang_info.get('is_generated', True),
        'char_count'  : len(full_text),
        'paragraphs'  : len(segments)
    }))

except Exception as e:
    print(json.dumps({'error': str(e)}))
    sys.exit(1)
'@

$tempPy = [System.IO.Path]::GetTempFileName() + ".py"
Set-Content -Path $tempPy -Value $pythonScript -Encoding UTF8

try {
    $rawOutput      = & $pythonCmd $tempPy $videoId 2>&1
    $transcriptData = $rawOutput | ConvertFrom-Json

    if ($transcriptData.PSObject.Properties['error'] -and $transcriptData.error) {
        Write-Fail "Transcript error: $($transcriptData.error)"
        exit 1
    }

    $transcriptText = $transcriptData.text
    $charCount      = $transcriptData.char_count
    $paragraphs     = $transcriptData.paragraphs
    $isGenerated    = $transcriptData.is_generated

    Write-Success "Fetched $charCount chars across $paragraphs paragraphs (auto-generated: $isGenerated)"

} finally {
    Remove-Item $tempPy -Force -ErrorAction SilentlyContinue
}

# -------------------------------------------
# STEP 5: Build Markdown File
# -------------------------------------------

Write-Step "Building markdown file..."

$today     = Get-Date -Format "yyyy-MM-dd"
$safeTitle = $videoTitle -replace '[\\/:*?"<>|]', '' -replace "['\u2019\u2018]", '' `
                         -replace '\s+', '-' -replace '-{2,}', '-'
$safeTitle = $safeTitle.Trim('-').ToLower()
$fileName  = "yt-$safeTitle.md"
$filePath  = Join-Path $OutputPath $fileName

$transcriptNote = if ($isGenerated) {
    "> **Note:** This transcript was auto-generated by YouTube and may contain errors, especially with proper nouns or technical terms."
} else {
    "> **Note:** This transcript was sourced from manually-created captions."
}

$markdown = @"
---
title: "$($videoTitle -replace '"', "'")"
type: youtube-video
source: YouTube
channel: "$($channelName -replace '"', "'")"
url: "$canonicalUrl"
date_processed: $today
tags:
  - youtube
  - video-notes
---

# $videoTitle

| Field     | Value |
|-----------|-------|
| Channel   | $channelName |
| URL       | [$canonicalUrl]($canonicalUrl) |
| Processed | $today |

---

## Transcript

$transcriptNote

$transcriptText
"@

# -------------------------------------------
# STEP 6: Save File
# -------------------------------------------

Write-Step "Saving file..."

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Set-Content -Path $filePath -Value $markdown -Encoding UTF8

$sizeKb = [Math]::Round((Get-Item $filePath).Length / 1KB, 1)
Write-Success "Saved: $fileName ($sizeKb KB)"

# -------------------------------------------
# DONE
# -------------------------------------------

Write-Host ""
Write-Host "  Done. Next steps:" -ForegroundColor White
Write-Host "    cd C:\git\parkerj-lnv\ai-kb" -ForegroundColor Gray
Write-Host "    claude" -ForegroundColor Gray
Write-Host "    Then ask: 'Please ingest $fileName from raw/'" -ForegroundColor Gray
Write-Host ""