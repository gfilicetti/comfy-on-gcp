# --- A. FORMAT ---
# Format the disk (Do this from inside the VM, AND ONLY DO THIS ONCE EVER)
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-comfy-models-disk
