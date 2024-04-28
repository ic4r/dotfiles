
local This = {}

-- To easily layout windows on the screen, we use hs.grid to create a 4x4 grid.
-- If you want to use a more detailed grid, simply change its dimension here
local GRID_SIZE = 4
local HALF_GRID_SIZE = GRID_SIZE / 2
local JUMP_SIZE = 100

-- Set the grid size and add a few pixels of margin
-- Also, don't animate window changes... That's too slow
hs.grid.setGrid(GRID_SIZE .. 'x' .. GRID_SIZE)
hs.grid.setMargins({5, 5})
hs.window.animationDuration = 0

-- Defining screen positions
local screenPositions       = {}
screenPositions.left        = {x = 0,               y = 0,              w = HALF_GRID_SIZE,  h = GRID_SIZE     }
screenPositions.right       = {x = HALF_GRID_SIZE,  y = 0,              w = HALF_GRID_SIZE,  h = GRID_SIZE     }
screenPositions.top         = {x = 0,               y = 0,              w = GRID_SIZE,       h = HALF_GRID_SIZE}
screenPositions.bottom      = {x = 0,               y = HALF_GRID_SIZE, w = GRID_SIZE,       h = HALF_GRID_SIZE}
screenPositions.center      = {x = 0.5,             y = 0.2,            w = GRID_SIZE-1,     h = GRID_SIZE-0.5 }
 
screenPositions.topLeft     = {x = 0,               y = 0,              w = HALF_GRID_SIZE,  h = HALF_GRID_SIZE}
screenPositions.topRight    = {x = HALF_GRID_SIZE,  y = 0,              w = HALF_GRID_SIZE,  h = HALF_GRID_SIZE}
screenPositions.bottomLeft  = {x = 0,               y = HALF_GRID_SIZE, w = HALF_GRID_SIZE,  h = HALF_GRID_SIZE}
screenPositions.bottomRight = {x = HALF_GRID_SIZE,  y = HALF_GRID_SIZE, w = HALF_GRID_SIZE,  h = HALF_GRID_SIZE}

This.screenPositions = screenPositions


-- Saving the state of the window before activate function keys.works
origFrameSizes = {}
function setOrigFrame(curWinID, frame)
  if origFrameSizes[curWinID] == nil then
    origFrameSizes[curWinID] = hs.geometry.copy(frame)
  end
end

function This.revertOriginal()
  local curWin = hs.window.focusedWindow()

  if curWin then
    local frame = curWin:frame()

    if origFrameSizes[curWin:id()] then
      curWin:setFrame(origFrameSizes[curWin:id()], 0)

    else
      setOrigFrame(curWin:id(), frame)
    end
  end
end


-- This function will move either the specified or the focuesd
-- window to the requested screen position
function This.moveWindowToPosition(cell, window)
  prevFrameSizes3 = {}
  prevFrameSizes2 = {}

  if window == nil then
    window = hs.window.focusedWindow()
  end

  if window then
    setOrigFrame(window:id(), window:frame())
    local screen = window:screen()
    hs.grid.set(window, cell, screen)
  end
  printFrameAndScreen("좌우이동")
end

function printFrameAndScreen(log)
  local curWin = hs.window.focusedWindow()

  if curWin then
    local frame = curWin:frame()
    local screen = curWin:screen():frame()

    print(log .. "/Frame  - x: " .. frame.x .. ", y: " .. frame.y .. ", w: " .. frame.w .. ", h: " .. frame.h)
    print(log .. "/Screen - x: " .. screen.x .. ", y: " .. screen.y .. ", w: " .. screen.w .. ", h: " .. screen.h)
  end
end

-- This function will move either the specified or the focused
-- window to the center of the sreen and let it fill up the
-- entire screen.
prevFrameSizes = {}
function This.windowMaximize(factor, window)
   if window == nil then
    curWin = hs.window.focusedWindow()
   end
   if curWin then

      local curWinFrame = curWin:frame()
      -- window:maximize()
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
end



function This.moveLeft()
  local curWin = hs.window.focusedWindow()

  if curWin then
    local frame = curWin:frame()
    local screen = curWin:screen():frame()

    if frame.x - 5 == screen.x then
      frame.w = frame.w - JUMP_SIZE
      curWin:setFrame(frame, 0)
    else 
      This.moveWindowToPosition(screenPositions.left)
    end
  end
end

function This.moveRight()
  local curWin = hs.window.focusedWindow()

  if curWin then
    local frame = curWin:frame()
    local screen = curWin:screen():frame()

    if frame.x < screen.x + JUMP_SIZE then
      This.moveWindowToPosition(screenPositions.right)
    else
      frame.x = frame.x + JUMP_SIZE
      frame.w = frame.w - JUMP_SIZE
      curWin:setFrame(frame, 0)
    end
  end
end


function This.moveTop()
  local curWin = hs.window.focusedWindow()

  -- printFrameAndScreen("up")

  if curWin then
    local frame = curWin:frame()
    local screen = curWin:screen():frame()

    setOrigFrame(curWin:id(), frame)

    if frame.y == screen.y then
      frame.h = frame.h - JUMP_SIZE * 2
    else
      -- hs.alert.show("상단으로 키우기")
      frame.h = frame.h + (frame.y-screen.y)
      frame.y = screen.y
    end
    
    curWin:setFrame(frame, 0)

  end
end


function This.moveBottom()

  local curWin = hs.window.focusedWindow()

  -- printFrameAndScreen("down")

  if curWin then
    local frame = curWin:frame()
    local screen = curWin:screen():frame()

    setOrigFrame(curWin:id(), frame)

    -- 바닥에 닿지 않으면 h 를 바닥으로
    if frame.h + math.abs(screen.y - frame.y)  ~= screen.h then
      frame.h = screen.h
    else
      frame.y = frame.y + JUMP_SIZE * 2
      frame.h = frame.h - JUMP_SIZE * 2

    end
    curWin:setFrame(frame, 0)
  end
end


function This.size_plus()
  local win = hs.window.focusedWindow()

  if win:id() == 0 then
    return
  end

  local frame = win:frame()
  local screen = win:screen():frame()

  -- printFrameAndScreen("size_plus")

  -- 창의 왼쪽 넘김 방지
  if screen.x >= frame.x then
    frame.x = screen.x
  end  

  -- x 좌표가 화면 왼쪽에 가까우면 오른쪽으로 늘려준다. 
  if frame.x < screen.x + JUMP_SIZE then
      frame.w = frame.w + JUMP_SIZE
  else
      frame.x = frame.x - JUMP_SIZE
      frame.w = frame.w + JUMP_SIZE
  end

  if frame.w > screen.w then
      frame.w = screen.w
  end

  win:setFrame(frame, 0)
end

function This.size_minus()
  local win = hs.window.focusedWindow()

  if win:id() == 0 then
    return
  end

  local frame = win:frame()
  local screen = win:screen():frame()

  -- printFrameAndScreen("size_minus")

  if frame.x < screen.x + JUMP_SIZE then
      frame.w = frame.w - JUMP_SIZE
  else
      frame.x = frame.x + JUMP_SIZE
      frame.w = frame.w - JUMP_SIZE
  end

  win:setFrame(frame, 0)
end


function This.move_next_screen()
  local app = hs.window.focusedWindow()

  app:moveToScreen(app:screen():next())
  app:maximize()
end

function This.move_previous_screen()
  local app = hs.window.focusedWindow()

  app:moveToScreen(app:screen():previous())
  app:maximize()
end

function This.full_screen()
  local curWin = hs.window.focusedWindow()

  hs.alert.show("Full Screen Toggle")

  -- https://github.com/tstirrat/hammerspoon-config/blob/master/modules/fullscreen.lua
  if curWin ~= nil then
      curWin:setFullScreen(not curWin:isFullScreen())
  end
end

return This
