#!/bin/bash

# Start Jenkins with Configuration as Code (JCasC)
echo "Starting Jenkins with JCasC..."
export JENKINS_ADMIN_PASSWORD=$(aws ssm get-parameter --name "/${ENVIRONMENT}/jenkins/admin_password" --with-decryption --query Parameter.Value --output text)

java -jar /usr/share/jenkins/jenkins.war --httpPort=8080 --argumentsRealm.passwd.admin=$JENKINS_ADMIN_PASSWORD --argumentsRealm.roles.admin=admin

echo "Jenkins started and configured."
