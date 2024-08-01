local module = {
    sleepMenu = hs.menubar.new()
}

function module:preventSleep()
    self.sleepMenu:setTitle("😊")
    hs.caffeinate.set("displayIdle", true, true)
end

function module:allowSleep()
    self.sleepMenu:setTitle("😴")
    hs.caffeinate.set("displayIdle", false, true)
end

function module:toggleSleep()
    if hs.caffeinate.get("displayIdle") then
        self:allowSleep()
    else
        self:preventSleep()
    end
end

function module:start()
    self:allowSleep()
    self.sleepMenu:setClickCallback(function() self:toggleSleep() end)
end

return module