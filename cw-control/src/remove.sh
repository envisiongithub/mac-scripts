#!/bin/bash
PUBLIC_THUMBPRINTS=$(/bin/ls /opt/ | /usr/bin/grep -o -w -E "screenconnect-[[:alnum:]]{16}" | /usr/bin/grep -Eo ".{16}$")
PUBLIC_THUMBPRINTS_ARR=($PUBLIC_THUMBPRINTS)
if [ ${#PUBLIC_THUMBPRINTS} -eq 0 ]; then
    exit 1
else
    for thumbprintKey in "${!PUBLIC_THUMBPRINTS_ARR[@]}"; do
        THUMBPRINT="${PUBLIC_THUMBPRINTS_ARR[$thumbprintKey]}"
        NAMES_OF_USERS_STR2=$(/bin/ps aux | /usr/bin/grep $THUMBPRINT | /usr/bin/grep -Eo '^[^ ]+')
        NAMES_OF_USERS_ARR2=($NAMES_OF_USERS_STR2)
        for key2 in "${!NAMES_OF_USERS_ARR2[@]}"; do
            POTENTIAL_USER2="${NAMES_OF_USERS_ARR2[$key2]}"
            if [ $POTENTIAL_USER2 != "root" ]; then
                NON_ROOT_USER_ID2=$(id -u $POTENTIAL_USER2)
                /bin/launchctl asuser $NON_ROOT_USER_ID2 launchctl unload /Library/LaunchAgents/screenconnect-$THUMBPRINT-onlogin.plist >/dev/null 2>&1
            fi
        done
        /bin/launchctl unload "/Library/LaunchDaemons/screenconnect-$THUMBPRINT.plist" >/dev/null 2>&1
        /bin/rm "/Library/LaunchAgents/screenconnect-$THUMBPRINT-onlogin.plist" >/dev/null 2>&1
        /bin/rm "/Library/LaunchAgents/screenconnect-$THUMBPRINT-prelogin.plist" >/dev/null 2>&1
        /bin/rm "/Library/LaunchDaemons/screenconnect-$THUMBPRINT.plist" >/dev/null 2>&1
        /bin/rm -rf "/opt/screenconnect-$THUMBPRINT.app/" >/dev/null 2>&1
    done
    exit 0
fi
