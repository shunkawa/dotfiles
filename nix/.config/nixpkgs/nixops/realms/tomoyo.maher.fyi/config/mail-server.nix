{ config, lib, pkgs, ... }:

let
  secrets = (import ./secrets.nix);
in {
  imports = [
    "${((import <nixpkgs> {}).callPackage ../lib/nixos-mailserver.nix {})}"
  ];

  environment.systemPackages = with pkgs; [ mkpasswd ];

  mailserver = {
    enable = true;
    fqdn = "maher.fyi";
    domains = [ "maher.fyi" "rkm.id.au" ];
    vmailUserName = "vmail";
    vmailGroupName = "vmail";
    certificateScheme = 3;
    loginAccounts = {
      "ruben@maher.fyi" = (secrets.mailserver.loginAccounts."ruben@maher.fyi") // {
        sieveScript = ''
           require ["fileinto", "mailbox"];

           # I don't know what these addresses are, but they get heaps of spam.
           if anyof (
             address :is "to" "adele@rkm.id.au",
             address :is "to" "crazydaiz@rkm.id.au",
             address :is "to" "dele@rkm.id.au",
             address :is "to" "le@rkm.id.au",
             address :is "to" "olf@rkm.id.au",
             address :is "to" "rolf@rkm.id.au",
             address :is "to" "tarot@rkm.id.au"
           ) {
             fileinto :create "Junk";
             stop;
           }

           # Spammers
           if anyof (
             address :is "from" "bill.mousoulis@sitepoint.com",
             address :is "from" "hello@skillshare.com",
             address :is "from" "macca@blarneybulletin.com",
             address :is "from" "Yaren.Sahin@novatec-gmbh.de"
           ) {
             fileinto :create "Junk";
             stop;
           }


           if address :is "from" "notifications@github.com" {
             fileinto :create "GitHub";
             stop;
           }

           if anyof (exists "list-id", exists "list-unsubscribe") {
             fileinto :create "Lists";
             stop;
           }

           # if none of the above rules matched, the message will be filed into
           # INBOX
         '';
        catchAll = [ "maher.fyi" "rkm.id.au" ];
      };

      "r@rkm.id.au" = (secrets.mailserver.loginAccounts."r@rkm.id.au") // {
        sieveScript = ''
          redirect "ruben@maher.fyi";
          stop;
        '';
      };

      "nadiah@maher.fyi" = (secrets.mailserver.loginAccounts."nadiah@maher.fyi") // {};
    };
    dkimKeyDirectory = "/var/dkim";
    mailDirectory = "/mnt/var/lib/${config.users.users.vmail.name}";
    enableImap = true;
    enableImapSsl = true;
    debug = true;
    virusScanning = false;
  };

  users.users = {
    vmail = {
      home = lib.mkForce "/mnt/var/lib/${config.users.users.vmail.name}";
      createHome = true;
    };
  };

  # don't throw errors because there's no ipv6
  services.dovecot2.extraConfig = ''
    listen = *

    namespace inbox {
      inbox = yes
      separator = /

      mailbox Spam {
        auto = subscribe
        special_use = \Junk
      }

      mailbox Trash {
        auto = subscribe
        special_use = \Trash
      }

      mailbox Drafts {
        auto = subscribe
        special_use = \Drafts
      }

      mailbox Sent {
        auto = subscribe
        special_use = \Sent
      }

      mailbox Archive {
        auto = subscribe
        special_use = \Archive
      }
    }
  '';

  services.postfix.transport = ''
    * smtp:mx.maher.fyi
  '';

  services.postfix.extraConfig = ''
    inet_protocols = ipv4
  '';
}
