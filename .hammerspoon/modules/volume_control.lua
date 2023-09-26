-------------------------------------------------------------------------------
-- Volume Control
-------------------------------------------------------------------------------

local function sendSystemKey(key)
    hs.eventtap.event.newSystemKeyEvent(key, true):post()
    hs.eventtap.event.newSystemKeyEvent(key, false):post()
end

local volume = {
    up   = function() sendSystemKey("SOUND_UP") end,
    down = function() sendSystemKey("SOUND_DOWN") end,
    mute = function() sendSystemKey("MUTE") end,
    play = function() sendSystemKey("PLAY") end,
    next = function() sendSystemKey("NEXT") end,
    previous = function() sendSystemKey("PREVIOUS") end,
}

hs.hotkey.bind({"ctrl"}, "f7", volume.previous)    
hs.hotkey.bind({"ctrl"}, "f8", volume.next)    
hs.hotkey.bind({"ctrl"}, "f9", volume.play)                     -- play & pause
hs.hotkey.bind({"ctrl"}, "f10", volume.mute)                    -- mute
hs.hotkey.bind({"ctrl"}, "f11", volume.down, nil, volume.down)  -- volume down
hs.hotkey.bind({"ctrl"}, "f12", volume.up, nil, volume.up)      -- volume up

-- END of Volume Control