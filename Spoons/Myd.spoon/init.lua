local module = {}

module.sleep = dofile(hs.spoons.resourcePath("sleep.lua"))
module.mouseWindow = dofile(hs.spoons.resourcePath("mouse_window.lua")) 

return module