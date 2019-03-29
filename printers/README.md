# Addigy Printer Scripts
For creating custom software items in Addigy that install the driver and configure the printer in a reliable way.

## Usage
- Begin a new custom software item in Addigy and upload the driver `pkg`
- Edit [generate.sh](generate.sh) with the settings for your printer
- Run [generate.sh](generate.sh) (locally)
- Copy the contents of the three generated files to the respective fields in the Addigy custom software item
- Repeat for additional printers
