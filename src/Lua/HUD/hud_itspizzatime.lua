local itspizzatime_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	if PTSR.pizzatime and PTSR.pizzatime_tics then
		/*
		if PTSR.pizzatime_tics < 85
			v.draw(0, 0, v.cachePatch("PIZZAPAL"), V_50TRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER)
		end
		*/
	end
	if PTSR.pizzatime and PTSR.pizzatime_tics and PTSR.pizzatime_tics < 10*TICRATE then
		local patch, patchscale = PTSR.getPatch(v, "ITSPIZZATIME1")
		if CV_PTSR.homework.value then
			patch, patchscale = PTSR.getPatch(v, "ITSHWTIME1")
		end
		if leveltime % 3 then
			patch, patchscale = PTSR.getPatch(v, "ITSPIZZATIME2")
			if CV_PTSR.homework.value then
				patch, patchscale = PTSR.getPatch(v, "ITSHWTIME2")
			end
		end
		if CV_PTSR.homework.value then
			v.drawScaled(0, (250*FU) - (PTSR.pizzatime_tics*FU)*3, (patchscale/3)*3/2, patch)
		else
			v.drawScaled(100*FRACUNIT, (250*FU) - (PTSR.pizzatime_tics*FU)*3, (patchscale/3)*3/2, patch)
		end
	end
end

customhud.SetupItem("PTSR_itspizzatime", ptsr_hudmodname, itspizzatime_hud, "game", 0)
