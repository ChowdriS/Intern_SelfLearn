import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import {
  Vpc,
  SubnetType,
  IpAddresses,
  Instance,
  InstanceType,
  InstanceClass,
  InstanceSize,
  MachineImage,
  SecurityGroup,
  Peer,
  Port,
} from 'aws-cdk-lib/aws-ec2';
import * as elbv2 from 'aws-cdk-lib/aws-elasticloadbalancingv2';
import * as targets from 'aws-cdk-lib/aws-elasticloadbalancingv2-targets';
import { Duration } from 'aws-cdk-lib';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as s3deploy from 'aws-cdk-lib/aws-s3-deployment';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import * as origins from 'aws-cdk-lib/aws-cloudfront-origins';
import { RemovalPolicy } from 'aws-cdk-lib';


export class Ec2StackSai extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // ---------- VPC ----------
    const vpc = new Vpc(this, 'SaiVpc', {
      ipAddresses: IpAddresses.cidr('10.0.0.0/16'),
      natGateways: 1, // reduce cost, can be 3 for HA
      maxAzs: 3,
      subnetConfiguration: [
        { name: 'Public', subnetType: SubnetType.PUBLIC, cidrMask: 24 },
        { name: 'Private', subnetType: SubnetType.PRIVATE_WITH_EGRESS, cidrMask: 24 },
      ],
    });

    // ---------- Security Groups ----------
    const albSg = new SecurityGroup(this, 'AlbSg', { vpc });
    albSg.addIngressRule(Peer.anyIpv4(), Port.tcp(80), 'Allow HTTP from anywhere');

    const ec2Sg = new SecurityGroup(this, 'Ec2Sg', { vpc });
    ec2Sg.addIngressRule(albSg, Port.tcp(80), 'Allow traffic from ALB');
    ec2Sg.addEgressRule(Peer.anyIpv4(), Port.allTraffic());

    // ---------- EC2 (Nginx) ----------
    const instance = new Instance(this, 'SaiWebServer', {
      vpc,
      vpcSubnets: { subnetType: SubnetType.PRIVATE_WITH_EGRESS },
      instanceType: InstanceType.of(InstanceClass.T2, InstanceSize.MICRO),
      machineImage: MachineImage.latestAmazonLinux2023(),
      securityGroup: ec2Sg,
    });

    instance.addUserData(
      'yum update -y',
      'yum install -y nginx',
      'systemctl enable nginx',
      'systemctl start nginx',
      `echo "<h1>Hello from Sai EC2 via CDK!</h1>" > /usr/share/nginx/html/index.html`

    );

    // ---------- ALB ----------
    const alb = new elbv2.ApplicationLoadBalancer(this, 'SaiAlb', {
      vpc,
      internetFacing: true,
      securityGroup: albSg,
      vpcSubnets: { subnetType: SubnetType.PUBLIC },
    });

    const listener = alb.addListener('HttpListener', { port: 80, open: true });

    listener.addTargets('WebTargets', {
      port: 80,
      targets: [new targets.InstanceTarget(instance)],
      healthCheck: {
        path: '/',
        port: '80',
        protocol: elbv2.Protocol.HTTP,
        healthyThresholdCount: 2,
        interval: Duration.seconds(30),
      },
    });

    // ---------- S3 Bucket ----------
    const siteBucket = new s3.Bucket(this, 'FrontendBucket', {
      removalPolicy: RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
    });

    // ---------- CloudFront OAI ----------
    const oai = new cloudfront.OriginAccessIdentity(this, 'S3OAI');
    siteBucket.grantRead(oai);

    // ---------- CloudFront Distribution ----------
    const distribution = new cloudfront.Distribution(this, 'SaiDistribution', {
      defaultBehavior: {
        origin: new origins.S3Origin(siteBucket, { originAccessIdentity: oai }),
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
      },
      defaultRootObject: 'index.html',
    });

    // ---------- Deploy sample index.html ----------
    const indexHtml = `
      <html>
        <head><title>Sai Frontend</title></head>
        <body>
          <h1>Hello from S3 + CloudFront!</h1>
          <p>Deployed using AWS CDK 🚀</p>
        </body>
      </html>
    `;

    new s3deploy.BucketDeployment(this, 'DeployWebsite', {
      sources: [s3deploy.Source.data('index.html', indexHtml)],
      destinationBucket: siteBucket,
      distribution,
      distributionPaths: ['/*'],
    });

    new cdk.CfnOutput(this, 'BucketName', { value: siteBucket.bucketName });
    new cdk.CfnOutput(this, 'CloudFrontURL', { value: `https://${distribution.distributionDomainName}` });
    new cdk.CfnOutput(this, 'AlbDnsName', { value: alb.loadBalancerDnsName });
  }
}
