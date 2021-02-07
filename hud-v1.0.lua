inputX = 0
inputY = 0
inputPressed = false

mode = 0

GPSCoordsX = 0
GPSCoordsY = 0

Pitch = 0 -- radians
Roll = 0 -- radians
Yaw = 0 -- radians

TargetCoords1X = 0
TargetCoords1Y = 0
TargetCoords1Enabled = false

TargetCoords2X = 0
TargetCoords2Y = 0
TargetCoords2Enabled = false

ALPHA = 255

MapZoom = 1


function withinBox(ix, iy, bx, by, bw, bh)
	if ix > bx and iy > by and ix < bx + bw and iy < by + bh then
		return true
	end
	return false
end

function collectInput()
	inputX = input.getNumber(3)
	inputY = input.getNumber(4)
	inputPressed = input.getBool(1)
	GPSCoordsX = input.getNumber(9)
	GPSCoordsY = input.getNumber(10)
	Pitch = input.getNumber(11) * 2 * 3.1415
	Roll = input.getNumber(12) * 2 * 3.1415
	Yaw = -input.getNumber(13) * 2 * 3.1415
	Altitude = input.getNumber(14)
	
	TargetCoords2Enabled = input.getBool(3)
	if (TargetCoords2Enabled) then
		TargetCoords2X = input.getNumber(7)
		TargetCoords2Y = input.getNumber(8)
	end
end

function updateScreen(x, y)
	if withinBox(x, y, 0, 76, 14, 10) and ALPHA < 240 then
		ALPHA = ALPHA * 1.05
	end
	
	if withinBox(x, y, 0, 86, 14, 10) and ALPHA > 5 then
		ALPHA = ALPHA / 1.05
	end
	
	if withinBox(x, y, 0, 0, 14, 10) then
		mode = 0
	elseif withinBox(x, y, 0, 10, 14, 10) then
		mode = 1
	elseif withinBox(x, y, 0, 20, 14, 10) then
		mode = 2	
	end
	
	if mode == 0 then
		if withinBox(x, y, 14, 86, 10, 10) then
			if MapZoom > 50 then return end
			
			MapZoom = MapZoom * 1.05	
			return
		end
		
		if withinBox(x, y, 24, 86, 10, 10) then
			if  MapZoom < 0.1 then return end
			MapZoom = MapZoom * 0.95
			return
		end 
		
		if withinBox(x, y, 10, 0, 82, 96) then
			TargetCoords1Enabled = true
			TargetCoords1X, TargetCoords1Y = map.screenToMap(GPSCoordsX, GPSCoordsY, MapZoom, 82, 96, x - 14, y)
		end
	end
end

function sendGPSInfo()
	output.setBool(3, TargetCoords1Enabled)
	output.setNumber(7, TargetCoords1X)
	output.setNumber(8, TargetCoords1Y)
end

function onTick()
	collectInput()
	
	if inputPressed then
		updateScreen(inputX, inputY)
	end
	
	sendGPSInfo()
end

function drawMapExt(MX, MY, MZ, SX, SY)
	adjustedX, adjustedY = map.screenToMap(0, 0, MZ, screen.getWidth(), screen.getHeight(), SX, SY)
	screen.drawMap(MX - adjustedX, MY - adjustedY, MZ)
	
end

function renderMap()
	drawMapExt(GPSCoordsX, GPSCoordsY, MapZoom, 55, 48)
	
	screen.setColor(255, 0, 0, ALPHA)
	if TargetCoords1Enabled then
		tx, ty = map.mapToScreen(GPSCoordsX, GPSCoordsY, MapZoom, 82, 96, TargetCoords1X, TargetCoords1Y)
		if tx > 0 then
			screen.drawCircle(tx + 14, ty, 1)
		end
	end
	
	screen.setColor(0, 255, 0, ALPHA)
	if TargetCoords2Enabled then
		tx, ty = map.mapToScreen(GPSCoordsX, GPSCoordsY, MapZoom, 82, 96, TargetCoords2X, TargetCoords2Y)
		if tx > 0 then
			screen.drawCircle(tx + 14, ty, 1)
		end
	end
	
	screen.setColor(0, 0, 255, ALPHA)
	screen.drawCircle(41 + 14, 48, 1)
	screen.setColor(255, 255, 255, ALPHA)
	screen.setColor(0, 0, 0, ALPHA / 2)
	screen.drawRectF(14, 86, 20, 10)
	screen.setColor(255, 255, 255, ALPHA)
	screen.drawRect(14, 86, 10, 10)
	screen.drawRect(24, 86, 10, 10)
	screen.drawText(17, 89, "-")
	screen.drawText(27, 89, "+")
end

function drawTargetOnHorizon(x, y)
	rel_x = x - GPSCoordsX
	rel_y = y - GPSCoordsY
	
	anglePointToNorth = math.atan(rel_x, rel_y)
	angle = anglePointToNorth - Yaw
	
	if math.cos(angle) > 0 then
		xpos = math.sin(angle) * 41 + 41
		if xpos > 0 and xpos < 82 then
			screen.drawCircleF(xpos + 14, 48, 2)
		end
	end
end

function renderCamera()
	
end

function renderHorizon()
	
	horHeight = Pitch / 3.1415 * 48 * 4
	x1, y1 = 55, 48 + horHeight
	x2, y2 = math.cos(Roll) * -1000 + 55, math.sin(Roll) * -1000 + 48 + horHeight
	x3, y3 = math.sin(Roll) * -1000 + 55, math.cos(Roll) * 1000 + 48 + horHeight
	x4, y4 = math.cos(Roll) *  1000 + 55, math.sin(Roll) * 1000 + 48 + horHeight
	x5, y5 = math.sin(Roll) *  1000 + 55, math.cos(Roll) * -1000 + 48 + horHeight
	
	screen.setColor(101, 67, 33, ALPHA)
	screen.drawTriangleF(x1, y1, x2, y2, x3, y3)
	screen.drawTriangleF(x1, y1, x3, y3, x4, y4)
	screen.setColor(0, 0, 255, ALPHA)
	screen.drawTriangleF(x1, y1, x2, y2, x5, y5)
	screen.drawTriangleF(x1, y1, x4, y4, x5, y5)
	screen.setColor(0, 0, 0, ALPHA)
	screen.drawCircle(55, 48, 5)
	screen.drawLine(0, 48, 50, 48)
	screen.drawLine(60, 48, 1000, 48)
	screen.drawLine(55, 0, 55, 43)
	screen.drawLine(55, 53, 55, 1000)
	
	pitchlist = ""
	for i=-36,36 do pitchlist = pitchlist .. string.format("%4i\n\n", 10 * -i) end
	
	boxheight = Pitch / 3.1415 * 217 -387
	screen.drawTextBox(75, boxheight, 20, 96, pitchlist)
	screen.drawText(30, 90, string.format("YAW:%4i", math.floor(Yaw / 3.1415 * 180)))
	screen.drawText(30, 0, string.format("ALT:%4i", math.floor(Altitude)))
	
	if TargetCoords1Enabled then
		screen.setColor(255, 0, 0, ALPHA)
		drawTargetOnHorizon(TargetCoords1X, TargetCoords1Y)
	end
	if TargetCoords2Enabled then
		screen.setColor(0, 255, 0, ALPHA)
		drawTargetOnHorizon(TargetCoords2X, TargetCoords2Y)
	end
	
	
end


function onDraw()
	screen.setColor(255, 255, 255, ALPHA)
	if mode == 0 then
		renderMap()
	elseif mode == 1 then
		renderHorizon()
	elseif mode == 2 then
		renderCamera()
	end
	
	screen.setColor(0, 0, 0, ALPHA)
	screen.drawRectF(0, 0, 14, 96)
	screen.setColor(0, 255, 0, ALPHA)
	screen.drawText(0, 1, "MAP")
	screen.setColor(255, 0, 0, ALPHA)
	screen.drawText(0, 11, "HRZ")
	screen.setColor(0, 0, 255, ALPHA)
	screen.drawText(0, 21, "CAM")
	
	screen.setColor(255, 255, 255, 255)
	screen.drawText(4, 76, "+")
	screen.drawText(4, 86, "-")
end

