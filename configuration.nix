# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
    # Include the results of the hardware scan.
    imports = [ ./hardware-configuration.nix ];

    # List packages installed in system profile.
    environment.systemPackages = with pkgs; [
        vim git wget i3status dmenu elinks tmux htop atop diffuse ];

    # Use the GRUB 2 boot loader.
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;

    # Define on which hard drive you want to install Grub.
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.extraEntries =
        ''
        menuentry "Other Distos" {
            configfile /grub/grub.voidlinux.cfg
        } ''; 

    boot.initrd.luks.devices = [ {
        device = "/dev/sda4";
        name = "gentoo_root";
        preLVM = true; } ];

    # Set up the swap device
#   swapDevices = [ { device = "/dev/vg_rfnashlaptop/lv_swap"; } ];
    boot.kernelParams = ["resume=/dev/vg_rfnashlaptop/lv_swap"];

#   boot.initrd.supportedFilesystems = [ "zfs" ];
    boot.kernelModules = [ "netatop"
        "vboxdrv"
        "vboxnetadp"
        "vboxnetflt"
        "vboxpci" ];

    boot.extraModulePackages = [
        pkgs.linuxPackages.netatop
        pkgs.linuxPackages.virtualbox ];

    # Set up networking
    networking.hostName = "athena.robertnash.net"; 
    networking.wireless.enable = true;

    fileSystems = [
    { mountPoint = "/boot";
        label = "boot";
        fsType = "ext2"; }
    { mountPoint = "/tmp";
        device = "tmpfs";
        fsType = "tmpfs";
        options = "size=2G"; }
    { mountPoint = "/var/lib/docker";
        label = "docker";
        fsType = "btrfs";
        options = "compress=lzo"; }
    ];

    # Select internationalisation properties.
    i18n = {
        consoleFont = "lat9w-16";
        consoleKeyMap = "dvorak";
        defaultLocale = "en_US.UTF-8";
    };

    # Set up system shells
    programs.bash.enableCompletion = true;
    programs.zsh.enable = true;

    services = {
        openssh.enable = true;
        printing.enable = true;
        unbound.enable = true;
        ntp.enable = true;
        gpm.enable = true;
        haveged.enable = true;
        oidentd.enable = true;
        xserver = {
            enable = true;
            enableTCP = true;
            layout = "dvorak";
            xkbOptions = "lv3:ralt_switch,ctrl:swapcaps,compose:ralt,terminate:ctrl_alt_bksp";
            windowManager.i3.enable = true;
            desktopManager.xterm.enable = true;
            synaptics.enable = true;
            synaptics.twoFingerScroll = true; };
#       httpd = {
#           enable = true;
#           enableUserDir = true;
#           adminAddr = "rfnash@localhost";
#           extraModules =  [
#           { name = "php5";
#               path = "${pkgs.php}/modules/libphp5.so"; } ]; };
        opensmtpd = {
            enable = true;
            serverConfiguration =
                ''
                listen on localhost
                table aliases { root = rfnash }
            accept for local alias <aliases> deliver to maildir "%{user.directory}/Maildir/Inbox"
                accept for any relay
                ''; };
        smartd.enable = true;
        smartd.devices = [ { device = "/dev/sda"; } ];
        gogoclient = {
            # enable = true;
            server = "montreal.freenet6.net";
            username = "rfnash";
            password = "/etc/nixos/gogoc.passwd"; };

        # TODO: automatically generate SSL certs
        dovecot2 = {
            enable = true;
            enablePop3 = false;
            mailLocation = "maildir:~/Maildir:LAYOUT=fs:INBOX=~/Maildir/Inbox";
            extraConfig = "mail_debug = yes";
            sslServerCert = "/etc/ssl/dovecotcert.pem";
            sslServerKey = "/etc/ssl/private/dovecot.pem";
            sslCACert = "/etc/ssl/private/dovecot.pem"; };

        tor = {
            client.enable = true;
            client.privoxy.enable = true;
            client.privoxy.listenAddress = "127.0.0.1:8118";
            client.socksListenAddress = "127.0.0.1:9150";
            relay.enable = true; };
        privoxy.enable = true;
        privoxy.listenAddress = "127.0.0.1:8123"; };

    security.sudo.wheelNeedsPassword = false;
    users.defaultUserShell = "/run/current-system/sw/bin/zsh";
    security.setuidPrograms = [ "sendmail" ];
    time.timeZone = "America/Detroit";
    hardware.pulseaudio.enable = true;
    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = true;

#   TODO: automatically fix shebang and permissions on temp_throttle.sh
#   systemd.services.temp-throttle = {
#       wantedBy = [ "multi-user.target" ];
#       description = "throttles CPU when temp exceeds limit";
#       path = [ pkgs.bash pkgs.cpufrequtils ];
#       serviceConfig.ExecStart = "/etc/nixos/temp-throttle/temp_throttle.sh 80";
#   };

    users.extraGroups.rfnash.gid = 1000;
    users.extraUsers.rfnash = {
        createHome = true;
        home = "/home/rfnash";
        description = "Robert F. Nash";
        extraGroups = [
            "wheel"
            "audio"
            "lp"
            "cdrom"
            "video"
            "systemd-journal"
            "users"
            "grsecurity"
            "libvirtd"
            "tty"
            ];
        shell = "/run/current-system/sw/bin/zsh";
        uid = 1000;
        group = "rfnash"; };

    fonts = {
        enableFontDir = true;
        enableGhostscriptFonts = true;
        fonts = with pkgs; [
            dejavu_fonts
            liberation_ttf
            terminus_font
            ttf_bitstream_vera
#           symbola
            ];
    };
}
