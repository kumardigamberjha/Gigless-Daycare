import os
import time
from datetime import datetime, timedelta

# Configuration
MEDIA_DIR = '/media/digamber-jha/G/child/backend/Backend/media'
# Threshold: 2 months (approx 60 days)
DAYS_THRESHOLD = 60
# Media extensions to look for
MEDIA_EXTENSIONS = ('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.mp4', '.avi', '.mov', '.mkv', '.webm')

def cleanup_media(dry_run=True):
    """
    Deletes media files older than the specified threshold.
    :param dry_run: If True, only lists files to be deleted without actually deleting them.
    """
    now = time.time()
    threshold_time = now - (DAYS_THRESHOLD * 24 * 60 * 60)
    
    threshold_date = datetime.fromtimestamp(threshold_time)
    print(f"Cleanup started. Looking for files older than: {threshold_date.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Searching in: {MEDIA_DIR}")
    print(f"Dry run mode: {'ON' if dry_run else 'OFF'}")
    print("-" * 50)

    count = 0
    total_size = 0

    if not os.path.exists(MEDIA_DIR):
        print(f"Error: Media directory '{MEDIA_DIR}' does not exist.")
        return

    for root, dirs, files in os.walk(MEDIA_DIR):
        for file in files:
            if file.lower().endswith(MEDIA_EXTENSIONS):
                file_path = os.path.join(root, file)
                try:
                    # Get file stats
                    file_stat = os.stat(file_path)
                    # We use mtime (last modification time) as it's most reliable for "age"
                    file_mtime = file_stat.st_mtime
                    
                    if file_mtime < threshold_time:
                        file_size = file_stat.st_size
                        mtime_date = datetime.fromtimestamp(file_mtime).strftime('%Y-%m-%d')
                        
                        if dry_run:
                            print(f"[WOULD DELETE] {file_path} (Last modified: {mtime_date}, Size: {file_size / 1024:.2f} KB)")
                        else:
                            os.remove(file_path)
                            print(f"[DELETED] {file_path} (Last modified: {mtime_date})")
                        
                        count += 1
                        total_size += file_size
                except Exception as e:
                    print(f"Error processing {file_path}: {e}")

    print("-" * 50)
    if dry_run:
        print(f"Dry run complete. Found {count} files to delete, totaling {total_size / (1024 * 1024):.2f} MB.")
        print("To actually delete files, set 'dry_run=False' in the script.")
    else:
        print(f"Cleanup complete. Deleted {count} files, freed {total_size / (1024 * 1024):.2f} MB.")

if __name__ == "__main__":
    # Change to False to actually delete files
    cleanup_media(dry_run=True)
