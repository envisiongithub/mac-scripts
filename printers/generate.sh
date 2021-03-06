#!/bin/bash

# REQUIRED SETTINGS
QUEUE_NAME="Default_Printer"
DEVICE_MODEL="Acme Pro 100 MFP"
DEVICE_URI="ipp://192.168.0.100/ipp/print"
PPD_FILE="/Library/Printers/PPDs/Contents/Resources/acme.ppd.gz"

# OPTIONAL SETTINGS
#OLD_QUEUE=( "" )
#DEVICE_NICKNAME="Front Desk"
#DRIVER_PKG="/Library/Addigy/ansible/packages/Sprocket Acme (1.0.0)/driver.pkg"
#DRIVER_TAR="/Library/Addigy/ansible/packages/Sprocket Acme (1.0.0)/driver.tar.gz"
#CLASS="D"
#ORGANIZATION="Sprocket Co"
#PPD_VERSION="1.0"
#KEXT_TEAM_ID="6HB5Y2QTA3"
#OPTIONS=(
#	"printer-is-shared=false"
#)
#QUEUE_OPTIONS=(
#	"printer-is-shared=false"
#)
#DRIVER_OPTIONS=(
#)

# DON'T EDIT ANYTHING BELOW HERE

FUNC=$(cat <<-'END_FUNC'
	is_at_least () {
	    if [[ $1 == $2 ]]; then
	        return 0
	    fi
	    local IFS=.
	    local i ver1=($1) ver2=($2)
	    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
	        ver1[i]=0
	    done
	    for ((i=0; i<${#ver1[@]}; i++)); do
	        if [[ -z ${ver2[i]} ]]; then
	            ver2[i]=0
	        fi
	        if ((10#${ver1[i]} > 10#${ver2[i]})); then
	            return 0
	        fi
	        if ((10#${ver1[i]} < 10#${ver2[i]})); then
	            return 1
	        fi
	    done
	    return 0
	}
END_FUNC
)

echo "Generating install files for $QUEUE_NAME..."
/bin/mkdir "$QUEUE_NAME"
/usr/bin/cd "$QUEUE_NAME"

# Create condition script
echo "Generating condition script..."

echo "#!/bin/bash" > "$QUEUE_NAME/condition.sh"

if [ -n "$DRIVER_PKG" ] || [ -n "$DRIVER_TAR" ]; then
	/bin/cat >> "$QUEUE_NAME/condition.sh" <<-DRIVEXIST
		# Check if printer driver exists
		if [ ! -f "$PPD_FILE" ]; then
		    echo "Driver is not installed."
		    exit 1
		fi

DRIVEXIST
fi

if [ -n "$PPD_VERSION" ]; then
	echo -e "$FUNC" >> "$QUEUE_NAME/condition.sh"
	/bin/cat >> "$QUEUE_NAME/condition.sh" <<-DRIVVER

		# Check if printer driver is the same or later version
		if ! is_at_least \$( /usr/bin/zgrep 'FileVersion' "$PPD_FILE" | /usr/bin/awk -F '"' '{print \$2}') ${PPD_VERSION}; then
		    echo "Installed driver is old."
		    exit 1
		fi

DRIVVER
fi

/bin/cat >> "$QUEUE_NAME/condition.sh" <<-QEXIST
	# Check if print queue exists
	ERROR=\$( { /usr/bin/lpoptions -p $QUEUE_NAME -l > /dev/null; } 2>&1 )
	if [ -n "\$ERROR" ]; then
	    echo \$ERROR
	    exit 1
	fi

QEXIST

if [ -n "$QUEUE_OPTIONS" ]; then
	echo "# Check if print queue options match" >> "$QUEUE_NAME/condition.sh"
	for OPTION in "${QUEUE_OPTIONS[@]}"; do
		/bin/cat >> "$QUEUE_NAME/condition.sh" <<-QOPTS
			if ! /usr/bin/lpoptions -p $QUEUE_NAME | /usr/bin/grep "$OPTION" > /dev/null; then
			    echo "Print queue options do not match."
			    exit 1
			fi
QOPTS
	done
fi

if [ -n "$DRIVER_OPTIONS" ]; then
	echo "# Check if print driver options match" >> "$QUEUE_NAME/condition.sh"
	for OPTION in "${DRIVER_OPTIONS[@]}"; do
		/bin/cat >> "$QUEUE_NAME/condition.sh" <<-DOPTS
			if ! /usr/bin/lpoptions -p $QUEUE_NAME -l | /usr/bin/grep "$OPTION" > /dev/null; then
			    echo "Print driver options do not match."
			    exit 1
			fi
DOPTS
	done
fi

/bin/cat >> "$QUEUE_NAME/condition.sh" <<-EOF

	# Nothing to do, already installed
	echo "Printer driver and queue are already installed and configured."
	exit 0
EOF

# Create install script
echo "Generating install script..."

echo "#!/bin/bash" > "$QUEUE_NAME/install.sh"
if [ -n "$KEXT_TEAM_ID" ] || [ -n "$PPD_VERSION" ]; then
	echo -e "$FUNC" >> "$QUEUE_NAME/install.sh"
fi

if [ -n "$KEXT_TEAM_ID" ]; then
	/bin/cat >> "$QUEUE_NAME/install.sh" <<-KEXT

		# Check for KEXT whitelisting
		if is_at_least \$(/usr/bin/sw_vers -productVersion) "10.13.4"; then
		    if ! /usr/bin/sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "SELECT team_id FROM kext_policy_mdm;" | /usr/bin/grep "$KEXT_TEAM_ID"; then
		        echo 'Kernel extension not whitelisted.'
		        exit 1
		    fi
		fi

KEXT
fi

if [ -n "$DRIVER_PKG" ]; then
	if [ -n "$PPD_VERSION" ]; then
		/bin/cat >> "$QUEUE_NAME/install.sh" <<-INSTDRIV

			# Install driver if old or not present
			if [ ! -f "$PPD_FILE" ] || ! is_at_least \$( /usr/bin/zgrep 'FileVersion' "$PPD_FILE" | /usr/bin/awk -F '"' '{print \$2}') ${PPD_VERSION}; then
			    /usr/sbin/installer -pkg "$DRIVER_PKG" -target /
			fi

INSTDRIV
	else
		/bin/cat >> "$QUEUE_NAME/install.sh" <<-INSTDRIV

			# Install driver if not present
			if [ ! -f "$PPD_FILE" ]; then
			    /usr/sbin/installer -pkg "$DRIVER_PKG" -target /
			fi

INSTDRIV
	fi
elif [ -n "$DRIVER_TAR" ]; then
	if [ -n "$PPD_VERSION" ]; then
		/bin/cat >> "$QUEUE_NAME/install.sh" <<-INSTDRIV

			# Install driver if old or not present
			if [ ! -f "$PPD_FILE" ] || ! is_at_least \$( /usr/bin/zgrep 'FileVersion' "$PPD_FILE" | /usr/bin/awk -F '"' '{print \$2}') ${PPD_VERSION}; then
			    /usr/bin/tar -xzf "$DRIVER_TAR" -C /Library/Printers/PPDs/Contents/Resources/
			    /bin/chmod 644 "$PPD_FILE"
			fi

INSTDRIV
	else
		/bin/cat >> "$QUEUE_NAME/install.sh" <<-INSTDRIV

			# Install driver if not present
			if [ ! -f "$PPD_FILE" ]; then
			    /usr/bin/tar -xzf "$DRIVER_TAR" -C /Library/Printers/PPDs/Contents/Resources/
			    /bin/chmod 644 "$PPD_FILE"
			fi

INSTDRIV
	fi
fi

/bin/cat >> "$QUEUE_NAME/install.sh" <<-'MCXQ'
	# Delete old MCX print queues if exist
	if /usr/bin/lpstat -p | /usr/bin/grep "mcx_" > /dev/null 2>&1; then
	    /usr/bin/lpstat -p | /usr/bin/awk '{print $2}' | /usr/bin/grep "mcx_" | while read -r MCX_Q; do
	        /usr/sbin/lpadmin -x $MCX_Q
	    done
	    echo "MCX print queues deleted."
	fi
MCXQ

if [ -n "$OLD_QUEUE" ]; then
	for i in "${OLD_QUEUE[@]}"; do
		/bin/cat >> "$QUEUE_NAME/install.sh" <<-OLDQ
			# Delete old print queue if exists
			if /usr/bin/lpstat -p | /usr/bin/grep $i; then
			    /usr/sbin/lpadmin -x "$i"
			    echo "Old print queue $i deleted."
			fi
OLDQ
	done
fi

OPTION_STR=""
for OPTION in "${OPTIONS[@]}"; do
	OPTION_STR="$OPTION_STR -o $OPTION"
done
if [[ $PPD_FILE == drv* ]]; then
	PPD_ARG="-m \"$PPD_FILE\""
else
	PPD_ARG="-P \"$PPD_FILE\""
fi
if [ -n "$DEVICE_NICKNAME" ]; then
	DESCRIPTION="$DEVICE_NICKNAME - $DEVICE_MODEL"
	LOCATION="$ORGANIZATION - $DEVICE_NICKNAME"
else
	DESCRIPTION="$DEVICE_MODEL"
	LOCATION="$ORGANIZATION"
fi
/bin/cat >> "$QUEUE_NAME/install.sh" <<-INSTQ
	# Delete print queue if exists
	if /usr/bin/lpstat -p | /usr/bin/grep $QUEUE_NAME; then
	    /usr/sbin/lpadmin -x $QUEUE_NAME
	    echo "Existing print queue deleted."
	fi

	# Create print queue
	/usr/sbin/lpadmin -p "$QUEUE_NAME" -v "$DEVICE_URI" -D "$DESCRIPTION" -L "$LOCATION" $PPD_ARG -E $OPTION_STR
	echo "$QUEUE_NAME print queue created."

	# Restart CUPS
	echo "Restarting CUPS..."
	/bin/launchctl stop org.cups.cupsd
	/bin/launchctl start org.cups.cupsd
	echo "Done!"

INSTQ

# Create remove script
echo "Generating remove script..."

echo "#!/bin/bash" > "$QUEUE_NAME/remove.sh"
echo "/usr/sbin/lpadmin -x $QUEUE_NAME" >> "$QUEUE_NAME/remove.sh"

echo "Done!"
exit 0
