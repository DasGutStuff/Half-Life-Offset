
obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/atmos/heat.dmi'
	icon_state = "intact"
	pipe_icon = "hepipe"
	level = 2
	var/initialize_directions_he
	var/surface = 2	//surface area in m^2

	minimum_temperature_difference = 20
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

	// BubbleWrap
	New()
		..()
		initialize_directions_he = initialize_directions	// The auto-detection from /pipe is good enough for a simple HE pipe
	// BubbleWrap END

	initialize()
		normalize_dir()
		var/node1_dir
		var/node2_dir

		for(var/direction in cardinal)
			if(direction&initialize_directions_he)
				if (!node1_dir)
					node1_dir = direction
				else if (!node2_dir)
					node2_dir = direction

		for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,node1_dir))
			if(target.initialize_directions_he & get_dir(target,src))
				node1 = target
				break
		for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,node2_dir))
			if(target.initialize_directions_he & get_dir(target,src))
				node2 = target
				break
		if(!node1 && !node2)
			qdel(src)
			return

		update_icon()
		return


	process()
		if(!parent)
			..()
		else
			var/environment_temperature = 0
			if(istype(loc, /turf/simulated/))
				if(loc:blocks_air)
					environment_temperature = loc:temperature
				else
					var/datum/gas_mixture/environment = loc.return_air()
					environment_temperature = environment.temperature
				var/datum/gas_mixture/pipe_air = return_air()
				if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
					parent.temperature_interact(loc, volume, thermal_conductivity)
			else if(istype(loc, /turf/space/))
				parent.radiate_heat_to_space(surface, 1)


obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'icons/atmos/junction.dmi'
	icon_state = "intact"
	pipe_icon = "hejunction"
	level = 2
	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	// BubbleWrap
	New()
		.. ()
		switch ( dir )
			if ( SOUTH )
				initialize_directions = NORTH
				initialize_directions_he = SOUTH
			if ( NORTH )
				initialize_directions = SOUTH
				initialize_directions_he = NORTH
			if ( EAST )
				initialize_directions = WEST
				initialize_directions_he = EAST
			if ( WEST )
				initialize_directions = EAST
				initialize_directions_he = WEST
	// BubbleWrap END

	initialize()
		for(var/obj/machinery/atmospherics/target in get_step(src,initialize_directions))
			if(target.initialize_directions & get_dir(target,src))
				node1 = target
				break
		for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,initialize_directions_he))
			if(target.initialize_directions_he & get_dir(target,src))
				node2 = target
				break

		if(!node1&&!node2)
			qdel(src)
			return

		update_icon()
		return
