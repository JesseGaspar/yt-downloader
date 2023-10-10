# YT-Downloader

> :warning: **Disclaimer**: This software is solely intended for educational purposes. Permission is granted for educational use and modification. Redistribution, commercial use, or any for-profit activities are not permitted without prior written consent from the author.

## Table of Contents
1. [Metadata and License](#metadata-and-license)
2. [Error Handling](#error-handling)
3. [Initial Setup](#initial-setup)
4. [Functions](#functions)
5. [Main Execution](#main-execution)
6. [Video Download](#video-download)
7. [File Management and Video Compression](#file-management-and-video-compression)
8. [Short Video Creation](#short-video-creation)
9. [External Dependencies](#external-dependencies)

---

## Metadata and License

The script comes with a detailed copyright and licensing section, explicitly allowing educational use and modification.

## Error Handling

The script utilizes Bash's `set -e` to exit if any command fails.

## Initial Setup

Variables are defined for file paths, file names, and settings.
The only thing you have to do is:

`sh start.sh`

## Functions

- `validate_time_format()`: Validates a time string in the hh:mm:ss format.
- `upload_video()`: Uploads a video to YouTube using Python.
- `macos_install(), linux_install(), linux_install_ytdlp()`: Install necessary packages based on the operating system.
- `install_package()`: Checks and installs a required package.
- `conditional_install()`: Determines the OS and conditionally installs the required packages.
- `refresh_shell_session()`: Refreshes the shell session after package installations.

## Main Execution

The script identifies the user's OS and installs required packages like yt-dlp, yasm, pkg-config, etc.

### User Input

The script collects input to determine:
- The YouTube video URL
- Whether to compress the video
- The folder name for downloads
- Whether to download the entire video or a specific segment

## Video Download

The script uses `yt-dlp` to download the video from YouTube based on the user's choice.

## File Management and Video Compression

After downloading, the video is optionally compressed and watermarked using ffmpeg.

## Short Video Creation

Users have the option to create a short video clip from the downloaded video.

## External Dependencies

The script relies on external Python scripts (`uploadYoutube.py`) and assets like a watermark image.

---

Overall, this script serves as a comprehensive tool for automating YouTube video downloading and processing tasks. It also has the capability to upload the processed videos back to YouTube.
