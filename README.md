# yt-downloader
This software is solely intended for educational purposes. Permission is hereby granted for educational use and modification. Redistribution, commercial use or any for-profit activities are not permitted without prior written consent from the author.

The provided script is a Bash script designed for downloading, processing, and optionally uploading videos from YouTube. Below are key aspects of the script's functionality:

Metadata and License
The script comes with a detailed copyright and licensing section, explicitly allowing educational use and modification.

Error Handling
The script exits if any command fails (set -e).

Initial Setup
Variables are defined for file paths, file names, and settings.

Functions
validate_time_format(): Validates a time string in the hh:mm:ss format.
upload_video(): Uploads a video to YouTube using Python.
macos_install(), linux_install(), linux_install_ytdlp(): Install necessary packages based on the operating system.
install_package(): Checks and installs a required package.
conditional_install(): Determines the OS and conditionally installs the required packages.
refresh_shell_session(): Refreshes the shell session after package installations.

Main Execution
The script identifies the user's OS and installs required packages like yt-dlp, yasm, pkg-config, etc.
User input is collected to determine:
The YouTube video URL.
Whether to compress the video.
The folder name for downloads.
Whether to download the entire video or a specific segment.

Video Download
The script uses yt-dlp to download the video from YouTube based on the user's choice.

File Management and Video Compression
After downloading, the video is optionally compressed and watermarked using ffmpeg.

Short Video Creation
Users have the option to create a short video clip from the downloaded video.

External Dependencies
The script relies on external Python scripts (uploadYoutube.py) and assets like a watermark image.

Overall, this script serves as a comprehensive tool for automating YouTube video downloading and processing tasks. It also has the capability to upload the processed videos back to YouTube.
