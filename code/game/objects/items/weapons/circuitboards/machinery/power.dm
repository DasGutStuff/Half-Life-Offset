#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/weapon/circuitboard/smes
	name = T_BOARD("superconductive magnetic energy storage")
	build_path = "/obj/machinery/power/smes/buildable"
	board_type = "machine"
	origin_tech = "powerstorage=6;engineering=4"
	frame_desc = "Requires 1 superconducting magnetic coil and 30 wires."
	req_components = list("/obj/item/weapon/smes_coil" = 1, "/obj/item/stack/cable_coil" = 30)

/obj/item/weapon/circuitboard/batteryrack
	name = T_BOARD("battery rack PSU")
	build_path = "/obj/machinery/power/smes/batteryrack"
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=2"
	frame_desc = "Requires 3 power cells."
	req_components = list("/obj/item/weapon/stock_parts/cell" = 3)

/obj/item/weapon/circuitboard/ghettosmes
	name = T_BOARD("makeshift PSU")
	desc = "An APC circuit repurposed into some power storage device controller"
	build_path = "/obj/machinery/power/smes/batteryrack/makeshift"
	board_type = "machine"
	frame_desc = "Requires 3 power cells."
	req_components = list("/obj/item/weapon/stock_parts/cell" = 3)
