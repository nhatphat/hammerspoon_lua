local module = {}

function module:binding_shortcuts(config)
    config.hyper:bind({}, 'space', function()
        hs.eventtap.keyStroke({"cmd", "shift"}, "space", 0) -- 0 to avoid delay
    end)
end

return module