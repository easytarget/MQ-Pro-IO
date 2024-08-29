# Setup files for MQ Pro on ubuntu
1 `55_net.cfg`
  Place in `/etc/cloud/cloud.cfg.d/` on the SD card and edit before first boot to preconfigure a wifi network.
  see comments in file
1 `rtl_bt/*`
  Bluetooth firmware files, place in `/usr/lib/firmware/rtl_bt/`.
  Also install `bluez` to use via `bluetoothctl`
  Requires a reboot
1 `mqpro-status-led.service`
  Place in `/etc/systemd/system/`, run `sudo systemctl daemon-reload` then `sudo systemctl enable --now mqpro-status-led.service`
