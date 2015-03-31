#!/bin/bash

# Exit status:
# 0 = Success
# 1 = improper command-line arguments
# 2 = executed by root, but no force-root option provided
# 3 = install dependencies failed
# 4 = failed to build ehs package
# 5 = failed to install ehs package
# 6 = failed to build FreeRDP package
# 7 = failed to install FreeRDP package
# 8 = failed to build casablanca package
# 9 = failed to test casablanca build
# 10 = failed to install casablanca package
# 11 = failed to build FreeRDP-WebConnect package
# 99 = failed to execute some shell command

# trap handler: print location of last error and process it further
#
function exit_handler()
{
        MYSELF="$0"               # equals to my script name
        LASTLINE="$1"            # argument 1: last line of error occurence
        LASTERR="$2"             # argument 2: error code of last command
        #echo "${MYSELF}: line ${LASTLINE}: exit status of last command: ${LASTERR}"

        case ${LASTERR} in
			0)	;;
			1)	echo ${USAGE}
				;;
			2) 	echo "If you wish to run this script as root, use the --force-root option."
				echo ${USAGE}
				;;
			3) 	echo 'Unable to install dependencies. Try to manually install packages listed in install_prereqs.sh according to your distribution.'
				echo 'After that, run the script without the --install-deps flag'
				;;
			4) 	echo 'Unable to build ehs package. Exiting...'
				#cleanup
				;;
			5) 	echo "Unable to install ehs package into /usr. Exiting..."
				#cleanup
				;;
			6) 	echo 'Unable to build FreeRDP package. Exiting...'
				#cleanup
				;;
			7)	echo "Unable to install FreeRDP package into /usr. Exiting..."
				#cleanup
				;;
			8)	echo "Unable to build casablanca package. Exiting..."
				;;
			9)	echo "Testing the casablanca build failed. Exiting... "
				;;
			10)	echo "Unable to install casablanca package into /usr. Exiting..."
				;;
			11)	echo "Unable to build FreeRDP-WebConnect. Exiting..."
				#cleanup
				;;
			99) echo 'Internal error. Make sure you have an internet connection and that nothing is interfering with this script before running again (broken/rooted system or something deleting parts of the file-tree in mid-process).'
				#cleanup
				;;
			*)	echo 'Unknown error exit. Should not have happened.'
				;;
		esac
}

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Install dependencies
apt-get install -qy --force-yes build-essential \
				g++-4.8 \
				libxml++2.6-dev \
				libssl-dev \
				libboost1.54-all-dev \
				libpng-dev \
				libdwarf-dev \
				subversion \
				subversion-tools \
				svn2cl \				
				autotools-dev \
				autoconf \
				libtool \
				git \
				cmake


# replace old gcc/g++ with new one
rm /usr/bin/g++  
ln -s /usr/bin/g++-4.8 /usr/bin/g++  
rm /usr/bin/gcc  
ln -s /usr/bin/gcc-4.8 /usr/bin/gcc 

#########################################
##     BUILDING FreeRDP-WebConnect     ##
#########################################
echo "---- Downloading FreeRDP-WebConnect Project ----"
cd /tmp
git clone https://github.com/HurricaneHernandez/FreeRDP-WebConnect.git
cd FreeRDP-WebConnect
./setup-all.sh -f

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

mkdir -p /etc/service/wsgate
cat <<'EOT' > /etc/service/wsgate/run
#!/bin/bash

exec /wsgate/wsgate -c /wsgate/wsgate.ini >> /var/log/wsgate 2>&1
EOT


chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

# Install wsgate
mkdir /wsgate
mv /tmp/FreeRDP-WebConnect/wsgate/build/* /wsgate
mv /tmp/files/wsgate.ini /wsgate/

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get purge --remove build-essential cmake subversion subversion-tools svn2cl git -y 
apt-get autoremove -y 
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/*
