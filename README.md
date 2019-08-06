## Instructions for running the "watchdog" script##

## PREREQUIREMENT
#Create a user for the service (without home directory)
sudo useradd -M watchdog
#Prevent Logging in with the user
sudo usermod -L watchdog

## DOWNLOAD THE FILES
#Download the script and the unit file from GitHub repository
sudo wget https://raw.githubusercontent.com/IgorCurl/General/master/CodingChalangeSolution.sh -O /usr/bin/CodingChalangeSolution.sh
#Download the unit file from GitHub repository
sudo wget https://raw.githubusercontent.com/IgorCurl/General/master/watchdog.service -O /etc/systemd/system/watchdog.service
#Download the config file into /etc (preferred directory of the configuration files)
sudo wget https://raw.githubusercontent.com/IgorCurl/General/master/CodingChalangeSolution.conf -O /etc/CodingChalangeSolution.conf

## CONFIGURE THE SERVICE
#Set "execute" permission for the script
sudo chmod +x /usr/bin/CodingChalangeSolution.sh
#Edit the configuration parameters (follow instructions in the .conf file)
vim /etc/CodingChalangeSolution.conf
#Enable that the service starts whenever the system boots
sudo systemctl enable watchdog
#We can now start the service
sudo systemctl start watchdog

