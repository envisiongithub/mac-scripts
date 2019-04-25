# REQUIRED SETTINGS
QUEUE_NAME="ED-Sharp5070"
DEVICE_MODEL="Sharp MX-5070N"
DEVICE_URI="lpd://192.168.0.100/"
PPD_FILE="/Library/Printers/PPDs/Contents/Resources/SHARP MX-5070N.PPD.gz"

# OPTIONAL SETTINGS
DEVICE_NICKNAME="Copier"
DRIVER_PKG="/Library/Addigy/ansible/packages/Printer | ED Sharp 5070 Copier (1.0.0)/MX-C52.pkg"
CLASS="P"
ORGANIZATION="Envision Design"
PPD_VERSION="1.14"
OPTIONS=(
	"printer-is-shared=false"
	"Option1=Finisher"
	"Option2=Installed"
	"Option5=3TrayDrawer"
	"Option9=PModule33"
)
QUEUE_OPTIONS=(
	"printer-is-shared=false"
)
DRIVER_OPTIONS=(
	"Option1/Output Tray Options: NotInstalled InnerFinisher \*Finisher LSFinisher SSFinisher LSSFinisher"
	"Option2/Right Tray: NotInstalled \*Installed"
	"Option5/Input Tray Options: NotInstalled 1TrayDrawer 2TrayDrawer \*3TrayDrawer TandemTrayDrawer"
	"Option9/Punch Module: NotInstalled \*PModule33 PModule24 PModule4W"
)
