
--[[
	* 공식 Doc: https://www.hammerspoon.org/docs/index.html
	* Getting start: http://www.hammerspoon.org/go/
	* Lua script 문법: https://learnxinyminutes.com/docs/lua/

--]]

require('modules.inputsource_aurora') --01.오로라 인풋 소스: 한글일 때 상단바 녹색으로 표시
--02.Make the alerts look nicer. -> setting
--03.Lock the screen -> {"cmd", "option", "ctrl"}, "l"
--04. 한글 입력 전환하기 -> {'shift'}, 'space'

require('modules.auto_script') --autoclick, autokey

require('modules.window_move') -- windows control 

-------------------------------------------------------------------------------
hyper = {"ctrl", "shift", "cmd"}

-- Make the alerts look nicer.
hs.alert.defaultStyle.fillColor =  {white = 0.05, alpha = 0.75}
hs.alert.defaultStyle.strokeColor =  {white = 1, alpha = 0}
hs.alert.defaultStyle.strokeWidth = 5
hs.alert.defaultStyle.radius = 10
hs.alert.defaultStyle.textColor = {white = 10, alpha = 10}


hs.hotkey.bind(hyper, 'r', hs.reload) --keymap:Reload Hammerspoon

--테스트 TEST
function hello ()
	-- body
	hs.alert.show("Hello, world!")
	hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end


hs.hotkey.bind({'shift', 'option'}, 'c', function() --keymap: Launch Chrome
	hs.application.launchOrFocus("Google Chrome")
end)

-- 문자 붙여넣기
-- hs.hotkey.bind(hyper, 'p', function() --keymap: Launch Chrome
-- 	hs.eventtap.keyStrokes("abcd") 
-- end)

-------------------------------------------------------------------------------
--03. Lock the screen. This may also be possible with hs.caffeinate.lockScreen.
hs.hotkey.bind({"cmd", "option", "ctrl"}, "l", function()
    os.execute("pmset displaysleepnow")
end)

-------------------------------------------------------------------------------
--04. 한글 입력 전환하기 ->{'shift'}, 'space', changeInput
do  -- input sorce changer
    local inputSource = {
        english = "com.apple.keylayout.ABC",
        korean = "com.apple.inputmethod.Korean.2SetKorean",
    }

    local changeInput = function()

        local current = hs.keycodes.currentSourceID()
        local nextInput = nil

        if current == inputSource.english then
            nextInput = inputSource.korean
        else
            nextInput = inputSource.english
        end
        hs.keycodes.currentSourceID(nextInput)

        if nextInput == inputSource.english then
        	hs.alert.show("English")
        else
        	hs.alert.show(" 한글")
        end
    end

    -- hs.hotkey.bind({'shift'}, 'space', changeInput)
    hs.hotkey.bind({}, 'F16', changeInput)
end

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


-- Start Macros
hello()
