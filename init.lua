-- https://developer.apple.com/library/archive/technotes/tn2450/_index.html#//apple_ref/doc/uid/DTS40017618-CH1-KEY_TABLE_USAGES
-- remap key
hs.execute('hidutil property --set "$(cat key.map)"')

-- using `F16` as trigger key
hyper = hs.hotkey.modal.new({}, "F15")
hs.hotkey.bind({}, "F16", function()
	hyper:enter()
end, function()
	hyper:exit()
end)

config = {
	allModifierKeys = { "cmd", "ctrl", "alt", "shift" },
	hyper = hyper,
}

rightHotkey = require("right_modifier_key")
config.rightHotkey = rightHotkey

-- ========================
--      global hot key
-- ========================

hyper:bind({}, "R", hs.reload)
hyper:bind({}, "C", hs.toggleConsole)

-- ========================
--      custom spoons
-- ========================
hs.console.clearConsole()

myd = hs.loadSpoon("Myd")
myd.sleep:start()
myd.mouseWindow:startMoveMouse(config)
myd.mouseWindow:startMoveWindow(config)
myd.quick_binding_shortcuts:binding_shortcuts(config)
myd.path_watcher:yaak()

drawOnScreen = hs.loadSpoon("DrawOnScreen")
drawOnScreen:defaultUsage(config)

-- appSwitcher = hs.loadSpoon("AppSwitcher")
-- appSwitcher:start(config)

-- windowSwitcher = hs.loadSpoon("WindowSwitcher")
-- windowSwitcher:start(config)

dockAppNoti = hs.loadSpoon("DockAppNoti")
dockAppNoti:start()

windowHalfsAndThirds = hs.loadSpoon("WindowHalfsAndThirds")
windowHalfsAndThirds:defaultUsage(config)

windowDimmer = hs.loadSpoon("WindowDimmer")
windowDimmer:defaultUsage(config)

-- hs.window.highlight.ui.overlay = true
-- hs.window.highlight.start()
-- hs.window.highlight.ui.flashDuration = 0.3
-- hs.window.highlight.ui.frameWidth = 10
-- hs.window.highlight.ui.windowShownFlashColor = { 0, 0, 0, 0 }
-- hs.window.highlight.ui.windowHiddenFlashColor = { 0, 0, 0, 0 }
-- hs.window.highlight.ui.windowShownFlashColorInvert = { 0, 0, 0, 0 }
-- hs.window.highlight.ui.windowHiddenFlashColorInvert = { 0, 0, 0, 0 }
-- hs.window.highlight.ui.isolateColor = { 0, 0, 0, 0 }

-- startup-tasks
require("startup").setup()
