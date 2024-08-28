local module = {
    menubar = {},
}

getApplicationBadgeCount = function(bundleID)
    return hs.execute("./Spoons/DockAppNoti.spoon/get_badge_count.sh " .. bundleID)
end

getApplicationDockItems = function()
    local runningApps = hs.application.runningApplications()

    local apps = {}

    for _, app in pairs(runningApps) do
        local bundleID = app:bundleID()
        if app:kind() == 1 and bundleID ~= nil then
            local badge = getApplicationBadgeCount(bundleID)
            
            if badge ~= '' then
                table.insert(apps, {app = app, badge = badge})
            end
        end
    end

    return apps
end

generateAppIconFromDockItem = function(item, badge)
    local id = item:bundleID()
    local appIcon = hs.image.imageFromAppBundle(id)

    local iconSize = 15
    local canvas = hs.canvas.new {
        x = 0,
        y = 0,
        h = iconSize + 2,
        w = iconSize + 2
    }
    local dot = '•'
    local fillColor = badge == dot
                        and { red = 0, green = 1, blue = 0, alpha = 1 }
                        or { red = 1, green = 0, blue = 0, alpha = 1 }

    canvas:appendElements({
        {
            type = "image",
            frame = { h = iconSize, w = iconSize, x = 0, y = 2 },
            image = appIcon
        },{
            type = "circle",
            fillColor = fillColor,
            radius = 5,
            center = {x = 2, y = 2},
            strokeColor = { alpha = 0 },
        }
    })

    return canvas:imageFromCanvas()
end

function module:showAppNotiOnMenuBar()
    local items = getApplicationDockItems()
    local section = os.time(os.date("!*t"))

    for _, item in pairs(items) do
        local id = item.app:bundleID()
        local badge = item.badge

        if self.menubar[id] == nil then
            local menu = hs.menubar.new()
            menu:setClickCallback(function() hs.application.launchOrFocusByBundleID(id) end)
            self.menubar[id] = { menu = menu }
        end

        if self.menubar[id].badge ~= badge then
            self.menubar[id].badge = badge
            self.menubar[id].menu:setIcon(generateAppIconFromDockItem(item.app, badge), false)
        end

        -- assign new section for existed menubar's items
        self.menubar[id].section = section
    end

    -- everything with old section will be deleted
    for id, _ in pairs(self.menubar) do
        if self.menubar[id].section ~= section then
            self.menubar[id].menu:delete()
            self.menubar[id] = nil
        end
    end
end

function module:start()
    hs.application.enableSpotlightForNameSearches(true)
    self:showAppNotiOnMenuBar()
    self.tm = hs.timer.doEvery(1.12, function() self:showAppNotiOnMenuBar() end)
end

return module