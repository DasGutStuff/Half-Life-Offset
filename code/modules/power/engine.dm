/turf/simulated/floor/engine/attack_hand(mob/user)
	user.Move_Pulled(src)

/turf/simulated/floor/engine/ex_act(severity)
	switch(severity)
		if(1.0)
			ChangeTurf(baseturf)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				ChangeTurf(baseturf)
				qdel(src)
				return
		else
	return

/turf/simulated/floor/engine/blob_act()
	if (prob(25))
		ChangeTurf(/turf/space)
		qdel(src)
		return
	return