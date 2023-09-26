-- 윈도우 사이즈 조절 딜레이를 줄여준다. win:setFrame(f, 0)로 대체 가능
-- hs.window.animationDuration = 0
-- ref: http://www.hammerspoon.org/docs/hs.window.html#screen


hotkey = {"ctrl", "cmd", "option"}
J_SIZE = 100

hs.hotkey.bind(hotkey, 'm', max_win_toggle)         -- toggle window max size
hs.hotkey.bind(hotkey, 'f', fullscreen_toggle)      -- toggle full screen 

hs.hotkey.bind(hotkey, 'p', move_screen)            -- move to other screen (monitor)

hs.hotkey.bind(hotkey, 'left', move_win_to_left)    -- move to left-side (half)
hs.hotkey.bind(hotkey, 'right', move_win_to_right)  -- move to right-side (half)
hs.hotkey.bind(hotkey, '=', size_plus)              -- window size up
hs.hotkey.bind(hotkey, '-', size_minus)             -- window size down
hs.hotkey.bind(hotkey, 'up', expand_up)             -- window size expand to top
hs.hotkey.bind(hotkey, 'down', expand_down)         -- window size expand to bottom



local function move_win_to_left()
    local win = hs.window.focusedWindow()   -- 현재 활성화된 앱의 윈도우
    local frame = win:frame()
    local screen = win:screen():frame()     -- 현재 화면
    frame.x = screen.x
    frame.y = screen.y
    frame.w = screen.w / 2      -- width를 화면의 1/2 로 조정
    frame.h = screen.h
    win:setFrame(frame)
end

local function move_win_to_right()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local screen = win:screen():frame()
    frame.x = screen.x + (screen.w / 2) -- 윈도우의 x 좌표를 화면 width의 1/2 로 조정
    frame.y = screen.y
    frame.w = screen.w / 2      -- width를 화면의 1/2 로 조정
    frame.h = screen.h
    win:setFrame(frame)
end

local function size_plus()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local screen = win:screen():frame()

    if frame.x < 0 then
        frame.x = screen.x
    end    

    if screen.x == frame.x then
        frame.w = frame.w + J_SIZE
    else
        frame.x = frame.x - J_SIZE
        frame.w = frame.w + J_SIZE
    end

    if frame.w > screen.w then
        frame.w = screen.w
    end

    win:setFrame(frame, 0)
end

local function size_minus()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local screen = win:screen():frame()

    if screen.x == frame.x then
        frame.w = frame.w - J_SIZE
    else
        frame.x = frame.x + J_SIZE
        frame.w = frame.w - J_SIZE
    end

    win:setFrame(frame, 0)
end

local function expand_up()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local screen = win:screen():frame()

    frame.h = frame.y + frame.h
    frame.y = 0

    local log = hs.logger.new('[Win][Up]','debug')
    log.i("screen.h:", screen.h, "frame.h:", frame.h, "screen.y:", screen.y, "frame.y:", frame.y)

    if frame.h >= screen.h then
        frame.h = screen.h / 2
    end

    log.i("screen.h:", screen.h, "frame.h:", frame.h, "screen.y:", screen.y, "frame.y:", frame.y)

    win:setFrame(frame, 0.5) -- frame, delay
end

local function expand_down()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local screen = win:screen():frame()

    local log = hs.logger.new('[Win][Down]','debug')

    log.i("-------------------------------------------------------")
    -- log.i("[frame]:",frame)
    log.i("[frame] ", "frame.x:", frame.x, "frame.y:", frame.y, "frame.w:", frame.w , "frame.h:", frame.h, "->", frame)
    -- log.i("[screen]:", screen)
    log.i("[screen] ", "screen.x:", screen.x, "screen.y:", screen.y, "screen.w:", screen.w, "screen.h:", screen.h, "->", screen)

    -- if frame.h + 1 == screen.h then
    --     log.i("1")
    --     frame.h = screen.h / 2 + (screen.y - frame.y)
    --     frame.y = screen.h / 2
    -- else
    --     log.i("2")
    --     frame.h = screen.h
    -- end

    -- log.i("screen.h:", screen.h, "frame.h:", frame.h, "screen.y:", screen.y, "frame.y:", frame.y)
    
    frame.x = screen.x
    frame.y = screen.y / 2
    frame.h = screen.w / 2
    frame.w = screen.h

    log.i("-------------------------------------------------------")
    -- log.i("[frame]:",frame)
    log.i("[frame] ", "frame.x:", frame.x, "frame.y:", frame.y, "frame.w:", frame.w , "frame.h:", frame.h, "->", frame)
    -- log.i("[screen]:", screen)
    log.i("[screen] ", "screen.x:", screen.x, "screen.y:", screen.y, "screen.w:", screen.w, "screen.h:", screen.h, "->", screen)

    win:setFrame(frame, 0.5)

    log.i("-------------------------------------------------------")
    -- log.i("[frame]:",frame)
    log.i("[frame] ", "frame.x:", frame.x, "frame.y:", frame.y, "frame.w:", frame.w , "frame.h:", frame.h, "->", frame)
    -- log.i("[screen]:", screen)
    log.i("[screen] ", "screen.x:", screen.x, "screen.y:", screen.y, "screen.w:", screen.w, "screen.h:", screen.h, "->", screen)
end



local function move_screen()
    local app = hs.window.focusedWindow()

    app:moveToScreen(app:screen():previous())
    app:maximize()
end

prevFrameSizes = {}
local function max_win_toggle()
    

    local curWin = hs.window.focusedWindow()
    local curWinFrame = curWin:frame()

    if prevFrameSizes[curWin:id()] then
        -- restore frame position and reset storage
        hs.alert.show("Previous Size Window")
        curWin:setFrame(prevFrameSizes[curWin:id()])
        prevFrameSizes[curWin:id()] = nil
    else
        -- store current frame position
        hs.alert.show("Maximize Window")
        prevFrameSizes[curWin:id()] = hs.geometry.copy(curWinFrame)
        curWin:maximize()
    end
end

local function fullscreen_toggle()
    local curWin = hs.window.focusedWindow()

    hs.alert.show("Full Screen Toggle")

    -- https://github.com/tstirrat/hammerspoon-config/blob/master/modules/fullscreen.lua
    if curWin ~= nil then
        curWin:setFullScreen(not curWin:isFullScreen())
    end
end

