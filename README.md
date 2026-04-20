A lightweight, terminal-based Bash script for downloading YouTube (and other supported sites) content with a clean "Matrix" green-on-black aesthetic. It features dual progress bars for updates and processing, utilizing yt-dlp and ffmpeg for high-quality media extraction.

✨ Features
Dual-Phase Progress Bars: * UPDATE: Visually tracks the yt-dlp self-update phase.

PROCESS: Real-time progress tracking for both downloads and ffmpeg conversions.

Matrix Aesthetic: Beautiful green-on-black UI with high-visibility indicators.

Auto-Update: Automatically checks for and updates yt-dlp via pip on every run.

Audio/Video Modes: Download high-quality MP3s or the best available MP4 video.

Smart Naming: Automatically fetches and formats filenames based on video titles.

🛠 Prerequisites
Ensure you have the following installed and available in your PATH:

yt-dlp: (Installed via pip)

Bash
pip install -U yt-dlp
ffmpeg & ffprobe: Required for media conversion and duration detection.

Bash: Designed for Unix-like environments (Linux, macOS, WSL).

🚀 Installation
Clone the repository or download the script:

Bash
git clone https://github.com/your-username/matrix-ytdlp.git
cd matrix-ytdlp
Make the script executable:

Bash
chmod +x download.sh
📖 Usage
Run the script with a URL and a mode flag (a for audio or v for video):

Bash
./download.sh <URL> <mode>
Examples
Download Audio (MP3):

Bash
./download.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" a
Download Video (MP4):

Bash
./download.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" v
📂 Storage Structure
The script automatically organizes downloads into the following directory tree:

Plaintext
storage/downloads/ytdlp/
├── audio/    # Processed .mp3 files
└── video/    # Merged .mp4 files
⚙️ Configuration
You can customize the base directory and subdirectories by editing the variables at the top of the script:

Bash
BASE_DIR="storage/downloads/ytdlp"
AUDIO_SUBDIR="audio"
VIDEO_SUBDIR="video"
📝 License
This project is open-source and available under the MIT License.
