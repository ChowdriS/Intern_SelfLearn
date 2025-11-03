import * as cdk from 'aws-cdk-lib';
import { Vpc, SubnetType, IpAddresses } from 'aws-cdk-lib/aws-ec2';
import { Construct } from 'constructs';

export class Day4Stack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc = new Vpc(this, 'MyVpc', {
      ipAddresses: IpAddresses.cidr('10.0.0.0/16'),
      availabilityZones:  ["us-east-1a", "us-east-1b"],
      natGateways: 1,
      subnetConfiguration: [
        {
          cidrMask: 24,
          name: 'public',
          subnetType: SubnetType.PUBLIC,
        },
        {
          cidrMask: 24,
          name: 'private',
          subnetType: SubnetType.PRIVATE_WITH_EGRESS,
        }
      ]
    });
  }
}
