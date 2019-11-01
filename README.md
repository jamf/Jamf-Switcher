# Jamf Switcher
<p align="center"><img src="/../assets/images/Jamf%20Switcher-512x512.png" width="256" height="256"></p>

Jamf Switcher is an app which points either Jamf Pro applications or your default browser to a particular Jamf deployment and is configured by Self Service Bookmarks.

# Usage
1. Within Jamf Pro, navigate to Settings > Self Service > Bookmarks
<p align="center"><img src="/../assets/images/Screenshot%202019-10-31%2022.04.06.png" width="512"></p>
2. Set DISPLAY NAME as desired
3. For DESCRIPTION, include one of the below (case doesn't matter):
    - Jamf
    - JPS
    - JSS
4. Enter the Jamf Pro URL in the URL field.
5. Optionally set an icon.
6. Scope as needed.
7. Launch Self Service and navigate to Bookmarks, make sure that your Bookmarks are visible before proceeeding.
<p align="center"><img src="/../assets/images/Screenshot%202019-10-31%20at%2019.55.56.png" width="512"></p>
8. On a device with the Self Service Bookmarks in scope, download the [latest version of Jamf Switcher](https://github.com/dataJAR/Jamf-Switcher/releases/latest)
9. Launch Jamf Switcher.
10. On launch you might be asked to move to the Applications folder if not there already, please do so updates can be received:
<p align="center"><img src="/../assets/images/Screenshot%202019-10-31%20at%2022.28.33.png" width="512"></p>
11. Choose to check for updates automatically or not:
<p align="center"><img src="/../assets/images/Screenshot%202019-10-31%20at%2022.32.23.png" width="512"></p>
12. Jamf Switcher should now load showing a window listing details from the Bookmarks with the DESCRIPTION set as per 3, in the format of:
    - DISPLAY NAME - URL
<p align="center"><img src="/../assets/images/Screenshot%202019-10-31%20at%2020.00.35.png" height="512"></p>    
13. Now you can either:

- Select an entry and press CMD + O to open the URL in your default browser.
- Double click & a window will appear which will either:

	* Open /Applications/Jamf Pro/ to allow you select a Jamf Pro application, if the Jamf Pro folder is in /Applications/Jamf Pro/ <p align="center"><img src="/../assets/images/Screenshot%202019-10-31%20at%2020.10.31.png" width="512"></p>
        
	* Open /Applications/, if the Jamf Pro folder cannot be found at /Applications/Jamf Pro/ <p align="center"><img src="/../assets/images/Screenshot%202019-10-31%20at%2020.06.38.png"></p>
14. With an app selected, ~/Library/Preferences/com.jamfsoftware.jss.plist is amended as per:

	- 'allowInvalidCertificate' is set to 'TRUE'
	- 'url' is set to the URL of the entry selected

15. The selected app is launched.

# Alternatives
Other folks have created their own apps which reach the same end goal, find the below:

- [JamfProSwitcher](https://github.com/ninxsoft/JamfProSwitcher)
- [JSS Switcher](https://github.com/PhantomPhixer/Phixits/tree/master/JSS%20Switcher)
- [Switch JSS](https://github.com/jason-tratta/SwitchJSS)
