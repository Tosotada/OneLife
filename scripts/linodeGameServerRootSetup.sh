# For remote game servers

# Run as root to perform initial setup and user account creation



echo ""
echo ""
echo "Future root ssh logins will be key-based only, with password forbidden"
echo ""
echo ""


mkdir .ssh

chmod 744 .ssh

cd .ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAsiD85AwaNxcUzNzHPapVaGVIQCTUfdKT2tyd26MWqEds2UHLZund+S930BWz7guu3/mzuTomJnPxZPSyb+62ZiuAR0YaGZwYwMrFkrbPsXf6//MZDBvdMMcqPyqLj3Iny2ZZ9LTnSIs0hqQ3SksvP/qqHthS1YQWMwZlRxs6MmZdEuy4qZZgpnexf6uaWTEcxEO2Nij8LdEN8+jJZLHVkXSSD9c/ssTmdXss3/sVSZHYR+28HeqUahRsO0Rz6mR3FwB+ZslZlWiMFTzjkH5IA/XOiNK5Ezf1+EsQOn2OVfaCMlfJQ6YGp1kgFI01j2ZWHnqHaacvVc+C+9fAmIscZw==" > authorized_keys

chmod 644 authorized_keys

sed -i 's/PermitRootLogin yes/PermitRootLogin without-password/' /etc/ssh/sshd_config

service ssh restart


echo ""
echo ""
echo "Installing packages..."
echo ""
echo ""



apt-get -o Acquire::ForceIPv4=true update
apt-get -y install emacs-nox mercurial g++ expect gdb make fail2ban ufw


echo ""
echo ""
echo "Whitelisting only main server and backup server IP address for ssh"
echo "Opening port 8005 for game server"
echo ""
echo ""

ufw allow from 72.14.184.149 to any port 22
ufw allow from 173.230.147.48 to any port 22
ufw allow 8005
ufw --force enable


echo ""
echo ""
echo "Setting up new user account jcr13 without a password..."
echo ""
echo ""

useradd -m -s /bin/bash jcr13


dataName="OneLifeData7"


su jcr13<<EOSU

cd /home/jcr13

echo "ulimit -c unlimited >/dev/null 2>&1" >> ~/.bash_profile

ulimit -c unlimited

mkdir checkout
cd checkout



echo "Using data repository $dataName"

hg clone http://hg.code.sf.net/p/hcsoftware/OneLife
hg clone http://hg.code.sf.net/p/hcsoftware/$dataName
hg clone http://hg.code.sf.net/p/minorgems/minorGems


cd $dataName

lastTaggedDataVersion=\`hg tags | grep "OneLife" -m 1 | awk '{print \$1}' | sed -e 's/OneLife_v//'\`


echo "" 
echo "Most recent Data hg version is:  \$lastTaggedDataVersion"
echo ""

hg update OneLife_v\$lastTaggedDataVersion



cd ../OneLife/server

echo "http://onehouronelife.com/ticketServer/server.php" > settings/ticketServerURL.ini

ln -s ../../$dataName/objects .
ln -s ../../$dataName/transitions .

./configure 1

make

./runHeadlessServerLinux.sh


cd /home/jcr13
mkdir .ssh

chmod 744 .ssh

cd .ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAsiD85AwaNxcUzNzHPapVaGVIQCTUfdKT2tyd26MWqEds2UHLZund+S930BWz7guu3/mzuTomJnPxZPSyb+62ZiuAR0YaGZwYwMrFkrbPsXf6//MZDBvdMMcqPyqLj3Iny2ZZ9LTnSIs0hqQ3SksvP/qqHthS1YQWMwZlRxs6MmZdEuy4qZZgpnexf6uaWTEcxEO2Nij8LdEN8+jJZLHVkXSSD9c/ssTmdXss3/sVSZHYR+28HeqUahRsO0Rz6mR3FwB+ZslZlWiMFTzjkH5IA/XOiNK5Ezf1+EsQOn2OVfaCMlfJQ6YGp1kgFI01j2ZWHnqHaacvVc+C+9fAmIscZw==" > authorized_keys

chmod 644 authorized_keys


exit
EOSU

echo ""
echo "Done with remote setup."
echo ""
