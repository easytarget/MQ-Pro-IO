# Setup files for MQ Pro on ubuntu
1. `55_net.cfg`
  - Place in `/etc/cloud/cloud.cfg.d/` on the SD card and edit before first boot to preconfigure a wifi network.
  - see comments in file
2. `rtl_bt/*`
  - Bluetooth firmware files, place in `/usr/lib/firmware/rtl_bt/`.
  - Also install `bluez` to use via `bluetoothctl`
  - Requires a reboot
3. `mqpro-status-led.service`
  - Place in `/etc/systemd/system/`
  - Run `sudo systemctl daemon-reload`
  - Then `sudo systemctl enable --now mqpro-status-led.service`
