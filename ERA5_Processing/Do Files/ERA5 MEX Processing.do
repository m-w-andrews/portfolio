*Opening Commands
capture log close
set more off
clear all

*Enter Root Directory Under 'else' Command
if ("`c(username)'" == "andm2") {
	global root "G:\Work\Robinson\Data"
} 
else {
	global root "?????" //insert root to folder containing .do File, Data Folder, Intermediate Folder, and Output Folder
}

*Log
log using "$root\Output\MEX_ERA5_log", replace


//+----------DETAILS-----------
//AUTHOR: Michael W. Andrews
//CONTACT: andm2013@gmail.com
//PRODUCTION DATE: May 13, 2020
//LAST EDITED: 
display "$S_TIME  $S_DATE"
//LAST EDITED BY: 
display "`c(username)'"

*Append all days
forvalues year = 1998(1)2019 {
	clear
	display "$S_TIME  $S_DATE"
	set obs 1 // Create Seed Observation
	generate cve_mun = . // Create Seed Variable
	save `year', replace // Save Seed
	
	forvalues month = 1(1)12 { //MONTH
		clear
		set obs 1 // Create Seed Observation
		generate cve_mun = . // Create Seed Variable
		save `year'_`month', replace
		
		forvalues day = 1(1)31 { //DAY
			capture confirm file "$root\GEE Mexico ERA5\MEX_`year'_`month'_`day'.csv"
			if _rc == 0 { //'_rc' is a macro created by 'capture confirm file'
				clear
				import delimited "$root\GEE Mexico ERA5\MEX_`year'_`month'_`day'.csv"
				***Step 2: Adjust
				generate year = `year', after(cve_mun)
				generate month = `month', after(year)
				generate day = `day', after(month)
				foreach var in maximum_2m_air_temperature minimum_2m_air_temperature dewpoint_2m_temperature {
					replace `var' = `var' - 273.15
					rename `var' `var'_C
				}
				replace total_precipitation = total_precipitation * 1000
				rename total_precipitation total_precipitation_mm
				***Step 3: Save
				append using `year'_`month'
				save `year'_`month', replace
				display "`year'_`month'_`day' appended"
			}
			else {
				display "`year'_`month'_`day' IS AN INVALID DATE"
			}
		}
		
		append using `year'
		save `year', replace
		erase `year'_`month'.dta
	}
	
	sort year month day cve_mun
	save `year', replace
}

	clear
	set obs 1 // Create Seed Observation
	generate cve_mun = . // Create Seed Variable

	forvalues year = 1998(1)2019 {
	append using `year'
	erase `year'.dta
}
drop if cve_mun == .
save "$root\Output\MEX_ERA5.dta", replace
display "$S_TIME  $S_DATE"

*Finished
display "$S_TIME  $S_DATE"
capture log close
clear all

