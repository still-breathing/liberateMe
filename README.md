# Matrix-style yt-dlp Downloader

A lightweight, terminal-based Bash script for downloading media with a clean "Matrix" green-on-black aesthetic. It features dual progress bars for updates and processing, utilizing `yt-dlp` and `ffmpeg` for high-quality media extraction.

## ✨ Features

* **Dual-Phase Progress Bars:** * **UPDATE:** Tracks the `yt-dlp` self-check phase.
    * **PROCESS:** Maps real-time progress for both downloads and `ffmpeg` conversions.
* **Matrix Aesthetic:** High-visibility green-on-black UI using ANSI escape codes.
* **Auto-Update:** Automatically triggers a `yt-dlp` update via pip to ensure compatibility with site changes.
* **Smart Naming:** Automatically fetches video titles for clean file naming.
* **Audio/Video Toggle:** Download high-quality MP3s or the best available MP4 video with a single flag.

---

## 🛠 Prerequisites

Ensure you have the following installed and available in your `PATH`:

1.  **yt-dlp:** (Installed via pip)
    ```bash
    pip install -U yt-dlp
    ```
2.  **ffmpeg & ffprobe:** Required for media conversion and progress calculation.
3.  **Bash:** Designed for Unix-like environments (Linux, macOS, WSL).

---

## 🚀 Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/matrix-ytdlp.git](https://github.com/your-username/matrix-ytdlp.git)
    cd matrix-ytdlp
    ```

2.  **Make the script executable:**
    ```bash
    chmod +x download.sh
    ```

---

## 📖 Usage

Run the script by providing a URL and a mode flag (`a` for audio or `v` for video):

```bash
./download.sh <URL> <mode>
