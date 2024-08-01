local module = {
    menubar = {},
}

getApplicationDockItems = function()
    local dock = hs.axuielement.applicationElement('Dock')
    local dockItems = dock:attributeValue('AXChildren')[1]

    local apps = {}

    for _, item in pairs(dockItems.AXChildren) do
        local subrole = item.AXSubrole or ''
        local badgeLabel = item:attributeValue('AXStatusLabel') or ''
        if subrole == 'AXApplicationDockItem' and badgeLabel ~= '' then
            table.insert(apps, item)
        end
    end

    return apps
end

generateAppIconFromDockItem = function(item)
    local id = hs.application.find(item:attributeValue('AXTitle')):bundleID()
    local badge = item:attributeValue('AXStatusLabel')
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
    local apps = getApplicationDockItems()
    local section = os.time(os.date("!*t"))

    for _, a in pairs(apps) do
        local application = hs.application.find(a:attributeValue('AXTitle'))
        if application == nil then
            goto continue
        end

        local id = application:bundleID()
        local badge = a:attributeValue('AXStatusLabel')

        if self.menubar[id] == nil then
            local menu = hs.menubar.new()
            menu:setClickCallback(function() hs.application.launchOrFocusByBundleID(id) end)
            self.menubar[id] = { menu = menu }
        end

        if self.menubar[id].badge ~= badge then
            self.menubar[id].badge = badge
            self.menubar[id].menu:setIcon(generateAppIconFromDockItem(a), false)
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

    ::continue::
end

function module:start()
    self:showAppNotiOnMenuBar()
    self.tm = hs.timer.doEvery(1.12, function() self:showAppNotiOnMenuBar() end)
end

return module