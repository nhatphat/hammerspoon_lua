-- reload config
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'R', hs.reload)

-- toggle console
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'C', hs.toggleConsole)


-- ========================
--      custom spoons
-- ========================

drawOnScreen = hs.loadSpoon("DrawOnScreen")
drawOnScreen:defaultUsage()