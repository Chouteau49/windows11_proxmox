#!/bin/bash

ISO_NAME="win11.iso"
ISO_PATH="/var/lib/vz/template/iso/$ISO_NAME"
ISO_URL="https://software-download.microsoft.com/pr/Win11_French_x64.iso"

# Vérifier si l'ISO est déjà présent
if [ -f "$ISO_PATH" ]; then
    echo "L'ISO Windows 11 existe déjà, pas besoin de le télécharger."
else
    echo "Téléchargement de l'ISO Windows 11..."
    wget -O "$ISO_PATH" "$ISO_URL"
    
    if [ $? -eq 0 ]; then
        echo "Téléchargement réussi !"
    else
        echo "Erreur lors du téléchargement de l'ISO." >&2
        exit 1
    fi
fi

# Paramètres
VM_ID=110               # ID unique pour la VM
VM_NAME="Windows11"     # Nom de la VM
ISO_PATH="local:iso/win11.iso"
STORAGE="local-lvm"     # Stockage utilisé pour le disque
DISK_SIZE="80G"         # Taille du disque
RAM_SIZE="8192"         # RAM en Mo (8 Go)
CPU_CORES="4"           # Nombre de cœurs CPU
BRIDGE="vmbr0"          # Interface réseau de la VM

echo "Création de la VM Windows 11 avec l'ID $VM_ID..."

# Création de la VM
qm create $VM_ID --name $VM_NAME --memory $RAM_SIZE --cores $CPU_CORES --net0 virtio,bridge=$BRIDGE

# Ajout du disque
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE:$DISK_SIZE

# Ajout du lecteur CD avec l'ISO de Windows
qm set $VM_ID --ide2 $ISO_PATH --boot order=ide2

# Ajout d'une carte graphique standard
qm set $VM_ID --vga qxl

# Activation du TPM 2.0 pour éviter l'erreur d'installation de Windows 11
qm set $VM_ID --tpmstate0 $STORAGE:1,version=v2.0

# Ajout de pilotes VirtIO (si nécessaire, après installation de Windows)
qm set $VM_ID --virtio0 $STORAGE:32

# Finalisation et démarrage de la VM
qm start $VM_ID

echo "VM Windows 11 créée et démarrée avec succès !"
