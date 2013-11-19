awesome-wm-furious
==================

Awesome WM script for modal client (applications' windows) management.

## Features
* modal keygrabber
* cacth client mode (bring to focused tag)
* dropdown mode (dropdown target client)
* centralized configuration
* multi-screen support
* application oriented

### ROR (Run On Raise)
Classic "run or raise" will focus the requested application if some matching exists. Else it will spawn that application on its default tag and screen.

### Catch
This mode will move the requested application () to the focused tag, if some matching client exists. Else it will spawm the application to the focused tag.

### Dropdown
Is a "dropdown" like mode that makes the target client sticky (vible on all tags), floating, and resized according to a given geometry (static for now). If a matching client exists, then it is used, otherwise the corresponding application is spawned. The dropdown client is plated on the focused tag.


## Configuration
```lua
myappz = {}
myappz["f"] = { info="firefox", cmd="firefox", tag="1", screen=1, match="Firefox", type="instance" }

```

### In the rc.lua
A sample `rc.lua` file is available for demo here. It modified the default `rc.lua` file with minimum requirements to make furious work.

Add furious lib dependency :
```lua
require("furious")
```

Then switch global keys setting from classic to furious one :
```lua
-- Set keys
furious_init_global(globalkeys)
--root.keys(globalkeys) no more required
```

Finally, add furious client keys to rc clientkeys :
```lua
clientkeys = awful.util.table.join(
    get_clientkeys(),
    ................. 
-- }}}
```

