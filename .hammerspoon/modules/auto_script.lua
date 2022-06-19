---------- AutoClick ----------
enableAutoClick = false
-- Seconds to delay before next click. 0.001 works OK.
speedDelay = 0.05
myTimer = nil

function mouseClick()
    -- Run right mouseclick
    -- hs.eventtap.rightClick(hs.mouse.getAbsolutePosition())
    hs.eventtap.leftClick(hs.mouse.getAbsolutePosition())
end

function isAutoClickerEnabled()
    return enableAutoClick
end

function sleep(n)
    local t = os.clock()
    while os.clock() - t <= n do
      -- nothing
    end
end


hs.hotkey.bind({"ctrl", "shift", "cmd"}, "s", function() 
    -- Set continuous run to true
    if enableAutoClick then 
        enableAutoClick = false
        myTimer = nil
        hs.alert.show("Stop Auto Click!")
        hs.notify.new({title="[STOP] Auto clk", informativeText=""}):send()
    else 
        enableAutoClick = true
        myTimer = hs.timer.doWhile(isAutoClickerEnabled, mouseClick, speedDelay)  
        hs.alert.show("Start Auto Click!")
        hs.notify.new({title="[START] Auto clk", informativeText=""}):send()
    end

    -- enableAutoClick = true
    -- myTimer = hs.timer.doWhile(isAutoClickerEnabled, mouseClick, speedDelay)  
end)

--------------Auto forward ---------------------------------------------------
-- 
enableAutoKey = false
keySpeedDelay = 0.05
myKeyTimer = nil

function fowradKeyPush()
    hs.eventtap.event.newKeyEvent(no_mod, "up", true):post()
    -- hs.eventtap.event.newKeyEvent(no_mod, "space", true):post()
end

function isAutoKeyEnabled()
    return enableAutoKey
end

hs.hotkey.bind({"ctrl", "shift", "cmd"}, "w", function() 
    -- Set continuous run to true
    if not isAutoKeyEnabled() then
        enableAutoKey = true
        myKeyTimer = hs.timer.doWhile(isAutoKeyEnabled, fowradKeyPush, keySpeedDelay)  
        hs.alert.show("Start Auto Key - Forward!")
    else
        enableAutoKey = false
        myKeyTimer = nil
        hs.eventtap.event.newKeyEvent(no_mod, "up", false):post()
        hs.alert.show("Stop Auto Key - Forward!")
    end


    -- enableAutoKey = true
    -- myKeyTimer = hs.timer.doWhile(isAutoKeyEnabled, fowradKeyClick, keySpeedDelay)
end)


------
