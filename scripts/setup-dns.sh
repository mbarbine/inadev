#!/bin/bash

# Variables
DOMAIN_NAME_1="inadev.cheeseusfries.com"
DOMAIN_NAME_2="jenkins.cheeseusfries.com"
ALB_DNS_NAME=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?State.Code==`active`].DNSName' --output text --region "us-east-2")
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='cheeseusfries.com.'].Id" --output text)

if [ -z "$HOSTED_ZONE_ID" ]; then
  echo "Hosted zone for cheeseusfries.com not found."
  exit 1
fi

# Create Route 53 DNS record for the Next.js application (inadev.cheeseusfries.com)
cat > change-batch-inadev.json <<EOL
{
  "Comment": "Creating DNS record for inadev",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${DOMAIN_NAME_1}",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",  # Hosted Zone ID for ALB in us-east-2
          "DNSName": "${ALB_DNS_NAME}",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
EOL

# Create Route 53 DNS record for Jenkins (jenkins.cheeseusfries.com)
cat > change-batch-jenkins.json <<EOL
{
  "Comment": "Creating DNS record for Jenkins",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${DOMAIN_NAME_2}",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",  # Hosted Zone ID for ALB in us-east-2
          "DNSName": "${ALB_DNS_NAME}",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
EOL

# Apply DNS changes for Next.js app
aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch file://change-batch-inadev.json

# Apply DNS changes for Jenkins
aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch file://change-batch-jenkins.json

echo "DNS records created successfully for $DOMAIN_NAME_1 and $DOMAIN_NAME_2."
