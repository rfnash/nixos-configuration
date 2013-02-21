

{ config, pkgs, ... }:

{
  require = [ ./hardware-configuration.nix ];

  boot = {
    loader.grub = {
       enable = true;
       version = 2;
       device = "/dev/sda";
    };
    initrd = {
      luks.devices = [ { 
        device = "/dev/sda3";
        name = "gentoo_root";
	preLVM = true;
      } ];
      supportedFilesystems = [ "zfs"];
    };
  };

  networking = {
    hostName = "nixos";
    wireless.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [80 443 9001 9030 31329 48286 51413 15899 2222];
      allowedUDPPorts = [80 443 9001 9030 31329 48286 51413 15899 2222];
    };
  };
  
  fileSystems = [ 
    { mountPoint = "/";
      label = "nix-btrfs";
      fsType = "ext4";
    }
    {
      mountPoint = "/home";
      label = "home";
      fsType = "ext4";
    }
    {
      mountPoint = "/tmp";
      device = "tmpfs";
      fsType = "tmpfs";
      options = "size=2G";
    }
  ];

  swapDevices = [ { device = "/dev/vg_rfnashlaptop/lv_swap"; } ];

  i18n = {
     consoleFont = "lat9w-16";
     consoleKeyMap = "dvorak";
     defaultLocale = "en_US.UTF-8";
   };

   services = {
     # openssh.enable = true;
     printing.enable = true;
     unbound.enable = true;  
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
      redshift
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
