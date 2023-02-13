# Chrome Extensions

Browser extensions can perform a number of tasks like access filesystems, gain telemetry on what processes are running on a host, view browsing history, etc. Here is a list of the APIs that Google makes available to Chrome Extension developers https://github.com/krypted/extensionsmanager/blob/main/Chrome%20Extensions/apilist. Or in a standard shell scripting array form to aid in tool development, see https://github.com/krypted/extensionsmanager/blob/main/Chrome%20Extensions/apilistasarray.

```
find ~/Library/Application\ Support/Google/Chrome/Default/Extensions -type f -name "manifest.json" -print0 | xargs -I {} -0 grep '"name":' "{}" | uniq
```
The
```
