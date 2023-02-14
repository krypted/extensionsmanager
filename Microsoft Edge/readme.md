Browser extensions can perform a number of tasks like access filesystems, gain telemetry on what processes are running on a host, view browsing history, etc. Here is a list of the APIs that Microsoft makes available to Microsoft Edge extension developers https://github.com/krypted/extensionsmanager/blob/main/Microsoft%20Edge/apis. Or in a standard shell scripting array form to aid in tool development, see https://github.com/krypted/extensionsmanager/blob/main/Microsoft%20Edge/apisasarray.

## Get A List of Extensions
Edge for Mac stores a list of extensions in ~/Library/Application\ Support/Microsoft\ Edge/Default/Extensions (where the ~ denotes a user's home directory). To see a list of all of the extensions in Chrome on a given machine, the following find command can parse through the directory (or directories if a * is used like in /Users/*/Library/Application\ Support/Microsoft\ Edge/Default/Extensions), read the manifest.json for extensions.

```
find ~/Library/Application\ Support/Microsoft\ Edge/Default/Extensions -type f -name "manifest.json" -print0 | xargs -I {} -0 grep '"name":' "{}" | uniq
```
Microsoft Edge exposes a few features in a property list, but none involve extensions (the traditional method for Mac management).
```
defaults read ~/Library/Preferences/com.microsoft.edgemac.plist 
{
    LastRunAppBundlePath = "/Applications/Microsoft Edge.app";
    LoginKeychainEmpty = 1;
    OptionalDataCollectionEnabled = 0;
}
```
