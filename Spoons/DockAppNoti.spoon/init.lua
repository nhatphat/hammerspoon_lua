local module = {}

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

function module:showAppNoti()
    local apps = getApplicationDockItems()

    if self.canvas ~= nil then
        self.canvas:delete()
    end

    local frame = hs.screen.mainScreen():frame()
    local iconSize = 30
    self.canvas = hs.canvas.new {
        x = 0,
        y = 30,
        h = frame.h,
        w = iconSize
    }
    
    local y = 0
    for _, a in pairs(apps) do
        local id = hs.application.find(a:attributeValue('AXTitle')):bundleID()
        local badge = a:attributeValue('AXStatusLabel')
        local icon = hs.image.imageFromAppBundle(id)
        local spacing = 10
        y = y + spacing
        self.canvas:appendElements({
            {
                type = "image",
                frame = { h = iconSize, w = iconSize, x = 0, y = y },
                image = icon,
                trackMouseUp = true,
                id = id
            },{
                type = "circle",
                fillColor = { red = 1, green = 0, blue = 0, alpha = 1 },
                radius = 8,
                center = {x = 8, y = y + 5},
                strokeColor = { alpha = 0 },
                trackMouseUp = true,
                id = id
            },{
                type = "text",
                text = badge,
                textColor = { white = 1 },
                textSize = 10,
                textAlignment = "center",
                frame = { x = 3, y = y - y * .02, h = 10, w = 10 },
                trackMouseUp = true,
                id = id
            }
        })
        y = y + iconSize
    end

    self.canvas:show()
    self.canvas:mouseCallback(function(_, event, appID, _, _)
       if event == "mouseUp" then
            hs.application.launchOrFocusByBundleID(appID)
       end 
    end)
end

function module:start()
    self:showAppNoti()
    self.tm = hs.timer.doEvery(1.12, function() self:showAppNoti() end)
end

return module