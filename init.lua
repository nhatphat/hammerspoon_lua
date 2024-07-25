-- remapping `capslock` to `F16` => https://developer.apple.com/library/archive/technotes/tn2450/_index.html#//apple_ref/doc/uid/DTS40017618-CH1-KEY_TABLE_USAGES
hs.execute('hidutil property --set ' .. "'{" .. '"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006B}]' .. "}'")

-- using `F16` as trigger key
hyper = hs.hotkey.modal.new({}, 'F15')
hs.hotkey.bind({}, 'F16', function() hyper:enter() end, function() hyper:exit() end)

config = {
    allModifierKeys = {'cmd', 'ctrl', 'alt', 'shift'},
    hyper = hyper
}

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
