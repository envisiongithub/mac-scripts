# Addigy Printer Scripts
For creating custom software items in Addigy that install the driver and configure the printer in a reliable way.

## Basic Usage
- Begin a new custom software item in Addigy and upload the driver package or tarball
- Edit [generate.sh](generate.sh) with the settings for your printer
- Run [generate.sh](generate.sh) (locally)
- Copy the contents of the three generated files to the respective fields in the Addigy custom software item. For the Conditions script, switch off "Install On Success"
- Repeat for additional printers

## Settings
- `QUEUE_NAME` - (required) name of the printer queue, user usually never sees this
- `DEVICE_MODEL` - (required) can be the CUPS `MakeModel`, will be part of the CUPS `Info`
- `DEVICE_URI` - (required) the CUPS `DeviceURI`, hopefully you’re using static IPs…
- `PPD_FILE` - (required) path to the installed PPD
- `OLD_QUEUE` - array of queues this installer is replacing
- `DEVICE_NICKNAME` - e.g., Copier, Plotter, By Jane; will be part of the CUPS `Info` and `Location`
- `DRIVER_PKG` - if there’s a `.pkg` specify it’s path here
- `DRIVER_TAR` - if there’s no `.pkg`, create a tarball of the PPD and specify it’s path here
- `CLASS` - [D]esktop(default) [L]abel [P]roduction [W]ide (not currently used)
- `ORGANIZATION` - will be the first part of the CUPS `Location`
- `PPD_VERSION` - compare the `FileVersion` of the PPD (probably a better way to do this)
- `KEXT_TEAM_ID` - AFAIK only HP installs kernel extensions (6HB5Y2QTA3)
- `OPTIONS` - combined queue and driver options, formatted for `lpadmin`
- `QUEUE_OPTIONS` - queue options, formatted as displayed by `lpoptions`
- `DRIVER_OPTIONS` - driver options, formatted as displayed by `lpoptions`

## Notes
- if using the built-in legacy CUPS drivers, do not include either the `DRIVER_PKG` or `DRIVER_TAR`, the script will recognize the `drv://` path and configure the queue correctly

## Known Issues
- if the driver package is not self-contained (Samsung) or is an `.mpkg` (IBM), you’ll need to compress before uploading and manually add a decompression line to the install script

## To Do
- Batch creation by reading from a private repo
- Addigy API integration so there’s no need to copy and paste the scripts
- Add alternate setting to install Apple drivers using `softwareupdate`
- Allow format of `Info` and `Location` to be specified per queue
- AutoPkg integration to track new driver versions

## Contributing
Submit a pull request!
