#!/bin/bash

# --- Configuration ---
USER_NAME="root"
USER_HOME="/root"
# --- End Configuration ---

# --- Constants ---
VENV_PYTHON="$USER_HOME/ComfyUI/venv/bin/python"
# --- End Constants ---

# 1. Mount the Persistent Disk (Required Step)
# This mounts the disk created in the earlier step: 'comfy-models-disk'
if ! grep -qs '/mnt/disks/models' /proc/mounts; then
	echo "Creating mount point if it doesn't exist"
	mkdir -p /mnt/disks/models

    echo "Mounting persistent disk..."
    sudo mount -o discard,defaults /dev/disk/by-id/google-comfy-models-disk /mnt/disks/models
    # Ensure the user has permission to write to the mount point
    sudo chown -R $USER_NAME:$USER_NAME /mnt/disks/models
else
    echo "Persistent disk already mounted."
fi

# 2. Conditional Installation of ComfyUI
if [ ! -d "$USER_HOME/ComfyUI" ]; then
    echo "ComfyUI not found. Starting installation..."
    echo "Installing as user: $USER_NAME"
    echo "Installing to homedir: $USER_HOME"

    # Use sh -c to execute a sequence of commands as the user, 
    # ensuring the commands start in the correct home directory.
    sudo -u $USER_NAME /bin/bash -c "
        # a. Clone ComfyUI
        echo \"Clone ComfyUI\"
        /usr/bin/git clone https://github.com/comfyanonymous/ComfyUI.git \"$USER_HOME/ComfyUI\"

        # b. Create and install dependencies inside the venv
        echo \"Create venv\"
        /usr/bin/python3 -m venv \"$USER_HOME/ComfyUI/venv\"
        echo \"Using python binary in our venv: $VENV_PYTHON\"
        
        # Install requirements
        echo \"Install requirements\"
        $VENV_PYTHON -m pip install -r \"$USER_HOME/ComfyUI/requirements.txt\"

        # c. Install ComfyUI Manager
        echo \"Install ComfyUI Manager\"
        /usr/bin/git clone https://github.com/ltdrdata/ComfyUI-Manager.git \"$USER_HOME/ComfyUI/custom_nodes/ComfyUI-Manager\"

        # d. Link models folder to the persistent disk
        echo \"Link models to persistent disk\"
        rm -rf \"$USER_HOME/ComfyUI/models\"
        ln -s /mnt/disks/models \"$USER_HOME/ComfyUI/models\"
    "
fi

# 3. Start ComfyUI as the non-root user (using venv Python)
echo "Starting ComfyUI..."
# CRITICAL FIX: Use the full path to the venv python executable
# We use nohup and backgrounding to keep the process running.
sudo -u $USER_NAME nohup $VENV_PYTHON "$USER_HOME/ComfyUI/main.py" --listen \
  > /var/log/comfyui.log 2>&1 &

echo "ComfyUI startup script finished. Check /var/log/comfyui.log for status."

