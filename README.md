YT-Downloader :arrow_down:
:warning: This software is intended solely for educational purposes. Permission is granted for educational use and modification. Redistribution, commercial use, or any for-profit activities are not permitted without prior written consent from the author.

:bookmark_tabs: Table of Contents
About
Metadata and License
Error Handling
Initial Setup
Functions
Main Execution
Video Download
File Management and Video Compression
Short Video Creation
External Dependencies
:bulb: About
This Bash script is designed for downloading, processing, and optionally uploading videos from YouTube. Below are key aspects of the script's functionality:

:lock: Metadata and License
The script comes with a detailed copyright and licensing section, explicitly allowing educational use and modification.

:x: Error Handling
The script exits if any command fails (set -e).

:gear: Initial Setup
Variables are defined for file paths, file names, and settings.

:wrench: Functions
validate_time_format(): Validates a time string in the hh:mm:ss format.
upload_video(): Uploads a video to YouTube using Python.
macos_install(), linux_install(), linux_install_ytdlp(): Install necessary packages based on the operating system.
install_package(): Checks and installs a required package.
conditional_install(): Determines the OS and conditionally installs the required packages.
refresh_shell_session(): Refreshes the shell session after package installations.
:rocket: Main Execution
The script identifies the user's OS and installs required packages like yt-dlp, yasm, pkg-config, etc.

User input is collected to determine:

The YouTube video URL.
Whether to compress the video.
The folder name for downloads.
Whether to download the entire video or a specific segment.
:floppy_disk: Video Download
The script uses yt-dlp to download the video from YouTube based on the user's choice.

:file_folder: File Management and Video Compression
After downloading, the video is optionally compressed and watermarked using ffmpeg.

:scissors: Short Video Creation
Users have the option to create a short video clip from the downloaded video.

:link: External Dependencies
The script relies on external Python scripts (uploadYoutube.py) and assets like a watermark image.
