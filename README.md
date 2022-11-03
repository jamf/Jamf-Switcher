Copyright 2022 DATA JAR LTD

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

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
10. Choose to check for updates automatically or not:
<p align="center"><img src="/../assets/images/Screenshot%202019-10-31%20at%2022.32.23.png" width="512"></p>
11. Jamf Switcher should now load showing a window listing details from the Bookmarks with the DESCRIPTION (as set in step 3) in the format of:
    - DISPLAY NAME - URL
<p align="center"><img src="/../assets/images/Screenshot%202019-10-31%20at%2020.00.35.png" height="512"></p>    
12. Now you can either:

- Select an entry and press CMD + O to open the URL in your default browser.
- Double click & a window will appear which will either:

	* Open /Applications/Jamf Pro/ to allow you select a Jamf Pro application, if the Jamf Pro folder is in /Applications/Jamf Pro/ <p align="center"><img src="/../assets/images/Screenshot%202019-10-31%20at%2020.10.31.png" width="512"></p>
        
	* Open /Applications/, if the Jamf Pro folder cannot be found at /Applications/Jamf Pro/ <p align="center"><img src="/../assets/images/Screenshot%202019-10-31%20at%2020.06.38.png"></p>
13. With an app selected, ~/Library/Preferences/com.jamfsoftware.jss.plist is amended as per:

	- 'allowInvalidCertificate' is set to 'TRUE'
	- 'url' is set to the URL of the entry selected

14. The selected app is launched.

# Alternatives
Other folks have created their own apps which reach the same end goal:

- [JamfProSwitcher](https://github.com/ninxsoft/JamfProSwitcher)
- [JSS Switcher](https://github.com/PhantomPhixer/Phixits/tree/master/JSS%20Switcher)
- [Switch JSS](https://github.com/jason-tratta/SwitchJSS)
