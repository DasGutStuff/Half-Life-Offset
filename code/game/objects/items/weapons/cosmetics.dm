/obj/item/weapon/lipstick
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	w_class = 1.0
	var/colour = "red"
	var/open = 0

/obj/item/weapon/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/weapon/lipstick/jade
	//It's still called Jade, but theres no HTML color for jade, so we use lime.
	name = "jade lipstick"
	colour = "lime"

/obj/item/weapon/lipstick/black
	name = "black lipstick"
	colour = "black"

/obj/item/weapon/lipstick/random
	name = "lipstick"

/obj/item/weapon/lipstick/random/New()
	colour = pick("red","purple","lime","black","green","blue","white")
	name = "[colour] lipstick"


/obj/item/weapon/lipstick/attack_self(mob/user as mob)
	overlays.Cut()
	user << "<span class='notice'>You twist \the [src] [open ? "closed" : "open"].</span>"
	open = !open
	if(open)
		var/image/colored = image("icon"='icons/obj/items.dmi', "icon_state"="lipstick_uncap_color")
		colored.color = colour
		icon_state = "lipstick_uncap"
		overlays += colored
	else
		icon_state = "lipstick"

/obj/item/weapon/lipstick/attack(mob/M as mob, mob/user as mob)
	if(!open)	return

	if(!istype(M, /mob))	return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.lip_style)	//if they already have lipstick on
			user << "<span class='notice'>You need to wipe off the old lipstick first!</span>"
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] does their lips with \the [src].</span>", \
								 "<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
			H.lip_style = "lipstick"
			H.lip_color = colour
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user, 20, target = H) && do_after(H, 20, 5, 0))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] does [H]'s lips with \the [src].</span>", \
									 "<span class='notice'>You apply \the [src].</span>")
				H.lip_style = "lipstick"
				H.lip_color = colour
				H.update_body()
	else
		user << "<span class='notice'>Where are the lips on that?</span>"

//you can wipe off lipstick with paper! see code/modules/paperwork/paper.dm, paper/attack()


/obj/item/weapon/haircomb //sparklysheep's comb
	name = "purple comb"
	desc = "A pristine purple comb made from flexible plastic."
	w_class = 1.0
	icon = 'icons/obj/items.dmi'
	icon_state = "purplecomb"
	item_state = "purplecomb"




/obj/item/weapon/haircomb/attack_self(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		user.visible_message(text("\red [] uses [] to comb their hair with incredible style and sophistication. What a [].", user, src, user.gender == FEMALE ? "lady" : "guy"))
	return

/obj/item/weapon/haircomb/attack(mob/living/carbon/M as mob, mob/user as mob)
	user.visible_message("\red [user] combs [M]'s hair with the [name]</span>")
	return

/obj/item/weapon/dumbbell //sparklysheep's comb
	name = "dumbbell"
	desc = "A pristine steel dumbbell on a metal bar that is quite heavy."
	w_class = 1.0
	icon = 'icons/obj/items.dmi'
	icon_state = "dumbell1"
	item_state = "dumbell1"

/obj/item/weapon/dumbbell/attack_self(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		user.visible_message(text("\red [] lifts the [] up high. What an amazing []!", user, src, user.gender == FEMALE ? "woman" : "guy"))
	return

/obj/item/weapon/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items.dmi'
	icon_state = "razor"
	flags = CONDUCT
	w_class = 1


/obj/item/weapon/razor/proc/shave(mob/living/carbon/human/H, location = "mouth")
	if(location == "mouth")
		H.f_style = "Shaved"
	else
		H.h_style = "Skinhead"

	H.update_hair()
	playsound(loc, 'sound/items/Welder2.ogg', 20, 1)


/obj/item/weapon/razor/attack(mob/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		var/location = user.zone_sel.selecting
		if(location == "mouth")
			if(!get_location_accessible(H, location))
				user << "<span class='warning'>The mask is in the way!</span>"
				return
			if(H.f_style == "Shaved")
				user << "<span class='warning'>Already clean-shaven!</span>"
				return

			if(H == user) //shaving yourself
				user.visible_message("[user] starts to shave their facial hair with [src].", \
									 "<span class='notice'>You take a moment to shave your facial hair with [src]...</span>")
				if(do_after(user, 50, target = H))
					user.visible_message("[user] shaves his facial hair clean with [src].", \
										 "<span class='notice'>You finish shaving with [src]. Fast and clean!</span>")
					shave(H, location)
			else
				var/turf/H_loc = H.loc
				user.visible_message("<span class='warning'>[user] tries to shave [H]'s facial hair with [src].</span>", \
									 "<span class='notice'>You start shaving [H]'s facial hair...</span>")
				if(do_after(user, 50, target = H))
					if(H_loc == H.loc)
						user.visible_message("<span class='warning'>[user] shaves off [H]'s facial hair with [src].</span>", \
											 "<span class='notice'>You shave [H]'s facial hair clean off.</span>")
						shave(H, location)

		else if(location == "head")
			if(!get_location_accessible(H, location))
				user << "<span class='warning'>The headgear is in the way!</span>"
				return
			if(H.h_style == "Bald" || H.h_style == "Balding Hair" || H.h_style == "Skinhead")
				user << "<span class='warning'>There is not enough hair left to shave!</span>"
				return

			if(H == user) //shaving yourself
				user.visible_message("[user] starts to shave their head with [src].", \
									 "<span class='notice'>You start to shave your head with [src]...</span>")
				if(do_after(user, 5, target = H))
					user.visible_message("[user] shaves his head with [src].", \
										 "<span class='notice'>You finish shaving with [src].</span>")
					shave(H, location)
			else
				var/turf/H_loc = H.loc
				user.visible_message("<span class='warning'>[user] tries to shave [H]'s head with [src]!</span>", \
									 "<span class='notice'>You start shaving [H]'s head...</span>")
				if(do_after(user, 50, target = H))
					if(H_loc == H.loc)
						user.visible_message("<span class='warning'>[user] shaves [H]'s head bald with [src]!</span>", \
											 "<span class='notice'>You shave [H]'s head bald.</span>")
						shave(H, location)
		else
			..()
	else
		..()
