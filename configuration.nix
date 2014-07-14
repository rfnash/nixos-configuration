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
    kernelModules = [
        "netatop"
        "vboxdrv"
        "vboxnetadp"
        "vboxnetflt"
        "vboxpci"
        ];
    extraModulePackages = [
        pkgs.linuxPackages.netatop
        pkgs.linuxPackages.virtualbox
        ];
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
      enableTCP = true;
      layout = "dvorak";
      xkbOptions = "lv3:ralt_switch,ctrl:swapcaps,compose:ralt,terminate:ctrl_alt_bksp";
      windowManager.i3.enable = true;
      desktopManager.xterm.enable = false;
      synaptics = {
        enable = true;
        twoFingerScroll = true;
      };
    };
    httpd = {
      enable = true;
      enableUserDir = true;
      adminAddr = "rfnash@localhost";
      extraModules =  [ { name = "php5"; path = "${pkgs.php}/modules/libphp5.so"; } ];
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
    # TODO: automatically generate SSL certs
    dovecot2 = {
      enable = true;
      enablePop3 = false;
      mailLocation = "maildir:~/Maildir:LAYOUT=fs:INBOX=~/Maildir/Inbox";
      extraConfig = "mail_debug = yes";
      sslServerCert = "/etc/ssl/dovecotcert.pem";
      sslServerKey = "/etc/ssl/private/dovecot.pem";
      sslCACert = "/etc/ssl/private/dovecot.pem";
    };

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
  security.setuidPrograms = [ "sendmail" ];
  time.timeZone = "America/Detroit";
  hardware.pulseaudio.enable = true;
  virtualisation.libvirtd.enable = true;

  # TODO: automatically download docker binary
  systemd.services.docker = {
    wantedBy = [ "multi-user.target" ];
    description = "Docker Daemon";
    path = [ pkgs.iptables ];
    serviceConfig.ExecStart = "/etc/nixos/docker -d";
  };

  # TODO: automatically fix shebang and permissions on temp_throttle.sh
  systemd.services.temp-throttle = {
    wantedBy = [ "multi-user.target" ];
    description = "throttles CPU when temp exceeds limit";
    path = [ pkgs.bash pkgs.cpufrequtils ];
    serviceConfig.ExecStart = "/etc/nixos/temp-throttle/temp_throttle.sh 80";
  };

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
    group = "rfnash";
  };
  programs.bash.enableCompletion = true;
  programs.zsh.enable = true;
  environment = {
    systemPackages = with pkgs; [
      anki
      aria2
      aspell
      aspellDicts.en
      atop
      bash
      bind                        # provides dig
      binutils
      bridge_utils                # Needed by qemu for some networking
      bogofilter
      calibre
      chromiumWrapper
      cpufrequtils
      cvs
      dar
      diffuse
      dmenu
      dnsmasq
      dropbox
      e17.terminology
      emacs
      fossil
      gimp
      fdm
      file
      finger_bsd
      firefoxWrapper
      git
      gnumake
      gnupg
      go
      gtk-engine-murrine
      gtk_engines
      gtypist
      haskellPackages.yeganesh
      hicolor_icon_theme
      htop
      inetutils
      jq
      kde4.ktouch
      keynav
      ledger
      libnotify
      links2
      linuxPackages.virtualbox
      lsof
      mailutils                   # Provides 'mail'
      mercurial
      most
      mplayer
      msmtp
      mu
      mutt
      ncdu
      nmap
      nodejs
      openjre
      opensmtpd
      openssl
      pamixer
      parcellite
      pavucontrol
      pidgin
      pinentry                    # Must be installed locally as well
      php
      python
      pythonPackages.notify
      pythonPackages.pip
      pythonPackages.pygtk
      pythonPackages.pyinotify
      rlwrap
      rxvt_unicode
      silver-searcher
      sloccount
      stow
      subversion
      swiProlog
      taskwarrior
      tig
      tmux
      unclutter
      units
      unrar
      vagrant
      vimbWrapper
      vim_configurable
      vimprobable2
      w3m
      weechat
      wget
      which
      wxPython
      xbindkeys
      xconq
      xdotool
      xfontsel
      xorg.xhost
      xsel
      zathura
      znc
      ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    firefox = {
      enableAdobeFlash = true;
    };
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
    fonts = with pkgs; [
      anonymousPro
      corefonts
      dejavu_fonts
      gentium
      liberation_ttf
      libertine
      lmodern
      terminus_font
      ttf_bitstream_vera
      symbola
      ];
  };
}
