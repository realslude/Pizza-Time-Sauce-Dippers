function PTSR.drawVoteScreenRoulette(v)
	customhud.CustomFontString(v, 160*FU, 20*FU, tostring("CHOOSING MAP!"), "PTFNT", V_SNAPTOTOP, "center", FRACUNIT/2, SKINCOLOR_WHITE)

	for i,info in ipairs(PTSR.vote_roulettelist) do
		local x = 35*FU
		local y = 60*FU
		
		local sel_x = x
		local sel_y = y
		
		local inner_x = x
		local inner_y = y
		
		local mapscale = FU/4
		local mapnum = info.mapnum
		local mappatch = v.cachePatch(G_BuildMapName(info.mapnum).."P")
		local selpatch = v.cachePatch("PTSR_MAP_PANEL")
		local innerpatch = v.cachePatch("PTSR_MAP_INNER")
		
		local player_skin = info.voter_info.skin
		local player_skincolor = info.voter_info.skincolor
		
		local player_patch = v.getSprite2Patch(player_skin, SPR2_XTRA)
		local player_colormap = v.getColormap(player_skin, player_skincolor)
		
		local x_offset = ((i-1)%6)*(50*FU)
		local column = FixedCeil( FixedDiv(i*FU, 6*FU) ) / FU
		
		local innerflag = V_50TRANS|V_ADD
		
		-- Adjust map icon's position
		x = $ - FixedMul(mappatch.width*FU, mapscale)/2
		y = $ - FixedMul(mappatch.height*FU, mapscale)/2
		x = $ + x_offset
		y = $ + (column-1)*(30*FU)
		
		-- Adjust selection for map icon's position
		sel_x = $ - FixedMul(selpatch.width*FU, mapscale)/2
		sel_y = $ - FixedMul(selpatch.height*FU, mapscale)/2
		sel_x = $ + x_offset
		sel_y = $ + (column-1)*(30*FU)
		
		-- Adjust inner yellow selection for map icon's position
		inner_x = $ - FixedMul(innerpatch.width*FU, mapscale)/2
		inner_y = $ - FixedMul(innerpatch.height*FU, mapscale)/2
		inner_x = $ + x_offset
		inner_y = $ + (column-1)*(30*FU)
		
		v.drawScaled(x, y, mapscale, mappatch)
		
		if PTSR.vote_routette_selection == i then
			v.drawScaled(inner_x, inner_y, mapscale, innerpatch, innerflag)
		
			v.drawScaled(sel_x, sel_y, mapscale, selpatch)
		end
		
		v.drawScaled(x, y, mapscale, player_patch, 0, player_colormap)
	end
end
