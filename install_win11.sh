#!/bin/bash

# Variables
ISO_NAME="Win11_24H2_French_x64.iso"
ISO_PATH="/var/lib/vz/template/iso/$ISO_NAME"
ISO_URL="https://lecrabeinfo.net/telecharger/windows-11-24h2-64-bits/"
VIRTIO_ISO_NAME="virtio-win.iso"
VIRTIO_ISO_PATH="/var/lib/vz/template/iso/$VIRTIO_ISO_NAME"
VIRTIO_ISO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"

# Téléchargement de l'ISO de Windows 11
if [ -f "$ISO_PATH" ]; then
    echo "L'ISO Windows 11 existe déjà, pas besoin de le télécharger."
else
    echo "Téléchargement de l'ISO Windows 11..."
    wget -O "$ISO_PATH" "$ISO_URL"
    if [ $? -eq 0 ]; then
        echo "Téléchargement réussi !"
    else
        echo "Erreur lors du téléchargement de l'ISO Windows 11." >&2
        exit 1
    fi
fi

# Téléchargement de l'ISO des pilotes VirtIO
if [ -f "$VIRTIO_ISO_PATH" ]; then
    echo "L'ISO des pilotes VirtIO existe déjà, pas besoin de le télécharger."
else
    echo "Téléchargement de l'ISO des pilotes VirtIO..."
    wget -O "$VIRTIO_ISO_PATH" "$VIRTIO_ISO_URL"
    if [ $? -eq 0 ]; then
        echo "Téléchargement réussi !"
    else
        echo "Erreur lors du téléchargement de l'ISO des pilotes VirtIO." >&2
        exit 1
    fi
fi

# Paramètres de la VM
VM_ID=110               # ID unique pour la VM
VM_NAME="Windows11"     # Nom de la VM
STORAGE="local-lvm"     # Stockage utilisé pour le disque
DISK_SIZE="80G"         # Taille du disque
RAM_SIZE="8192"         # RAM en Mo (8 Go)
CPU_CORES="1"           # Nombre de cœurs CPU
BRIDGE="vmbr0"          # Interface réseau de la VM

echo "Création de la VM Windows 11 avec l'ID $VM_ID..."

# Création de la VM
qm create $VM_ID --name $VM_NAME --memory $RAM_SIZE --cores $CPU_CORES --net0 virtio,bridge=$BRIDGE

# Ajout du disque
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE:$DISK_SIZE

# Ajout du lecteur CD avec l'ISO de Windows
qm set $VM_ID --ide2 local:iso/$ISO_NAME,media=cdrom

# Ajout du lecteur CD avec l'ISO des pilotes VirtIO
qm set $VM_ID --ide3 local:iso/$VIRTIO_ISO_NAME,media=cdrom

# Configuration du boot sur l'ISO de Windows
qm set $VM_ID --boot order=ide2

# Ajout d'une carte graphique standard
qm set $VM_ID --vga qxl

# Activation du TPM 2.0 pour la compatibilité avec Windows 11
qm set $VM_ID --tpmstate0 $STORAGE:1,version=v2.0

# Ajouter une note dans Proxmox pour la VM
qm set $VM_ID --description "# Windows 11\n### https://github.com/Chouteau49/windows11_proxmox"

# Démarrage de la VM
qm start $VM_ID

echo "VM Windows 11 créée et démarrée avec succès !"
echo "Connectez-vous à l'interface graphique de la VM pour installer Windows 11."