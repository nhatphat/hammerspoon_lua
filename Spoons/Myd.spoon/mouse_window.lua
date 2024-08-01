local module = {}

function module:startMoveMouse(config)
    config.hyper:bind({}, '`', function()
        local screen = hs.mouse.getCurrentScreen()
        local nextScreen = screen:next()
        local rect = nextScreen:fullFrame()
        local center = hs.geometry.rectMidPoint(rect)
        hs.mouse.absolutePosition(center)
    end)
end

function module:startMoveWindow(config)
    config.hyper:bind({}, 'w', function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local rect = win:frame():toUnitRect(screen:frame())
        win:move(rect, screen:next(), true, 0)
    end)
end

return module