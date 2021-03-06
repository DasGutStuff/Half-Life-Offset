/////////////////// Dough Ingredients ////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "dough"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/store/bread/plain
	list_reagents = list("nutriment" = 6)
	w_class = 3


// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/weapon/reagent_containers/food/snacks/flatdough(loc)
			user << "<span class='notice'>You flatten [src].</span>"
			qdel(src)
		else
			user << "<span class='warning'>You need to put [src] on a surface to roll it out!</span>"
	else
		..()


// sliceable into 3xdoughslices
/obj/item/weapon/reagent_containers/food/snacks/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	slices_num = 3
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/pizzabread
	list_reagents = list("nutriment" = 6)
	w_class = 3

/obj/item/weapon/reagent_containers/food/snacks/pizzabread
	name = "pizza bread"
	desc = "Add ingredients to make a pizza"
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "pizzabread"
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/pizza
	list_reagents = list("nutriment" = 7)
	w_class = 3


/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A slice of dough. Can be cooked into a bun."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "doughslice"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/bun
	filling_color = "#CD853F"
/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food/burgers&bread.dmi'
	icon_state = "bun"
	list_reagents = list("nutriment" = 1)
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/burger
	filling_color = "#CD853F"
/obj/item/weapon/reagent_containers/food/snacks/cakebatter
	name = "cake batter"
	desc = "Cook it to get a cake."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "cakebatter"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/store/cake/plain
	list_reagents = list("nutriment" = 9)
	w_class = 3
// Cake batter + rolling pin = pie dough
/obj/item/weapon/reagent_containers/food/snacks/cakebatter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/weapon/reagent_containers/food/snacks/piedough(loc)
			user << "<span class='notice'>You flatten [src].</span>"
			qdel(src)
		else
			user << "<span class='warning'>You need to put [src] on a surface to roll it out!</span>"
	else
		..()
/obj/item/weapon/reagent_containers/food/snacks/piedough
	name = "pie dough"
	desc = "Cook it to get a pie."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "piedough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/rawpastrybase
	slices_num = 3
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/pie/plain
	list_reagents = list("nutriment" = 9)
	w_class = 3
/obj/item/weapon/reagent_containers/food/snacks/rawpastrybase
	name = "raw pastry base"
	desc = "Must be cooked before use."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "rawpastrybase"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/pastrybase
	filling_color = "#CD853F"
	list_reagents = list("nutriment" = 1)
/obj/item/weapon/reagent_containers/food/snacks/pastrybase
	name = "pastry base"
	desc = "A base for any self-respecting pastry"
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "pastrybase"
	list_reagents = list("nutriment" = 1)
	filling_color = "#CD853F"