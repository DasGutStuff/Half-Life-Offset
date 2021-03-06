/obj/machinery/cell_charger
	name = "heavy-duty cell charger"
	desc = "A much more powerful version of the standard recharger that is specially designed for charging power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 40000	//40 kW. (this the power drawn when charging)
	power_channel = EQUIP
	var/obj/item/weapon/stock_parts/cell/charging = null
	var/chargelevel = -1

/obj/machinery/cell_charger/proc/updateicon()
	icon_state = "ccharger[charging ? 1 : 0]"

	if(charging && !(stat & (BROKEN|NOPOWER)) )

		var/newlevel = 	round(charging.percent() * 4.0 / 99)
		//world << "nl: [newlevel]"

		if(chargelevel != newlevel)

			overlays.Cut()
			overlays += "ccharger-o[newlevel]"

			chargelevel = newlevel
	else
		overlays.Cut()

/obj/machinery/cell_charger/examine(mob/user)
	if(!..(user, 5))
		return

	user << "There's [charging ? "a" : "no"] cell in the charger."
	if(charging)
		user << "Current charge: [charging.charge]"

/obj/machinery/cell_charger/attackby(obj/item/weapon/W, mob/user)
	if(stat & BROKEN)
		return

	if(istype(W, /obj/item/weapon/stock_parts/cell) && anchored)
		if(charging)
			user << "\red There is already a cell in the charger."
			return
		else
			var/area/a = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return
			if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				user << "\red The [name] blinks red as you try to insert the cell!"
				return

			user.drop_item()
			W.loc = src
			charging = W
			user.visible_message("[user] inserts a cell into the charger.", "You insert a cell into the charger.")
			chargelevel = -1
		updateicon()
	else if(istype(W, /obj/item/weapon/wrench))
		if(charging)
			user << "\red Remove the cell first!"
			return

		anchored = !anchored
		user << "You [anchored ? "attach" : "detach"] the cell charger [anchored ? "to" : "from"] the ground"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)

/obj/machinery/cell_charger/attack_hand(mob/user)
	if(charging)
		usr.put_in_hands(charging)
		charging.add_fingerprint(user)
		charging.updateicon()

		src.charging = null
		user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
		chargelevel = -1
		updateicon()

/obj/machinery/cell_charger/attack_ai(mob/user)
	if(istype(user, /mob/living/silicon/robot) && Adjacent(user)) // Borgs can remove the cell if they are near enough
		if(!src.charging)
			return

		charging.loc = src.loc
		charging.updateicon()
		charging = null
		update_icon()
		user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")


/obj/machinery/cell_charger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	if(charging)
		charging.emp_act(severity)
	..(severity)


/obj/machinery/cell_charger/process()
	//world << "ccpt [charging] [stat]"
	if((stat & (BROKEN|NOPOWER)) || !anchored)
		update_use_power(0)
		return

	if (charging && !charging.fully_charged())
		charging.give(active_power_usage*CELLRATE)
		update_use_power(2)

		updateicon()
	else
		update_use_power(1)
