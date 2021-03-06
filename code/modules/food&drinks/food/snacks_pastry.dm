//Pastry is a food that is made from dough which is made from wheat or rye flour.
//This file contains pastries that don't fit any existing categories.
////////////////////////////////////////////DONUTS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	bitesize = 5
	bonus_reagents = list("sugar" = 1)
	list_reagents = list("nutriment" = 3, "sugar" = 2)
	var/extra_reagent = null
	var/overlay_state = "box-donut1"
	filling_color = "#D2691E"

/obj/item/weapon/reagent_containers/food/snacks/donut/New()
	..()
	if(prob(30))
		icon_state = "donut2"
		src.overlay_state = "box-donut2"
		name = "frosted donut"
		reagents.add_reagent("sprinkles", 2)
		bonus_reagents = list("sprinkles" = 2, "sugar" = 1)
		filling_color = "#FF69B4"

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	name = "chaos donut"
	desc = "Like life, it never quite tastes the same."
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos/New()
	..()
	extra_reagent = pick("nutriment", "capsaicin", "frostoil", "krokodil", "plasma", "cocoa", "slimejelly", "banana", "berryjuice", "omnizine")
	reagents.add_reagent("[extra_reagent]", 3)
	bonus_reagents = list("[extra_reagent]" = 3, "sugar" = 1)
	if(prob(30))
		icon_state = "donut2"
		name = "frosted chaos donut"
		reagents.add_reagent("sprinkles", 2)
		bonus_reagents = list("sprinkles" = 2, "[extra_reagent]" = 3, "sugar" = 1)
		filling_color = "#FF69B4"

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bonus_reagents = list("sugar" = 1, "vitamin" = 1)
	extra_reagent = "berryjuice"

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/New()
	..()
	if(extra_reagent)
		reagents.add_reagent("[extra_reagent]", 3)
	if(prob(30))
		icon_state = "jdonut2"
		src.overlay_state = "box-donut2"
		name = "frosted jelly Donut"
		reagents.add_reagent("sprinkles", 2)
		bonus_reagents = list("sprinkles" = 2, "sugar" = 1)
		filling_color = "#FF69B4"

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/slimejelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	extra_reagent = "slimejelly"

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/cherryjelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	extra_reagent = "cherryjelly"

////////////////////////////////////////////MUFFINS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 6)
	filling_color = "#F4A460"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/muffin/berry
	name = "berry muffin"
	icon_state = "berrymuffin"
	desc = "A delicious and spongy little cake, with berries."

/obj/item/weapon/reagent_containers/food/snacks/muffin/booberry
	name = "booberry muffin"
	icon_state = "berrymuffin"
	alpha = 125
	desc = "My stomach is a graveyard! No living being can quench my bloodthirst!"

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 5)
	filling_color = "#FFE4E1"

////////////////////////////////////////////WAFFLES////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 8, "vitamin" = 1)
	filling_color = "#D2691E"

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "\improper Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 10, "vitamin" = 1)
	filling_color = "#9ACD32"

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "\improper Soylent Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 10, "vitamin" = 1)
	filling_color = "#9ACD32"

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "roffle waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	bitesize = 4
	bonus_reagents = list("vitamin" = 2)
	list_reagents = list("nutriment" = 8, "psilocybin" = 2, "vitamin" = 2)
	filling_color = "#00BFFF"

////////////////////////////////////////////OTHER////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	bitesize = 1
	bonus_reagents = list("nutriment" = 1)
	list_reagents = list("nutriment" = 1)
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	list_reagents = list("nutriment" = 4)
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/donkpocket/warm
	filling_color = "#CD853F"
	var/warm = 0

	proc/cooltime() //Not working, derp?
		if (src.warm)
			spawn( 4200 )
				src.warm = 0
				src.reagents.del_reagent("tricordrazine")
				src.name = "donk-pocket"
		return

//#TOREMOVE - change this to use the below item instead of adding the reagent in microwave code

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/warm
	name = "warm Donk-pocket"
	desc = "The heated food of choice for the seasoned traitor."
	bonus_reagents = list("omnizine" = 3)
	list_reagents = list("nutriment" = 4, "omnizine" = 3)

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	bonus_reagents = list("nutriment" = 2)
	list_reagents = list("nutriment" = 3)
	filling_color = "#F4A460"

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	list_reagents = list("nutriment" = 5)
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5)
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit/New()
	..()
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		reagents.add_reagent("omnizine", 5)
		bonus_reagents = list("omnizine" = 5, "nutriment" = 1, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	bitesize = 1
	bonus_reagents = list("nutriment" = 1)
	list_reagents = list("nutriment" = 1)
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to go down on."
	icon_state = "hotdog"
	bitesize = 3
	bonus_reagents = list("nutriment" = 1, "vitamin" = 3)
	list_reagents = list("nutriment" = 6, "ketchup" = 3, "vitamin" = 3)
	filling_color = "#8B0000"

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	filling_color = "#8B0000"

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"
	bonus_reagents = list("nutriment" = 1, "sugar" = 3)
	list_reagents = list("nutriment" = 3, "sugar" = 3)
	filling_color = "#CD853F"

/obj/item/weapon/reagent_containers/food/snacks/chococornet
	name = "chocolate cornet"
	desc = "Which side's the head, the fat end or the thin end?"
	icon_state = "chococornet"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	filling_color = "#FFE4C4"

/obj/item/weapon/reagent_containers/food/snacks/oatmealcookie
	name = "oatmeal cookie"
	desc = "The best of both cookie and oat"
	icon_state = "oatmealcookie"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	filling_color = "#D2691E"

/obj/item/weapon/reagent_containers/food/snacks/raisincookie
	name = "raisin cookie"
	desc = "Why would you put raisins on a cookie?"
	icon_state = "raisincookie"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/cherrycupcake
	name = "cherry cupcake"
	desc = "A sweet cupcake with cherry bits."
	icon_state = "cherrycupcake"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/bluecherrycupcake
	name = "blue cherry cupcake"
	desc = "Blue cherries inside a delicious cupcake"
	icon_state = "bluecherrycupcake"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 3)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	filling_color = "#F0E68C"