module = {}

function module:start()
    switcher = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces
    hs.window.switcher.ui.showThumbnails = false
    hs.window.switcher.ui.showSelectedThumbnail = false
    hs.window.switcher.ui.showSelectedTitle = false
    hs.window.switcher.ui.textSize = 2
    hs.hotkey.bind('alt', 'tab', function()switcher:next()end)
    hs.hotkey.bind('alt-shift', 'tab', function()switcher:previous()end)
end

return module