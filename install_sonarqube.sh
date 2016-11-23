#!/bin/sh
## Usage: ./install_sonarqube.sh VERSION
## Example: ./install_sonarqube.sh 6.1

#DB Config
#Set these to whatever your values should be.
DB_USER=sonarqube
DB_PASS=sonarqube
DB_NAME=sonarqube

#Configuration
DB_USER_PROP="\nsonar.jdbc.username=$DB_USER"
DB_PASS_PROP="\nsonar.jdbc.password=$DB_PASS"
DB_URL_PROP="\nsonar.jdbc.url=jdbc:postgresql://localhost/$DB_NAME"
BASE_URL="https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-"
DL_EXT=".zip"
SIG_EXT=".asc"
DL_URL=$BASE_URL$1$DL_EXT
SIG_URL=$DL_URL$SIG_EXT
TMP_DIR="/tmp/"
BASE_FILE="sonarqube-"
TMP_DL=$TMP_DIR$BASE_FILE$1$DL_EXT
TMP_SIG=$TMP_DL$SIG_EXT
INSTALL_ROOT=/opt/
INSTALL_DIR="sonarqube-"$1
INSTALL_PATH=$INSTALL_ROOT$INSTALL_DIR
SONAR_HOME=$INSTALL_ROOT"sonarqube"
CONFIG_FILE=$INSTALL_PATH"/conf/sonar.properties"

#Sonar system.d service unit
UNIT="[Unit]
\nDescription=SonarQube
\nAfter=network.target
\nAfter=network-online.target
\nAfter=postgresql.service
\n[Service]
\nExecStart=$SONAR_HOME/bin/linux-x86-64/sonar.sh start
\nExecStop=$SONAR_HOME/bin/linux-x86-64/sonar.sh stop
\nExecReload=$SONAR_HOME/bin/linux-x86-64/sonar.sh restart
\nPIDFile=$SONAR_HOME/bin/linux-x86-64/./SonarQube.pid
\nType=forking
\n[Install]
\nWantedBy=multi-user.target"

#Abort if this version is already installed
if [ -e $INSTALL_PATH ]; then
	echo "$INSTALL_PATH already exists!"
	exit 1
fi

#Download install package and sigs.
#Abort if downloads fail
curl --location $DL_URL --output $TMP_DL --fail
if [ ! -f $TMP_DL ]; then
	echo "\nDownload failed for $DL_URL\n"
	exit 1
fi
curl --location $SIG_URL --output $TMP_SIG --fail
if [ ! -f $TMP_SIG ]; then
	echo "\nDownload failed for $SIG_URL\n"
	exit 1
fi

#Get/Update distribution key
gpg --keyserver hkp://pgp.mit.edu --recv-keys 0xD26468DE

#Abort if verification fails
gpg --verify $TMP_SIG $TMP_DL
if [ ! $? -eq 0 ]; then
	echo "\nSignature verification failed\n"
	exit 1
else
	echo "\nSignature validated for downloaded archive.\n"
fi

#Unzip to the install directory
unzip -q $TMP_DL -d $INSTALL_ROOT

#Remove tmp files
rm -f $TMP_DL
rm -f $TMP_SIG

#Update softlink
if [ -e $SONAR_HOME ]; then
	rm -f $SONAR_HOME
fi
ln -s $INSTALL_PATH $SONAR_HOME

#Update database config
echo $DB_USER_PROP >> $CONFIG_FILE
echo $DB_PASS_PROP >> $CONFIG_FILE
echo $DB_URL_PROP >> $CONFIG_FILE

#Install service
echo $UNIT > /etc/systemd/system/sonarqube.service
chmod 664 /etc/systemd/system/sonarqube.service

#Start/Restart service
systemctl daemon-reload
systemctl enable sonarqube.service
systemctl restart sonarqube.service

#Exit message
echo "SonarQube install complete"
echo "Visit YourSonarServer:port/setup to migrate existing database to new version"
