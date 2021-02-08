function create_box(x, y, w, h)
	return {x = x, y = y, w = w, h = h}
end

function inside_box_and_pressed(m, box)
	return (m.pressed and m.x > box.x and m.y > box.y and m.x < box.x + box.w and m.y < box.y + box.h)
end


function set_color(r, g, b, a)
	screen.setColor(r, g, b, a)	
end
function draw_button_box(box)
	set_color(0, 0, 0, 255)
	screen.drawRectF(box.x, box.y, box.w, box.h)
end

function draw_buttons(buttons) 
	for i, b in ipairs(buttons) do
		draw_button_box(b[1])
		if b[5] == nil then
			set_color(255, 255, 255, 255)
		else
			r, g, n, a = b[5][1], b[5][2], b[5][3], b[5][4]
			set_color(r, g, n, a)
		end
		screen.drawText(b[1].x + 3, b[1].y + 2, b[2])
	end
end

function handle_buttons(buttons)
	for i, b in ipairs(buttons) do
		if inside_box_and_pressed(variables.m, b[1]) then
			b[3](b[4])
			return false
		end
	end
	return true
end

function gps_to_screen(x, y) 
	return map.mapToScreen(variables.GPS_X - variables.ms.x, variables.GPS_Y - variables.ms.y, variables.GPS_ZOOM, 96, 96, x, y)
end

function screen_to_gps(x, y)
	return map.screenToMap(variables.GPS_X - variables.ms.x, variables.GPS_Y - variables.ms.y, variables.GPS_ZOOM, 96, 96, x, y)
end

function map_zoom_change(factor)
	variables.GPS_ZOOM = variables.GPS_ZOOM * factor
end

function map_scroll_change(scroll)
	variables.ms.x = variables.ms.x + scroll.x * variables.GPS_ZOOM * 5
	variables.ms.y = variables.ms.y + scroll.y * variables.GPS_ZOOM * 5
end

function map_input()
	if variables.m.pressed then
		variables.marks[1].active = true
		variables.marks[1].x, variables.marks[1].y = screen_to_gps(variables.m.x, variables.m.y)
	end
end

function map_draw()
	screen.drawMap(variables.GPS_X - variables.ms.x, variables.GPS_Y - variables.ms.y, variables.GPS_ZOOM)
	
	if variables.marks[1].active then
		set_color(255, 0, 0, 255)
		x, y = gps_to_screen(variables.marks[1].x, variables.marks[1].y)
		screen.drawCircleF(x, y, 1)
	end
	
	if variables.marks[2].active then
		set_color(0, 255, 0, 255)
		x, y = gps_to_screen(variables.marks[2].x, variables.marks[2].y)
		screen.drawCircleF(x, y, 1)
	end
end

function horizon_input()
	
end

function draw_mark(mark)
	if mark.active then
		angle = math.atan(mark.y - variables.GPS_Y, mark.x - variables.GPS_X) - variables.yaw - math.pi / 2
		x = math.sin(angle) * 50 + 48
		y = 48
		if math.cos(angle) > 0 then
			set_color(255, 0, 0, 255)
			screen.drawCircleF(x, y, 2)
		end
	end
end

function horizon_draw()
	center_x, center_y = 48, 48
	size = 300
	
	height = 48--  + math.sin(variables.pitch) * size
	
	x2, y2 = 48 + math.cos(variables.roll + variables.pitch / 5) * size, height + math.sin(variables.roll + variables.pitch / 5) * size
	x3, y3 = 48 + math.cos(variables.roll + math.pi - variables.pitch / 5) * size, height + math.sin(variables.roll + math.pi - variables.pitch / 5) * size
	
	x4, y4 = 48 + math.cos(variables.roll + (math.pi / 2)) * 1000, height + math.sin(variables.roll + (math.pi / 2)) * 1000
	x5, y5 = 48 + math.cos(variables.roll + (math.pi * 1.5)) * 1000, height + math.sin(variables.roll + (math.pi * 1.5)) * 1000
	
	set_color(0, 0, 255, 255)
	screen.drawTriangleF(x2, y2, x3, y3, x4, y4)
	set_color(100, 100, 0, 255)
	screen.drawTriangleF(x2, y2, x3, y3, x5, y5)
	set_color(0, 0, 0, 255)
	screen.drawLine(0, 48, 96, 48)
	screen.drawLine(48, 0, 48, 96)
	
	set_color(255, 0, 0, 255)
	draw_mark(variables.marks[1])
	set_color(0, 255, 0, 255)
	draw_mark(variables.marks[2])
	
	set_color(20, 20, 20, 255)
	for radius = 80, 200 do
		screen.drawCircle(48, 48, radius / 2)	
	end
	
	set_color(255, 255, 255, 255)
	screen.drawText(2, 88, string.format("YAW %i", math.floor(variables.yaw / math.pi * 180)))
	screen.drawText(50, 88, string.format("ALT %i", math.floor(variables.altitude)))
end

function toggle_autohoover()
	if not variables.sp then
		variables.ah = not variables.ah
		variables.sp = true
	end
end

function toggle_cargo_door()
	if not variables.sp then
		variables.cd = not variables.cd
		variables.sp = true
	end
end

function settings_input()
	if variables.m.pressed == false then
		variables.sp = false	
	end
end

function settings_draw()
	set_color(0, 0, 0, 255)
	screen.drawClear()
end

function overlay_mode_decrease(a)
	if variables.ps == false then
		variables.current_mode = variables.current_mode - 1
		if variables.current_mode < 1 then
			variables.current_mode = 3
		end
		variables.ps = true
	end
end

function overlay_mode_increase(a)
	if variables.ps == false then
		variables.current_mode = variables.current_mode + 1
		if variables.current_mode > 3 then
			variables.current_mode = 1
		end
		
		variables.ps = true
	end
end

function overlay_input()
	handle_buttons(overlay_buttons)
	if variables.m.pressed == false then
		variables.ps = false
	end
	return not variables.ps
end

function read_vars()
	a = input.getNumber
	c = input.getBool
	variables.GPS_X = a(7)
	variables.GPS_Y = a(8)
	variables.marks[2].x = a(9)
	variables.marks[2].y = a(10)
	variables.marks[2].active = c(3)
	variables.m.x = a(3)
	variables.m.y = a(4)
	variables.m.pressed = c(1)
	variables.pitch = a(11) * 2 * math.pi
	variables.yaw = a(12) * 2 * math.pi
	variables.roll = a(13)  * 2 * math.pi
	variables.altitude = a(14)
	
	if c(6) == true then
		buttons[3][1][5] = {0, 255, 0, 255}
	else
		buttons[3][1][5] = {255, 0, 0, 255}
	end
	
	if c(7) == true then
		buttons[3][2][5] = {0, 255, 0, 255}
	else
		buttons[3][2][5] = {255, 0, 0, 255}
	end
end

function write_vars()
	a = output.setNumber
	c = output.setBool
	a(9, variables.marks[1].x)
	a(10, variables.marks[1].y)
	c(3, variables.marks[1].active)
	c(4, variables.ah)
	c(5, variables.cd)
end


overlay_buttons = {{create_box(2, 2, 10, 10), "<", overlay_mode_decrease, {}},  -- OVERLAY
                   {create_box(13, 2, 10, 10), ">", overlay_mode_increase, {}}}

buttons = {
    {{create_box(96 - 12, 2, 10, 10), "-", map_zoom_change, 1.05}, -- MAP
     {create_box(96 - 23, 2, 10, 10), "+", map_zoom_change, 1 / 1.05},
     {create_box(96 - 12, 96 - 45, 10, 10), "^", map_scroll_change, {x = 0, y = -1}},
     {create_box(96 - 12, 96 - 34, 10, 10), "<", map_scroll_change, {x = 1, y = 0}},
     {create_box(96 - 12, 96 - 23, 10, 10), ">", map_scroll_change, {x = -1, y = 0}},
     {create_box(96 - 12, 96 - 12, 10, 10), "v", map_scroll_change, {x = 0, y = 1}}},
     
    {}, -- HORIZON
    {
    	{create_box(2, 20, 80, 10), "AutoHoover", toggle_autohoover, {}, {255, 0, 0, 255}},
		{create_box(2, 30, 100, 10), "CargoDoor", toggle_cargo_door, {}, {255, 0, 0, 255}}
    }, -- SETTINGS
}

modes = {{i = map_input, d=map_draw}, {i = horizon_input, d=horizon_draw}, {i=settings_input, d=settings_draw}}
variables = {GPS_ZOOM = 1, ms = {x = 0, y = 0}, ps = 0, current_mode = 2, m = {}, marks = {{x = 0, y = 0, active=true}, {x = 0, y = 0, active=false}}}


function onTick()
	read_vars()
	if overlay_input() and handle_buttons(buttons[variables.current_mode]) then
		modes[variables.current_mode].i()
	end
	write_vars()
	
end

function onDraw()
	set_color(255, 255, 255, 255)
	screen.drawClear()
	modes[variables.current_mode].d()
	draw_buttons(buttons[variables.current_mode])
	draw_buttons(overlay_buttons)
end
