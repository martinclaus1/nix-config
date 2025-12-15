# nix-config

## basic installation

Create a root password using the TTY

```bash
sudo su
passwd
```

From your host, copy the public SSH key to the server

```bash
ssh-add ~/.ssh/<ssh_key>
ssh-copy-id -i ~/.ssh/<ssh_key> root@<nix_host>
```

SSH into the host with agent forwarding enabled (for the secrets repo access)

```bash
ssh -A root@<nix_host>
```

Enable flakes

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Partition and mount the drives using [disko](https://github.com/nix-community/disko)

```bash
curl https://raw.githubusercontent.com/martinclaus1/nix-config/refs/heads/main/hosts/ipanema/disko.nix \
    -o /tmp/disko.nix
nix --experimental-features "nix-command flakes" run github:nix-community/disko \
    -- -m destroy,format,mount /tmp/disko.nix
```

Install git

```bash
nix-env -f '<nixpkgs>' -iA git
```

Clone this repository

```bash
mkdir -p /mnt/etc/nixos
git clone https://github.com/martinclaus1/nix-config.git /mnt/etc/nixos
```

Avoid host key warnings:

```bash
sudo mkdir -p /mnt/etc/secrets/initrd
sudo ssh-keygen -t rsa -b 4096 -f /mnt/etc/secrets/initrd/ssh_host_rsa_key -N ""
```

Install the system

```bash
nixos-install \
--root "/mnt" \
--no-root-passwd \
--flake "git+file:///mnt/etc/nixos#hostname"
```

Unmount the filesystems

```bash
umount "/mnt/boot/efis/*"
umount -Rl "/mnt"
zpool export -a
```

Reboot

```bash
reboot
```

## Raspberry Pi installation

For Raspberry Pi (margarita), the installation uses the NixOS SD image which comes with NixOS pre-installed.

**Prerequisites:**

- Flash the [NixOS ARM SD image](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux) to an SD card
- Boot the Raspberry Pi from the SD card
- Connect via network (DHCP will assign an IP automatically)

**Initial setup from the Pi console:**

Create a root password

```bash
sudo su
passwd
```

**From your host machine:**

Copy the public SSH key to the Pi

```bash
ssh-add ~/.ssh/<ssh_key>
ssh-copy-id -i ~/.ssh/<ssh_key> root@<pi_ip>
```

**SSH into the Pi with agent forwarding** (for the secrets repo access)

```bash
ssh -A root@<pi_ip>
```

**On the Pi, clone the configuration:**

```bash
git clone https://github.com/martinclaus1/nix-config.git /etc/nixos
cd /etc/nixos
```

**Apply the configuration:**

```bash
nixos-rebuild switch --flake /etc/nixos#margarita
```

The system will rebuild and activate the new configuration. After this completes, your Raspberry Pi is configured and ready to use.

## Snippets

### Find actual network driver:

```bash
lspci -v | grep -i ethernet -A 5
```

### Debug acme challenge:

```bash
journalctl -u 'acme-*'
```

### Check network related boot logs:

```bash
sudo journalctl -b | grep -E "(network|ssh|initrd)"
```

Access console at boot with Crtl + Alt + F2

### Check network status

```bash
ip addr show
```

### Print multiple files

```bash
tail -n +1 /path/to/files/*.txt
```

### Keep the last 5 generations of the system

```bash
sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system
```

### Check podman logs

```bash
journalctl -fu podman-adguardhome-sync.service --since yesterday
```

### Free up disk space

```bash
sudo nix-collect-garbage -d
```

## startup

```bash
systemctl start cryptsetup.target
```
