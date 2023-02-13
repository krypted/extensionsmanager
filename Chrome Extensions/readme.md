# Chrome Extensions

Browser extensions can perform a number of tasks like access filesystems, gain telemetry on what processes are running on a host, view browsing history, etc. Here is a list of the APIs that Google makes available to Chrome Extension developers https://github.com/krypted/extensionsmanager/blob/main/Chrome%20Extensions/apilist. To see them delimited with a pipe, see: https://github.com/krypted/extensionsmanager/blob/main/Chrome%20Extensions/apilistasarray. Or in a standard shell scripting array form to aid in tool development, see https://github.com/krypted/extensionsmanager/blob/main/Chrome%20Extensions/apilistasarraybash.

## Get A List of Extensions
Google Chrome for Mac stores extensions in /Users/<username>/Library/Application\ Support/Google/Chrome/Default/Extensions. To see a list of all of the extensions in Google Chrome, the following find command can parse through the directory, read the manifest.json, and find the name field. It’s quoted such that it will skip those that also have short_name defined and given that extensions can have multiple versions on a computer, made to be unique.

```
find ~/Library/Application\ Support/Google/Chrome/Default/Extensions -type f -name "manifest.json" -print0 | xargs -I {} -0 grep '"name":' "{}" | uniq
``` 

## Find Extensions That Use A Specific Endpoint
Extensions are typically comprised of some javasscript and html files (to render what the javascripts are doing in modals, etc). So it's possible to repeat the above, but search for one of the APIs (for example, if one is deemed dangerous):

```  
find ~/Library/Application\ Support/Google/Chrome/Default/Extensions -type f -name "*.js" -print0 | xargs -I {} -0 grep 'chrome.contentSettings' "{}" | uniq
```

To list the Chrome extensions by endpoint used:
```
apilist=("chrome.accessibilityFeatures" "chrome.action"
"chrome.alarms" "chrome.audio" "chrome.bookmarks" "chrome.browserAction"
"chrome.browsingData" "chrome.certificateProvider" "chrome.commands"
"chrome.contentSettings" "chrome.contextMenus" "chrome.cookies"
"chrome.debugger" "chrome.declarativeContent" "chrome.declarativeNetRequest"
"chrome.desktopCapture" "chrome.devtools.inspectedWindow"
"chrome.devtools.network" "chrome.devtools.panels"
"chrome.devtools.recorder" "chrome.documentScan" "chrome.dom"
"chrome.downloads" "chrome.enterprise.deviceAttributes"
"chrome.enterprise.hardwarePlatform"
"chrome.enterprise.networkingAttributes" "chrome.enterprise.platformKeys"
"chrome.events" "chrome.extension" "chrome.extensionTypes"
"chrome.fileBrowserHandler" "chrome.fileSystemProvider"
"chrome.fontSettings" "chrome.gcm" "chrome.history" "chrome.i18n"
"chrome.identity" "chrome.idle" "chrome.input.ime" "chrome.instanceID"
"chrome.loginState" "chrome.management" "chrome.notifications"
"chrome.offscreen" "chrome.omnibox" "chrome.pageAction" "chrome.pageCapture"
"chrome.permissions" "chrome.platformKeys" "chrome.power"
"chrome.printerProvider" "chrome.printing" "chrome.printingMetrics"
"chrome.privacy" "chrome.proxy" "chrome.runtime" "chrome.scripting"
"chrome.search" "chrome.sessions" "chrome.storage" "chrome.system.cpu"
"chrome.system.display" "chrome.system.memory" "chrome.system.storage"
"chrome.tabCapture" "chrome.tabGroups" "chrome.tabs" "chrome.topSites"
"chrome.tts" "chrome.ttsEngine" "chrome.types" "chrome.vpnProvider"
"chrome.wallpaper" "chrome.wallpaper" "chrome.webNavigation"
"chrome.webRequest" "chrome.windows" "chrome.automation" "chrome.processes"
"chrome.app.runtime" "chrome.app.window" "chrome.appviewTag"
"chrome.bluetooth" "chrome.blueetoothLowEnergy" "chrome.bluetoothSocket"
"chrome.browser" "chrome.clipboard" "chrome.fileSystem" "chrome.hid"
"chrome.mdns" "chrome.mediaGalleries" "chrome.networking.onc"
"chrome.serial" "chrome.socket" "chrome.sockets.tcp"
"chrome.sockets.tcpServer" "chrome.sockets.udp" "chrome.syncFileSystem"
"chrome.system.network" "chrome.usb" "chrome.virtualKeyboard"
"chrome.webviewTag")
for apis in ${apilist[@]}; do
  echo "$apis"
  find ~/Library/Application\ Support/Google/Chrome/Default/Extensions -type
f -name "*.js" -print0 | xargs -I {} -0 grep $apis "{}" |
uniq
done
```
There are certainly less error prone or more elegant ways to do this, but that's what I've got for now. The array can be reduced to only list apis deemed safe (e.g. chrome.audio). Output can also be parsed to be more appropriate for different processing tools (e.g. in json or yaml). Further, it's also possible to remove the extensions by simply doing an rm of the guid-named directory each is stored in (although a kill on the Chrome process would help reduce any oddities an end user might experience).
