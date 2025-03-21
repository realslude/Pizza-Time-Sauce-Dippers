local timeafteranimation = 0

local ot_color_table = {
	SKINCOLOR_RED,
	SKINCOLOR_PEPPER,
	SKINCOLOR_SALMON,
	SKINCOLOR_WHITE,
	SKINCOLOR_SALMON,
	SKINCOLOR_PEPPER,
}

--[[@param v videolib]]
/*local function drawBarFill(v, x, y, scale, progress, patch)
	local clampedProg = max(0, min(progress, FU))
	local patch = v.cachePatch(patch)
	local drawwidth = FixedMul(clampedProg, BARWIDTH)
	local barOffset = ((leveltime%TIMEMODFAC)*FU/4)%BARSECTIONWIDTH
	v.drawCropped(
		x+FixedMul(BARXOFF, scale), y+FixedMul(BARYOFF, scale), -- x, y
		scale, scale, -- hscale, vscale
		patch, V_SNAPTOBOTTOM, -- patch, flags
		nil, -- colormap
		barOffset, 0, -- sx, sy
		drawwidth, patch.height*FU)
end*/

local function drawBar(v, x, y, scale, properties)
	local prog = properties and properties.offset or 0
	local length = properties and properties.length or 0
	local bar, barscale = PTSR.getPatch(v, properties and properties.bar or "SHOWTIMEBAR")
	local fill, fillscale = PTSR.getPatch(v, properties and properties.fill or "BARFILL")
	local ox = properties and properties.fill_xoffset or 0
	local oy = properties and properties.fill_yoffset or 0
	local ow = properties and properties.fill_widthoffset or 0
	local flags = properties and properties.flags or 0
	local color = properties and properties.color

	prog = -fill.width*$

	ox = FixedMul($, scale)
	oy = FixedMul($, scale)

	length = bar.width*$
	length = max(0, ($-ox)+ow)

	while prog < length do
		if prog+(fill.width*FU) < length then
			if prog < 0 then
				v.drawCropped(
					x+ox, y+oy,
					FixedMul(fillscale, scale), FixedMul(fillscale, scale),
					fill,
					flags,
					color,
					-prog,
					0,
					(fill.width*FU)-prog,fill.height*FU
				)
			else
				v.drawScaled(x+FixedMul(prog, scale)+ox,
					y+oy,
					FixedMul(fillscale, scale),
					fill,
					flags,
					color)
			end
			prog = $+(fill.width*FU)
		else
			if prog > 0 then
				v.drawCropped(
					x+FixedMul(prog, scale)+ox, y+oy,
					FixedMul(fillscale, scale), FixedMul(fillscale, scale),
					fill,
					flags,
					color,
					0, 0,
					length-prog,
					fill.height*FU
				)
			else
				v.drawCropped(
					x+ox, y+oy,
					FixedMul(fillscale, scale), FixedMul(fillscale, scale),
					fill,
					flags,
					color,
					-prog, 0,
					length,
					fill.height*FU
				)
			end
			prog = length
		end
	end
	v.drawScaled(x,y,FixedMul(barscale, scale),bar,flags)
end

-- always give scale or die
local function FlashSnakeCustomFontString(v, x, y, str, fontName, flags, align, scale)
	if not (type(str) == "string") then
		warn("No string given in FlashSnakeCustomFontString");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in FlashSnakeCustomFontString");
		return;
	end

	local font = customhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in FlashSnakeCustomFontString");
		return;
	end

	if (type(scale) != "number")
		scale = nil;
	end

	local kerning = font.kerning;
	if (scale != nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale != nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono != nil and scale != nil) then
		mono = $1 * scale;
	end
	
	local nextx = x;

	if (align == "right") then
		nextx = $1 - customhud.CustomFontStringWidth(v, str, fontName, scale);
	elseif (align == "center") then
		nextx = $1 - (customhud.CustomFontStringWidth(v, str, fontName, scale) / 2);
	end

	for i = 1,str:len() do
		local otcolornum = 1+(((leveltime+i)/4)%#ot_color_table)
		local iMul = (i*4)
		local iMulAndLT = leveltime+iMul
		local yAdd = cos(FixedAngle(iMulAndLT*FRACUNIT*10))*4
		local nextByte = str:byte(i,i);
		nextx = customhud.CustomFontChar(v, nextx, y+yAdd, nextByte, fontName, flags, scale, ot_color_table[otcolornum]);
	end
end

local bar_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	if PTSR.pizzatime then

		local bar_finish = 1475*FRACUNIT/10
		local TLIM = PTSR.maxtime or 0 
		
		local barfill = PTSR.isOvertime() and "BARFILL2" or "BARFILL"
		
		-- "TLIM" is time limit number converted to seconds to minutes
		--example, if CV_PTSR.timelimit.value is 4, it goes to 4*35 to 4*35*60 making it 4 minutes

		local div = ( (FU) / (pthud_expectedtime) )*PTSR.pizzatime_tics
		
		local ese = (PTSR.pizzatime_tics < pthud_expectedtime) and 
		ease.linear(div, pthud_start_pos, pthud_finish_pos) or pthud_finish_pos  -- ese is y axis tween
		
		-- hi saxa here BAR GO DOWN
		local time_offset = 60
		if not multiplayer and PTSR.timeover_tics >= time_offset then
			local tween = (PTSR.timeover_tics-time_offset)*FU/pthud_expectedtime
			ese = tween < FU and ease.linear(tween, pthud_finish_pos, pthud_start_pos) or pthud_start_pos
		end

		local pfEase = min(max(PTSR.pizzatime_tics - CV_PTSR.pizzatimestun.value*TICRATE - 50, 0), 100)
		pfEase = (pfEase*pfEase) * FU / 22
		if not multiplayer then pfEase = 0 end

		--local bar = PTSR.getPatch(v, "SHOWTIMEBAR") -- the orange border
		--local bar2 = PTSR.getPatch(v, "SHOWTIMEBAR2") -- the purple thing whats this used for???
		
		--1/PTSR.timeleft
		--PTSR.timeleft

		local pizzaface
		if animationtable['pizzaface'] // dont wanna risk anything yknow
			pizzaface = v.cachePatch(animationtable['pizzaface'].display_name)
		else
			pizzaface = v.cachePatch('PIZZAFACE_SLEEPING1')
		end
		
		local john
		
		if not PTSR.isOvertime() then
			john = v.cachePatch('JOHN1')
			if animationtable['john']
				john = v.cachePatch(animationtable['john'].display_name)
			end
		else
			john = v.cachePatch('REDJOHN1')
			if animationtable['redjohn']
				john = v.cachePatch(animationtable['redjohn'].display_name)
			end
		end

		--ease.linear(fixed_t t, [[fixed_t start], fixed_t end])
		if PTSR.maxtime then
			--for the bar length calculations
			local progress = FixedDiv(TLIM*FRACUNIT-PTSR.timeleft*FRACUNIT, TLIM*FRACUNIT)
			local johnx = FixedMul(progress, bar_finish)
			

			-- Fix negative errors?
			if johnx < 0 then
				johnx = 0
			end

			local johnscale = (FU/2) -- + (FU/4)

			-- during animation
			--purple bar, +1 fracunit because i want it inside the box 
			-- MAX VALUE FOR HSCALE: FRACUNIT*150
			-- v.drawStretched(91*FRACUNIT, ese + (5*FU)/3, min(themath,bar_finish), (FU/2) - (FU/12), bar2, V_SNAPTOBOTTOM)
	
			drawBar(v, 90*FU, ese, FU/2, {
				offset = FixedDiv(leveltime % (45*TICRATE), 45*TICRATE),
				length = progress,
				fill_xoffset = 5*FU,
				fill_yoffset = 5*FU,
				fill_widthoffset = -5*FU,
				fill = PTSR.timeleft and "BARFILL" or "BARFILL2",
				flags = V_SNAPTOBOTTOM
			})
			v.drawScaled((82*FU) + min(johnx,bar_finish), ese + (6*johnscale), johnscale, john, V_SNAPTOBOTTOM)
			v.drawScaled(230*FU, ese - (8*FU) + pfEase, FU/3, pizzaface, V_SNAPTOBOTTOM)
			local timestring = G_TicsToMTIME(PTSR.timeleft)
			local x = 165*FRACUNIT
			local y = 176*FRACUNIT + FRACUNIT/2
			local y_offset = (3*FRACUNIT)/2
			
			if PTSR.timeleft or not multiplayer then
				customhud.CustomFontString(v, x, ese + y_offset, timestring, "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/2, SKINCOLOR_WHITE)
			else
				local gm_metadata = PTSR.currentModeMetadata()
				
				local ot_text = gm_metadata.overtime_textontime or "OVERTIME!"
				
				FlashSnakeCustomFontString(v, x, ese + y_offset, ot_text, "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/2)
			end
			timeafteranimation = $ + 1
		end
	else
		timeafteranimation = 0
	end
end

customhud.SetupItem("PTSR_bar", ptsr_hudmodname, bar_hud, "game", 0)