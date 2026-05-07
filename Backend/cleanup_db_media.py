import os
import django
from datetime import datetime, timedelta
from django.utils import timezone
from django.conf import settings

# Setup Django Environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Backend.settings')
django.setup()

from students.models import RoomMedia, ChildMedia

def cleanup_media_from_db(dry_run=True):
    """
    Deletes media files and records based on database entries.
    - RoomMedia: older than 1 month
    - ChildMedia (Daily Activity): older than 3 months
    """
    now = timezone.now()
    
    # Thresholds
    room_cutoff = now - timedelta(days=30)
    child_cutoff = now - timedelta(days=90)

    print(f"Cleanup started at: {now.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"RoomMedia cutoff (1 month): {room_cutoff.strftime('%Y-%m-%d')}")
    print(f"ChildMedia cutoff (3 months): {child_cutoff.strftime('%Y-%m-%d')}")
    print(f"Dry run mode: {'ON' if dry_run else 'OFF'}")
    print("-" * 50)

    # 1. Process RoomMedia
    print("Processing RoomMedia...")
    old_room_media = RoomMedia.objects.filter(uploaded_at__lt=room_cutoff.date())
    room_count = 0
    for media in old_room_media:
        file_path = media.media_file.path if media.media_file else None
        if dry_run:
            print(f"[WOULD DELETE] RoomMedia: {media.id} - {file_path}")
        else:
            if media.media_file:
                media.media_file.delete(save=False) # Deletes the file from storage
            media.delete() # Deletes the record from DB
            print(f"[DELETED] RoomMedia: {media.id} - {file_path}")
        room_count += 1

    # 2. Process ChildMedia (Daily Activities)
    print("\nProcessing ChildMedia (Daily Activities)...")
    old_child_media = ChildMedia.objects.filter(uploaded_at__lt=child_cutoff)
    child_count = 0
    for media in old_child_media:
        file_path = media.file.path if media.file else None
        if dry_run:
            print(f"[WOULD DELETE] ChildMedia: {media.id} - {file_path} (Type: {media.activity_type})")
        else:
            if media.file:
                media.file.delete(save=False)
            media.delete()
            print(f"[DELETED] ChildMedia: {media.id} - {file_path}")
        child_count += 1

    print("-" * 50)
    if dry_run:
        print(f"Dry run complete.")
        print(f"Found {room_count} RoomMedia records to delete.")
        print(f"Found {child_count} ChildMedia records to delete.")
        print("To actually delete, run the script with 'dry_run=False'.")
    else:
        print(f"Cleanup complete.")
        print(f"Deleted {room_count} RoomMedia records.")
        print(f"Deleted {child_count} ChildMedia records.")

if __name__ == "__main__":
    import sys
    # Support command line argument: python cleanup_db_media.py False
    is_dry_run = True
    if len(sys.argv) > 1:
        is_dry_run = sys.argv[1].lower() != 'false'
    
    cleanup_media_from_db(dry_run=is_dry_run)
