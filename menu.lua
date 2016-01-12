-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local widget = require "widget"

--------------------------------------------

local playBtn

local function onPlayBtnRelease()
	
	composer.gotoScene( "level1", "crossFade", 600 )
	
	return true
end

function initializeBG( )
	local background = display.newImageRect( "puzzle.jpg", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	return background
end

function initializeTitleLogo( )
	local titleLogo = display.newImage( "logo.png" )
	titleLogo.width = display.contentWidth*0.75
	titleLogo.height = display.contentHeight*0.25
	titleLogo.x = display.contentWidth*0.5
	titleLogo.y = display.contentHeight*0.2

	return titleLogo
end

function initializePlayBtn( )
	playBtn = widget.newButton{
		label="Play Now",
		fontSize=math.round(display.contentWidth/16),
		labelColor = { default={255}, over={128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=display.contentWidth*0.5, height=display.contentHeight*0.25,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentWidth*0.5
	playBtn.y = display.contentHeight*0.75
end

function scene:create( event )
	local sceneGroup = self.view
	composer:removeHidden()
	composer.setVariable("lvl", "lvl1")

	local background = initializeBG()
	local titleLogo = initializeTitleLogo()
	
	initializePlayBtn()
	
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
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
	
	if playBtn then
		playBtn:removeSelf()	
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene