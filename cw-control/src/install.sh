#!/bin/bash
ORG="<ORG>"
VERSION="<VERSION>"
THUMB="<THUMB>"

# Usage: Is $1 at least $2
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

if is_at_least $(/usr/bin/sw_vers -productVersion) "10.14"; then
    if ! /usr/libexec/PlistBuddy -c "Print :screenconnect-$THUMB:kTCCServiceAccessibility:Allowed" "/Library/Application Support/com.apple.TCC/MDMOverrides.plist"; then
        echo 'Privacy Preferences not controlled.'
        exit 1
    fi
fi

/usr/bin/unzip -qo "/Library/Addigy/ansible/packages/ConnectWise Control | $ORG ($VERSION)/ConnectWiseControl-$ORG-$VERSION.zip"

/bin/mkdir -p /opt/
/bin/mv "/Library/Addigy/ansible/packages/ConnectWise Control | $ORG ($VERSION)/sc-$ORG/screenconnect-$THUMB.app" /opt/
/usr/bin/xattr -dr com.apple.quarantine "/opt/screenconnect-$THUMB.app"
/usr/sbin/chown -R root:wheel "/opt/screenconnect-$THUMB.app"
/bin/chmod 755 "/opt/screenconnect-$THUMB.app"

/bin/mv "/Library/Addigy/ansible/packages/ConnectWise Control | $ORG ($VERSION)/sc-$ORG/screenconnect-$THUMB.plist" /Library/LaunchDaemons/
/bin/mv "/Library/Addigy/ansible/packages/ConnectWise Control | $ORG ($VERSION)/sc-$ORG/screenconnect-$THUMB-prelogin.plist" /Library/LaunchAgents/
/bin/mv "/Library/Addigy/ansible/packages/ConnectWise Control | $ORG ($VERSION)/sc-$ORG/screenconnect-$THUMB-onlogin.plist" /Library/LaunchAgents/
/bin/rm -Rf "/Library/Addigy/ansible/packages/ConnectWise Control | $ORG ($VERSION)/sc-$ORG"

/bin/launchctl load "/Library/LaunchDaemons/screenconnect-$THUMB.plist"
CUR_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser;uid = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[1];print(uid);')
if [ $CUR_USER > 500 ]; then
    /bin/launchctl bootstrap gui/$CUR_USER /Library/LaunchAgents/screenconnect-$THUMB-onlogin.plist
fi
