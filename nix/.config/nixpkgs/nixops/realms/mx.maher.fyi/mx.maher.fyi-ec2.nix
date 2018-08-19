let
  accessKeyId = "personal-ec2-deployments";
  region = "ap-southeast-2";
in
{
  mx =
  { config, pkgs, resources, ... }:
  { deployment.targetEnv = "ec2";
    deployment.owners = [ "ruben@maher.fyi" ];
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.ebsBoot = true;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.securityGroups = [ "default" ];
    deployment.ec2.keyPair = resources.ec2KeyPairs.personal-ec2-deployments;
    deployment.ec2.elasticIPv4 = "13.211.249.75";
    deployment.ec2.tags = { "PrometheusAutodiscover" = "true"; };
    deployment.ec2.ebsInitialRootDiskSize = 50;
    deployment.storeKeysOnMachine = false;
    deployment.autoLuks = {
      root = {
        autoFormat = true;
        cipher = "aes-cbc-essiv:sha256";
        device = "/dev/xvda";
        keySize = 512;
        passphrase = (import ./secrets.nix).deployment.autoLuks.root.passphrase;
      };
    };
  };

  resources.ec2KeyPairs.personal-ec2-deployments = {
    inherit accessKeyId;
    inherit region;
  };
}
