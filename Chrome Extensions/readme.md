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
