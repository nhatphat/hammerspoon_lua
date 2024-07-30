local module = {}

function module:start(config)
    switcher = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces
    hs.window.switcher.ui.showThumbnails = false
    hs.window.switcher.ui.showSelectedThumbnail = false
    hs.window.switcher.ui.showSelectedTitle = false
    hs.window.switcher.ui.textSize = 2
    config.rightHotkey:bind('alt', 'tab', function()switcher:next()end)
    config.rightHotkey:bind('alt-shift', 'tab', function()switcher:previous()end)
end

return module