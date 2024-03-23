from celery import shared_task
from .models import LearningResource
import boto3  # Assuming you are using boto3 for Amazon S3 operations

@shared_task
def save_images_and_videos_to_s3(learning_resource_id, image_file, video_file):
    try:
        learning_resource = LearningResource.objects.get(id=learning_resource_id)
        
        # Upload image to Amazon S3
        s3_client = boto3.client('s3')
        image_key = 'images/{}_{}'.format(learning_resource.id, image_file.name)
        s3_client.upload_fileobj(image_file, 'your-s3-bucket-name', image_key)

        # Upload video to Amazon S3
        video_key = 'videos/{}_{}'.format(learning_resource.id, video_file.name)
        s3_client.upload_fileobj(video_file, 'your-s3-bucket-name', video_key)

        print("Images and videos saved to Amazon S3 for LearningResource:", learning_resource)
    except LearningResource.DoesNotExist:
        print("LearningResource with id {} does not exist".format(learning_resource_id))