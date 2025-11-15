# comfy-on-gcp
Setup instructions and scripts for getting ComfyUI working on Google Cloud

## Connections

### Logging into the VM
SSH into the VM with this command:

```bash
gcloud compute ssh comfy-gpu-box --zone=northamerica-northeast2-b
```

### Setting up a tunnel for the GUI
This command will set up a tunnel over SSH and will block:

```bash
gcloud compute ssh comfy-gpu-box --zone=northamerica-northeast2-b -- -L 8188:localhost:8188 -N
```

Now point your browser to: <http://localhost:8188>
