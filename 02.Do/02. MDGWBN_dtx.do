/********************************************************************
 IR Madagascar - sans CA (inclab proxy), avec empstat
 Variables:
   inclab, formal_definitivo (0-1), empstat, nb_charge
********************************************************************/

use  "$presim\02_MDGWBN_dtx_presim.dta", clear 

sort hhid

/*
global dtx_cpn_retr 0.01
global dtx_pen_r 0.1
global dtx_irsa_max_b1 350000
global dtx_irsa_max_b2 400000
global dtx_irsa_max_b3 500000
global dtx_irsa_max_b4 600000
global dtx_irsa_b1 0.0
global dtx_irsa_b2 0.05
global dtx_irsa_b3 0.10
global dtx_irsa_b4 0.15
global dtx_irsa_b5 0.20
*/

global dtx_mova 0.20


*****A. Assiette : déduction dans la limite de 1% du salaire brut pour les charges sociales

gen cotisation_soc_pc=w_inclab_formel*$dtx_cpn_retr

******B. 10% pour la constitution de pensions ou de retraite

gen pension_retraite_pc=w_inclab_formel*$dtx_pen_r

******C. IRSA **************************************************************************
*** revenu taxable

gen irsa_taxable_income=w_inclab_formel-cotisation_soc-pension_retraite

*========================
* IRSA - Barème progressif (mensuel)
*========================


* Calcul IRSA (progressif)

gen dtx_irsa_pc=0
* Tranche 1: <= 350 000 (0%)
replace dtx_irsa_pc = irsa_taxable_income * $dtx_irsa_b1 ///
    if irsa_taxable_income <= $dtx_irsa_max_b1

* Tranche 2: 350 001 - 400 000 (5%)
replace dtx_irsa_pc = ///
      ($dtx_irsa_max_b1 * $dtx_irsa_b1) ///
    + ((irsa_taxable_income - $dtx_irsa_max_b1) * $dtx_irsa_b2) ///
    if irsa_taxable_income >  $dtx_irsa_max_b1 ///
    &  irsa_taxable_income <= $dtx_irsa_max_b2

* Tranche 3: 400 001 - 500 000 (10%)
replace dtx_irsa_pc = ///
      ($dtx_irsa_max_b1 * $dtx_irsa_b1) ///
    + (($dtx_irsa_max_b2 - $dtx_irsa_max_b1) * $dtx_irsa_b2) ///
    + ((irsa_taxable_income - $dtx_irsa_max_b2) * $dtx_irsa_b3) ///
    if irsa_taxable_income >  $dtx_irsa_max_b2 ///
    &  irsa_taxable_income <= $dtx_irsa_max_b3

* Tranche 4: 500 001 - 600 000 (15%)
replace dtx_irsa_pc = ///
      ($dtx_irsa_max_b1 * $dtx_irsa_b1) ///
    + (($dtx_irsa_max_b2 - $dtx_irsa_max_b1) * $dtx_irsa_b2) ///
    + (($dtx_irsa_max_b3 - $dtx_irsa_max_b2) * $dtx_irsa_b3) ///
    + ((irsa_taxable_income - $dtx_irsa_max_b3) * $dtx_irsa_b4) ///
    if irsa_taxable_income >  $dtx_irsa_max_b3 ///
    &  irsa_taxable_income <= $dtx_irsa_max_b4

* Tranche 5: > 600 000 (20%)
replace dtx_irsa_pc = ///
      ($dtx_irsa_max_b1 * $dtx_irsa_b1) ///
    + (($dtx_irsa_max_b2 - $dtx_irsa_max_b1) * $dtx_irsa_b2) ///
    + (($dtx_irsa_max_b3 - $dtx_irsa_max_b2) * $dtx_irsa_b3) ///
    + (($dtx_irsa_max_b4 - $dtx_irsa_max_b3) * $dtx_irsa_b4) ///
    + ((irsa_taxable_income - $dtx_irsa_max_b4) * $dtx_irsa_b5) ///
    if irsa_taxable_income > $dtx_irsa_max_b4

********** D. IRCM: Revenus des Capitaux Mobiliers : 20%

gen dtx_mova_pc=inc_movable*$dtx_mova

********** E. Pas trop d'informations sur la distinction entre les types de revenus (heritages, ventes de biens, gain de loterie, etc.)

sum dtx_mova_pc dtx_irsa_pc pension_retraite_pc cotisation_soc_pc 

collapse (sum) dtx_mova_pc dtx_irsa_pc pension_retraite_pc cotisation_soc_pc (mean) hhsize , by(hhid)

rename (dtx_mova_pc dtx_irsa_pc pension_retraite_pc cotisation_soc_pc) (dtx_mova_hh dtx_irsa_hh pension_retraite_hh cotisation_soc_hh)

label var dtx_irsa_hh "Household Income Tax payment - IRSA"
label var pension_retraite_hh "Household pension payment"
label var cotisation_soc_hh "Household Social Contribution payment"
label var dtx_mova_hh "Household Movable Income Tax payment"

tempfile income_tax_collapse
save `income_tax_collapse'

save "$presim\02_MDGWBN_dtx.dta", replace 
