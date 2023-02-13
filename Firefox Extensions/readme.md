Browser extensions can perform a number of tasks like access filesystems, gain telemetry on what processes are running on a host, view browsing history, etc. Here is a list of the APIs that Google makes available to Chrome Extension developers https://github.com/krypted/extensionsmanager/blob/main/Chrome%20Extensions/apilist. To see them delimited with a pipe, see: https://github.com/krypted/extensionsmanager/blob/main/Chrome%20Extensions/apilistasarray. Or in a standard shell scripting array form to aid in tool development, see https://github.com/krypted/extensionsmanager/blob/main/Chrome%20Extensions/apilistasarraybash.

## Get A List of Extensions
Firefox for Mac stores a list of extensions in /Users/*/Library/Application\ Support/Firefox/Profiles/*/extensions.json (the first * denotes there's a manifest for each user and the second * denotes there are multiple profiles with their own sets of extensions for each Firefox user within that Mac user account). To see a list of all of the extensions in Firefox, the following find command can parse through the directory (or directories), read the extensions.json, and find the name field.

```
cat /Users/*/Library/Application\ Support/Firefox/Profiles/*/extensions.json | sed 's/"name"/\n"name"/g' | grep '"name"' | awk -F',' '{print $2}'
```
