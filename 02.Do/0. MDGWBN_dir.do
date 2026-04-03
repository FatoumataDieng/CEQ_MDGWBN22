* Madagascar 2022 CEQ
* Developed by: Fatoumata Dieng
* Directory

clear all

version 14

*** Install missing stata packages
cap net install ceq.pkg, replace

local packages povdeco ineqdeco quantiles winsor
foreach package in `packages' {
	capture which `package'
	if _rc == 111 {
		ssc install `package', replace
	}
}


*** Working with directories	

*  Fatou
else if inlist("`c(username)'","wb557366") {
	cd "C:/Users/wb557366/CEQ_MDG22/"
	global raw "C:/Users/wb557366/CEQ_MDG22/01.Data/0.Raw"
} 

*  Olive
else if inlist("`c(username)'","wb557366") {
	cd "C:/Users/wb557366/OneDrive - WBG/Documents/ECA/Olive/CEQ_MDG22/"
	global raw "C:/Users/wb557366/OneDrive - WBG/Documents/ECA/Olive/CEQ_MDG22/01.Data/0.Raw"

} 

*** Folder structure
*Code related
global do "./02.Do/"
global inps "./"

* Read only form OneDrive
* See globa raw redined above

*** Local data-storage (not on OneDrive) ************************************
global temp "./01.Data/2.Temp/"  //Must start with './'
global output "./01.Data/3.Output/"  //Must start with './'
global presim "./01.Data/1.Presim/"  //Must start with './'

*** Cleaning temp and presim local folders ************************************

//Must start with './'
*global Graphs "$TemMWB/graphs"

*** Loading simulation parameters ********************************************
import excel "MDG22_FiscalSim.xlsx", sheet(Parameters) first clear

levelsof global, local(params)
foreach z of local params {
	levelsof value  if global=="`z'", local(val)
	global `z' `val'
}


*** Cleaning temporary files ***********************************************************
local files : dir "${temp}" files "*.dta"
foreach file of local files {
	rm "${temp}/`file'"
}

*** Run Pre-simulaiton stage ***********************************************************

local files : dir "${presim}" files "*.dta"
foreach file of local files {
	rm "${presim}/`file'"
}



// Fatou: for the moment, run until line 78

do "${do}01.MDGWBN_pov.do" // already presim dta
do "${do}02.MDGWBN_dtx_presim.do"
do "${do}03.MDGWBN_pen.do" // already presim dta
do "${do}04.MDGWBN_dtr_presim.do"
do "${do}05.MDGWBN_vat_informal_merge_presim.do"
do "${do}06.MDGWBN_excise_presim.do"
do "${do}07.MDGWBN_sub_fuel_presim.do"
do "${do}08.MDGWBN_sub_elec_presim.do"
do "${do}09.MDGWBN_educ_presim.do"
do "${do}10.MDGWBN_health_presim.do"
do "${do}11.MDGWBN_gender_typology.do" // this step will create a list of gender typology variables
do "${do}12.MDGWBN_demographic_typology.do" // this step will create a new demographic indicator which will be added to the analysis

* Typology (restructur it if needed)

*** Run Simulaiton stage to create CEQ income indicators ************************************

local files : dir "${temp}" files "*.dta"
foreach file of local files {
	rm "${temp}/`file'"
}

do "${do}02.MDGWBN_dtx.do" // done
do "${do}04.MDGWBN_dtr.do"
do "${do}05.MDGWBN_vat_informal_merge.do"
do "${do}06.MDGWBN_excise.do"
do "${do}11.MDGWBN_customs.do"
do "${do}07.MDGWBN_sub_fuel.do"
do "${do}08.MDGWBN_sub_elec.do"
do "${do}09.MDGWBN_educ.do"
do "${do}10.MDGWBN_health.do"

*** Compiling results  *****************************************************
do "${do}12.MDGWBN_ceqincome.do"

**** note:please create a blank file in the $proc folder:CMR22WBN_CEQ_pov.xlsx
*** please add 
do "${do}13.MDGWBN_ECEQ_pov.do"

*********************************************************************
//END OF THE PROGRAM
*********************************************************************
