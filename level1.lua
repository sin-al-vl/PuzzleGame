-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

--------------------------------------------

local screenW, screenH = display.contentWidth, display.contentHeight
local indW, indH = screenW/1280, screenH/720

local rightPuzzlesCount, column, row;

local puz
local background, puzzleZone 

local takeSound 

local startTime


local function isAwayFromScreen( event )
	return event.x > 10 and event.x < screenW - 10 and event.y > 10 and event.y < screenH - 10
end

local function isInRightPlace( event, obj )
	return math.sqrt(math.pow(event.x - obj.targetX, 2) + math.pow(event.y - obj.targetY, 2)) <= obj.contentWidth*0.15	
end

local function dragBody( event )
	local body = event.target
	local phase = event.phase

	if "began" == phase then

		body.isFocus = true
		audio.play(takeSound)
		body:toFront()
		body.startX = body.x
		body.startY = body.y
	elseif body.isFocus then

		if "moved" == phase then

			if isAwayFromScreen(event) then
				body.x = event.x
				body.y = event.y
			else 
				transition.moveTo(body, { x = body.startX, y = body.startY, time = 400})
				body.isFocus = false
			end

		elseif "ended" == phase or "cancelled" == phase then

			if isInRightPlace(event, body) then

				transition.moveTo(body, { x = body.targetX, y = body.targetY, time = 200})
				body: removeEventListener("touch", dragBody)

				body:toBack()
				puzzleZone:toBack()
				background:toBack()

				rightPuzzlesCount = rightPuzzlesCount + 1;

				if (rightPuzzlesCount == row*column) then
					--rightPuzzlesCount = 0
					composer:removeScene("level1", true)

					composer.gotoScene( "win", {"crossFade", 600, params = startTime })
					--scene:destroy()
				end

			end
			body.isFocus = false
		end
	end

	return true
end

local function initializeBG()
	local background = display.newRect( 0, 0, screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( 0, 0, 1 )
	return background
end

local function initializePuzzleZone()
	local puzzleZone = display.newImage( composer.getVariable("lvl").."\\puzZone.jpg")
	puzzleZone.anchorX = 0
	puzzleZone.anchorY = 0
	puzzleZone:scale(indW*0.6, indH*0.6)

	puzzleZone.x = screenW - puzzleZone.contentWidth - (screenW - puzzleZone.contentWidth)*0.5
	puzzleZone.y = screenH - puzzleZone.contentHeight - (screenH - puzzleZone.contentHeight)*0.5

	return puzzleZone
end

local function generateCorrectRandomPlaces()
	local randomPos = {}
	local line
	if column*row/4 == math.round(column*row/4) then
		line = column*row/4
	else
		line = math.round(column*row/4) + 1
	end

	for i = 1, line do
		randomPos.newKey = {i}
		randomPos[i] = {}
		randomPos[i].isSet = false
		randomPos[i].x = screenW*0.1
		randomPos[i].y = screenH/(line*2)*(i*2 - 1) 

		randomPos.newKey = {i + line}
		randomPos[i + line] = {}
		randomPos[i + line].isSet = false
		randomPos[i + line].x = screenW*0.9
		randomPos[i + line].y = screenH/(line*2)*(i*2 - 1)

		randomPos.newKey = {i + line*2}
		randomPos[i + line*2] = {}
		randomPos[i + line*2].isSet = false
		randomPos[i + line*2].x = screenW/(line*2 + 2)*1.5 + screenW/(line*2 + 4)*(i*2 - 1)
		randomPos[i + line*2].y = screenH*0.15 

		randomPos.newKey = {i + line*3}
		randomPos[i + line*3] = {}
		randomPos[i + line*3].isSet = false
		randomPos[i + line*3].x = screenW/(line*2 + 2)*1.5 + screenW/(line*2 + 4)*(i*2 - 1)
		randomPos[i + line*3].y = screenH*0.85

	end

	return randomPos
end

local function generateCorrectIndex( randomPos )
	local ind = math.random(1, row*column)
		
	while ind <= row*column and randomPos[ind].isSet do
		ind = ind + 1
	end

	if randomPos[ind] == nil then
		ind = 1
		while randomPos[ind].isSet do
			ind = ind + 1
		end
	end

	return ind
end

local function readFromFile( pathStr )
	local path = system.pathForFile( pathStr , system.ResourceDirectory )
	local file, errorString = io.open( path, "r" )
	local dr = {}
	local puzCoefficient

	if not file then
    	print( "File error: " .. errorString )
	else
    	column, row, puzCoefficient = file:read( "*n" ), file:read( "*n" ), file:read( "*n" )

    	for i = 1, row do
			for k = 1, column do
				dr.newKey = {i..k}
				dr[i..k] = {}
				dr[i..k].x, dr[i..k].y = file:read( "*n" ), file:read( "*n" )
			end
		end
	end

	if file then
		io.close( file )
		file = nil
	end

	return column, row, puzCoefficient, dr
end

function scene:create( event )
	local sceneGroup = self.view
	composer:removeHidden()

	takeSound = audio.loadSound("sound\\CLICK.wav")

	background = initializeBG()
	puzzleZone = initializePuzzleZone()

	rightPuzzlesCount = 0

	local dr, puzCoefficient
	column, row, puzCoefficient, dr = readFromFile(composer.getVariable("lvl").."\\lvlInfo.txt")

	local randomPos = generateCorrectRandomPlaces()

	puz = {}
	for i = 1, row do
		for k = 1, column do
			puz.newKey = {i..k}
			puz[i..k] = display.newImage( composer.getVariable("lvl").."\\"..i..k..".png" )
			puz[i..k]:scale(indW*puzCoefficient, indH*puzCoefficient)

			ind = generateCorrectIndex(randomPos)

			puz[i..k].x, puz[i..k].y = randomPos[ind].x, randomPos[ind].y
			randomPos[ind].isSet = true

			local dx, dy = math.round(indW*dr[i..k].x), math.round(indH*dr[i..k].y)
			
			puz[i..k].targetX = puzzleZone.x + puzzleZone.contentWidth/(column*2)*(2*k - 1) + dx
			puz[i..k].targetY =	puzzleZone.y + puzzleZone.contentHeight/(row*2)*(2*i - 1) + dy

			puz[i..k]:addEventListener( "touch", dragBody )	
		end
	end
	
	sceneGroup:insert( background )
	sceneGroup:insert( puzzleZone )
	for i = 1, row do
		for k = 1, column do
			sceneGroup:insert( puz[i..k] )
		end
	end
	
	startTime = os.time()
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
	
	if puz then
		for i = 1, row do
			for k = 1, column do
				puz[i..k]:removeSelf()
			end
		end
		puz = nil
	end

	if puzzleZone then
		puzzleZone:removeSelf()
		puzzleZone = nil
	end

	if background then
		background:removeSelf()
		background = nil
	end

	audio.dispose(takeSound)
	rightPuzzlesCount = nil
	startTime = nil

end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene