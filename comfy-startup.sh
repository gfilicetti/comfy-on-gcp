#!/bin/bash

# --- Configuration ---
USER_NAME="admin_ginof_altostrat_com"
USER_HOME="/home/$USER_NAME"
# --- End Configuration ---

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

    # Use sh -c to execute a sequence of commands as the user, 
    # ensuring the commands start in the correct home directory.
    sudo -u $USER_NAME /bin/bash -c "
        # a. Clone ComfyUI
        git clone https://github.com/comfyanonymous/ComfyUI.git \"$USER_HOME/ComfyUI\"

        # b. Create and install dependencies inside the venv
        python3 -m venv \"$USER_HOME/ComfyUI/venv\"
        VENV_PYTHON=\"$USER_HOME/ComfyUI/venv/bin/python\"
        
        # Install requirements
        \"$VENV_PYTHON\" -m pip install -r \"$USER_HOME/ComfyUI/requirements.txt\"

        # c. Install ComfyUI Manager
        git clone https://github.com/ltdrdata/ComfyUI-Manager.git \"$USER_HOME/ComfyUI/custom_nodes/ComfyUI-Manager\"

        # d. Link models folder to the persistent disk
        rm -rf \"$USER_HOME/ComfyUI/models\"
        ln -s /mnt/disks/models \"$USER_HOME/ComfyUI/models\"
    "

    # a. Clone ComfyUI as the user
    sudo -u $USER_NAME git clone https://github.com/comfyanonymous/ComfyUI.git "$USER_HOME/ComfyUI"

    # b. Create and activate venv (CRITICAL FIX)
    sudo -u $USER_NAME python3 -m venv "$USER_HOME/ComfyUI/venv"

    # c. Install dependencies inside the venv
    # We use the full path to the venv python to avoid activation issues in startup script
    sudo -u $USER_NAME "$USER_HOME/ComfyUI/venv/bin/pip" install -r "$USER_HOME/ComfyUI/requirements.txt"

    # d. Install ComfyUI Manager
    sudo -u $USER_NAME git clone https://github.com/ltdrdata/ComfyUI-Manager.git "$USER_HOME/ComfyUI/custom_nodes/ComfyUI-Manager"

    # e. Re-establish the models folder symlink (from previous steps)
    # This assumes the base setup script in the past created the symlink structure.
    # We assume the models folder is empty/removed after the initial setup.
    sudo -u $USER_NAME rm -rf "$USER_HOME/ComfyUI/models"
    sudo -u $USER_NAME ln -s /mnt/disks/models "$USER_HOME/ComfyUI/models"
    
    echo "ComfyUI installation complete."
fi

# 3. Start ComfyUI as the non-root user (using venv Python)
echo "Starting ComfyUI..."
# CRITICAL FIX: Use the full path to the venv python executable
# We use nohup and backgrounding to keep the process running.
sudo -u $USER_NAME nohup "$USER_HOME/ComfyUI/venv/bin/python" "$USER_HOME/ComfyUI/main.py" --listen \
  > /var/log/comfyui.log 2>&1 &

echo "ComfyUI startup script finished. Check /var/log/comfyui.log for status."

