***********************************************************************************
* Madagascar 2022 CEQ
* Developed by: Fatoumata Dieng
* Section: Income tax inputs
************************************************************************************

/*
hhgrap hhnum q4a_xx q4a_01 q4a_02 q4a_03 q4b_04 q4a_11 q4a_12 q4a_19a q4a_24 q4a_26 q4a_27 q4a_15 q4a_46a q4a_46b q4a_48a q4a_48b q4a_50a q4a_50b q4a_52a q4a_52b q4a_57 q4a_62a q4a_62b q4a_64a q4a_64b q4a_66a q4a_66b q4a_68a q4a_68b q4a_01 q4a_02 q4a_03 q4a_04 q4a_07 q4a_09 q4b_09 q4a_96 q4a_97 
*/

// Path:

use "$raw\S10_ENA_B.dta",clear

*<_HHID_>
destring hhgrap,replace
*drop hhid
gen double hhid=hhgrap*10000+hhnum 
codebook hhid
*</_HHID_>

*<_Personal ID_>
gen pid=q10_13
*</_Personal ID_>

/* Income of Enterprise owners */

*=====================
*=====================
 *Measuring firm cost 
*=====================
*=====================

// 10.52 Pendant combien de mois l'entreprise a-t-elle été en activité au cours des 12 derniers mois?


*---> cos1 to 6 (Inputs)
gen double cos_1=q10_40*q10_52 // 10.40 Combien avez-vous dépensé pour l'achat de ces marchandises revendues en l'état, sans transformation, au cours des 30 derniers jours ou durant le dernier mois où l'entreprise a fonctionné?

gen double cos_2=q10_42*q10_52 // 10.42 Combien avez-vous dépensé en achat de matières premières pour les produits vendus au cours des 30 derniers jours ou durant le dernier mois où l'entreprise a fonctionné?

gen double cos_3=q10_44*q10_52 // 10.44 Combien avez-vous dépensé en autres consommations intermédiaires (téléphone, transport, fournitures, etc.) au cours des 30 derniers jours ou durant le dernier mois où l'entreprise a fonctionné?

gen double cos_4=q10_45*q10_52 // 10.45 Combien avez-vous dépensé en frais de loyer, eau et électricité au cours des 30 derniers jours ou durant le dernier mois où l'entreprise a fonctionné?

gen double cos_5=q10_46*q10_52 // 10.46 Combien avez-vous dépensé en frais de services pour utiliser ou louer des équipements au cours des 30 derniers jours ou durant le dernier mois où l'entreprise a fonctionné?

gen double cos_6=q10_47*q10_52 // 10.47 Combien avez-vous dépensé en autres frais et services au cours des 30 derniers jours ou durant le dernier mois où l'entreprise a fonctionné? (réparation d'équipement, etc.)

*---> cos-7 to cos-9 (License, other taxes, administrative expenses)
gen double cos_7=q10_48 // 10.48 Quel est le montant de la patente payée par l'entreprise au cours des 12 derniers mois ?
egen double cos_8=rsum(q10_49a q10_49b) // 10.49 Quel est le montant des autres impôts et taxes payés par l'entreprise au cours des 12 derniers mois ?
gen double cos_9=q10_50 //10.50 Quel est le montant des frais administratifs non règlementaires payés par l'entreprise au cours des 12 derniers mois ?

*---> cos-10: Salaries of people working at the firm 

recode q10_53d_1 q10_53d_2 q10_53d_3 q10_53d_4 (9999=.)

*AGV: I changed this because I think we should multiply the average wage by the number of employees
*ORIGINALLY: egen double cos_10=rowtotal(s10q62d_1 s10q62d_2 s10q62d_3 s10q62d_4)
gen wages1 = q10_53d_1*q10_53a_1
gen wages2 = q10_53d_2*q10_53a_2
gen wages3 = q10_53d_3*q10_53a_3
gen wages4 = q10_53d_4*q10_53a_4
egen double cos_10=rowtotal(wages1 wages2 wages3 wages4)
replace cos_10=cos_10*q10_52
* 10.52 Pendant combien de mois l'entreprise a-t-elle été en activité au cours des 12 derniers mois?


*---> Suming up all previous cost 
egen costot=rsum(cos_1 cos_2 cos_3 cos_4 cos_5 cos_6 cos_7 cos_8 cos_9 cos_10)
replace costot=costot*-1


*-------------------
 *Measuring firm net income 
*-------------------
// 10.39 Quel est le montant obtenus sur la revente de marchandises achetées et revendues en l'état au cours des 30 derniers jours ou durant le dernier mois où l'entreprise a fonctionné?

// 10.41 Quel est la valeur de la production en produits transformés de l'entreprise au cours des 30 derniers jours ou durant le dernier mois où l'entreprise a fonctionné ?

// 10.43 Quel est le montant obtenus sur les services rendus par l'entreprise au cours des 30 derniers jours ou durant le dernier mois où l'entreprise a fonctionné?

// 10.52 Pendant combien de mois l'entreprise a-t-elle été en activité au cours des 12 derniers mois?

egen double ingtot=rsum(q10_39 q10_41 q10_43) //
replace ingtot=ingtot*q10_52

*---> Net income 
egen double inc3_a=rsum(ingtot costot)
*replace inc3_a=0 if inc3_a<0

*-------------------
 *Measuring formality
*-------------------
 
gen double formal=1 if q10_29==1 // Est-ce que cette entreprise dispose d'un numéro statistique ?
replace formal=1 if q10_30==1 // Cette entreprise dispose-t-elle d'un numéro d'identification fiscal (NIF)?
replace formal=1 if q10_31==1 // Cette entreprise est-elle enregistrée au Registre de Commerce (RC)??
replace formal=1 if q10_32==1 // Les personnes qui travaillent dans cette entreprise sont-elles enregistrées à la CaNPS??

*-------------------
 *Organizing and adding to household level dataset 
*-------------------

egen formal_definitivo=rowtotal(formal)
replace formal_definitivo=1 if formal_definitivo!=0


// 10.21 Quelle est la part des bénéfices qui revient au ménage?
// 10.14 Quel est le numéro d'ordre du (des) propriétaire de cette entreprise? (Donner au maximum 2 personnes)


	gen perc_au_menage = 1
	replace perc_au_menage = .875 if q10_21==4 //Plus de 75%
	replace perc_au_menage = .625 if q10_21==3 //Entre 50 & 75%
	replace perc_au_menage = .375 if q10_21==2 //Entre 25 & 50%
	replace perc_au_menage = .125 if q10_21==1 //Moins de 25%
	replace inc3_a = inc3_a*perc_au_menage
	gen s01q00a1=q10_14_1
	gen s01q00a2=q10_14_2

	recode s01q00a* (-999999999=.)
	
	*replace s01q00a2 = .					// OJO: Assign profits to only one individual per firm/household
	recode s01q00a1 (.=1)                   //If the firm has no individual associated, we will give it to individual 1 in each household
	
	replace inc3_a=inc3_a/2 if s01q00a2!=. 	//If there are 2 owners in the household, we will assume they share profits equally. Problem: We cannot see if there are 3+ owners
	gen s10q12a_1=_n
	// fatou
	reshape long s01q00a , i(hhid s10q12a_1 inc3_a) j(member)
	
	keep hhid inc3_a s01q00a formal_definitivo
	drop if s01q00a==.
	
	collapse (sum) inc3_a (mean) formal_definitivo , by(hhid s01q00a)
	
	tempfile income_enterprise
	save `income_enterprise'


use "$raw\S02_EDUC.dta", clear

*<_HHID_>
destring hhgrap,replace
*drop hhid
gen double hhid=hhgrap*10000+hhnum 
codebook hhid
*</_HHID_>

*<_Personal ID_>
gen s01q00a=q2_0x
*</_Personal ID_>

rename (q2_0x q2_00) (q4a_xx q4a_00)

preserve

use "$raw\S04_EMPL_AI_reduit.dta",clear

*<_HHID_>
destring hhgrap,replace
*drop hhid
gen double hhid=hhgrap*10000+hhnum 
codebook hhid
*</_HHID_>

*<_Personal ID_>
gen s01q00a=q4a_xx
*</_Personal ID_>

tempfile S04_EMPL_AI
save `S04_EMPL_AI'

restore

merge 1:1 hhid hhgrap hhnum  s01q00a using `S04_EMPL_AI', gen(merged4)

preserve

use "$raw\S01_DEMO_01.dta",clear

*<_HHID_>
destring hhgrap,replace
*drop hhid
gen double hhid=hhgrap*10000+hhnum 
codebook hhid
*</_HHID_>

*<_Personal ID_>
gen s01q00a=hlid
*</_Personal ID_>

tempfile S01_DEMO_01
save `S01_DEMO_01'

use "$raw\S01_DEMO_02.dta",clear

*<_HHID_>
destring hhgrap,replace
*drop hhid
gen double hhid=hhgrap*10000+hhnum 
codebook hhid
*</_HHID_>

*<_Personal ID_>
gen s01q00a=q1_0x
*</_Personal ID_>

tempfile S01_DEMO_02
save `S01_DEMO_02'

merge 1:1 hhid hhgrap hhnum  s01q00a using `S01_DEMO_01', gen(merged0)

tempfile S01_DEMO
save `S01_DEMO'

restore

merge 1:1 hhid hhgrap hhnum  s01q00a using `S01_DEMO', gen(merged1)

preserve

use "$raw\S05_REVE.dta",clear

*<_HHID_>
destring hhgrap,replace
*drop hhid
gen double hhid=hhgrap*10000+hhnum 
codebook hhid
*</_HHID_>

*<_Personal ID_>
gen s01q00a=q5_0x
*</_Personal ID_>

tempfile S05_REVE
save `S05_REVE'

restore

merge 1:1 hhid hhgrap hhnum  s01q00a using `S05_REVE', gen(merged5)

preserve

use "$raw\ca_real_pl.dta",clear

drop hhid
gen double hhid=cluster*10000+hhnum 
codebook hhid // 16,853 HHs

sort hhid
rename cluster hhgrap

tempfile ca_real_pl
save `ca_real_pl'

restore

merge m:1 hhid hhgrap hhnum using `ca_real_pl', gen(merged6)

merge 1:1 hhid s01q00a using `income_enterprise', gen(income_enterprise)

recode inc3_a formal_definitivo (.=0)
		
label var inc3_a "firm net income"

*====================================================================================
*====================================================================================
 *Wage income and imputation method (blocked)
*====================================================================================
*====================================================================================

*-------------------
 *Preparing variables 
 *for consumption/mincer equations 
*-------------------

*--> Type of worker
gen wage_earner=(q4a_57>=1 & q4a_57<=4)

gen self_employ=(q4a_57==5)

*--> Age 
gen age = q1_04a

*--> Years of education
gen yearsedu = .
* Si diplôme secondaire ou plus → prioritaire
replace yearsedu = 6  if q2_26 == 1
replace yearsedu = 10 if q2_26 == 2
replace yearsedu = 13 if q2_26 == 6
replace yearsedu = 15 if q2_26 == 7
replace yearsedu = 16 if q2_26 == 8
replace yearsedu = 17 if q2_26 == 9
replace yearsedu = 18 if q2_26 == 10
replace yearsedu = 21 if q2_26 == 11
* Sinon utiliser classe atteinte
replace yearsedu = q2_25 if missing(yearsedu)
label var yearsedu "Years of education"

*--> step function for wage and self employed  
gen edu_w=yearsedu if wage_earner==1
gen edu_s=yearsedu if self_employ==1
gen age_w=age if wage_earner==1
gen age_s=age if self_employ==1
replace edu_w=. if wage_earner!=1
replace edu_s=. if self_employ!=1
replace age_w=. if wage_earner!=1
replace age_s=. if self_employ!=1

* Computing the average per household

cap drop _*
sort hhid
by hhid:egen hedu_s=mean(edu_s) 
bysort hhid:egen hedu_w=mean(edu_w) 
bysort hhid:egen hage_w=mean(age_w) 
bysort hhid:egen hage_s=mean(age_s) 
bysort hhid:egen num_w=sum(wage_earner) 
bysort hhid:egen num_s=sum(self_employ) 
recode num_s num_w hage_s hage_w hedu_s hedu_w (.=0)
gen hage_w2=hage_w^2

* Urban and Rural

*<_Urban_>
gen urban=(area=="Urbain")
label define urban 1 "Urban" 0 "Rural"
label values urban urban
tab urban,m
*</_Urban_>

* Working sector: public or private

gen sector_public=1 if inlist(q4a_27, 1)
gen sector_prive=1 if inlist(q4a_27,2,3)
gen sector_pri_associative=1 if inlist(q4a_27,4)
gen sector_pri_menage=1 if inlist(q4a_27,5)
gen sector_pri_international=1 if inlist(q4a_27,6,7)

// combien de jours dans la semaine
clonevar day_w=q4a_15
*recode months (.=0)

* Main activity Labor income (cash + In-Kind) 
sum q4a_46a q4a_62a q5_09 q5_11 q5_13  // 1st job: montant salaire
// q4a_62a: secondary job: montant salaire, 1000 MGA
// q5_09: revenus de loyers de maison d'habitation
// q5_11: revenus mobiliers et financiers
// q5_13: autre type de revenus
replace q4a_46a=q4a_46a*1000
replace q4a_62a=q4a_62a*1000
gen impa = q4a_46a*30  if q4a_46b==1
replace impa = q4a_46a*4  if q4a_46b==2
replace  impa = q4a_46a  if q4a_46b==3
replace impa = q4a_46a/12  if q4a_46b==4

*** 4.48 A combien évaluez-vous les primes ( uniquement ceux qui ne sont pas inclus dans le salaire)?
recode q4a_48a (999999998=.)
replace q4a_48a=q4a_48a*1000
gen impap = q4a_48a*30  if q4a_48b==1
replace impap = q4a_48a*4  if q4a_48b==2
replace  impap = q4a_48a  if q4a_48b==3
replace impap = q4a_48a/12  if q4a_48b==4

*** 4.50 A combien évaluez-vous ces avantages ( uniquement ceux qui ne sont pas inclus dans le salaire)?
recode q4a_50a (999999998=.)
replace q4a_50a=q4a_50a*1000
gen impaes = q4a_50a*30  if q4a_50b==1
replace impaes = q4a_50a*4  if q4a_50b==2
replace  impaes = q4a_50a  if q4a_50b==3
replace impaes = q4a_50a/12  if q4a_50b==4

*** 4.52 A combien évaluez-vous cette nourriture?
recode q4a_52a (999999998=.)
replace q4a_52a=q4a_52a*1000
gen impaN = q4a_52a*30  if q4a_52b==1
replace impaN = q4a_52a*4  if q4a_52b==2
replace  impaN = q4a_52a  if q4a_52b==3
replace impaN = q4a_52a/12  if q4a_52b==4

egen impa_f=rowtotal(impa impap impaes impaN) 

*(AGV) WE ARE NOW IGNORING THE FACT THAT PEOPLE MAY HAVE NOT WORKED THE WHOLE YEAR IN THEIR LAST JOB, BECAUSE THAT WOULD MEAN THAT THEY WERE UNEMPLOYED THE REST OF THE YEAR.

gen double inc1_a=impa_f

*** 4.62 Quel a été le salaire de [NOM] pour cet emploi pour la période de temps considérée?
recode q4a_62a (999999998=.)
replace q4a_62a=q4a_62a*1000
gen double isa = q4a_62a*30  if q4a_62b==1
replace isa = q4a_62a*4  if q4a_62b==2
replace isa = q4a_62a  if q4a_62b==3
replace isa = q4a_62a/12  if q4a_62b==4

*** 4.64 A combien évaluez-vous les primes ( uniquement ceux qui ne sont pas inclus dans le salaire)?
recode q4a_64a (999999998=.)
replace q4a_64a=q4a_64a*1000
gen double isap = q4a_64a*30  if q4a_64b==1
replace isap = q4a_64a*4  if q4a_64b==2
replace isap = q4a_64a  if q4a_64b==3
replace isap = q4a_64a/12  if q4a_64b==4

*** 4.66 A combien évaluez-vous ces avantages ( uniquement ceux qui ne sont pas inclus dans le salaire)?
recode q4a_66a (999999998=.)
replace q4a_66a=q4a_66a*1000
gen double isaes = q4a_66a*30  if q4a_66b==1
replace isaes = q4a_66a*4  if q4a_66b==2
replace isaes = q4a_66a  if q4a_66b==3
replace isaes = q4a_66a/12  if q4a_66b==4

*** 4.68 A combien évaluez-vous cette nourriture?
recode q4a_68a (999999998=.)
replace q4a_68a=q4a_68a*1000
gen double isaN = q4a_68a*30  if q4a_68b==1
replace isaN = q4a_68a*4  if q4a_68b==2
replace isaN = q4a_68a  if q4a_68b==3
replace isaN = q4a_68a/12  if q4a_68b==4

egen isa_f=rowtotal(isa isap isaes isaN) 

*(AGV) WE ARE NOW IGNORING THE FACT THAT PEOPLE MAY HAVE NOT WORKED THE WHOLE YEAR IN THEIR LAST JOB, BECAUSE THAT WOULD MEAN THAT THEY WERE UNEMPLOYED THE REST OF THE YEAR.

gen double inc2_a=isa_f

recode inc3_a inc2_a inc1_a (.=0)
egen inc_a=rsum(inc1_a inc2_a inc3_a) // adding main job, secondary job and enterpreneur income 

* Working population 

*** 4.01 Au cours des 7 derniers jours, [NOM] a-t-il/elle effectué un travail en échange d'un salaire, d'un traitement, d'une commission, de pourboires ou de tout autre forme de rémunération, même pour 1 heure seulement ?

*** 4.02 Au cours des 7 derniers jours, [NOM] a-t-il/elle dirigé une entreprise quelconque, une exploitation agricole ou exercé une autre activité professionnelle pour générer un revenu, même pour 1 heure seulement ?

*** 4.03 Au cours des 7 derniers jours, [NOM] a-t-il/elle contribué sans rémunération à une entreprise ou une exploitation agricole appartenant à un membre du ménage ou de la famille ?

*** 4.04 Bien que [NOM] n'est pas allé travailler les 7 derniers jours, [NOM] a-t-il/elle effectué un travail en échange d'un salaire, d'un traitement, d'une commission, de pourboires ou avez-vous dirigé une entreprise ?

recode q4a_01 2=0
recode q4a_02 2=0
recode q4a_03 2=0
recode q4a_04 2=0

egen working=rowtotal(q4a_01 q4a_02 q4a_03 q4a_04)
replace working=1 if working!=0



*-------------------
 *Estimating labor income 
*-------------------



/***
Estimation of Labor Income
--------------------------

Because household survey does not report income appropiately, we follow the recommendatios of CEQ Handbook (Lustig & Higgins, forthcoming) to estimate labor  income using consumption.
We estimatea regression of consumption using as an explanatory 
variables: place of residence (urban/rural), if the household has a public employee, number of wage earners,
average education of wage earners, average age of wage earners, number of self-employed, average education of wage earners, average age of wage earners.

***/

**Regression to estimate labor income
*(AGV) After talking with Gabriela, we believe that the dependent variable should be total consumption per worker
egen occupied = rowmax(working wage_earner self_employ) 
bys hhid: egen workers = total(occupied)
gen dtotlab = the/workers
regress dtotlab urban sector_public num_w num_s hedu_w hedu_s  hage_w hage_s hage_w2 //dtot from s01_me_SEN2018 

/***
We use the coefficients of the regression to estimate labor income for each individual 
and  also estimate an annual measure of income based on answers contained in 
household survey. Then, we compare estimated labor income against total consumption 
of household and we select as a measure of labor income the closest of two options: 
estimated labor income or annualized labor income reported in hhd. 

***/

//OFF

**Using coefficient to estimate labor income
gen eylab=_b[_cons]+_b[urban]*urban+_b[sector_pub]*sector_pub+ ///
_b[num_w]*wage_earner+_b[num_s]*self_employ+wage_earner*_b[hedu_w]*yearsedu+ ///
self_employ*_b[hedu_s]*yearsedu+wage_earner*_b[hage_w]*age+self_employ*_b[hage_s]*age

* replace eylab=0 if working==0 & s04q50!=1 // fatou

*replace eylab=0 if e10==.

format the inc_a eylab q4a_46a q4a_62a %14.0fc

tempvar dif_e dif_i

bysort hhid:egen seylab=sum(eylab) 
bysort hhid:egen sinc_a=sum(inc_a) 


gen `dif_e'=abs(seylab-the)/the //desviation of estimated labor income from consumption
gen `dif_i'=abs(sinc_a-the)/the //desviation of reported labor income from consumption

gen mdif_i=(`dif_i'<`dif_e')   // if desviation of reported labor income is lower than estimated 
gen mdif_e=(`dif_e'<`dif_i') // if desviation of estimated labor income is lower than reported

*Substitution of labor income
gen inclab=inc_a 	 if mdif_i==1  //if the desviation of reported income is lower, we use this figure
replace inclab=eylab if mdif_e==1  //Estimated labor income if the desviaton is lower
replace inclab=inc_a if mdif_e==0 & mdif_i==0 //few cases with income reported 


replace inclab=inc_a  // !!! Notice here we ignore all previous steps on  inc_A!!! (DV)

replace inclab=0 if inclab<0
*replace inclab=0 if working==0

label var inclab "Estimated Brut Labor Income"
format %16.2fc inclab


*====================================================================================
*====================================================================================
* Personal Income Tax
*====================================================================================
*====================================================================================



*** 5.03 Est-ce que [NOM] a bénéficié d'une pension de veuvage (en cas de perte du conjoint) ou d'orphelinat (perte du parent) ?

*Pension
gen pension_invalidite_widow=1 if q5_03==1
replace pension_invalidite_widow=1 if q5_05==1

*Total income earners 
global other_income q5_01 q5_03 q5_05 q5_07 q5_09 q5_11 q5_13

foreach var of global other_income{
	recode `var' 2=0
	}

egen other_income= rowtotal( $other_income)	
	
gen some_income=1 if other_income!=0
replace some_income=1 if inclab!=0
bys hhid: egen total_income_apportant=total(some_income)

sort hhid s01q00a

*<_lf_statut_>
gen l_status=3 if (q4a_96==2 & q4a_97==2) | q4b_09!=3   // inactive
replace l_status=2 if (q4a_96==1 | q4a_97==1 | q4b_04<4 ) // unemployed
replace l_status=1 if q4a_01==1 | q4a_02==1 | q4a_03==1 |(q4a_04==1 & q4a_07==1) | q4a_09<5 // employed
replace l_status=3 if q4b_04~=. & (l_status==1 | l_status==2)
replace l_status=2 if q4b_04<4 
*replace lstatus=. if age<15 // infants should not be in the labor force
tab l_status,m
tab age l_status if age>=15,m
tab age if l_status==. & age>=15 // no observations
label define l_status 1 "Employed" 2 "Unemployed" 3 "Inactive",replace
label values l_status l_status
tab l_status,m
*</_lf_statut_>

gen lstatus=l_status
label define lstatus 1 "Employed" 2 "Unemployed" 3 "Inactive",replace
label values lstatus lstatus

*<_Status in employment_>*
gen     empstat=1 if q4a_01==1 & q4a_24==1  // wage
replace empstat=2 if q4a_01==1 & q4a_24==3  // domestic
replace empstat=3 if q4a_02==1 & q4a_24==2 & q4a_26==1 // employer
replace empstat=4 if q4a_02==1 & q4a_24==2 & q4a_26==2 /*self-employed(same as employer except for last question)*/
replace empstat=5 if q4a_03==1 | q4a_24==5  //contrib_family
replace empstat=6 if q4a_01==1 & q4a_24==4 // trainee
replace empstat=7 if q4a_11==3|q4a_11==4|q4a_12==3|q4a_12==4|q5_04==10 //subsistence_farm
label define empstat 1 "Employee" 2 "Domestic" 3 "Employer" 4 "Self-employed" 5 "Family Contribution" 6 "Trainee" 7 "Subsistence farm"
label values empstat empstat
replace empstat=. if lstatus~=1  // we only consider "employed"
tab empstat,m
*</_Status in employment_>*

*<_Occupation_> code ISCO 8*
gen occup=q4a_19a
label define occup 1 "Manager" 2 "Professionals" 3 "Technician and associate professionals" 4 "Clerical support workers" 5 "Service and sale workers" 6 "Skilled agricultural forestry and fishery workers" 7 "Craft and related trade workers" 8 "Plant and machine operators and assemblers" 9 "Elementary occupation" 0 "Armed Force occupation"
label values occup occup
replace occup=. if lstatus~=1  // we only consider "employed people"
tab occup,m
tab age occup,m
*</_Occupation_>*

*---- checks
replace formal_definitivo = 0 if missing(formal_definitivo)
capture confirm variable nb_charge
if _rc gen nb_charge = 0

capture assert inrange(formal_definitivo,0,1) if !missing(formal_definitivo)

*---- parts formel/informel
gen w_inclab_formel   = inclab * formal_definitivo if empstat==1
label var w_inclab_formel "Wage brut income"


gen inc_movable=q5_12*1000
gen inc_rental=q5_10*1000
gen inc_other=q5_14*1000

keep hhgrap hhnum q4a_xx hhid s01q00a hhsize area region strate inc3_a formal_definitivo wage_earner self_employ age yearsedu edu_w edu_s age_w age_s hedu_s hedu_w hage_w hage_s num_w num_s hage_w2 urban sector_public sector_prive sector_pri_associative sector_pri_menage sector_pri_international day_w impa impap impaes impaN impa_f inc1_a isa isap isaes isaN isa_f inc2_a inc_a working occupied workers dtotlab eylab seylab sinc_a mdif_i mdif_e inclab pension_invalidite_widow other_income some_income total_income_apportant inc_movable inc_rental inc_other w_inclab_formel


label var inc_movable "Montant annuel du revenu de mobiliers et financiers (dividendes d'actions, intérêts sur placements, etc.)"

label var inc_rental "Montant annuel du revenu provenant de loyers de maison d'habitation"

label var inc_other "Montant annuel d'autres revenus (gain de loterie, héritage, vente de biens, etc.)"


sort hhid s01q00a
cap drop __000*
save "$presim\02_MDGWBN_dtx_presim.dta", replace 
