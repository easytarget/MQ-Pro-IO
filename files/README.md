# Setup files for MQ Pro on ubuntu
### [`55_net.cfg`](./55_net.cfg)
  - Place in `/etc/cloud/cloud.cfg.d/` on the SD card *and edit with your network details* before first boot to preconfigure a wifi network.
  - After the first boot this file will appear (renamed and with some comments at the top) in `/etc/netplan/`, named (by defaut) `50-cloud-init.yaml`
    - You can edit the file there to modify or correct the config.
    - Use `netplan try` to test your modifications. Read the Docs.
### [`rtl_bt/*`](./rtl_bt/)
  - Bluetooth firmware files, place in `/usr/lib/firmware/rtl_bt/`.
  - Also install `bluez` to use via `bluetoothctl`
  - Requires a reboot
### [`mqpro-status-led.service`](./mqpro-status-led.service)
  - Place in `/etc/systemd/system/`
  - Run `sudo systemctl daemon-reload`
  - Then `sudo systemctl enable --now mqpro-status-led.service`
