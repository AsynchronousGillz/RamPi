# INSTALL

## setup.sh

In the setup.sh script you are prompted to enter the host name of the machine you are going to be installing the wireless density testing script on this is important as it will set it to the host name then set a host name file that will be copied later. Then tars the FARM directory on the local machine then, ssh to the target host then installs the authorized key in the ssh authorized_keys file. The scp the tar ball on the local machine to target host. The does an update and installs the needed applications. This then will reboot the machine and then reconnect then untar's the tar ball on the target machines disk then will run the install.sh script. Once the install.sh script is done then setup.sh will shutdown the target host.

## install.sh

install.sh is located with in the config directory as it needs to be run as root. To do this just use sudo.... you should know that. First it installs updates, the sets ntp, then changes the host name, calls the dynamic DNS script, then it will install the driver. Then copies the rc.local and then all done.

## Scripts
+ curl101.sh
... `Usage: ./curl101.sh  [ number of times to download ] [ target host to download ]`

+ ftp101.sh.
... `Usage: ./ftp101.sh  [ number of times to download ] [ target host to download ] [ target file to download ]`

+ iperf101.sh
... `Usage: ./iperf101.sh  [ number of times to download ] [ target iperf server ]`

+ ping.sh
... `Usage: ./ping101.sh  [ number of times ] [ target host ]`

+ wdt101.sh
... `Usage: ./wdt101.sh  [ options ]`
