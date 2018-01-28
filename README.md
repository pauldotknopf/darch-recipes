# Darch recipes

My personal [Darch](https://github.com/pauldotknopf/darch) recipes.

## Want to use them?

You can boot my images. Each one has a guest account baked in that has no password. **WARNING**: Booting these essentially gives me full power over your entire computer. You can trust me though :)

Here are the instructions.

### 1. Install Darch

Instructions [here](https://github.com/pauldotknopf/darch/blob/develop/README.md#installation)

### 2. Stage image

```bash
# You can checkout my image I use for development.
export IMAGE="development"
# Also, you can try "i3" or "plasma".
sudo darch images pull docker.io/pauldotknopf/darch-arch-personal-$IMAGE:latest
sudo darch stage docker.io/pauldotknopf/darch-arch-personal-$IMAGE:latest
sudo darch stage sync-bootloader
```

### 3. Reboot and select grub menu entry