let
  accessKeyId = "ec2-deployment";
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
    deployment.ec2.keyPair = resources.ec2KeyPairs.deployment;
    deployment.ec2.elasticIPv4 = "";
    deployment.ec2.tags = { "PrometheusAutodiscover" = "true"; };
    deployment.ec2.ebsInitialRootDiskSize = 20;
  };

  resources.ec2KeyPairs.deployment = {
    inherit accessKeyId;
    inherit region;
  };
}
