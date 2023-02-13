THe
```
cat /Users/*/Library/Application\ Support/Firefox/Profiles/*/extensions.json | sed 's/"name"/\n"name"/g' | grep '"name"' | awk -F',' '{print $2}'
```
