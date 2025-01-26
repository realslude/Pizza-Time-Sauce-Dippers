PTSR.PizzaTimeTrigger = function(mobj)
	local gm_metadata = PTSR.currentModeMetadata()

	local aimode = true

	if gm_metadata.player_pizzaface then
		aimode = false
	end

	if not (PTSR.pizzatime and PTSR.spawn_location_atdefault) then
		if DiscordBot then
			local discord_pizzatime_text = "This text isn't supposed to show. Uh oh!"
			
			if aimode then
				discord_pizzatime_text = ":pizza: Pizza Time has started!\n"
			else
				discord_pizzatime_text = ":pizza: Pizza Time has started! Pizzas:\n"
			end
			
			DiscordBot.Data.msgsrb2 = $ .. discord_pizzatime_text
		end
		
		PTSR.pizzatime = true
		PTAnimFunctions.NewAnimation('pizzaface', 'PIZZAFACE_SLEEPING', 2, 11, true)
		PTAnimFunctions.NewAnimation('john', 'JOHN', 2, 22, true)
		PTAnimFunctions.NewAnimation('redjohn', 'REDJOHN', 1, 22, true)

		local thesign = P_SpawnMobj(0,0,0, MT_SIGN)
		P_SetOrigin(thesign, PTSR.spawn_location.x, PTSR.spawn_location.y, PTSR.spawn_location.z)
		
		if multiplayer and aimode and not CV_PTSR.nopizza.value then
			PTSR:SpawnPFAI()
		end
		
		thesign.angle = PTSR.spawn_location.angle
		
		if thesign.subsector then
			PTSR.endsector = thesign.subsector.sector
		end
		
		PTSR.timeleft = CV_PTSR.timelimit.value*TICRATE*60
		PTSR.maxtime = CV_PTSR.timelimit.value*TICRATE*60
		
		PTSR.maxlaps = CV_PTSR.default_maxlaps.value

		-- Custom timelimit Header 
		if mapheaderinfo[gamemap].ptsr_timelimit then -- in minutes
			PTSR.timeleft = tonumber(mapheaderinfo[gamemap].ptsr_timelimit)*TICRATE*60
			PTSR.maxtime = tonumber(mapheaderinfo[gamemap].ptsr_timelimit)*TICRATE*60
		elseif mapheaderinfo[gamemap].ptsr_timelimit_secs then -- in seconds
			PTSR.timeleft = tonumber(mapheaderinfo[gamemap].ptsr_timelimit_secs)*TICRATE
			PTSR.maxtime = tonumber(mapheaderinfo[gamemap].ptsr_timelimit_secs)*TICRATE
		end
		
		-- Custon maxlaps header
		if mapheaderinfo[gamemap].ptsr_maxlaps and CV_PTSR.default_maxlaps.value then -- if header and not 0
			PTSR.maxlaps = tonumber(mapheaderinfo[gamemap].ptsr_maxlaps)
		end
		
		if gm_metadata["instant_overtime"] then
			PTSR.timeleft = 1
		end
		
		PTSR.laps = 1 -- new day new me
		
		PTSR_DoHook("onpizzatime")
		
		-- player pf only stuff
		if multiplayer and not aimode and not CV_PTSR.nopizza.value then
			local count = PTSR_COUNT()

			if count.active > 1 then
				if CV_PTSR.pizzachoosetype.value == 1 then
					mobj.player.ptsr.pizzaface = true
					mobj.pfstuntime = CV_PTSR.pizzatimestun.value*TICRATE
					chatprint("\x85*"..mobj.player.name.." has become a pizza!") 
					if DiscordBot then
						DiscordBot.Data.msgsrb2 = $ .. "- [" .. #mobj.player .. "] **" .. mobj.player.name .. "**\n"
					end
				else
					local active_playernums = {}
					local playerschoosing = CV_PTSR.pizzacount.value
					
					if count.active < playerschoosing then
						playerschoosing = 1
					end
					if playerschoosing then
						-- store every playernum
						for player in players.iterate() do
							if CV_PTSR.pizzachoosetype.value == 3 and player == mobj.player then
								continue
							end
							if player.quittime then
								player.spectator = true
								continue
							end
							
							table.insert(active_playernums, #player)
						end
						-- loop for every pizza needed
						for i=1,playerschoosing do
							local chosen_playernum = P_RandomRange(1,#active_playernums) -- random entry in table
							local chosen_player = active_playernums[chosen_playernum] -- get the chosen value in table
							players[chosen_player].ptsr.pizzaface = true
							players[chosen_player].realmo.pfstuntime = CV_PTSR.pizzatimestun.value*TICRATE
							
							chatprint("\x85*"..players[chosen_player].name.." has become a pizza!") 
							if DiscordBot then
								DiscordBot.Data.msgsrb2 = $ .. "- [" .. chosen_player .. "] **" .. players[chosen_player].name .. "**\n"
							end
							
							table.remove(active_playernums, chosen_playernum) -- so we dont repeat the pizza given
						end
					end
				end
			end
		end

		for player in players.iterate() do
			local pmo = player.mo
			if not (pmo and pmo.valid) then continue end
			
			player.powers[pw_carry] = 0
			
			player.ptsr.laps = 1
			
			for i,v in ipairs(PTSR.ESLOCATIONS) do
				v.lap_list[player] = player.ptsr.laps -- is 1
			end
			
			P_SetOrigin(pmo, PTSR.end_location.x,PTSR.end_location.y, PTSR.end_location.z)
			
			pmo.state = S_PLAY_STND
			
			pmo.angle = PTSR.end_location.angle - ANGLE_90
			
			PTSR:AddComboTime(player, player.ptsr.combo_maxtime) -- give everyone combo time cause IM NICE!
			
			-- if pizza time triggerer
			if pmo == mobj then
				PTSR:AddCombo(player, 1)
			end
			
			local angle_frompotal = mapheaderinfo[gamemap].ptsr_lapangle 
			if angle_frompotal and tonumber(angle_frompotal) ~= nil then
				pmo.angle = FixedAngle(tonumber(angle_frompotal)*FRACUNIT)
			end
			
			if not player.ptsr.pizzaface then
				player.powers[pw_invulnerability] = CV_PTSR.tpinv.value*TICRATE+20
				--player.powers[pw_nocontrol] = 20
				L_SpeedCap(player.mo, 0)
			end
		end
		
		local pizzatime_triggertag = mapheaderinfo[gamemap].ptsr_pizzatime_triggertag
		if pizzatime_triggertag and tonumber(pizzatime_triggertag) then
			P_LinedefExecute(tonumber(pizzatime_triggertag))
		end
		
		if PTSR.john and PTSR.john.valid then
			local john = PTSR.john
			PTSR.KnockJohnPillar(john)
		end
		
		if not PTSR.IsOverTimeMusicInPriority() then
			local uList = PTSR.useBFDImus and PTSR.MusicList.BFDI or PTSR.MusicList -- hi guys, pac here
			if uList.Laps[1] and mapmusname ~= uList.Laps[1] then
				S_ChangeMusic(uList.Laps[1], true)
			end
		end
	end
end