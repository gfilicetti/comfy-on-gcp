## 1. Create the persistent disk for models
gcloud compute disks create comfy-models-disk \
    --size=200GB \
    --type=pd-balanced \
    --zone=us-east4-a
