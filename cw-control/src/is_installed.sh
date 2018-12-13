#!/bin/bash
# exits success if app is already installed and up-to-date
VERSION="<VERSION>"
THUMB="<THUMB>"

APP="/opt/screenconnect-$THUMB.app"
if [ ! -d "${APP}" ]; then
    echo "Does not exist: ${APP}"
    exit 1
fi

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

INSTALLED_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP/Contents/Info.plist";)
echo "Current Version: ${INSTALLED_VERSION}"

if is_at_least $INSTALLED_VERSION $VERSION; then
    echo "Installed version is the same or newer than the ${VERSION}."
    exit 0
else
    echo "Installed version is older than ${VERSION}."
    exit 1
fi
