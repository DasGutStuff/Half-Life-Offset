

/obj/item/weapon/gun/grenadelauncher
	name = "grenade launcher"
	icon = 'icons/obj/gun.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = 4
	throw_speed = 2
	throw_range = 10
	force = 5
	var/list/grenades = new/list()
	var/max_grenades = 3
	materials = list(MAT_METAL=2000)

	examine(mob/user)
		if(..(user, 2))
			user << "<span class='notice'>[grenades] / [max_grenades] Grenades.</span>"

	attackby(obj/item/I as obj, mob/user as mob)

		if((istype(I, /obj/item/weapon/grenade)))
			if(grenades.len < max_grenades)
				user.drop_item()
				I.loc = src
				grenades += I
				user << "<span class='notice'>You put the grenade in the grenade launcher.</span>"
				user << "<span class='notice'>[grenades.len] / [max_grenades] Grenades.</span>"
			else
				usr << "<span class='warning'>The grenade launcher cannot hold more grenades.</span>"

	afterattack(obj/target, mob/user , flag)

		if (istype(target, /obj/item/weapon/storage/backpack ))
			return

		else if (locate (/obj/structure/table, src.loc))
			return

		else if(target == user)
			return

		if(grenades.len)
			spawn(0) fire_grenade(target,user)
		else
			usr << "<span class='warning'>The grenade launcher is empty.</span>"

	proc
		fire_grenade(atom/target, mob/user)
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("<span class='warning'>[] fired a grenade!</span>", user), 1)
			user << "<span class='warning'>You fire the grenade launcher!</span>"
			var/obj/item/weapon/grenade/chem_grenade/F = grenades[1] //Now with less copypasta!
			grenades -= F
			F.loc = user.loc
			F.throw_at(target, 30, 2, user)
			message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from a grenade launcher ([src.name]).")
			log_game("[key_name_admin(user)] used a grenade ([src.name]).")
			F.active = 1
			F.icon_state = initial(icon_state) + "_active"
			playsound(user.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
			spawn(15)
				F.prime()