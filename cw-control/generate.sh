#!/bin/bash
CERT="Developer ID Application: Name (ID)"

THUMB=$(/bin/ls | /usr/bin/grep -Eow "screenconnect-[[:alnum:]]{16}" | /usr/bin/grep -Eo ".{16}$")
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "screenconnect-$THUMB.app/Contents/Info.plist")
if ! echo $VERSION | /usr/bin/grep -E "\..+\."; then
    VERSION="$VERSION.0"
fi
PARAM_FILE="screenconnect-$THUMB.app/Contents/Resources/ClientLaunchParameters.txt"
SRV=$(echo $(<$PARAM_FILE) | /usr/bin/grep -Eo "h=[^&]*" | /usr/bin/grep -Eo "[^=]+$")
KEY=$(echo $(<$PARAM_FILE) | /usr/bin/grep -Eo "k=[^&]*" | /usr/bin/grep -Eo "[^=]+$")

while read -r; do
    ORGS_ARR[i++]=$REPLY
done < organizations.csv
[[ $REPLY ]] && ORGS_ARR[i++]=$REPLY

if [ ${#ORGS_ARR[@]} -eq 0 ] ; then
    echo "organizations.csv is empty"
    exit 1
else
    /bin/mkdir "FOR_DEPLOYMENT"
    /bin/cp src/is_installed.sh FOR_DEPLOYMENT/is_installed.sh
    /bin/cp src/remove.sh FOR_DEPLOYMENT/remove.sh
    /usr/bin/sed -i '' -e "s/<VERSION>/$VERSION/g" FOR_DEPLOYMENT/is_installed.sh
    /usr/bin/sed -i '' -e "s/<THUMB>/$THUMB/g" FOR_DEPLOYMENT/is_installed.sh

    LOOP=false
    for ORG_KEY in "${!ORGS_ARR[@]}" ; do
        ORG="${ORGS_ARR[$ORG_KEY]}"
        echo "Generating install files for $ORG..."
        
        /bin/mkdir "sc-$ORG"
        
        /bin/cp -R "screenconnect-$THUMB.app" "sc-$ORG/screenconnect-$THUMB.app"
        /bin/cp src/screenconnect.plist "sc-$ORG/screenconnect-$THUMB.plist"
        /bin/cp src/screenconnect-prelogin.plist "sc-$ORG/screenconnect-$THUMB-prelogin.plist"
        /bin/cp src/screenconnect-onlogin.plist "sc-$ORG/screenconnect-$THUMB-onlogin.plist"
        
        echo "?y=Guest&k=$KEY&t=&c=$ORG&c=&c=&c=&c=&c=&c=&c=&s=&h=$SRV&p=443&e=Access" > "sc-$ORG/$PARAM_FILE"
        /usr/bin/codesign -fs "$CERT" "sc-$ORG/screenconnect-$THUMB.app"
        if ! $LOOP; then
            /usr/bin/codesign -dr - "sc-$ORG/screenconnect-$THUMB.app"
            LOOP=true
        fi
        
        /usr/bin/sed -i '' -e "s/<THUMB>/$THUMB/g" "sc-$ORG/screenconnect-$THUMB.plist"
        /usr/bin/sed -i '' -e "s/<THUMB>/$THUMB/g" "sc-$ORG/screenconnect-$THUMB-prelogin.plist"
        /usr/bin/sed -i '' -e "s/<THUMB>/$THUMB/g" "sc-$ORG/screenconnect-$THUMB-onlogin.plist"
        
        /usr/bin/zip -rq "FOR_DEPLOYMENT/ConnectWiseControl-$ORG-$VERSION.zip" "sc-$ORG/" -x "*.DS_Store" -x "__MACOSX"
        /bin/rm -Rf "sc-$ORG"
        
        /bin/cp src/install.sh "FOR_DEPLOYMENT/install-$ORG.sh"
        /usr/bin/sed -i '' -e "s/<ORG>/$ORG/g" "FOR_DEPLOYMENT/install-$ORG.sh"
        /usr/bin/sed -i '' -e "s/<VERSION>/$VERSION/g" "FOR_DEPLOYMENT/install-$ORG.sh"
        /usr/bin/sed -i '' -e "s/<THUMB>/$THUMB/g" "FOR_DEPLOYMENT/install-$ORG.sh"
    done
    echo "Done!"
    exit 0
fi
