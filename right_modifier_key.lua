local hotkey = require("hs.hotkey")
local eventtap = require("hs.eventtap")

local module = {
    keys = {},
    keysActive = false
}

function module:bind(mods, key, message, pressedfn, releasedfn, repeatfn)
    local newHotkey = hotkey.new(mods, key, message, pressedfn, releasedfn, repeatfn)

    if type(mods) == "string" then mods = {mods} end
    table.insert(module.keys, newHotkey) -- group by the first key
end

-- determines whether or not to enable/disable the keys
et = eventtap.new(
    { eventtap.event.types.flagsChanged },
    function(e)
        local flags = e:rawFlags()
        local isAlt = flags & eventtap.event.rawFlagMasks.deviceRightAlternate > 0
        local isCmd = flags & eventtap.event.rawFlagMasks.deviceRightCommand > 0
        local isCtrl = flags & eventtap.event.rawFlagMasks.deviceRightControl > 0
        local isShift = flags & eventtap.event.rawFlagMasks.deviceRightShift > 0
        if isAlt or isCmd or isCtrl or isShift then
            if not module.keysActive then
                for _, v in ipairs(module.keys) do
                    v:enable()
                end
                module.keysActive = true
            end
        else
            if module.keysActive then
                for _, v in ipairs(module.keys) do
                    v:disable()
                end
                module.keysActive = false
            end
        end
    end
):start()

return module