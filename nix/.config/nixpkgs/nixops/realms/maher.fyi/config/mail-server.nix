{ hostName }: { config, lib, pkgs, ... }:

let
  secrets = (import ./secrets.nix);
in {
  imports = [
    "${((import <nixpkgs> {}).callPackage ../lib/nixos-mailserver.nix {})}"
  ];

  environment.systemPackages = with pkgs; [ mkpasswd ];

  mailserver = {
    enable = true;
    fqdn = "mx.maher.fyi";
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
    dkimKeyDirectory = "/data/mx.maher.fyi/var/dkim";
    mailDirectory = "/data/mx.maher.fyi/var/lib/${config.users.users.vmail.name}";
    enableImap = true;
    enableImapSsl = true;
    debug = true;
    virusScanning = false;
    mailboxes = [
      { name = "Archive"; auto = "subscribe"; specialUse = "Archive"; }
      { name = "Drafts"; auto = "subscribe"; specialUse = "Drafts"; }
      { name = "Junk"; auto = "subscribe"; specialUse = "Junk"; }
      { name = "Sent"; auto = "subscribe"; specialUse = "Sent"; }
      { name = "Trash"; auto = "subscribe"; specialUse = "Trash"; }
    ];
    lmptSaveToDetailMailbox = "no";
  };

  # macOS mail client 9.3 requires TLSv1
  services.postfix.extraConfig = ''
    smtpd_tls_protocols = TLSv1.2, TLSv1.1, TLSv1, !SSLv2, !SSLv3
    smtp_tls_protocols = TLSv1.2, TLSv1.1, TLSv1, !SSLv2, !SSLv3
    smtpd_tls_mandatory_protocols = TLSv1.2, TLSv1.1, TLSv1, !SSLv2, !SSLv3
    smtp_tls_mandatory_protocols = TLSv1.2, TLSv1.1, TLSv1, !SSLv2, !SSLv3
  '';

  users.users = {
    vmail = {
      home = lib.mkForce "/data/mx.maher.fyi/var/lib/${config.users.users.vmail.name}";
      createHome = true;
    };
  };
}
