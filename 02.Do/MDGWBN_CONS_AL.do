***********************************************************************************
* Madagascar 2022 CEQ
* Developed by: Fatoumata Dieng
* Section: Assices
************************************************************************************

// Path:


**************************************************************************
**************************************************************************

	use "$raw\S09_CONS_A.dta", clear
	
	sort	hhgrap hhnum
	egen 	hhid = 	concat(hhgrap hhnum), format(%9.0g) punct(",")
	rename 	hhgrap 	cluster
	
	drop 	q9a_02 				// Drop the filter yes/no questions
	rename 	q9a_01 item_t

	gen amount = q9a_03 + q9a_04 + q9a_05 + q9a_06 + q9a_07
	
	recode amount (. = 0)
	/*Dataset contains the complete list of items for all expenditures, for 
	all households, whether they consumed them or not. If household did not 
	consume that item this is recorded as missing value. These are not missing 
	values: they are zeros. So we recode them as zeros*/
	
	drop q9a_03 q9a_04 q9a_05 q9a_06 q9a_07
	/*Note that original dataset distinguishes different expenditure categories
	for events and celebrations: food (q9a_03); drinks (q9a_04); clothing (q9a_05); 
	rent of location (q9a_06) and other expenditure (q9a_07). We aggregated all 
	expenditure in the "amount" variable, and dropped original variables, 
	but maybe we need to disaggregate categories.*/
	
	gen desc = ""
	replace desc = "Ceremony: Fin du Ramadan" 					if item_t == 1
	replace desc = "Ceremony: other muslim celebrations" 		if item_t == 2
	replace desc = "Ceremony: christmas" 						if item_t == 3
	replace desc = "Ceremony: easter" 							if item_t == 4
	replace desc = "Ceremony: pentecost" 						if item_t == 5
	replace desc = "Ceremony: other christian celebrations" 	if item_t == 6
	replace desc = "Ceremony: celebrations of other religions" 	if item_t == 7
	replace desc = "Ceremony: new year" 						if item_t == 8
	replace desc = "Ceremony: national celebration" 			if item_t == 9
	replace desc = "Ceremony: marriage" 						if item_t == 10
	replace desc = "Ceremony: baptism" 							if item_t == 11
	replace desc = "Ceremony: communion/confirmation" 			if item_t == 12
	replace desc = "Ceremony: funerals" 						if item_t == 13
	replace desc = "Ceremony: exhumation" 						if item_t == 14
	replace desc = "Ceremony: circumcision" 					if item_t == 15
	replace desc = "Ceremony: other celebrations" 				if item_t == 16
	assert !mi(desc)
	
	*tostring item_t, gen(item)
	rename item_t item

	*drop item_t
	
	gen str3 recall = "12M"
	
	replace amount=12*amount
	
	order hhid, after(hhnum)
	
	gen category = "events and ceremonies" 
	
	label define item 1 "Ceremony: Fin du Ramadan" 2 "Ceremony: other muslim celebrations" 3 "Ceremony: christmas" 4 "Ceremony: easter" 5 "Ceremony: pentecost" 6 "Ceremony: other christian celebrations" 7 "Ceremony: celebrations of other religions" 8 "Ceremony: new year" 9 "Ceremony: national celebration" 10 "Ceremony: marriage" 11 "Ceremony: baptism" 12 "Ceremony: communion/confirmation" 13 "Ceremony: funerals" 14 "Ceremony: exhumation" 15 "Ceremony: circumcision" 16 "Ceremony: other celebrations"
	label values item item
	
tab item,m
	
	save "$temp\S09_CONS_A.dta", replace

*************************************************************************
*************************************************************************

	use "$raw\S09_CONS_B.dta", clear
	
	sort 	hhgrap hhnum
	egen 	hhid = 	concat(hhgrap hhnum), format(%9.0g) punct(",")
	rename 	hhgrap 	cluster
	
	drop 	q9b_02 				// Drop the filter yes/no questions
	
	rename 	q9b_01 item_t
	decode item_t, gen(desc)
	*tostring item_t, gen (item)
	rename item_t item

	*drop item_t
	
	rename 	q9b_03 amount
	
	recode amount (. = 0)
	/*Dataset contains the complete list of items for all expenditures, for 
	all households, whether they consumed them or not. If household did not 
	consume that item this is recorded as missing value. These are not missing 
	values: they are zeros. So we recode them as zeros*/
		
	gen str3 recall = "7D"
	
	replace amount=52*amount
	
	gen category = "other expenditures - 7D"
	
	order hhid, after(hhnum)
	
		
	save "$temp\S09_CONS_B.dta", replace
	
********************************************************************
********************************************************************


	use "$raw\S09_CONS_C.dta", clear
	
	sort	hhgrap hhnum
	egen 	hhid = 	concat(hhgrap hhnum), format(%9.0g) punct(",")
	rename 	hhgrap 	cluster
	
	drop 	q9c_02 	// these are the filter yes/no questions
	
	rename 	q9c_01 item_t
	decode item_t, gen(desc)
	tostring item_t, gen (item)
	drop item_t
	
	rename 	q9c_03 amount
	
	replace amount=12*amount
	
	recode amount (. = 0)
	/*Dataset contains the complete list of items for all expenditures, for 
	all households, whether they consumed them or not. If household did not 
	consume that item this is recorded as missing value. These are not missing 
	values: they are zeros. So we recode them as zeros*/
		
	gen str3 recall = "30D"
	
	gen category = "other expenditures - 30D"
	
	label define item 301 "Whisky et autres liqueurs" 302 "Vins" 303 "Gaz domestique" 304 "Carburant pour groupe electrogène à usage domestique" 305 "Piles électriques" 306 "Insecticide, tortillon anti-moustique, cire" 307 "Salaire du personnel de maison (gardien, boy, chauffeur, cuisinier, etc.)" 308 "Frais de ramassage des ordures ménagères" 309 "Frais de mouture des céréales" 310 "Frais de parking mensuel" 311 "Revues, journal ou magazine mensuel etc." 312 "Frais de coiffure homme et femme (salon, tressage, coupe, etc.), manicure, pédicure" 313 "Savon de toilette" 314 "Pâte dentifrice" 315 "Papier toilette" 316 "Serviettes hygiéniques, couches jetables pour bébé, etc." 317 "Lait, lotion de toilette corporelle (glycérine, vaseline, etc.)" 318 "Autres produits de toilettes (rasoir, champoing, coton, etc.)" 319 "Briquet" 320 "Vêtements d'occasion (Friperie) femmes (15 ans et plus): robe, jupe, pantalon, ensemble, etc." 321 "Sous-vêtements d'occasion (Friperie) femme (15 ans et plus): slip, jupon, tee shirt,soutien gorge, collant, etc." 322 "Vêtements d'occasion (Friperie) enfants (0-14 ans): layette pour bébé, chemise, pantalon garçon, robe fillette, slip enfant, blouses, etc. (Pas inclure les uniformes scolaires)" 323 "Vêtements d'occasion (Friperie) hommes (15 ans et plus): chemise, pantalon, veste, ensemble, vêtements de travail, etc." 324 "Sous-vêtements d'occasion (Friperie) homme (15 ans et plus): slip, chaussettes, tee shirt et maillot de corps, etc." 325 "Crédit de communication pour téléphone fixe" 326 "Frais d'abonnement au réseau de distribution d'eau" 327 "Frais d'abonnement au réseau de distribution d'électricité" 329 "Antibiotique" 330 "Anti-inflammatoire" 331 "Anti-dépresseurs" 332 "Anxiolitiques" 333 "Anti-histaminiques" 334 "Antidiabétique" 335 "Anti hypertendu" 336 "Antalgique" 337 "Fortifiant (Magnesium,Calcium, Vitamine, etc…)"
	
	order hhid, after(hhnum)
		
	save "$temp\S09_CONS_C.dta", replace

	
**************************************************************************
**************************************************************************

	use "$raw\S09_CONS_D.dta", clear
	
	sort 	hhgrap hhnum
	egen 	hhid = 	concat(hhgrap hhnum), format(%9.0g) punct(",")
	rename 	hhgrap 	cluster
	
	drop 	q9d_02 			// Drop the filter yes/no questions
	
	rename 	q9d_01 item_t
	decode item_t, gen(desc)
	tostring item_t, gen (item)
	drop item_t
	
	rename 	q9d_03 amount
	
	replace amount=4*amount
	
	recode amount (. = 0)
	/*Dataset contains the complete list of items for all expenditures, for 
	all households, whether they consumed them or not. If household did not 
	consume that item this is recorded as missing value. These are not missing 
	values: they are zeros. So we recode them as zeros*/
		
	gen str3 recall = "3M"
	
	gen category = "other expenditures - 3M"
	
	order hhid, after(hhnum)
	
	save "$temp\S09_CONS_D.dta", replace	

	
**************************************************************************
**************************************************************************

	use "$raw\S09_CONS_E.dta", clear
	
	sort 	hhgrap hhnum
	egen 	hhid = 	concat(hhgrap hhnum), format(%9.0g) punct(",")
	rename 	hhgrap 	cluster
	
	drop 	q9e_02 			// Drop the filter yes/no questions
	
	rename 	q9e_01 item_t
	decode item_t, gen(desc)
	tostring item_t, gen (item)
	drop item_t
	
	rename 	q9e_03 amount
	
	replace amount=2*amount
	
	recode amount (. = 0)
	/*Dataset contains the complete list of items for all expenditures, for 
	all households, whether they consumed them or not. If household did not 
	consume that item this is recorded as missing value. These are not missing 
	values: they are zeros. So we recode them as zeros.*/
		
	gen str3 recall = "6M"
	
	gen category = "other expenditures - 6M"
	
	order hhid, after(hhnum)
	
	save "$temp\S09_CONS_E.dta", replace	

************************************************************************
************************************************************************

	use "$raw\S09_CONS_F.dta", clear
	
	sort 	hhgrap hhnum
	egen 	hhid = 	concat(hhgrap hhnum), format(%9.0g) punct(",")
	rename 	hhgrap 	cluster

		
	drop 	q9f_02 			// ME: drop the filter yes/no questions
	
	rename 	q9f_01 item_t
	decode item_t, gen(desc)
	tostring item_t, gen (item)
	drop item_t
	
	rename 	q9f_03 amount
	
	recode amount (. = 0)
	/*Dataset contains the complete list of items for all expenditures, for 
	all households, whether they consumed them or not. If household did not 
	consume that item this is recorded as missing value. These are not missing 
	values: they are zeros. So we recode them as zeros*/
		
	gen str3 recall = "12M"
	
	gen category = "other expenditures - 12M"
	
	order hhid, after(hhnum)
	
	save "$temp\S09_CONS_F.dta", replace	
	
	
************************************************************************
************************************************************************

	use "$raw\S02_EDUC.dta", clear
	
	sort	hhgrap hhnum
	egen 	hhid = 	concat(hhgrap hhnum), format(%9.0g) punct(",")
	rename 	hhgrap 	cluster
	
	rename 	q2_0x	pid
	
	keep  cluster hhnum hhid pid q2_16 q2_17 q2_18 q2_19 q2_20 q2_21 q2_22 q2_23 
	/*Keep only variables recording amounts paid*/
	
	rename q2_* amount_*
	
	recode amount_* (. = 0)
	/*Dataset contains the complete list of items for all expenditures, for 
	all indidviduals of all households, whether they consumed them or not. 
	If individual did not consume that item this is recorded as missing value. 
	These are not missing values: they are zeros. So we recode them as zeros*/
	
	reshape long amount, i(cluster hhnum hhid pid) j(item) string
	
	drop pid
	collapse (sum) amount, by(cluster hhnum hhid item) 
	/* collapse the file to get rid of the distinction 
	between expenditures reported for different family members*/
	
	replace item = "q2_16" 	if item == "_16"
	replace item = "q2_17" 	if item == "_17"
	replace item = "q2_18" 	if item == "_18"
	replace item = "q2_19" 	if item == "_19"
	replace item = "q2_20" 	if item == "_20"
	replace item = "q2_21" 	if item == "_21" 
	replace item = "q2_22" 	if item == "_22"
	replace item = "q2_23" 	if item == "_23"

	gen 	desc = ""
	replace desc = "Education: fees" 			  	if item == "q2_16" 
	replace desc = "Education: FRAM/PASCOMA" 		if item == "q2_17" 
	replace desc = "Education: school supplies" 	if item == "q2_18" 
	replace desc = "Education: other supplies" 		if item == "q2_19" 
	replace desc = "Education: uniforms"			if item == "q2_20" 
	replace desc = "fafh: food at school" 			if item == "q2_21" 
	replace desc = "Education: transport" 		   	if item == "q2_22" 
	replace desc = "Education: other expenditures" 	if item == "q2_23"
	assert !mi(desc)
	
	/* q2_21 variable has information on food expenditure at school. 
	For that reason we labeled this expenditure as "fafh: food at school"*/
	
	gen str3 recall = "12M"
	
	gen category = "education" 
	
	save "$temp\S02_EDUC.dta", replace


***************************************************************************
***************************************************************************
	use "$raw\S03_SANT.dta", clear

	sort 	hhgrap hhnum
	egen 	hhid = 	concat(hhgrap hhnum), format(%9.0g) punct(",")
	rename 	hhgrap 	cluster
	rename  q3_0x 	pid
	
	isid hhid pid
	
	keep  	cluster hhnum hhid pid q3_13 q3_14 q3_15 q3_16 q3_17 ///
			q3_18 q3_20 q3_22 q3_23 q3_25 q3_26 q3_27  
			/*Keep only variables recording amounts paid*/
	
	rename q3_* amount_*
	
	recode amount_* (. = 0)
	/*Dataset contains the complete list of items for all expenditures, for 
	all indidviduals of all households, whether they consumed them or not. 
	If individual did not consume that item this is recorded as missing value. 
	These are not missing values: they are zeros. So we recode them as zeros*/
	
	reshape long amount, i(cluster hhnum hhid pid) j(item) string
	
	drop pid
	collapse (sum) amount, by(cluster hhnum hhid item) 
	/* collapse the file to get rid of the distinction 
	between expenditures reported for different family members*/
		
	replace item="q3_13" 	if item=="_13"  	 
	replace item="q3_14"	if item=="_14"
	replace item="q3_15" 	if item== "_15" 
	replace item="q3_16"	if item== "_16" 
	replace item="q3_17" 	if item== "_17" 
	replace item="q3_18"	if item== "_18"
	
	replace item="q3_20"	if item== "_20" 	
	replace item="q3_22"	if item== "_22"
	replace item="q3_23"	if item== "_23"
	replace item="q3_25"	if item== "_25"
	replace item="q3_26"	if item== "_26"
	replace item="q3_27"	if item== "_27"
	
	gen str3 recall = ""
	replace recall = "3M"  if inlist(item,"q3_13","q3_14","q3_15","q3_16","q3_17","q3_18")
	replace recall = "12M" if inlist(item,"q3_20","q3_22","q3_23","q3_25","q3_26","q3_27")
	assert !mi(recall)
	
	
	gen 	desc = ""
	replace desc = "Health: doctor" 					if item == "q3_13" 
	replace desc = "Health: specialist" 				if item == "q3_14" 
	replace desc = "Health: dentiste" 					if item == "q3_15" 
	replace desc = "Health: healer" 					if item == "q3_16" 
	replace desc = "Health: medical exams"				if item == "q3_17" 
	replace desc = "Health: medicine" 					if item == "q3_18" 
	
	replace desc = "Health: hospitalization" 			if item == "q3_20" 
	replace desc = "Health: glasses" 					if item == "q3_22"
	replace desc = "Health: devices (wheelchair, etc)"	if item == "q3_23"
	replace desc = "Health: vaccination" 				if item == "q3_25"
	replace desc = "Health: circumcision" 				if item == "q3_26"
	replace desc = "Health: check up" 					if item == "q3_27"
	assert !mi(desc)
	
	gen category = "health" 
	
	replace amount=4*amount if inlist(item,"q3_13","q3_14","q3_15","q3_16","q3_17","q3_18")
	
	
	save "$temp\S03_SANT.dta", replace



**************************************************************************
*************************************************************************

	use "$raw\S11_LOGE.dta", clear	

	sort 	hhgrap hhnum
	egen 	hhid = 	concat(hhgrap hhnum), format(%9.0g) punct(",")
	rename 	hhgrap 	cluster

	keep cluster hhnum hhid q11_24 q11_26 q11_37 q11_45 q11_45a q11_48 q11_48a q11_52 q11_52a
	
	
	gen str3 recall_q11_24 = "30D" 
	
	gen str3 recall_q11_26 = "30D" 
	
	gen str3 recall_q11_37 = "30D" 
	
	assert !mi(q11_45a) if !mi(q11_45)
	gen str3 recall_q11_45 = "no recall (exp is 0)"
	replace  recall_q11_45 = "7D" if q11_45a==1
	replace  recall_q11_45 = "30D" if q11_45a==2
	replace  recall_q11_45 = "2M" if q11_45a==3
	replace  recall_q11_45 = "3M" if q11_45a==4
	
	assert !mi(q11_48a) if !mi(q11_48)
	gen str3 recall_q11_48 = "no recall (exp is 0)"
	replace  recall_q11_48 = "7D" if q11_48a==1
	replace  recall_q11_48 = "30D" if q11_48a==2
	replace  recall_q11_48 = "2M" if q11_48a==3
	replace  recall_q11_48 = "3M" if q11_48a==4
	
	assert !mi(q11_52a) if !mi(q11_52)
	gen str3 recall_q11_52 = "no recall (exp is 0)"
	replace  recall_q11_52 = "7D" if q11_52a==1
	replace  recall_q11_52 = "30D" if q11_52a==2
	replace  recall_q11_52 = "2M" if q11_52a==3
	replace  recall_q11_52 = "3M" if q11_52a==4
		
	drop q11_45a q11_48a q11_52a 
	
	rename q11_* amount_*
	
	recode amount_* (. = 0)
	/*Dataset contains the complete list of items for all expenditures, for 
	all households, whether they consumed them or not. If household did not 
	consume that item this is recorded as missing value. These are not missing 
	values: they are zeros. So we recode them as zeros*/
	
	reshape long amount, i(cluster hhid) j(item) string
	
	replace item = "q11_24" 	if item== "_24" 	 	
	replace item = "q11_26" 	if item== "_26" 	 	
	replace item = "q11_37" 	if item== "_37" 	 	
	replace item = "q11_45" 	if item== "_45" 	 	
	replace item = "q11_48" 	if item== "_48" 	 	
	replace item = "q11_52" 	if item== "_52" 	 	
		
	
	gen str3 recall = ""
	replace recall = recall_q11_24 if item == "q11_24"
	replace recall = recall_q11_26 if item == "q11_26"
	replace recall = recall_q11_37 if item == "q11_37"
	replace recall = recall_q11_45 if item == "q11_45"
	replace recall = recall_q11_48 if item == "q11_48"
	replace recall = recall_q11_52 if item == "q11_52"
	
	drop recall_*
	
	assert !mi(recall)
	tab recall
	inspect amount if recall == "no "
	assert amount == 0 if recall == "no "
	replace recall = "no recall (exp is 0)" if recall == "no "
	
	gen desc = ""
	replace desc = "housing: running water"  	 	if item == "q11_24"
	replace desc = "housing: non-running water" 	if item == "q11_26"
	replace desc = "housing: electricity" 			if item == "q11_37"
	replace desc = "housing: telephone"			 	if item == "q11_45"
	replace desc = "housing: internet"			 	if item == "q11_48"
	replace desc = "housing: television"		 	if item == "q11_52"
	assert !mi(desc)
	
	gen category = "housing"
	

	
	order amount item desc recall, after(hhid)
	
	save "$temp\housing.dta", replace



****************************************************************************
****************************************************************************
	use "$raw\S12_AVOI.dta", clear	
			
	sort 	hhgrap hhnum
	egen 	hhid = 	concat(hhgrap hhnum), format(%9.0g) punct(",")
	rename 	hhgrap 	cluster

	*rename 	durable item_t
		rename 	q12_01 item_t

	decode item_t, gen(desc)
	tostring item_t, gen (item)
	drop item_t
	
	rename q12_092	amount 
	/*This variable is used for adding to the consumption aggregate goods 
	included in the durables module but that actually are not durables.*/
		
	recode amount (. = 0)
	/*Dataset contains the complete list of items for all expenditures, for 
	all households, whether they consumed them or not. If household did not 
	consume that item this is recorded as missing value. These are not missing 
	values: they are zeros. So we recode them as zeros*/
		
	gen str3 recall = "12M"
	
	gen category = "other dwelling expenditures - 12M"
	
	keep cluster hhid amount item desc recall hhnum category
	
	order hhid, after(hhnum)
	
	save "$temp\dwelling_items.dta", replace	


***************************************************************************
***************************************************************************

//	Append all expenditures

	use "$temp/S02_EDUC", clear
	append using "$temp/S03_SANT"
	append using "$temp/S09_CONS_A"
	append using "$temp/S09_CONS_B"
	append using "$temp/S09_CONS_C"
	append using "$temp/S09_CONS_D"
	append using "$temp/S09_CONS_E"
	append using "$temp/S09_CONS_F"
	append using "$temp/housing"
	append using "$temp/dwelling_items"
	
	sort cluster hhid item 
	
	order hhnum, after(cluster)
	
	save "$temp\all_nfnd", replace
