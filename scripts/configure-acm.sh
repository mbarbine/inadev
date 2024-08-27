#!/bin/bash

# Set the AWS Region and domain names
REGION="us-east-2"
DOMAIN_INADEV="inadev.cheeseusfries.com"
DOMAIN_JENKINS="jenkins.cheeseusfries.com"

# Retrieve the hosted zone ID for the domain
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='cheeseusfries.com.'].Id" --output text --region $REGION)

# Create ACM Certificates for both domains
create_acm_certificate() {
    DOMAIN=$1
    CERTIFICATE_ARN=$(aws acm request-certificate \
        --domain-name "$DOMAIN" \
        --validation-method DNS \
        --query "CertificateArn" --output text --region $REGION)

    echo "Created ACM certificate for $DOMAIN: $CERTIFICATE_ARN"
    echo $CERTIFICATE_ARN
}

# Validate ACM certificates using Route 53 DNS records
validate_acm_certificate() {
    CERTIFICATE_ARN=$1

    # Retrieve the validation record
    VALIDATION_OPTIONS=$(aws acm describe-certificate \
        --certificate-arn "$CERTIFICATE_ARN" \
        --query "Certificate.DomainValidationOptions[0].ResourceRecord" --output json --region $REGION)

    # Extract name and value for the DNS validation
    NAME=$(echo "$VALIDATION_OPTIONS" | jq -r '.Name')
    VALUE=$(echo "$VALIDATION_OPTIONS" | jq -r '.Value')

    # Create a Route 53 DNS validation record
    cat > change-batch.json <<EOF
{
  "Comment": "ACM Certificate DNS Validation",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$NAME",
        "Type": "CNAME",
        "TTL": 60,
        "ResourceRecords": [{ "Value": "$VALUE" }]
      }
    }
  ]
}
EOF

    # Apply the DNS validation record
    aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch file://change-batch.json --region $REGION
    echo "DNS validation record created for $CERTIFICATE_ARN"
}

# Wait for ACM certificate to be validated
wait_for_certificate_validation() {
    CERTIFICATE_ARN=$1
    echo "Waiting for certificate validation..."
    aws acm wait certificate-validated --certificate-arn "$CERTIFICATE_ARN" --region $REGION
    echo "Certificate validated: $CERTIFICATE_ARN"
}

# Associate the ACM certificates with the ALB listeners
associate_certificate_with_alb() {
    ALB_LISTENER_ARN=$1
    CERTIFICATE_ARN=$2

    aws elbv2 modify-listener --listener-arn "$ALB_LISTENER_ARN" \
        --certificates CertificateArn="$CERTIFICATE_ARN" \
        --region $REGION
    echo "Associated certificate with ALB listener."
}

# Create and validate certificates for both domains
CERTIFICATE_ARN_INADEV=$(create_acm_certificate "$DOMAIN_INADEV")
CERTIFICATE_ARN_JENKINS=$(create_acm_certificate "$DOMAIN_JENKINS")

# Validate the certificates using DNS
validate_acm_certificate "$CERTIFICATE_ARN_INADEV"
validate_acm_certificate "$CERTIFICATE_ARN_JENKINS"

# Wait for the certificates to be validated
wait_for_certificate_validation "$CERTIFICATE_ARN_INADEV"
wait_for_certificate_validation "$CERTIFICATE_ARN_JENKINS"

# Retrieve ALB Listener ARNs
ALB_LISTENER_ARN_HTTP=$(aws elbv2 describe-listeners --load-balancer-arn $(terraform output -raw alb_arn) --query 'Listeners[?Protocol==`HTTP`].ListenerArn' --output text --region $REGION)
ALB_LISTENER_ARN_HTTPS=$(aws elbv2 describe-listeners --load-balancer-arn $(terraform output -raw alb_arn) --query 'Listeners[?Protocol==`HTTPS`].ListenerArn' --output text --region $REGION)

# Associate certificates with ALB listeners
associate_certificate_with_alb "$ALB_LISTENER_ARN_HTTP" "$CERTIFICATE_ARN_INADEV"
associate_certificate_with_alb "$ALB_LISTENER_ARN_HTTPS" "$CERTIFICATE_ARN_JENKINS"
