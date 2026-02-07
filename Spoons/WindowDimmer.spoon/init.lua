-- WindowDimmer.spoon
-- Dims all inactive windows by placing a semi-transparent canvas below the active window
-- Similar to HazeOver functionality

local cache  = {}
local module = { cache = cache }

-- Configuration
local CONFIG = {
  opacity = 0.5,                    -- Dimming opacity (0.0 - 0.9)
  color = { red = 0, green = 0, blue = 0 },  -- Dimming color (black)
  enabled = false,                  -- Is dimming currently active
}

-- Create a dimming canvas for a specific screen
local createCanvas = function(screen)
  -- Use fullFrame() instead of frame() to cover the entire screen including menubar
  local frame = screen:fullFrame()
  
  local canvas = hs.canvas.new(frame)
    :level(hs.canvas.windowLevels.normal)
    :behavior({
      hs.canvas.windowBehaviors.transient,
      hs.canvas.windowBehaviors.moveToActiveSpace,
      hs.canvas.windowBehaviors.ignoresCycle,
    })
    :alpha(1.0)
    :clickActivating(false)  -- Allow clicks to pass through
  
  -- Add the dimming rectangle
  canvas[1] = {
    type = 'rectangle',
    action = 'fill',
    fillColor = {
      red = CONFIG.color.red,
      green = CONFIG.color.green,
      blue = CONFIG.color.blue,
      alpha = CONFIG.opacity
    },
    frame = { x = 0, y = 0, w = frame.w, h = frame.h }
  }
  
  return canvas
end

-- Update canvas positions and levels to sit below the active window
local updateCanvases = function()
  if not CONFIG.enabled or not cache.canvases then
    return
  end
  
  local activeWindow = hs.window.focusedWindow()
  
  -- Check if active window is fullscreen
  local isFullscreen = false
  if activeWindow then
    isFullscreen = activeWindow:isFullScreen()
  end
  
  -- Get all screens and update canvases
  local screens = hs.screen.allScreens()
  
  for _, screen in ipairs(screens) do
    local screenId = screen:id()
    local canvas = cache.canvases[screenId]
    
    if canvas then
      -- Update canvas frame in case screen resolution changed
      -- Use fullFrame() to cover entire screen including menubar
      local frame = screen:fullFrame()
      canvas:frame(frame)
      canvas[1].frame = { x = 0, y = 0, w = frame.w, h = frame.h }
      
      -- Hide canvas if active window is fullscreen on this screen
      if isFullscreen and activeWindow:screen():id() == screenId then
        canvas:hide()
      else
        canvas:show()
      end
    end
  end
end

-- Create canvases for all screens
local createAllCanvases = function()
  if cache.canvases then
    -- Clean up existing canvases
    for _, canvas in pairs(cache.canvases) do
      canvas:delete()
    end
  end
  
  cache.canvases = {}
  
  local screens = hs.screen.allScreens()
  for _, screen in ipairs(screens) do
    local screenId = screen:id()
    cache.canvases[screenId] = createCanvas(screen)
  end
  
  updateCanvases()
end

-- Hide all canvases
local hideCanvases = function()
  if not cache.canvases then
    return
  end
  
  for _, canvas in pairs(cache.canvases) do
    canvas:hide()
  end
end

-- Show all canvases
local showCanvases = function()
  if not cache.canvases then
    return
  end
  
  for _, canvas in pairs(cache.canvases) do
    canvas:show()
  end
  
  updateCanvases()
end

-- Start the window dimmer
module.start = function()
  if CONFIG.enabled then
    return
  end
  
  CONFIG.enabled = true
  
  -- Create canvases for all screens
  createAllCanvases()
  
  -- Watch for window focus changes
  if not cache.windowFilter then
    cache.windowFilter = hs.window.filter.new()
    cache.windowFilter:subscribe(hs.window.filter.windowFocused, function()
      updateCanvases()
    end)
    cache.windowFilter:subscribe(hs.window.filter.windowUnfocused, function()
      updateCanvases()
    end)
  end
  
  -- Watch for screen changes
  if not cache.screenWatcher then
    cache.screenWatcher = hs.screen.watcher.new(function()
      createAllCanvases()
    end)
    cache.screenWatcher:start()
  end
  
  -- Watch for space changes (virtual desktops)
  if not cache.spaceWatcher then
    cache.spaceWatcher = hs.spaces.watcher.new(function()
      updateCanvases()
    end)
    cache.spaceWatcher:start()
  end
  
  print("WindowDimmer: Started")
end

-- Stop the window dimmer
module.stop = function()
  if not CONFIG.enabled then
    return
  end
  
  CONFIG.enabled = false
  
  -- Hide and clean up canvases
  if cache.canvases then
    for _, canvas in pairs(cache.canvases) do
      canvas:delete()
    end
    cache.canvases = nil
  end
  
  -- Stop watchers
  if cache.windowFilter then
    cache.windowFilter:unsubscribeAll()
    cache.windowFilter = nil
  end
  
  if cache.screenWatcher then
    cache.screenWatcher:stop()
    cache.screenWatcher = nil
  end
  
  if cache.spaceWatcher then
    cache.spaceWatcher:stop()
    cache.spaceWatcher = nil
  end
  
  print("WindowDimmer: Stopped")
end

-- Toggle dimming on/off
module.toggle = function()
  if CONFIG.enabled then
    module.stop()
  else
    module.start()
  end
end

-- Set opacity (0.0 - 0.9)
module.setOpacity = function(opacity)
  CONFIG.opacity = math.max(0.0, math.min(0.9, opacity))
  
  if cache.canvases then
    for _, canvas in pairs(cache.canvases) do
      canvas[1].fillColor.alpha = CONFIG.opacity
    end
  end
  
  print(string.format("WindowDimmer: Opacity set to %.1f", CONFIG.opacity))
end

-- Increase opacity
module.increaseOpacity = function()
  module.setOpacity(CONFIG.opacity + 0.1)
end

-- Decrease opacity
module.decreaseOpacity = function()
  module.setOpacity(CONFIG.opacity - 0.1)
end

-- Get current state
module.isEnabled = function()
  return CONFIG.enabled
end

-- =================
--   default usage
-- =================
function module:defaultUsage(config)
  -- Set up hotkey binding for toggle (Hyper+D)
  config.hyper:bind({}, 'D', function()
    self.toggle()
  end)
  
  -- Optional: Hyper+D with modifiers for opacity control
  config.hyper:bind({'shift'}, 'D', function()
    self.increaseOpacity()
  end)
  
  config.hyper:bind({'alt'}, 'D', function()
    self.decreaseOpacity()
  end)
  
  -- Auto-start dimming
  self.start()
  
  print("WindowDimmer: Initialized (Hyper+D to toggle, Hyper+Shift+D to increase opacity, Hyper+Alt+D to decrease)")
end

return module
