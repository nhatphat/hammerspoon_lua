-- https://developer.apple.com/library/archive/technotes/tn2450/_index.html#//apple_ref/doc/uid/DTS40017618-CH1-KEY_TABLE_USAGES
-- remap key
hs.execute('hidutil property --set "$(cat key.map)"')

-- using `F16` as trigger key
hyper = hs.hotkey.modal.new({}, 'F15')
hs.hotkey.bind({}, 'F16', function() hyper:enter() end, function() hyper:exit() end)

config = {
    allModifierKeys = {'cmd', 'ctrl', 'alt', 'shift'},
    hyper = hyper
}

rightHotkey = require('right_modifier_key')
config.rightHotkey = rightHotkey

-- ========================
--      global hot key
-- ========================

hyper:bind({'cmd'}, 'R', hs.reload)
hyper:bind({'cmd'}, 'C', hs.toggleConsole)

-- ========================
--      custom spoons
-- ========================

drawOnScreen = hs.loadSpoon("DrawOnScreen")
drawOnScreen:defaultUsage(config)

appSwitcher = hs.loadSpoon("AppSwitcher")
appSwitcher:start(config)

windowSwitcher = hs.loadSpoon("WindowSwitcher")
windowSwitcher:start()