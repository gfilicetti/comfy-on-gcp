# Comfy UI on Google Cloud
Setup instructions and scripts for getting ComfyUI working on Google Cloud

## Provisioning

### FIRST TIME ONLY - Provision the external drive for models
We use an external drive that only has to be created once and then loaded with models.

If this is your first time, provision the disk with this command:

```bash
./comfy-provision-disk.sh
```

### Provision the VM
Use this command to provision the VM for Comfy UI. 

It uses a g2-standard-24 machine with 2 x L4 GPUs on it.

**NOTE:** A start up script will be installed into this VM. See `comfy-startup.sh` for details

```bash
./comfy-provision-vm.sh
```

## Connections

### Logging into the VM
SSH into the VM with this command:

```bash
gcloud compute ssh comfy-gpu-box --zone=us-east4-a
```

### FIRST TIME ONLY - Format the external drive for models
We use an external drive that only has to be created once and then loaded with models.

If this is your first time, you'll need to format this drive.

After ssh'ing to the box, as above, run this command to format the drive:

```bash
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-comfy-models-disk
```

### Setting up a tunnel for the GUI
This command will set up a tunnel over SSH and will block:

```bash
gcloud compute ssh comfy-gpu-box --zone=us-east4-a -- -L 8188:localhost:8188 -N
```

Now point your browser to: <http://localhost:8188>
