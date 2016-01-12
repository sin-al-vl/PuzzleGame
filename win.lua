-----------------------------------------------------------------------------------------
--
-- win.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local widget = require "widget"

--------------------------------------------

local restartBtn, menuBtn

local screenW, screenH = display.contentWidth, display.contentHeight

local function onRestartBtnRelease()
	
	composer.gotoScene( "level1", "crossFade", 600 )
	
	return true	
end

local function onNextLvlBtnRelease()
	
	composer.setVariable("lvl", "lvl2")
	composer.gotoScene( "level1", "crossFade", 600 )
	
	return true	
end

local function onMenuBtnRelease( lvl )
	
	composer.setVariable("lvl", lvl)
	composer.gotoScene( "menu", "crossFade", 600 )
	
	return true
end

local function initializeBG(  )
	local background = display.newImageRect( "puzzle.jpg", screenW, screenH)
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	return background
end

local function initializeBackTitle()
	local backTitle = display.newRect(screenW*0.5, screenH*0.3, screenW*0.75, screenH*0.5)
	backTitle:setFillColor(1, 1, 1)

	return backTitle
end

local function initializeTitleLogo()
	local titleLogo = display.newText("Time:", screenW*0.5, screenH*0.15, native.systemFont, math.round(screenW/16))
	titleLogo.width = screenW*0.75
	titleLogo.height = screenH*0.25
	titleLogo:setFillColor( 0, 0, 1 )

	return titleLogo
end

local function initializeTime(min, sec)
	local str
	if min > 0 and min < 10 then
		str = "0"..min
	else
		str = "00"
	end

	if sec < 10 then
		str = str..":0"..sec
	else
		str = str..":"..sec
	end

	local time = display.newText(str , screenW*0.5, screenH*0.35, native.systemFont, math.round(screenW/16)*2)
	time.width = screenW*0.75
	time.height = screenH*0.25
	time:setFillColor( 0, 0, 1 )

	return time
end

local function initializeRestartBtn()
	restartBtn = widget.newButton{
		label="Restart",
		fontSize=math.round(screenW/16),
		labelColor = { default={255}, over={128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=screenW*0.33, height=screenH*0.25,
		onRelease = onRestartBtnRelease
	}
	restartBtn.x = screenW*0.5 - restartBtn.width
	restartBtn.y = screenH*0.7
end

local function initializeNextLvlBtn()
	nextLvlBtn = widget.newButton{
		label="Next level",
		fontSize=math.round(screenW/16),
		labelColor = { default={255}, over={128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=screenW*0.33, height=screenH*0.25,
		onRelease = onNextLvlBtnRelease
	}
	nextLvlBtn.x = screenW*0.5 
	nextLvlBtn.y = screenH*0.7
end

local function initializeMenuBtn( )
	menuBtn = widget.newButton{
		label="Menu",
		fontSize=math.round(screenW/16),
		labelColor = { default={255}, over={128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=screenW*0.33, height=screenH*0.25,
		onRelease = onMenuBtnRelease
	}
	menuBtn.x = screenW*0.5 + menuBtn.width
	menuBtn.y = screenH*0.7
	
end

function scene:create( event )
	local sceneGroup = self.view
	composer:removeHidden()

	local dt = os.time() - event.params
	local min, sec = 0, dt%60
	if(dt >= 60)then
		min = math.round(dt/60)
	end

	local background = initializeBG()
	local backTitle = initializeBackTitle()
	local titleLogo = initializeTitleLogo()
	local time = initializeTime(min, sec)

	initializeRestartBtn()
	initializeNextLvlBtn()
	initializeMenuBtn()

	sceneGroup:insert( background )
	sceneGroup:insert( backTitle )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( time )
	sceneGroup:insert( restartBtn )
	sceneGroup:insert( nextLvlBtn )
	sceneGroup:insert( menuBtn )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	if restartBtn then
		restartBtn:removeSelf()	
		restartBtn = nil
	end

	if menuBtn then
		menuBtn:removeSelf()	
		menuBtn = nil
	end

	if nextLvlBtn then
		nextLvlBtn:removeSelf()	
		nextLvlBtn = nil
	end
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene