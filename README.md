# matlab-session-bookmarks
Save your opened files and easily open them again in a future coding session. 

## How to use
```
bookmark list               lists all available bookmarks that are stored,
                            including date the bookmark was stored.

bookmark list <name>        will list all files storen in a bookmark file.

bookmark save <name>        will store all open files in a bookmark file.
                            You can restore these open files using:

bookmark restore <name>     Restores you saved bookmarks.

bookmark delete <name>      Will delete the bookmark.

bookmark closeall           Will close all open editors. Prompts for confirmation.
bookmark closeall -y        Will close all open editors without prompt for confirmation.
``` 
