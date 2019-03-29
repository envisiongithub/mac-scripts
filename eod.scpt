-- Gone for the Day (GFD) script
--
-- Prompts the user to confirm then quits all apps and logs user out
--
-- @package EnvisionDesign\Gone for the Day
-- @author  Richard Wingfield <rwingfield@envisiondesign.net>
-- @author  Chris Peters <cpeters@envisiondesign.net>
-- @author  Shawn Maddock <smaddock@envisiondesign.net>
-- @license MIT MIT License

--Ask user to confirm
set fullMsg to "Thanks for being a good citizen and leaving your computer in a secure state when leaving the office.

This will QUIT all apps and take you to the login window. Please don’t leave until you see the login window as you may be asked to save files before the script can complete."
display alert "Are you leaving now?" message fullMsg buttons {"Cancel", "OK"}

if button returned of result = "OK" then
	--Close all Finder windows
	tell application "Finder" to close every window
	
	--Quit all applications
	tell application "System Events" to set allApps to displayed name of (every process whose background only is false) as list
	set exclusions to {"Finder", "Gone for the Day", "Script Editor"}
	repeat with thisApp in allApps
		set thisApp to thisApp as text
		if thisApp is not in exclusions then
			tell application thisApp to quit
		end if
	end repeat
	
	--Notify user of log out
	tell application "Finder" to activate
	display notification "You can log back in at any time" with title "now SWITCHING to LOGIN WINDOW..."
	delay 5
	
	--Log out user
	--tell application "System Events" to log out
	tell application "loginwindow" to «event aevtrlgo»
	return
end if
