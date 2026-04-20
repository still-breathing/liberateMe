#!/bin/bash
# ============================================================
# Matrix-style yt-dlp Downloader
# ------------------------------------------------------------
# Features:
# - Auto-update yt-dlp (pip-installed)
# - Dual progress bars:
#     * UPDATE   → yt-dlp update phase
#     * PROCESS  → download / conversion phase
# - Real progress for yt-dlp + ffmpeg
# - Matrix green-on-black terminal theme
# - Clean ✔ completion indicator
#
# Requirements:
# - yt-dlp installed via pip
# - ffmpeg + ffprobe available in PATH
# ============================================================


# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
# Base directory for all downloads
BASE_DIR="storage/downloads/ytdlp"

# Subdirectories for media types
AUDIO_SUBDIR="audio"
VIDEO_SUBDIR="video"


# ------------------------------------------------------------
# Matrix Color Theme (ANSI escape codes)
# ------------------------------------------------------------
# Bright green for highlights
GREEN="\033[1;32m"

# Dim green for UI elements (bars, labels)
DIM_GREEN="\033[0;32m"

# Reset terminal colors
RESET="\033[0m"

# Clear current terminal line
CLEAR_LINE="\033[2K"


# ------------------------------------------------------------
# Logging Helpers
# ------------------------------------------------------------
# Minimal, readable logs that don’t interfere with UI
log_info() {
    echo -e "${GREEN}[INFO]${RESET} $1"
}

log_error() {
    echo -e "${GREEN}[ERROR]${RESET} $1" >&2
}

log_success() {
    echo -e "${GREEN}✔ $1${RESET}"
}


# ------------------------------------------------------------
# Progress Bar Renderer
# ------------------------------------------------------------
# Arguments:
#   $1 → percentage (0–100)
#   $2 → label (UPDATE / PROCESS)
#   $3 → terminal row (0 = top)
#
# Uses tput to avoid breaking terminal layout
draw_bar() {
    local percent=$1
    local label="$2"
    local row="$3"

    # Detect terminal width (fallback to 80)
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)

    # Reserve space for label + percentage
    local bar_width=$((cols - 25))
    ((bar_width < 20)) && bar_width=20

    # Calculate filled portion
    local filled=$((percent * bar_width / 100))

    # Save cursor position
    tput sc

    # Move cursor to requested row
    tput cup "$row" 0

    # Draw bar
    printf "${CLEAR_LINE}${DIM_GREEN}%s [" "$label"
    printf "%${filled}s" | tr ' ' '█'
    printf "%$((bar_width - filled))s" | tr ' ' '░'
    printf "] %3d%%%s" "$percent" "$RESET"

    # Restore cursor position
    tput rc
}


# ------------------------------------------------------------
# yt-dlp Update Check (pip-installed)
# ------------------------------------------------------------
# pip / python updates do not expose reliable progress,
# so we provide a visually smooth, bounded update bar.
check_and_update_ytdlp() {
    if ! command -v yt-dlp >/dev/null 2>&1; then
        log_error "yt-dlp not found. Install with: pip install -U yt-dlp"
        exit 1
    fi

    log_info "Checking yt-dlp updates..."

    # Background animation while update runs
    (
        for i in {1..90}; do
            draw_bar "$i" "UPDATE  " 0
            sleep 0.03
        done
    ) &
    updater_pid=$!

    # Perform actual update
    python -m yt_dlp -U >/dev/null 2>&1

    # Stop animation
    wait "$updater_pid"

    # Finalize update bar
    draw_bar 100 "UPDATE  " 0
}


# ------------------------------------------------------------
# yt-dlp Download with Real Progress
# ------------------------------------------------------------
# Uses yt-dlp progress template to extract %
# and map it directly to the PROCESS bar.
yt_dlp_with_progress() {
    yt-dlp \
        --newline \
        --progress-template "%(progress._percent_str)s" \
        "$@" 2>/dev/null | while read -r line; do

            # Strip % symbol and validate numeric value
            percent=$(echo "$line" | tr -d '%')
            [[ "$percent" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue

            draw_bar "${percent%.*}" "PROCESS " 1
        done
}


# ------------------------------------------------------------
# ffmpeg Conversion Progress
# ------------------------------------------------------------
# ffmpeg exposes time-based progress, so we:
# - read total duration via ffprobe
# - calculate % from processed seconds
ffmpeg_with_progress() {
    local input="$1"
    local output="$2"

    # Get total duration (seconds)
    duration=$(ffprobe -v error \
        -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$input")
    duration=${duration%.*}

    ffmpeg -y -i "$input" \
        -vn -acodec libmp3lame -q:a 2 "$output" \
        -progress pipe:1 -nostats 2>/dev/null | while read -r line; do

            case "$line" in
                out_time_ms=*)
                    ms=${line#*=}
                    sec=$((ms / 1000000))
                    percent=$((sec * 100 / duration))
                    ((percent > 100)) && percent=100
                    draw_bar "$percent" "PROCESS " 1
                    ;;
            esac
        done
}


# ------------------------------------------------------------
# Argument Validation
# ------------------------------------------------------------
if [ "$#" -ne 2 ]; then
    log_error "Usage: $0 <url> <a|v>"
    exit 1
fi

URL="$1"
OPTION="$2"

# Basic URL sanity check
[[ "$URL" =~ ^https?:// ]] || {
    log_error "Invalid URL"
    exit 1
}


# ------------------------------------------------------------
# UI Initialization
# ------------------------------------------------------------
clear
echo -e "${GREEN}Matrix Downloader Initialized${RESET}\n"


# ------------------------------------------------------------
# Update Phase
# ------------------------------------------------------------
check_and_update_ytdlp


# ------------------------------------------------------------
# Directory Setup
# ------------------------------------------------------------
mkdir -p "$BASE_DIR" || exit 1
cd "$BASE_DIR" || exit 1

# Fetch clean title early (used for naming)
title=$(yt-dlp --get-filename -o "%(title)s" "$URL")
[ -z "$title" ] && {
    log_error "Failed to fetch title"
    exit 1
}


# ------------------------------------------------------------
# AUDIO MODE
# ------------------------------------------------------------
if [ "$OPTION" = "a" ]; then
    mkdir -p "$AUDIO_SUBDIR"
    cd "$AUDIO_SUBDIR" || exit 1

    # Download best audio to temp file
    temp_pattern="%(id)s.%(ext)s"
    temp_file=$(yt-dlp --get-filename -f bestaudio -o "$temp_pattern" "$URL")

    yt_dlp_with_progress -f bestaudio -o "$temp_pattern" "$URL"

    # Convert to MP3 with real progress
    ffmpeg_with_progress "$temp_file" "${title}.mp3"

    # Cleanup
    rm -f "$temp_file"


# ------------------------------------------------------------
# VIDEO MODE
# ------------------------------------------------------------
elif [ "$OPTION" = "v" ]; then
    mkdir -p "$VIDEO_SUBDIR"
    cd "$VIDEO_SUBDIR" || exit 1

    yt_dlp_with_progress \
        -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/best" \
        -o "%(title)s.%(ext)s" \
        "$URL"

else
    log_error "Invalid option. Use 'a' or 'v'"
    exit 1
fi


# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------
draw_bar 100 "PROCESS " 1
echo -e "\n\n${GREEN}✔ Finished successfully${RESET}"
exit 

