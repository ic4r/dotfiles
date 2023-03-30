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

    local log = hs.logger.new('[Win]','debug')
    log.i("screen.h:", screen.h, "frame.h:", frame.h, "screen.y:", screen.y, "frame.y:", frame.y)

    if frame.h >= screen.h then
        frame.h = screen.h / 2
    end

    win:setFrame(frame, 0)
end

local function expand_down()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local screen = win:screen():frame()

    local log = hs.logger.new('[Win]','debug')
    log.i("screen.h:", screen.h, "frame.h:", frame.h, "screen.y:", screen.y, "frame.y:", frame.y)

    if frame.h + 1 == screen.h then
        frame.h = screen.h / 2 + (screen.y - frame.y)
        frame.y = screen.h / 2
    else
        frame.h = screen.h
    end

    win:setFrame(frame, 0)
end

local function toggle_fullscreen()
    local win = hs.window.focusedWindow()
    win:toggleFullScreen()
end

local function move_screen()
    local app = hs.window.focusedWindow()
    app:moveToScreen(app:screen():next())
    -- app:maximize()
end

prevFrameSizes = {}
local function max_win_toggle()
    local curWin = hs.window.focusedWindow()
    local curWinFrame = curWin:frame()

    if prevFrameSizes[curWin:id()] then
        -- restore frame position and reset storage
        curWin:setFrame(prevFrameSizes[curWin:id()])
        prevFrameSizes[curWin:id()] = nil
    else
        -- store current frame position
        prevFrameSizes[curWin:id()] = hs.geometry.copy(curWinFrame)
        curWin:maximize()
    end
    
end

hotkey = {"ctrl", "cmd", "option"}
J_SIZE = 100

hs.hotkey.bind(hotkey, 'm', max_win_toggle)         -- toggle window max size
hs.hotkey.bind(hotkey, 'p', move_screen)            -- move to other screen (monitor)
hs.hotkey.bind(hotkey, 'f', toggle_fullscreen)      -- toggle full screen 
hs.hotkey.bind(hotkey, 'left', move_win_to_left)    -- move to left-side (half)
hs.hotkey.bind(hotkey, 'right', move_win_to_right)  -- move to right-side (half)
hs.hotkey.bind(hotkey, '=', size_plus)              -- window size up
hs.hotkey.bind(hotkey, '-', size_minus)             -- window size down
hs.hotkey.bind(hotkey, 'up', expand_up)             -- window size expand to top
hs.hotkey.bind(hotkey, 'down', expand_down)         -- window size expand to bottom


-- 윈도우 사이즈 조절 딜레이를 줄여준다. win:setFrame(f, 0)로 대체 가능
-- hs.window.animationDuration = 0

-- https://www.hammerspoon.org/go/ 여기 예제 많음
-- ref: http://www.hammerspoon.org/docs/hs.window.html#screen


local SkyRocket = hs.loadSpoon("SkyRocket")

sky = SkyRocket:new({
  -- Opacity of resize canvas
  opacity = 0.3,

  -- Which modifiers to hold to move a window?
  moveModifiers = {'cmd', 'ctrl'},

  -- Which mouse button to hold to move a window?
  moveMouseButton = 'left',

  -- Which modifiers to hold to resize a window?
  resizeModifiers = {'cmd', 'ctrl'},

  -- Which mouse button to hold to resize a window?
  resizeMouseButton = 'right',
})

