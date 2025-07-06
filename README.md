# initrd settings

Avoid host key warnings:

```bash
sudo mkdir -p /etc/secrets/initrd
sudo ssh-keygen -t rsa -b 4096 -f /etc/secrets/initrd/ssh_host_rsa_key -N ""
```

Find actual network driver:

```bash
lspci -v | grep -i ethernet -A 5
```

# Set luks UUID

Look for the FSTYPE cryto_luks
```bash
lsblk -f
```