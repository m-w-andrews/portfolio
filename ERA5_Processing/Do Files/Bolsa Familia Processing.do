*Opening Commands
capture log close
set more off
clear all

*Enter Root Directory Under 'else' Command
if ("`c(username)'" == "andm2") {
	global root "G:/Work/Robinson/Data"
} 
else {
	global root "?????"
}

*Log
log using "$root/Output/bolsa_familia_Logfile", replace


//+----------DETAILS-----------
//AUTHOR: Michael W. Andrews
//CONTACT: andm2013@gmail.com
//PRODUCTION DATE: May 13, 2020
//LAST EDITED: 
display "$S_TIME  $S_DATE"
//LAST EDITED BY: 
display "`c(username)'"

import delimited "$root/BolsaFamilia/2004.csv"
save "$root/Output/bolsafamilia_2004_2019.dta", replace

//import delimited "$root\Data\Bolsa Familia\2004.csv", delimiters(";")
forvalues year=2004/2019 {
				***Step 1: Import
                clear
				import delimited "$root/BolsaFamilia/`year'.csv"
				***Step 2: Save
				save "$root/Output/bf`year'.dta", replace
				clear
				***Step 3: Bring in Master
				use "$root/Output/bolsafamilia_2004_2019.dta"
				***Step 4: Merge
				merge 1:1 cãdigo using "$root/Output/bf`year'.dta", nogen
				save "$root/Output/bolsafamilia_2004_2019.dta", replace
				erase "$root/Output/bf`year'.dta"
        }
clear

use "$root/Output/bolsafamilia_2004_2019.dta"
reshape long famãliasbeneficiãrias valortotalrepassado, i(cãdigo) j(month)




**Finished
display "$S_TIME  $S_DATE"
capture log close
clear all
