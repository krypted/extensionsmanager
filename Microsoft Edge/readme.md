

```
find ~/Library/Application\ Support/Microsoft\ Edge/Default/Extensions -type f -name "manifest.json" -print0 | xargs -I {} -0 grep '"name":' "{}" | uniq
```
