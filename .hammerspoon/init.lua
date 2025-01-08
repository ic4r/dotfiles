
--[[
	* 공식 Doc: https://www.hammerspoon.org/docs/index.html
	* Getting start: http://www.hammerspoon.org/go/
	* Lua script 문법: https://learnxinyminutes.com/docs/lua/

    -- https://www.hammerspoon.org/go/ 예제를 참고하자.
--]]

-----------------------------------------------------------------------------
-- Default 
-----------------------------------------------------------------------------
local hyper = {'cmd', 'shift', 'ctrl'}
local hyper2 = {'cmd', 'alt', 'ctrl'}

-- Make the alerts look nicer.
hs.alert.defaultStyle.fillColor =  {white = 0.05, alpha = 0.75}
hs.alert.defaultStyle.strokeColor =  {white = 1, alpha = 0}
hs.alert.defaultStyle.strokeWidth = 5
hs.alert.defaultStyle.radius = 10
hs.alert.defaultStyle.textColor = {white = 10, alpha = 10}

-----------------------------------------------------------------------------
-- Custom Modules
-----------------------------------------------------------------------------
--01.오로라 인풋 소스: 한글일 때 상단바 녹색으로 표시
--02.Make the alerts look nicer. -> setting
--03.Lock the screen -> {"cmd", "option", "ctrl"}, "l"
--04. 한글 입력 전환하기 -> {'shift'}, 'space'

-- require('modules.inputsource_aurora') -- 오로라 인풋 소스: 한글일 때 상단바 녹색으로 표시
require('modules.auto_script')        -- autoclick, autokey
require('modules.volume_control')     -- volume Control




--테스트 TEST
function hello ()
	-- body
	hs.alert.show("🔨🥄✅✅✅✅✅✅")
	hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end

-- 프로그램 실행
-- hs.hotkey.bind({'shift', 'option'}, 'c', function() --keymap: Launch Chrome
-- 	hs.application.launchOrFocus("Google Chrome")
-- end)

-- 문자 붙여넣기
-- hs.hotkey.bind(hyper, 'p', function() --keymap: Launch Chrome
-- 	hs.eventtap.keyStrokes("abcd") 
-- end)


-----------------------------------------------------------------------------
--04. 한글 입력 전환하기 ->{'shift'}, 'space', changeInput
-- do  -- input sorce changer
--     local inputSource = {
--         english = "com.apple.keylayout.ABC",
--         korean = "com.apple.inputmethod.Korean.2SetKorean",
--     }

--     local changeInput = function()

--         local current = hs.keycodes.currentSourceID()
--         local nextInput = nil

--         if current == inputSource.english then
--             nextInput = inputSource.korean
--         else
--             nextInput = inputSource.english
--         end
--         hs.keycodes.currentSourceID(nextInput)

--         if nextInput == inputSource.english then
--         	hs.alert.show("English")
--         else
--         	hs.alert.show("한글")
--         end
--     end

--     -- hs.hotkey.bind({'shift'}, 'space', changeInput)
--     hs.hotkey.bind({}, 'F16', changeInput)
-- end


-- f13 key를 escape로 매핑 
-- local caps_mode = hs.hotkey.modal.new()
-- local inputEnglish = "com.apple.keylayout.ABC"

-- local on_caps_mode = function()
--     caps_mode:enter()
-- end

-- local off_caps_mode = function()

--     caps_mode:exit()

--     local input_source = hs.keycodes.currentSourceID()

--     if not (input_source == inputEnglish) then
--         hs.keycodes.currentSourceID(inputEnglish)
--     end
--     hs.eventtap.keyStroke({}, 'escape')
-- end

-- hs.hotkey.bind({}, 'f13', on_caps_mode, off_caps_mode)


-- 한글잘림 해결
-- local input_source = hs.keycodes.currentSourceID()

-- if not (input_source == inputEnglish) then
--     hs.eventtap.keyStroke({}, 'right')
--     hs.keycodes.currentSourceID(inputEnglish)
--     hs.eventtap.keyStroke({}, 'escape')
-- end


------


-----------------------------------------------------------------------------
-- SkyRocket: cmd+ctrl+마우스왼클릭으로 
-----------------------------------------------------------------------------
local SkyRocket = hs.loadSpoon("SkyRocket")

sky = SkyRocket:new({
  -- Opacity of resize canvas
  opacity = 0.3,

  -- Which modifiers to hold to move a window?
  moveModifiers = {'cmd', 'ctrl'},

  -- Which mouse button to hold to move a window?
  moveMouseButton = 'left',

  -- Which modifiers to hold to resize a window?
  resizeModifiers = {'cmd', 'alt'},

  -- Which mouse button to hold to resize a window?
  resizeMouseButton = 'left',
})


-----------------------------------------------------------------------------
-- HyperKey (https://github.com/dbalatero/HyperKey.spoon)
-----------------------------------------------------------------------------
-- local hyper = {'cmd', 'shift', 'ctrl', 'alt'}

-- Load and create a new switcher
local HyperKey = hs.loadSpoon("HyperKey")
hyperKey = HyperKey:new(hyper)

-- Bind some applications to keys
hyperKey
  :bind('c'):toApplication('/Applications/Google Chrome.app')
  :bind('s'):toApplication('/Applications/Safari.app')
  :bind('t'):toApplication('/Applications/Alacritty.app')

-- Bind some functions to keys
local reloadHammerspoon = function()
  hs.application.launchOrFocus("Hammerspoon")
  hs.reload()
end

hyperKey
  :bind('r'):toFunction("Reload Hammerspoon", reloadHammerspoon)
  :bind('l'):toFunction("Lock screen", hs.caffeinate.startScreensaver)

-----------------------------------------------------------------------------
-- Window Management
---- require('modules.window_move')        -- windows control 창이동 컨트롤 // 미사용
-----------------------------------------------------------------------------
--
-- #### rectangle 로 대체 ####
--
-- local wm = require('modules/window-management')

-- hs.hotkey.bind(hyper2, "m", function()	wm.windowMaximize(0) end)
-- hs.hotkey.bind(hyper2, "f", function() wm.full_screen() end)

-- hs.hotkey.bind(hyper2, "left",  function() wm.moveLeft() end)
-- hs.hotkey.bind(hyper2, "right", function() wm.moveRight() end)
-- hs.hotkey.bind(hyper2, "up",    function() wm.moveTop() end)
-- hs.hotkey.bind(hyper2, "down",  function() wm.moveBottom() end)

-- hs.hotkey.bind(hyper2, "]", function() hs.window.focusedWindow():moveOneScreenEast() end)
-- hs.hotkey.bind(hyper2, "[", function() hs.window.focusedWindow():moveOneScreenWest() end)
-- -- hs.hotkey.bind(hyper2, "n", function() wm.move_next_screen() end)
-- hs.hotkey.bind(hyper2, "p", function() wm.move_previous_screen() end)

-- hs.hotkey.bind(hyper2, "1", function() wm.moveWindowToPosition(wm.screenPositions.topLeft) end)
-- hs.hotkey.bind(hyper2, "2", function() wm.moveWindowToPosition(wm.screenPositions.topRight) end)
-- hs.hotkey.bind(hyper2, "3", function() wm.moveWindowToPosition(wm.screenPositions.bottomLeft) end)
-- hs.hotkey.bind(hyper2, "4", function() wm.moveWindowToPosition(wm.screenPositions.bottomRight) end)
-- hs.hotkey.bind(hyper2, "5", function() wm.moveWindowToPosition(wm.screenPositions.center) end)

-- hs.hotkey.bind(hyper2, "=", function() wm.size_plus() end)
-- hs.hotkey.bind(hyper2, "-", function() wm.size_minus() end)

-- -- Revert to the original state
-- hs.hotkey.bind(hyper2, "0", function() wm.revertOriginal() end)
-----------------------------------------------------------------------------

--03. Lock the screen. This may also be possible with hs.caffeinate.lockScreen.
hs.hotkey.bind(hyper2, "l", function()
  os.execute("pmset displaysleepnow")
end)

-- Start Macros
hello()
