local module = {}
local sleepToggle = hs.menubar.new()

local function preventSleep()
    sleepToggle:setTitle("😊")
    hs.caffeinate.set("displayIdle", true, true)
end

local function allowSleep()
    sleepToggle:setTitle("😴")
    hs.caffeinate.set("displayIdle", false, true)
end

local function toggleSleep()
    if hs.caffeinate.get("displayIdle") then
        allowSleep()
    else
        preventSleep()
    end
end

function module:sleepMenuBar()
    allowSleep()
    sleepToggle:setClickCallback(toggleSleep)
end

return module