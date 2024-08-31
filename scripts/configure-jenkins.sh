#!/bin/bash

# Environment variables
JENKINS_ADMIN_USER="admin"
JENKINS_ADMIN_PASSWORD="adminpassword"

# Ensure Java is installed
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk

# Add Jenkins repository and install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins

# Start Jenkins and enable it on boot
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Secure Jenkins: Create an admin user and disable the initial setup wizard
sudo sed -i 's/.*JENKINS_ENABLE_SETUP_WIZARD.*/JENKINS_ENABLE_SETUP_WIZARD=false/g' /etc/default/jenkins

# Create a Jenkins admin user using Groovy script
cat <<EOF > /var/lib/jenkins/init.groovy.d/admin-user.groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('$JENKINS_ADMIN_USER', '$JENKINS_ADMIN_PASSWORD')
instance.setSecurityRealm(hudsonRealm)
instance.save()
EOF

echo "Jenkins has been installed and configured with an admin user."
echo "Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "The initial admin password is located in /var/lib/jenkins/secrets/initialAdminPassword"
# Fetch the initial admin password for convenience
sudo cat /var/lib/jenkins/secrets/initialAdminPassword