PTSR.StartNewLap = function(mobj)
	local player = mobj.player

	if not player.ptsr.pizzaface and not player.spectator and player.playerstate ~= PST_DEAD and mobj.valid then
		PTSR.LapTP(player, true)

		S_StartSound(nil, sfx_lap2, player)
		if not multiplayer and PTSR.aipf then
			PTSR:SpawnPFAI()
		end
		
		player.ptsr.laptime = 0
		
		for i,v in ipairs(PTSR.ESLOCATIONS) do
			v.lap_list[player] = player.ptsr.laps
		end
		
		player.ptsr.laps = $ + 1
		PTSR.laps = $ + 1

		/* Unused code idk what tf this is for
		if player.ptsr.laps > PTSR.laps
			PTSR.laps = player.ptsr.laps
		end
		*/
		
		-- Elfilin support
		
		if player.elfilin and player.mo.elfilin_portal then
			player.mo.elfilin_portal.fuse = 1
		end

		if not CV_PTSR.nomusic.value then -- if music on
			if not PTSR.IsOverTimeMusicInPriority() then
				local uList = PTSR.useBFDImus and PTSR.MusicList.BFDI or PTSR.MusicList -- hi guys, pac here
				if uList.Laps[player.ptsr.laps] and mapmusname ~= uList.Laps[player.ptsr.laps] then
					S_ChangeMusic(uList.Laps[player.ptsr.laps], true, player)
				end
			end
		end
	else -- FAKE LAP -- 
		mobj.pfstuntime = TICRATE*CV_PTSR.fakelapstun.value
		P_SetOrigin(mobj, PTSR.end_location.x,PTSR.end_location.y, PTSR.end_location.z)
		mobj.angle = PTSR.end_location.angle - ANGLE_90
	end
end 