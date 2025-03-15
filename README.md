# windows11_proxmox

```bash
bash -c "$(wget -qLO- --header="Cache-Control: no-cache" https://raw.githubusercontent.com/Chouteau49/windows11_proxmox/main/install_win11.sh)"
```

Après l'exécution de ce script, allez dans l'interface Proxmox, sélectionnez la VM, puis allez dans l'onglet "Matériel" et ajoutez un disque SATA.

Cliquer dans la console pour boot sur la ide2

Pour créer un compte loacl

OOBE\BYPASSNRO

et supprimer le reseau dans matériel de proxmox

