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

## Snippets

Find actual network driver:

```bash
lspci -v | grep -i ethernet -A 5
```

Debug acme challenge:

```bash
journalctl -u 'acme-*'
```

Check network related boot logs:

```bash
sudo journalctl -b | grep -E "(network|ssh|initrd)"
```

Access console at boot with Crtl + Alt + F2

Check network status

```bash
ip addr show
```

Print multiple files

```bash
tail -n +1 /path/to/files/*.txt
```

Keep the last 5 generations of the system

```bash
sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system
```

Check podman logs

```bash
journalctl -fu podman-adguardhome-sync.service --since yesterday
```

## startup

systemctl start cryptsetup.target
