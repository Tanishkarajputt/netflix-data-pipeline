import kagglehub
import boto3
import os

# download dataset
path = kagglehub.dataset_download("shivamb/netflix-shows")

print(path)


