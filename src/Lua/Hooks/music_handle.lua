PTSR.MusicList = {
	Laps = {
		[1] = "PIZTIM",
		[2] = "DEAOLI",
		[3] = "PIJORE",
	},
	BFDI = {
		Laps = {
			[1] = "BFDIES"
		},
		Overtime = "BFDIOV",
		HurryUp = "BFDIHU"
	},
	Overtime = "OTMUSB", -- default
	HurryUp = "OTMUSA", -- default
}

PTSR.client_allowhurryupmusic = true

local commands = {
	["#CLEAR_LAP_MUSIC"] = function()
		PTSR.MusicList.Laps = {}
	end,
	["#LAPMUS"] = function(arg1, arg2)
		if (arg1 == nil) or not tonumber(arg1) 
		or (arg2 == nil) then
			return
		end
		
		PTSR.MusicList.Laps[tonumber(arg1)] = arg2
	end,
	["#TOGGLE_HURRYUP_MUSIC"] = function(arg1, arg2)
		if (arg1 == nil) then
			return
		end
		
		if not (arg1:lower() == "true" or arg1:lower() == "false") then
			return
		end
		
		if arg1:lower() == "true" then
			PTSR.client_allowhurryupmusic = true
		elseif arg1:lower() == "false"
			PTSR.client_allowhurryupmusic = false
		end
	end,
	["#DEFAULT_OVERTIME_MUS"] = function(arg1, arg2)
		if (arg1 == nil) then
			return
		end
		
		if S_MusicExists(arg1) then
			PTSR.MusicList.Overtime = arg1
		end
	end,
	["#DEFAULT_HURRYUP_MUS"] = function(arg1, arg2)
		if (arg1 == nil) then
			return
		end
		
		if S_MusicExists(arg1) then
			PTSR.MusicList.HurryUp = arg1
		end
	end,
}

local ps_auto = "client/SpiceRunners/ps_autoload.txt"-- auto pizza script path

local ps_auto_file = io.openlocal(ps_auto, "r")

if ps_auto_file then
	local line_count = 0
	
	for line in ps_auto_file:lines() do
		line_count = $ + 1
		
		if line:len() <= 1 then continue end
		
		if line:sub(1,1) == "#" then
			local split_command = line:split(" ")
			--
			if split_command[1] and commands[split_command[1]] then
				commands[split_command[1]](split_command[2], split_command[3])
			end
		end
	end
	ps_auto_file:close()
else
	ps_auto_file = io.openlocal(ps_auto, "w")
	ps_auto_file:close()
end

function PTSR.IsOverTimeMusicInPriority()
	return (PTSR.timeleft <= 20*TICRATE and multiplayer and PTSR.client_allowhurryupmusic) or PTSR.timeover
end

local IS_PANIC = false

addHook("ThinkFrame", function()
	if not PTSR.IsPTSR() then return end
	if CV_PTSR.nomusic.value then return end
	if PTSR.gameover then return end
	if not consoleplayer then return end
	
	local laps = consoleplayer.ptsr.laps
	
	local uList = PTSR.useBFDImus and PTSR.MusicList.BFDI or PTSR.MusicList -- hi guys, pac here
	
	if PTSR.pizzatime then
		--PTSR.timeleft <= 56*TICRATE
		if leveltime then -- srb2 is super slow tbh
			if PTSR.timeover then
				
				local mus = CV_PTSR.overtime_music.value
				
				local mus_str = uList.Overtime
				local gm_metadata = PTSR.currentModeMetadata()
				
				if mus then
					if gm_metadata.overtime_music then
						S_ChangeMusic(gm_metadata.overtime_music, true, player)
						mapmusname = gm_metadata.overtime_music
					elseif mapmusname ~= mus_str then
						S_ChangeMusic(mus_str, true, player)
						mapmusname = mus_str
					end
				end
				
				P_SetupLevelSky(34)
				P_SetSkyboxMobj(nil)
				
				if mus then
					return
				end
			elseif PTSR.timeleft <= 20*TICRATE and multiplayer
			and PTSR.client_allowhurryupmusic then -- Hurry up
				local mus = CV_PTSR.overtime_music.value
				
				local mus_str = uList.HurryUp
				
				if S_MusicName() ~= mus_str then
					S_ChangeMusic(mus_str, false, player)
					mapmusname = mus_str
				end
				
				if mus then
					return
				end
			end
		end
	
		if uList.Laps[laps] and mapmusname ~= uList.Laps[laps] then
			local newmus = uList.Laps[laps]
			if S_MusicExists(newmus) then
				S_ChangeMusic(newmus, true, player)
				mapmusname = newmus
			else
				S_StopMusic(player)
			end
		end
		
		if S_MusicName() ~= "PIZTIM" then
			IS_PANIC = false
		end
		
		local length = S_GetMusicLength()

		if not multiplayer
		and S_MusicName() == "PIZTIM"
		and PTSR.timeleft <= 56*TICRATE
		and not IS_PANIC then
			S_ChangeMusic("PIZTIM", false, consoleplayer)
			S_SetMusicPosition(length-(PTSR.timeleft/TICRATE*1000))
			IS_PANIC = true
		end
	end
end)