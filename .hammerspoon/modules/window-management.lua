
local This = {}

-- To easily layout windows on the screen, we use hs.grid to create a 4x4 grid.
-- If you want to use a more detailed grid, simply change its dimension here
local GRID_SIZE = 4
local HALF_GRID_SIZE = GRID_SIZE / 2

-- Set the grid size and add a few pixels of margin
-- Also, don't animate window changes... That's too slow
hs.grid.setGrid(GRID_SIZE .. 'x' .. GRID_SIZE)
hs.grid.setMargins({5, 5})
hs.window.animationDuration = 0

-- Defining screen positions
local screenPositions       = {}
screenPositions.left        = {x = 0,              y = 0,              w = HALF_GRID_SIZE, h = GRID_SIZE     }
screenPositions.right       = {x = HALF_GRID_SIZE, y = 0,              w = HALF_GRID_SIZE, h = GRID_SIZE     }
screenPositions.top         = {x = 0,              y = 0,              w = GRID_SIZE,      h = HALF_GRID_SIZE}
screenPositions.bottom      = {x = 0,              y = HALF_GRID_SIZE, w = GRID_SIZE,      h = HALF_GRID_SIZE}

screenPositions.topLeft     = {x = 0,              y = 0,              w = HALF_GRID_SIZE, h = HALF_GRID_SIZE}
screenPositions.topRight    = {x = HALF_GRID_SIZE, y = 0,              w = HALF_GRID_SIZE, h = HALF_GRID_SIZE}
screenPositions.bottomLeft  = {x = 0,              y = HALF_GRID_SIZE, w = HALF_GRID_SIZE, h = HALF_GRID_SIZE}
screenPositions.bottomRight = {x = HALF_GRID_SIZE, y = HALF_GRID_SIZE, w = HALF_GRID_SIZE, h = HALF_GRID_SIZE}

This.screenPositions = screenPositions

-- This function will move either the specified or the focuesd
-- window to the requested screen position
function This.moveWindowToPosition(cell, window)
  if window == nil then
    window = hs.window.focusedWindow()
  end
  if window then
    local screen = window:screen()
    hs.grid.set(window, cell, screen)
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

prevFrameSizes2 = {}
function This.heght_max()

  local curWin = hs.window.focusedWindow()

  if curWin then
    local frame = curWin:frame()
    local screen = curWin:screen():frame()

    if prevFrameSizes2[curWin:id()] then

      curWin:setFrame(prevFrameSizes2[curWin:id()])
      prevFrameSizes2[curWin:id()] = nil
    else

      prevFrameSizes2[curWin:id()] = hs.geometry.copy(frame)
      frame.y = 0
      frame.h = screen.h

      curWin:setFrame(frame, 0)

    end
  end

end

function This.heght_top()

  local curWin = hs.window.focusedWindow()

  if curWin then
    local frame = curWin:frame()
    local screen = curWin:screen():frame()

    if prevFrameSizes3[curWin:id()] then
      hs.alert.show("위 풀")
      -- curWin:setFrame(prevFrameSizes3[curWin:id()])
      prevFrameSizes3[curWin:id()] = nil
      frame.y = 0
      frame.h = screen.h

    else
      hs.alert.show("위 반쪽")
      prevFrameSizes3[curWin:id()] = hs.geometry.copy(frame)
      frame.y = 0
      frame.h = screen.h/2

    end

    curWin:setFrame(frame, 0)
  end

end

prevFrameSizes3 = {}
function This.heght_bottom()

  local curWin = hs.window.focusedWindow()

  if curWin then
    local frame = curWin:frame()
    local screen = curWin:screen():frame()

    if prevFrameSizes3[curWin:id()] then
      hs.alert.show("아래 풀")
      -- curWin:setFrame(prevFrameSizes3[curWin:id()])
      prevFrameSizes3[curWin:id()] = nil
      frame.y = 0
      frame.h = screen.h

    else
      hs.alert.show("아래 반쪽")
      prevFrameSizes3[curWin:id()] = hs.geometry.copy(frame)
      frame.y = screen.h/2
      frame.h = screen.h/2

    end

    curWin:setFrame(frame, 0)
  end

end


function This.size_plus(JUMP_SIZE)
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local screen = win:screen():frame()

  if frame.x < 0 then
      frame.x = screen.x
  end    

  if screen.x == frame.x then
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

function This.size_minus(JUMP_SIZE)
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local screen = win:screen():frame()

  if screen.x == frame.x then
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
