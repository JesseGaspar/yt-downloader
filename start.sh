#!/bin/bash
# ----------------------------------------------------------
# LICENSE
# ----------------------------------------------------------
# Educational Use Only
# Copyright 2023 Jesse Gaspar
#
# This software is solely intended for educational purposes.
# Permission is hereby granted for educational use and modification.
# Redistribution, commercial use or any for-profit activities are
# not permitted without prior written consent from the author.
# YT-Downloader © 2023 by Jesse Gaspar is licensed under CC BY-NC 4.0 
# ----------------------------------------------------------

# Stop the script if any command fails
set -e

# Starting
echo "Starting..."

# ----------------------------------------------------------
# VARIABLES
# ----------------------------------------------------------
# Define paths and settings for video downloading and processing
DOWNLOAD_PATH="downloads"
CREDENTIALS_PATH="credentials/youtube.json"
OUTPUT_FILE_NAME="temp_video"
OUTPUT_FILE_EXTENSION="mkv"
DESKTOP_FILE_NAME="default"
SHORT_FILE_NAME="short"
WATERMARK_TEXT="Your watermark"
WATERMARK_IMAGE_PATH="assets/images/watermark.png"
UPLOAD_TO_YOUTUBE="FALSE"

# ----------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------

# Validate hh:mm:ss time format
validate_time_format() {
  if [[ $1 =~ ^([0-9]{2}):([0-9]{2}):([0-9]{2})$ ]]; then
    return 0
  else
    return 1
  fi
}

# Upload video to YouTube
upload_video() {
  local video_path=$1
  local title=$2
  local description=$3
  local tags=$4
  if [ -f "${title}.uploaded" ]; then
    echo "The video ${title} has already been uploaded. Skipping upload."
  else
    python3 functions/uploadYoutube.py "$CREDENTIALS_PATH" "$video_path" "$title" "$description" "$tags"
    touch "${title}.uploaded"
  fi
}

# MacOS package installation
macos_install() {
  local target=$1
  echo "Installing ${target} on MacOS. Please wait..."
  brew install "$target"
}

# Linux package installation
linux_install() {
  local target=$1
  echo "Installing ${target} on Linux. Please wait..."
  sudo apt-get install -y "$target"
}

# Linux yt-dlp package installation
linux_install_ytdlp() {
  echo "Installing yt-dlp on Linux. Please wait..."
  sudo add-apt-repository ppa:tomtomtom/yt-dlp
  sudo apt update
  sudo apt install yt-dlp
}

# Check and install necessary packages
install_package() {
  local package=$1
  local installer=$2

  # MacOS-specific installation
  if [ "$installer" == "macos_install" ]; then
    if ! brew list --formula | grep -q "^${package}\$"; then
      echo "${package} is not installed. Installing..."
      $installer "$package"
    fi
  # Linux-specific installation
  elif [ "$installer" == "linux_install" ]; then
    if [ "$package" == "yt-dlp" ]; then
      linux_install_ytdlp
    else
      if ! dpkg -l | grep -q "^ii  ${package} "; then
        echo "${package} is not installed. Installing..."
        $installer "$package"
      fi
    fi
  fi

  # Refresh the shell session after package installation
  refresh_shell_session
}

# OS-specific package installation
conditional_install() {
  local os=$(uname)
  local installer

  # Determine the OS and set the corresponding installer function
  if [ "$os" == "Darwin" ]; then
    echo "MacOS system detected."
    installer=macos_install
  elif [ "$os" == "Linux" ]; then
    echo "Linux system detected."
    installer=linux_install
  else
    echo "Unsupported operating system."
    exit 1
  fi

  # Loading
  echo "Please wait..."

  # Install packages
  for package in yt-dlp yasm pkg-config libass-dev ffmpeg x264; do
    install_package "$package" "$installer"
  done

  # Refresh the shell session after all installations
  refresh_shell_session
}

# Refresh the shell session
refresh_shell_session() {
  if [ -n "$ZSH_VERSION" ]; then
    if [ -f ~/.zshrc ]; then
      source ~/.zshrc
    else
      echo ".zshrc file not found."
    fi
  elif [ -n "$BASH_VERSION" ]; then
    if [ -f ~/.bash_profile ]; then
      source ~/.bash_profile
    elif [ -f ~/.bashrc ]; then
      source ~/.bashrc
    else
      echo ".bash_profile or .bashrc file not found."
    fi
  fi
}

# ----------------------------------------------------------
# EXECUTION
# ----------------------------------------------------------

# Start the conditional installation based on the detected OS
conditional_install

# ----------------------------------------------------------
# USER INTERACTIONS
# ----------------------------------------------------------

# Prompt the user for the YouTube video URL
read -p "Please enter the YouTube video URL: " video_url

# Validate the provided URL
if [[ ! $video_url =~ ^https://www.youtube.com/.*$ ]]; then
  echo "Invalid URL"
  exit 1
fi

# Ask the user whether the downloaded video should be compressed
read -p "Do you want to compress the video? [y/N]: " compress_option

# Ask the user if they want to name the folder with a custom name instead of the date
read -p "Do you want to name the folder with a custom name instead of the date? [y/N]: " custom_folder

# Set the folder name based on the user's choice
if [ "$custom_folder" == "y" ] || [ "$custom_folder" == "Y" ]; then
  read -p "Please enter the folder name: " current_date
else
  current_date=$(date +"%d-%m-%Y")
fi

# Create a new folder with the date or custom name
mkdir -p "$DOWNLOAD_PATH/$current_date"

# Ask the user whether they want to download the entire video or a segment
while true; do
  read -p "Would you like to download the entire video or just a portion of the video? [1/2]: " download_option
  if [ "$download_option" == "1" ]; then
    yt_dlp_args='-f bestvideo+bestaudio/best'
    break
  elif [ "$download_option" == "2" ]; then
    while true; do
      read -p "Please specify the time segment you want to download (format: hh:mm:ss): " video_time
      if validate_time_format "$video_time"; then
        yt_dlp_args="-f bestvideo+bestaudio/best --postprocessor-args \"-ss 00:00:00 -t $video_time\""
        break
      else
        echo "Invalid time format. The hh:mm:ss format must be followed, where hh is the hour (e.g., 01), mm is the minutes (e.g., 30), and ss is the seconds (e.g., 40). Please try again."
      fi
    done
    break
  else
    echo "Invalid option. Please try again."
  fi
done

# ----------------------------------------------------------
# VIDEO DOWNLOAD
# ----------------------------------------------------------

# Download the video based on the user's choice
if [ "$download_option" == "1" ]; then
  yt-dlp $video_url -f 'bestvideo+bestaudio/best' -o "$DOWNLOAD_PATH/${current_date}/$OUTPUT_FILE_NAME.%(ext)s"
elif [ "$download_option" == "2" ]; then
  yt-dlp $video_url -f 'bestvideo+bestaudio/best' --postprocessor-args "-ss 00:00:00 -t $video_time" -o "$DOWNLOAD_PATH/${current_date}/$OUTPUT_FILE_NAME.%(ext)s"
fi

# ----------------------------------------------------------
# FILE MANAGEMENT AND VIDEO COMPRESSION
# ----------------------------------------------------------

# Capture the real extension of the downloaded file
real_ext=$(find "$DOWNLOAD_PATH/${current_date}" -name $OUTPUT_FILE_NAME'.*')

# Define the output file name with the current time
output=$(date +"%H-%M-%S")

# Rename the downloaded video file
mv "${real_ext}" "$DOWNLOAD_PATH/${current_date}/${output}.$OUTPUT_FILE_EXTENSION"

# Compress the video based on the user's choice
if [ "$compress_option" == "y" ] || [ "$compress_option" == "Y" ]; then
  # Compress with ffmpeg using libx264 encoder and some options for reduced file size
  ffmpeg -i "$DOWNLOAD_PATH/${current_date}/${output}.$OUTPUT_FILE_EXTENSION" -i $WATERMARK_IMAGE_PATH -filter_complex "[0:v][1:v]overlay=(W-w)/2:(H-h)/2[v1];[v1]drawtext=text='$WATERMARK_TEXT':x=w-text_w-10:y=10:fontsize=24:fontcolor=white[vout]" -map "[vout]" -map 0:a -c:v libx264 -crf 30 -preset veryfast -c:a aac -b:a 128k "$DOWNLOAD_PATH/${current_date}/${output}-$DESKTOP_FILE_NAME.$OUTPUT_FILE_EXTENSION"
else
  # No compression, but watermarking will be added
  ffmpeg -i "$DOWNLOAD_PATH/${current_date}/${output}.$OUTPUT_FILE_EXTENSION" -i $WATERMARK_IMAGE_PATH -filter_complex "[0:v][1:v]overlay=(W-w)/2:(H-h)/2[v1];[v1]drawtext=text='$WATERMARK_TEXT':x=w-text_w-10:y=10:fontsize=24:fontcolor=white[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy "$DOWNLOAD_PATH/${current_date}/${output}-$DESKTOP_FILE_NAME.$OUTPUT_FILE_EXTENSION"
fi

# ----------------------------------------------------------
# SHORT VIDEO CREATION
# ----------------------------------------------------------

# Ask the user if they want to create a short video
read -p "Do you want to create a short video? [y/N]: " create_short

# Proceed if the user opts to create a short video
if [ "$create_short" == "y" ] || [ "$create_short" == "Y" ]; then
  # Use a while loop to ensure the user inputs a valid duration
  while true; do
    read -p "How many seconds should the short be? (maximum value of 59): " short_duration
    if [ "$short_duration" -le 59 ]; then
      break # Exit loop when a valid value is entered
    else
      echo "Invalid short duration. The maximum allowed value is 59. Please try again."
    fi
  done
  
  # Extract original video resolution using ffprobe
  video_info=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$DOWNLOAD_PATH/${current_date}/${output}-$DESKTOP_FILE_NAME.$OUTPUT_FILE_EXTENSION")
  original_width=$(echo $video_info | cut -d"x" -f1)
  original_height=$(echo $video_info | cut -d"x" -f2)
  
  # Initialize the scaling command
  scale_cmd=""
  
  # Check if scaling is needed based on the original video dimensions
  if [ "$original_width" -lt 720 ] || [ "$original_height" -lt 1280 ]; then
    scale_cmd="scale=-1:1280,"
  fi

  # Calculate coordinates for centered crop
  crop_x=$(( ($original_width - 720) / 2 ))
  crop_y=$(( ($original_height - 1280) / 2 ))
  
  # Create the short video based on user's choice to compress or not
  if [ "$compress_option" == "y" ] || [ "$compress_option" == "Y" ]; then
    ffmpeg -i "$DOWNLOAD_PATH/${current_date}/${output}.$OUTPUT_FILE_EXTENSION" -ss 00:00:00 -t 00:00:$short_duration -vf "${scale_cmd}crop=720:1280:$crop_x:$crop_y,drawtext=text='$WATERMARK_TEXT':x=w-text_w-10:y=10:fontsize=24:fontcolor=white" -c:v libx264 -crf 30 -preset veryfast "$DOWNLOAD_PATH/${current_date}/${output}-$SHORT_FILE_NAME.$OUTPUT_FILE_EXTENSION"
  else
    ffmpeg -i "$DOWNLOAD_PATH/${current_date}/${output}.$OUTPUT_FILE_EXTENSION" -ss 00:00:00 -t 00:00:$short_duration -vf "${scale_cmd}crop=720:1280:$crop_x:$crop_y,drawtext=text='$WATERMARK_TEXT':x=w-text_w-10:y=10:fontsize=24:fontcolor=white" -c:v libx264 -c:a copy "$DOWNLOAD_PATH/${current_date}/${output}-$SHORT_FILE_NAME.$OUTPUT_FILE_EXTENSION"
  fi
fi

# ----------------------------------------------------------
# YOUTUBE UPLOAD FUNCTIONALITY
# ----------------------------------------------------------

# Check if the YouTube upload system is enabled
if [ "$UPLOAD_TO_YOUTUBE" == "TRUE" ]; then

  # Ask whether to upload the desktop video to YouTube
  read -p "Do you want to upload the desktop video to YouTube? [y/N]: " upload_desktop
  
  if [ "$upload_desktop" == "y" ] || [ "$upload_desktop" == "Y" ]; then
    # Collect metadata for the desktop video upload
    read -p "Enter the title for the desktop video: " desktop_title
    read -p "Enter the description for the desktop video: " desktop_description
    read -p "Enter the tags for the desktop video (comma-separated): " desktop_tags

    # Invoke the function to upload the desktop video
    upload_video "$DOWNLOAD_PATH/${current_date}/${output}-$DESKTOP_FILE_NAME.$OUTPUT_FILE_EXTENSION" "$desktop_title" "$desktop_description" "$desktop_tags"
  fi

  # If a short video was created, offer to upload it too
  if [ "$create_short" == "y" ] || [ "$create_short" == "Y" ]; then
    
    # Ask whether to upload the short video to YouTube
    read -p "Do you want to upload the short video to YouTube? [y/N]: " upload_short
    
    if [ "$upload_short" == "y" ] || [ "$upload_short" == "Y" ]; then
      # Collect metadata for the short video upload
      read -p "Enter the title for the short video: " short_title
      read -p "Enter the description for the short video: " short_description
      read -p "Enter the tags for the short video (comma-separated): " short_tags

      # Invoke the function to upload the short video
      upload_video "$DOWNLOAD_PATH/${current_date}/${output}-$SHORT_FILE_NAME.$OUTPUT_FILE_EXTENSION" "$short_title" "$short_description" "$short_tags"
    fi
  fi

fi
