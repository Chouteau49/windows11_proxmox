#!/bin/bash

# Variables
ISO_NAME="Win11_24H2_French_x64.iso"
ISO_PATH="/var/lib/vz/template/iso/$ISO_NAME"
ISO_URL="https://software.download.prss.microsoft.com/dbazure/Win11_24H2_French_x64.iso?t=20777ac4-fce6-4e0f-8f9a-639ec6ddc60f&P1=1742139497&P2=601&P3=2&P4=HYAJmgDON99Sh8h2KX4dmSC5MQJgUyDybN4t1A6exVnLcyJ6F0wLijn%2b8TJMD7BMUr111Huf7Y6poAhSooNuZHYQsgv5QM%2fMtnDCp7JadU2EZYPaWAW6Rw7DGiPpz7nM4y%2blM5FWfphNkza9iohhuQV0HSB9LfAQ5LdHRVUpIjp9%2fnc%2bsVHXOVfLgHHSrMbkasX6X2%2fij8FWSoGLl8FTSHV7Qh8gpgvCcJzMH2YhK68qSPzkFfEHBkx7DxNgUcVPVEsTRn7qiEp2R5VdDSeTVcl02WIeWma8szjwATEUBpn%2bWVzrtSDw6stlYmXVVDTIyjfVeO%2bjH3QlhV7fH8nPdA%3d%3d"
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
VM_ID=101              # ID unique pour la VM
VM_NAME="Windows11"     # Nom de la VM
STORAGE="local-lvm"     # Stockage utilisé pour le disque
DISK_SIZE="50G"         # Taille du disque
RAM_SIZE="16384"         # RAM en Mo (16 Go)
CPU_CORES="16"           # Nombre de cœurs CPU
CPU_SOCKETS="1"        # Nombre de sockets CPU
BRIDGE="vmbr0"          # Interface réseau de la VM
VMNET="e1000,bridge=vmbr0,firewall=0,tag=401" # Your network definition for VM

echo "version : 8"

echo "Création de la VM Windows 11 avec l'ID $VM_ID..."
echo "VM_ID: $VM_ID"
echo "STORAGE: $STORAGE"
echo "DISK_SIZE: $DISK_SIZE"

# Création de la VM
qm create $VM_ID --name "$VM_NAME" --memory $RAM_SIZE --cores $CPU_CORES --sockets $CPU_SOCKETS
if [ $? -ne 0 ]; then
    echo "Erreur lors de la création de la VM." >&2
    exit 1
fi

qm set $VM_ID --bios ovmf
qm set $VM_ID --cpu host
qm set $VM_ID --machine pc-q35-8.1
# Ajout du contrôleur SCSI en VirtIO SCSI single
qm set $VM_ID --scsihw virtio-scsi-single
# qm set $VM_ID --agent 1,fstrim_cloned_disks=1
# sed -i 's/scsi0:/sata0:/' /etc/pve/qemu-server/$VM_ID.conf
# sed -i 's/sata0:.*/&,discard=on/' /etc/pve/qemu-server/$VM_ID.conf
qm set $VM_ID --ide2 local:iso/$ISO_NAME,media=cdrom
qm set $VM_ID --ide3 local:iso/$VIRTIO_ISO_NAME,media=cdrom
qm set $VM_ID --boot order='sata0;ide2'
qm set $VM_ID --ostype win11
qm set $VM_ID --net0 $VMNET
qm set $VM_ID --efidisk0 $STORAGE:1,efitype=4m,pre-enrolled-keys=1,size=4M
qm set $VM_ID --tpmstate0 $STORAGE:1,size=4M,version=v2.0
qm set $VM_ID --vga virtio
qm start $VM_ID
# Ajouter une note dans Proxmox pour la VM
qm set $VM_ID --description "Windows 11 - https://github.com/Chouteau49/windows11_proxmox"
# Démarrage de la VM à l'amorçage
qm set $VM_ID --onboot 1
# Démarrage de la VM
qm start $VM_ID

echo "VM Windows 11 créée et démarrée avec succès !"
echo "Connectez-vous à l'interface graphique de la VM pour installer Windows 11."

# Instruction pour ajouter un disque SATA après l'exécution du script
echo "Après l'exécution de ce script, ajoutez un disque SATA à la VM avec la commande suivante :"
echo "qm set $VM_ID --sata0 $STORAGE:$VM_ID-disk-1,size=$DISK_SIZE"