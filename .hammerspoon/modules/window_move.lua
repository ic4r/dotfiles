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

hs.hotkey.bind(hotkey, 'm', max_win_toggle)
hs.hotkey.bind(hotkey, 'p', move_screen)
hs.hotkey.bind(hotkey, 'f', toggle_fullscreen)
hs.hotkey.bind(hotkey, 'left', move_win_to_left)
hs.hotkey.bind(hotkey, 'right', move_win_to_right)

-- ref: http://www.hammerspoon.org/docs/hs.window.html#screen