# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ];


  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
      extraEntries =
        ''
        menuentry "Other Distos" {
          configfile /grub/grub.archlinux.cfg
        }
      '';
    };
    initrd = {
      luks.devices = [ {
        device = "/dev/sda4";
        name = "gentoo_root";
        preLVM = true;
      } ];
      supportedFilesystems = [ "zfs" ];
    };
    kernelModules = [ "netatop" ];
    extraModulePackages = [ pkgs.linuxPackages.netatop ];
  };

  networking = {
    hostName = "athena.robertnash.net";
    wireless.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 113 9001 9030 ];
      allowedUDPPorts = [ 80 443 113 9001 9030 ];
    };
  };

  fileSystems = [
  {
    mountPoint = "/boot";
    label = "boot";
    fsType = "ext2";
  }
  {
    mountPoint = "/home";
    label = "exherbo";
    fsType = "btrfs";
    options = "compress=lzo";
  }
  {
    mountPoint = "/tmp";
    device = "tmpfs";
    fsType = "tmpfs";
    options = "size=2G";
  }
  {
    mountPoint = "/mnt/arch";
    label = "arch-btrfs";
    fsType = "btrfs";
    options = "compress=lzo";
  }
  {
    mountPoint = "/mnt/debian";
    label = "sid";
    fsType = "ext4";
  }
  {
    mountPoint = "/var/lib/docker";
    label = "docker";
    fsType = "btrfs";
    options = "compress=lzo";
  }
  {
    mountPoint = "/mnt/alpine";
    label="alpine";
    fsType="ext4";
  }
  {
    mountPoint = "/mnt/backup";
    label="backup";
    fsType="btrfs";
    options = "compress=lzo";
  }
  {
    mountPoint = "/mnt/shared-ext2";
    label="shared-ext2";
    fsType="ext2";
  }
  ];

  swapDevices = [ { device = "/dev/vg_rfnashlaptop/lv_swap"; } ];

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

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
      layout = "dvorak";
      xkbOptions = "lv3:ralt_switch,ctrl:swapcaps,compose:ralt,terminate:ctrl_alt_bksp";
      desktopManager.xterm.enable = false;
      modules = [ "xf86-input-synaptics" ];
      synaptics = {
        enable = true;
        maxSpeed = "0.8";
        twoFingerScroll = true;
      };
    };
    httpd = {
      enable = true;
      enableUserDir = true;
      adminAddr = "rfnash@localhost";
      extraModules =  [ { name = "php5"; path = "/nix/store/j0ihspf2zhkdspsd9n7ma8zn19macpkm-php-5.3.18/modules/libphp5.so"; } ];
    };
    opensmtpd = {
      enable = true;
      serverConfiguration =
        ''
        listen on localhost
        table aliases { root = rfnash }
      accept for local alias <aliases> deliver to maildir "%{user.directory}/Maildir/Inbox"
        accept for any relay
        '';
    };
    smartd = {
      enable = true;
      devices = [ { device = "/dev/sda"; } ];
    };
    gogoclient = {
      enable = true;
      server = "montreal.freenet6.net";
      username = "rfnash";
      password = "/etc/nixos/gogoc.passwd";
    };
    dovecot2 = {
      enable = true;
      enablePop3 = false;
      mailLocation = "maildir:~/Maildir:LAYOUT=fs:INBOX=~/Maildir/Inbox";
    tor = {
      client = {
        enable = true;
        privoxy.enable = true;
        privoxy.listenAddress = "127.0.0.1:8118";
        socksListenAddress = "127.0.0.1:9150";
      };
      relay = {
        enable = true;
      };
    };
    privoxy = {
      enable = true;
      listenAddress = "127.0.0.1:8123";
    };
    redshift = {
      enable = true;
      latitude = "41.820202";
      longitude = "-86.236801";
    };
  };

  security.sudo.wheelNeedsPassword = false;
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";
  time.timeZone = "America/Detroit";
  hardware.pulseaudio.enable = true;

  environment = {
    enableBashCompletion = true;
    systemPackages = with pkgs; [
      aria2
      atop
      calibre
      dropbox
      emacs
      fdm
      file
      gdb
      git
      gnupg
      htop
      incrtcl
      inetutils
      ledger
      mu
      ncdu
      php
      tcl
      texLiveFull
      tk
      unzip
      vim_configurable
      weechat
      xclip
      xsel
      zsh
      ];

    x11Packages = with pkgs; [
      rxvt_unicode
      ];
  };

  nixpkgs.config = {
    rxvt_unicode = {
      perlSupport = true;
    };

    vim = {
      python = true;
    };
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    extraFonts = [
      pkgs.anonymousPro
      pkgs.corefonts
      pkgs.dejavu_fonts
      pkgs.gentium
      pkgs.liberation_ttf
      pkgs.libertine
      pkgs.lmodern
      pkgs.terminus_font
      pkgs.ttf_bitstream_vera
      ];
  };
}
