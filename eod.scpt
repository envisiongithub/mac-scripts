--Ask for Confirmation
set theAlertText to "Are you leaving now?"
set theAlertMessage to "Thanks for being a good citizen and leaving your computer in a secure state when leaving the office.

This will QUIT all apps and take you to the login window. Please don’t leave until you see the login window as  you may be asked to save files before the script can complete."
display alert theAlertText message theAlertMessage

if button returned of result = "OK" then
	--Run AppleScript
	tell application "Finder" to close every window
	
	--Quit All Applications
	tell application "System Events" to set allApps to displayed name of (every process whose background only is false) as list
	set exclusions to {"Finder", "eod"}
	repeat with thisApp in allApps
		set thisApp to thisApp as text
		if thisApp is not in exclusions then
			tell application thisApp to quit
		end if
	end repeat
	
	--Display Notification
	tell application "Finder" to activate
	display notification "You can log back in at any time" with title "now SWITCHING to LOGIN WINDOW..."
	
	--Pause
	delay 5
	
	--Run Shell Script
	do shell script "'/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession' -suspend"
end if
