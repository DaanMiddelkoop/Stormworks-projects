
variables = {GPS_X = 0, GPS_Y = 0, autopilot = false, GOAL_X = 0, GOAL_Y = 0, GOAL_SET = false}

function distance_steering()
	variables.autohoover = false
	angle_to_north = math.atan(variables.deltax, variables.deltay)
	angle = angle_to_north - variables.YAW
	steering_direction = -math.sin(angle) / 10
	
	variables.leftright = -steering_direction
	variables.ad = variables.ROLL
	variables.updown = (variables.PITCH + 0.15)
	
end

function precision_steering()
	angle_to_point = math.atan(variables.deltax, variables.deltay)
	angle = angle_to_point - variables.YAW 
	
	deltaroll = variables.deltax * math.cos(variables.YAW) + variables.deltay * math.sin(variables.YAW)
	deltapitch = variables.deltax * math.sin(variables.YAW) + variables.deltay * math.cos(variables.YAW)
	
	variables.ad = math.sin(angle) * (variables.distance / 100)
	variables.updown = math.cos(angle) * (variables.distance / 100)
	
	variables.ad = math.min(0.3, math.max(-0.3, variables.ad))
	variables.updown = math.min(0.3, math.max(-0.3, variables.updown))
	
	variables.autohoover = true
	
end

function calculate_autopilot()
	variables.deltax = variables.mark.x - variables.GPS_X
	variables.deltay = variables.mark.y - variables.GPS_Y
	
	variables.distance = math.sqrt(variables.deltax * variables.deltax + variables.deltay * variables.deltay)
	if variables.distance > 100 then
		distance_steering()
	else
		precision_steering()
	end
end

function readvars()
	variables.GPS_X = input.getNumber(7)
	variables.GPS_Y = input.getNumber(8)
	
	variables.YAW =  ((1-input.getNumber(11))%1) * math.pi * 2
	variables.PITCH = input.getNumber(12) * math.pi
	variables.ROLL = input.getNumber(13) * math.pi
	
	variables.mark = {}
	variables.mark.x = input.getNumber(9)
	variables.mark.y = input.getNumber(10)
	variables.mark.active = input.getBool(7)
	
	variables.autopilot = input.getBool(8)
	variables.autohoover = input.getBool(1)
	
	variables.ws = input.getNumber(2)
	variables.ad = input.getNumber(1)
	variables.updown = input.getNumber(4)
	variables.leftright = input.getNumber(3)
end

function writevars()
	output.setBool(1, variables.autopilot and variables.mark.active)
	output.setBool(2, variables.autohoover)
	output.setBool(3, variables.autopilot)
	output.setNumber(1, variables.ws)
	output.setNumber(2, variables.ad)
	output.setNumber(3, variables.updown)
	output.setNumber(4, variables.leftright)
end

function onTick()
	readvars()
	if variables.autopilot and variables.mark.active then
		calculate_autopilot()	
	end
	writevars()
end
