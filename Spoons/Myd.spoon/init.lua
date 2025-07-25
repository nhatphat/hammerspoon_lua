local module = {}

module.sleep = dofile(hs.spoons.resourcePath("sleep.lua"))
module.mouseWindow = dofile(hs.spoons.resourcePath("mouse_window.lua")) 
module.quick_binding_shortcuts = dofile(hs.spoons.resourcePath("quick_binding_shortcuts.lua")) 

return module