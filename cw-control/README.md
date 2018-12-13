# ConnectWise Control
ConnectWise Control (formerly ScreenConnect) does not code-sign the guest Access agent, which means in macOS Mojave, even with a UAMDM server, a PPPC profile cannot pre-approve the agent. These scripts are how we sign and deploy the agent ourselves to work around that.

## Disclaimer
These scripts modify third-party software. It’s your responsibility to verify the modifications do not violate the license agreement between you and the software vendor. It’s also your responsibility to verify the modifications do not adversely affect the software, the software vendor’s servers, or the devices which you install the software. Refer to the [LICENSE](../LICENSE) prior to using these scripts.

## 1. generate.sh
### Pre-Requisites
- A ConnectWise Control account (obvs)
- An Apple Developer Account
- A Mac to use for the code-signing
- A Developer ID Application certificate from the ADA installed in the login Keychain on the code-signing Mac
- The ConnectWise Control Access agent from your account installed “the documented way” on a test Mac you have access to
- Organization names in Control consisting of a 2 – 5 letter code. E.g., `ED` for “Envision Design, LLC.” If you use some other naming schema, you may have to modify this script.

### Usage
1. Clone or download the repo to the Mac you’re using for the code-signing
1. Edit [organizations.csv](organizations.csv) to have one organization code/name per line
1. Edit the `CERT` variable at the top of [generate.sh](generate.sh) to be the full name of your installed Developer ID Application certifcate
1. Copy the existing `screenconnect-XXXXXXXXXXXXXXXX.app` from `/opt` to the directory you downloaded (where [generate.sh](generate.sh) is located)
1. Run [generate.sh](generate.sh)

You should end up with ZIP files for each of your organizations that contain a signed application as well as the LaunchDaemon and Agents to run the application. Also the script will print the code signature needed to create a PPPC profile.

## 2. is_installed.sh (optional)
You can run `is_installed.sh` on target machines which will exit success if the Access agent is already successfully installed and up-to-date.

- If using Addigy
    - Create a custom software item named “ConnectWise Control | ORG” where `ORG` matches the value you entered in [organizations.csv](organizations.csv)
    - Copy the contents of `is_installed.sh` into the Condition Script, removing the hashbang from the beginning
    - Set the “Install On Success” option to false
- If using another solution
    - Copy `is_installed.sh` to your target machines and execute

## 3. install.sh
### Pre-Requisites
- For macOS 10.14 and up, you'll need to deploy a PPPC MDM profile allowing Accessibility and System Event Automation for `screenconnect-THUMB` where `THUMB` is the value determined above.
- The install paths are specific to Addigy. If you're using a different deployment tool, you'll need to edit the paths.

### Usage
Note the following will need to be done for each organization
- If using Addigy
    - Upload the ZIP file for this organization as the install file
    - Copy the contents of the `install-ORG.sh` for this organization into the Installation Script, removing the hashbang from the beginning
    - Deploy the custom software to the appropriate policies
- If using another solution
    - Copy `install-ORG.sh` and the ZIP file for this organization to the target machines and execute the script

## 4. remove.sh
- If using Addigy
    - Copy the contents of the `remove.sh` into the Removal Script, removing the hashbang from the beginning
- If using another solution
    - Copy and run `remove.sh` to a target machine to uninstall the Access agent from that machine

## TODO
- Add check for automation PPPC
- Integrate with Addigy API to create custom software items automatically
- Output signed PKGs instead of ZIPs
- Include signed PPPC profile in output
