//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

//Circuit boards are in /code/game/objects/items/weapons/circuitboards/machinery/

/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = 1
	anchored = 1
	use_power = 0
	var/obj/item/weapon/circuitboard/circuit = null
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null
	var/state = 1

	proc/update_desc()
		var/D
		if(req_components)
			D = "Requires "
			var/first = 1
			for(var/I in req_components)
				if(req_components[I] > 0)
					D += "[first?"":", "][num2text(req_components[I])] [req_component_names[I]]"
					first = 0
			if(first) // nothing needs to be added, then
				D += "nothing"
			D += "."
		desc = D

/obj/machinery/constructable_frame/machine_frame
	attackby(obj/item/P as obj, mob/user as mob)
		if(P.crit_fail)
			user << "\red This part is faulty, you cannot add this to the machine!"
			return
		switch(state)
			if(1)
				if(istype(P, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = P
					if (C.get_amount() < 5)
						user << "<span class='warning'>You need five lengths of cable to add them to the frame.</span>"
						return
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "<span class='notice'>You start to add cables to the frame.</span>"
					if(do_after(user, 20) && state == 1)
						if(C.use(5))
							user << "<span class='notice'>You add cables to the frame.</span>"
							state = 2
							icon_state = "box_1"
				else
					if(istype(P, /obj/item/weapon/wrench))
						playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
						user << "\blue You dismantle the frame"
						new /obj/item/stack/sheet/metal(src.loc, 5)
						qdel(src)
			if(2)
				if(istype(P, /obj/item/weapon/circuitboard))
					var/obj/item/weapon/circuitboard/B = P
					if(B.board_type == "machine")
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
						user << "\blue You add the circuit board to the frame."
						circuit = P
						user.drop_item()
						P.loc = src
						icon_state = "box_2"
						state = 3
						components = list()
						req_components = circuit.req_components.Copy()
						for(var/A in circuit.req_components)
							req_components[A] = circuit.req_components[A]
						req_component_names = circuit.req_components.Copy()
						for(var/A in req_components)
							var/cp = text2path(A)
							var/obj/ct = new cp() // have to quickly instantiate it get name
							req_component_names[A] = ct.name
						if(circuit.frame_desc)
							desc = circuit.frame_desc
						else
							update_desc()
						user << desc
					else
						user << "\red This frame does not accept circuit boards of this type!"
				else
					if(istype(P, /obj/item/weapon/wirecutters))
						playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
						user << "\blue You remove the cables."
						state = 1
						icon_state = "box_0"
						var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
						A.amount = 5

			if(3)
				if(istype(P, /obj/item/weapon/crowbar))
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					state = 2
					circuit.loc = src.loc
					circuit = null
					if(components.len == 0)
						user << "\blue You remove the circuit board."
					else
						user << "\blue You remove the circuit board and other components."
						for(var/obj/item/weapon/W in components)
							W.loc = src.loc
					desc = initial(desc)
					req_components = null
					components = null
					icon_state = "box_1"
				else
					if(istype(P, /obj/item/weapon/screwdriver))
						var/component_check = 1
						for(var/R in req_components)
							if(req_components[R] > 0)
								component_check = 0
								break
						if(component_check)
							playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
							var/obj/machinery/new_machine = new src.circuit.build_path(src.loc, src.dir)
							new_machine.component_parts.Cut()
							src.circuit.construct(new_machine)
							for(var/obj/O in src)
								if(circuit.contain_parts) // things like disposal don't want their parts in them
									O.loc = new_machine
								else
									O.loc = null
								new_machine.component_parts += O
							if(circuit.contain_parts)
								circuit.loc = new_machine
							else
								circuit.loc = null
							new_machine.RefreshParts()
							qdel(src)
					else
						if(istype(P, /obj/item))
							for(var/I in req_components)
								if(istype(P, text2path(I)) && (req_components[I] > 0))
									playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
									if(istype(P, /obj/item/stack/cable_coil))
										var/obj/item/stack/cable_coil/CP = P
										if(CP.get_amount() > 1)
											var/camt = min(CP.amount, req_components[I]) // amount of cable to take, idealy amount required, but limited by amount provided
											var/obj/item/stack/cable_coil/CC = new /obj/item/stack/cable_coil(src)
											CC.amount = camt
											CC.update_icon()
											CP.use(camt)
											components += CC
											req_components[I] -= camt
											update_desc()
											break
									user.drop_item()
									P.loc = src
									components += P
									req_components[I]--
									update_desc()
									break
							user << desc
							if(P && P.loc != src && !istype(P, /obj/item/stack/cable_coil))
								user << "\red You cannot add that component to the machine!"

//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
*/
/obj/item/weapon/circuitboard/vendor
	name = "circuit board (Booze-O-Mat Vendor)"
	build_path = /obj/machinery/vending/boozeomat
	board_type = "machine"
	origin_tech = "programming=1"
	frame_desc = "Requires 3 Resupply Canisters."
	req_components = list(
							/obj/item/weapon/vending_refill/boozeomat = 3)

	var/list/names_paths = list(/obj/machinery/vending/boozeomat = "Booze-O-Mat",
							/obj/machinery/vending/coffee = "Solar's Best Hot Drinks",
							/obj/machinery/vending/snack = "Getmore Chocolate Corp",
							/obj/machinery/vending/cola = "Robust Softdrinks",
							/obj/machinery/vending/cigarette = "ShadyCigs Deluxe")

/obj/item/weapon/circuitboard/vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		set_type(pick(names_paths), user)


/obj/item/weapon/circuitboard/vendor/proc/set_type(typepath, mob/user)
		build_path = typepath
		name = "circuit board ([names_paths[build_path]] Vendor)"
		user << "<span class='notice'>You set the board to [names_paths[build_path]].</span>"
		req_components = list(text2path("/obj/item/weapon/vending_refill/[copytext("[build_path]", 24)]") = 3)

/obj/item/weapon/circuitboard/smes
	name = "circuit board (SMES)"
	build_path = /obj/machinery/power/smes
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=5;engineering=5"
	frame_desc = "Requires 5 pieces of cable, 5 Power Cells and 1 Capacitor."
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/cell = 5,
							/obj/item/weapon/stock_parts/capacitor = 1)
/obj/item/weapon/circuitboard/emitter
	name = "circuit board (Emitter)"
	build_path = /obj/machinery/power/emitter
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=5;engineering=5"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)
/*#TOREMOVE - part of turbines, not yet implemented
/obj/item/weapon/circuitboard/power_compressor
	name = "circuit board (Power Compressor)"
	build_path = /obj/machinery/power/compressor
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=5;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/manipulator = 6)
*/
/obj/item/weapon/circuitboard/power_turbine
	name = "circuit board (Power Turbine)"
	build_path = /obj/machinery/power/turbine
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=5"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/capacitor = 6)
/*#TOREMOVE - when LINDA is ported
/obj/item/weapon/circuitboard/thermomachine
	name = "circuit board (Freezer)"
	desc = "Use screwdriver to switch between heating and cooling modes."
	build_path = /obj/machinery/atmospherics/unary/cold_sink/freezer
	board_type = "machine"
	origin_tech = "programming=3;plasmatech=3"
	frame_desc = "Requires 2 Matter Bins, 2 Micro Lasers, 1 piece of cable and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)
/obj/item/weapon/circuitboard/thermomachine/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(build_path == /obj/machinery/atmospherics/unary/cold_sink/freezer)
			build_path = /obj/machinery/atmospherics/unary/heat_reservoir/heater
			name = "circuit board (Heater)"
			user << "<span class='notice'>You set the board to heating.</span>"
		else
			build_path = /obj/machinery/atmospherics/unary/cold_sink/freezer
			name = "circuit board (Freezer)"
			user << "<span class='notice'>You set the board to cooling.</span>"
*/

/obj/item/weapon/circuitboard/biogenerator
	name = "circuit board (Biogenerator)"
	build_path = /obj/machinery/biogenerator
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;materials=3"
	frame_desc = "Requires 1 Matter Bin, 1 Manipulator, 1 piece of cable and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)
/obj/item/weapon/circuitboard/hydroponics
	name = "circuit board (Hydroponics Tray)"
	build_path = /obj/machinery/portable_atmospherics/hydroponics
	board_type = "machine"
	origin_tech = "programming=1;biotech=1"
	frame_desc = "Requires 2 Matter Bins and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)
/obj/item/weapon/circuitboard/microwave
	name = "circuit board (Microwave)"
	build_path = /obj/machinery/microwave
	board_type = "machine"
	origin_tech = "programming=1"
	frame_desc = "Requires 1 Micro Laser, 2 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)
/*
/obj/item/weapon/circuitboard/oven
	name = "circuit board (Oven)"
	build_path = /obj/machinery/kitchen_machine/oven
	board_type = "machine"
	origin_tech = "programming=1;plasmatech=1"
	frame_desc = "Requires 2 Micro Lasers, 5 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/console_screen = 1)
/obj/item/weapon/circuitboard/grill
	name = "circuit board (Grill)"
	build_path = /obj/machinery/kitchen_machine/grill
	board_type = "machine"
	origin_tech = "programming=1;plasmatech=1"
	frame_desc = "Requires 2 Micro Lasers, 5 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/console_screen = 1)
/obj/item/weapon/circuitboard/candy_maker
	name = "circuit board (Candy Maker)"
	build_path = /obj/machinery/kitchen_machine/candy_maker
	board_type = "machine"
	origin_tech = "programming=2"
	frame_desc = "Requires 1 Manipulator, 5 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/console_screen = 1)
#TOREMOVE - when NT cooking machines are fully implemented */
/obj/item/weapon/circuitboard/gibber
	name = "circuit board (Gibber)"
	build_path = /obj/machinery/gibber
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)


/obj/item/weapon/circuitboard/processor
	name = "circuit board (Food processor)"
	build_path = /obj/machinery/processor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/recycler
	name = "circuit board (Recycler)"
	build_path = /obj/machinery/recycler
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/seed_extractor
	name = "circuit board (Seed Extractor)"
	build_path = /obj/machinery/seed_extractor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/smartfridge
	name = "circuit board (Smartfridge)"
	build_path = /obj/machinery/smartfridge
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1)

/obj/item/weapon/circuitboard/monkey_recycler
	name = "circuit board (Monkey Recycler)"
	build_path = /obj/machinery/monkey_recycler
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/holopad
	name = "circuit board (AI Holopad)"
	build_path = /obj/machinery/hologram/holopad
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1)
/* #TOREMOVE - not yet implemented
/obj/item/weapon/circuitboard/chem_dispenser
	name = "circuit board (Portable Chem Dispenser)"
	build_path = /obj/machinery/chem_dispenser/constructable
	board_type = "machine"
	origin_tech = "materials=4;engineering=4;programming=4;plasmatech=3;biotech=3"
	frame_desc = "Requires 2 Matter Bins, 1 Capacitor, 1 Manipulator, 1 Console Screen, and 1 Power Cell."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/cell = 1)
/obj/item/weapon/circuitboard/chem_heater
	name = "circuit board (Chemical Heater)"
	build_path = /obj/machinery/chem_heater
	board_type = "machine"
	origin_tech = "materials=2;engineering=2"
	frame_desc = "Requires 1 Micro Laser and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)
//Almost the same recipe as destructive analyzer to give people choices.
/obj/item/weapon/circuitboard/experimentor
	name = "circuit board (E.X.P.E.R.I-MENTOR)"
	build_path = /obj/machinery/r_n_d/experimentor
	board_type = "machine"
	origin_tech = "magnets=1;engineering=1;programming=1;biotech=1;bluespace=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/micro_laser = 2)
*/
/obj/item/weapon/circuitboard/destructive_analyzer
	name = "Circuit board (Destructive Analyzer)"
	build_path = "/obj/machinery/r_n_d/destructive_analyzer"
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2;programming=2"
	frame_desc = "Requires 1 Scanning Module, 1 Manipulator, and 1 Micro-Laser."
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1)
/obj/item/weapon/circuitboard/autolathe
	name = "Circuit board (Autolathe)"
	build_path = "/obj/machinery/autolathe"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 3 Matter Bins, 1 Manipulator, and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 3,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)
/obj/item/weapon/circuitboard/protolathe
	name = "Circuit board (Protolathe)"
	build_path = "/obj/machinery/r_n_d/protolathe"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 2 Matter Bins, 2 Manipulators, and 2 Beakers."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/reagent_containers/glass/beaker = 2)
/obj/item/weapon/circuitboard/circuit_imprinter
	name = "Circuit board (Circuit Imprinter)"
	build_path = "/obj/machinery/r_n_d/circuit_imprinter"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 1 Matter Bin, 1 Manipulator, and 2 Beakers."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/reagent_containers/glass/beaker = 2)
/obj/item/weapon/circuitboard/pacman
	name = "Circuit Board (PACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman"
	board_type = "machine"
	origin_tech = "programming=3:powerstorage=3;plasmatech=3;engineering=3"
	frame_desc = "Requires 1 Matter Bin, 1 Micro-Laser, 2 Pieces of Cable, and 1 Capacitor."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/capacitor = 1)
/obj/item/weapon/circuitboard/pacman/super
	name = "Circuit Board (SUPERPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/super"
	origin_tech = "programming=3;powerstorage=4;engineering=4"
/obj/item/weapon/circuitboard/pacman/mrs
	name = "Circuit Board (MRSPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/mrs"
	origin_tech = "programming=3;powerstorage=5;engineering=5"
obj/item/weapon/circuitboard/rdserver
	name = "Circuit Board (R&D Server)"
	build_path = "/obj/machinery/r_n_d/server"
	board_type = "machine"
	origin_tech = "programming=3"
	frame_desc = "Requires 2 pieces of cable, and 1 Scanning Module."
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 1)

/obj/item/weapon/circuitboard/mechfab
	name = "Circuit board (Exosuit Fabricator)"
	build_path = "/obj/machinery/mecha_part_fabricator"
	board_type = "machine"
	origin_tech = "programming=3;engineering=3"
	frame_desc = "Requires 2 Matter Bins, 1 Manipulator, 1 Micro-Laser and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)
/obj/item/weapon/circuitboard/podfab
	name = "Circuit board (Spacepod Fabricator)"
	build_path = "/obj/machinery/spod_part_fabricator" //ah fuck my life
	board_type = "machine"
	origin_tech = "programming=3;engineering=3"
	frame_desc = "Requires 3 Matter Bins, 2 Manipulators, 2 Micro-Lasers, and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 3,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/micro_laser = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)
/obj/item/weapon/circuitboard/clonepod
	name = "Circuit board (Clone Pod)"
	build_path = "/obj/machinery/clonepod"
	board_type = "machine"
	origin_tech = "programming=3;biotech=3"
	frame_desc = "Requires 2 Manipulator, 2 Scanning Module, 2 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)
/obj/item/weapon/circuitboard/clonescanner
	name = "Circuit board (Cloning Scanner)"
	build_path = "/obj/machinery/dna_scannernew"
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	frame_desc = "Requires 1 Scanning Module, 1 Manipulator, 1 Micro-Laser, 2 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 2,)
/obj/item/weapon/circuitboard/mech_recharger
	name = "circuit board (Mech Bay Recharger)"
	build_path = /obj/machinery/mech_bay_recharge_port
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	frame_desc = "Requires 1 piece of cable and 5 Capacitors."
	req_components = list(
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/capacitor = 5)
							/*
/obj/item/weapon/circuitboard/teleporter_hub
	name = "circuit board (Teleporter Hub)"
	build_path = /obj/machinery/teleport/hub
	board_type = "machine"
	origin_tech = "programming=3;engineering=5;bluespace=5;materials=4"
	frame_desc = "Requires 3 Bluespace Crystals and 1 Matter Bin."
	req_components = list(
							/obj/item/bluespace_crystal = 3,
							/obj/item/weapon/stock_parts/matter_bin = 1)
/obj/item/weapon/circuitboard/teleporter_station
	name = "circuit board (Teleporter Station)"
	build_path = /obj/machinery/teleport/station
	board_type = "machine"
	origin_tech = "programming=4;engineering=4;bluespace=4"
	frame_desc = "Requires 2 Bluespace Crystals, 2 Capacitors and 1 Console Screen."
	req_components = list(
							/obj/item/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/telesci_pad
	name = "Circuit board (Telepad)"
	build_path = /obj/machinery/telepad
	board_type = "machine"
	origin_tech = "programming=4;engineering=3;materials=3;bluespace=4"
	frame_desc = "Requires 2 Bluespace Crystals, 1 Capacitor, 1 piece of cable and 1 Console Screen."
	req_components = list(
							/obj/item/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1) #TOREMOVE telesci not implemented */
/obj/item/weapon/circuitboard/sleeper
	name = "circuit board (Sleeper)"
	build_path = /obj/machinery/sleeper
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3;materials=3"
	frame_desc = "Requires 1 Matter Bin, 1 Manipulator, 1 piece of cable and 2 Console Screens."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 2)
/obj/item/weapon/circuitboard/sleep_console
	name = "circuit board (Sleeper Console)"
	build_path = /obj/machinery/sleep_console
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3;materials=3"
	frame_desc = "Requires 2 pieces of cable and 2 Console Screens."
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 2)
/obj/item/weapon/circuitboard/bodyscanner
	name = "circuit board (Body Scanner)"
	build_path = /obj/machinery/bodyscanner
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3;materials=3"
	frame_desc = "Requires 1 Scanning Module, 2 pieces of cable and 2 Console Screens."
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 2)
/obj/item/weapon/circuitboard/bodyscanner_console
	name = "circuit board (Body Scanner Console)"
	build_path = /obj/machinery/body_scanconsole
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3;materials=3"
	frame_desc = "Requires 2 pieces of cable and 2 Console Screens."
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 2)
/obj/item/weapon/circuitboard/cryo_tube
	name = "circuit board (Cryotube)"
	build_path = /obj/machinery/atmospherics/unary/cryo_cell
	board_type = "machine"
	origin_tech = "programming=4;biotech=3;engineering=4"
	frame_desc = "Requires 1 Matter Bin, 1 piece of cable and 4 Console Screens."
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 4)
/obj/item/weapon/circuitboard/cyborgrecharger
	name = "circuit board (Cyborg Recharger)"
	build_path = /obj/machinery/recharge_station
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=3"
	frame_desc = "Requires 2 Capacitors, 1 Power Cell and 1 Manipulator."
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/cell = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)
// Telecomms circuit boards:
/obj/item/weapon/circuitboard/telecomms/receiver
	name = "Circuit Board (Subspace Receiver)"
	build_path = /obj/machinery/telecomms/receiver
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=1"
	frame_desc = "Requires 1 Subspace Ansible, 1 Hyperwave Filter, 2 Manipulators, and 1 Micro-Laser."
	req_components = list(
							/obj/item/weapon/stock_parts/subspace/ansible = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/micro_laser = 1)
/obj/item/weapon/circuitboard/telecomms/hub
	name = "Circuit Board (Hub Mainframe)"
	build_path = /obj/machinery/telecomms/hub
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Manipulators, 2 Cable Coil and 2 Hyperwave Filter."
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/filter = 2)
/obj/item/weapon/circuitboard/telecomms/relay
	name = "Circuit Board (Relay Mainframe)"
	build_path = /obj/machinery/telecomms/relay
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=2"
	frame_desc = "Requires 2 Manipulators, 2 Cable Coil and 2 Hyperwave Filters."
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/filter = 2)
/obj/item/weapon/circuitboard/telecomms/bus
	name = "Circuit Board (Bus Mainframe)"
	build_path = /obj/machinery/telecomms/bus
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil and 1 Hyperwave Filter."
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1)
/obj/item/weapon/circuitboard/telecomms/processor
	name = "Circuit Board (Processor Unit)"
	build_path = /obj/machinery/telecomms/processor
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 3 Manipulators, 1 Hyperwave Filter, 2 Treatment Disks, 1 Wavelength Analyzer, 2 Cable Coils and 1 Subspace Amplifier."
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 3,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/subspace/treatment = 2,
							/obj/item/weapon/stock_parts/subspace/analyzer = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/amplifier = 1)
/obj/item/weapon/circuitboard/telecomms/server
	name = "Circuit Board (Telecommunication Server)"
	build_path = /obj/machinery/telecomms/server
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil and 1 Hyperwave Filter."
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1)
/obj/item/weapon/circuitboard/telecomms/broadcaster
	name = "Circuit Board (Subspace Broadcaster)"
	build_path = /obj/machinery/telecomms/broadcaster
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=1"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil, 1 Hyperwave Filter, 1 Ansible Crystal and 2 High-Powered Micro-Lasers. "
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/subspace/crystal = 1,
							/obj/item/weapon/stock_parts/micro_laser/high = 2)
/* #TOREMOVE - not yet implemented
/obj/item/weapon/circuitboard/ore_redemption
	name = "circuit board (Ore Redemption)"
	build_path = /obj/machinery/mineral/ore_redemption
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/device/assembly/igniter = 1)
/obj/item/weapon/circuitboard/mining_equipment_vendor
	name = "circuit board (Mining Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/matter_bin = 3)
*/