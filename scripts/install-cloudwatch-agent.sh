#!/bin/bash

# Install CloudWatch Agent
sudo yum install amazon-cloudwatch-agent -y

# Create CloudWatch Agent configuration
cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "namespace": "Jenkins/EC2",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_active"],
        "resources": ["*"],
        "totalcpu": true
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "resources": ["*"]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/jenkins/jenkins.log",
            "log_group_name": "/aws/jenkins/logs",
            "log_stream_name": "{instance_id}/jenkins.log"
          }
        ]
      }
    }
  }
}
EOF

# Start the CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

echo "CloudWatch Agent installed and configured."
