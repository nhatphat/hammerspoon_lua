local module = {}

function module:yaak()
    local yaak_folder = "/Users/teq-macm1mobile-4/Documents/personal/yaak"

    module.tm = hs.timer.doEvery(1209, function()
        hs.execute("cd " .. yaak_folder .. " && git push")
    end)

    -- module.yaak = hs.pathwatcher.new(yaak_folder, function(files, flagTables)
    --     for i, file in ipairs(files) do
    --         local flags = flagTables[i]
    --         -- print(hs.inspect(flags))
    --         print("File changed: " .. file)
    --     end
    -- end)

    -- module.yaak:start()
end

return module