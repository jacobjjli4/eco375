/*******************************************************************************
Class: 				ECO375 Winter 2023
Project: 			Feasibility Plan
Names: 				Jia Jun (Jacob) Li 1006824750
					Benjamin Lee 1007236475

Date Created: 		Mar 14 2023
Last Updated:		Mar 14 2023

Description:		Merge ACS income and race data on the census tract level
					with our preexisting HOLC and electoral data.
*******************************************************************************/

clear all
set more off

* Directories for Jacob
global PATH "C:/Users/lijia/OneDrive - University of Toronto/Documents/School/1-5 ECO375/ECO375 Project/"
global OUTPUT_PATH "$PATH/3 - Output"
global INPUT_PATH "$PATH/1 - Data"

* Directories for Ben
// global PATH "/Users/benlee/Documents/GitHub/eco375"
// global OUTPUT_PATH "$PATH/3 - Output"
// global INPUT_PATH "$PATH/1 - Data"

capture log close
log using "$OUTPUT_PATH/jacob_test_log", replace text


* Prepare race data for merge
cd "$INPUT_PATH/Covariates"
import excel "Census Tract Population Data (2020).xlsx", firstrow clear
gen tract_code = substr(GEO_ID, 10, 13)

save "cleaned_Census Tract Population Data (2020)", replace

* Prepare income data for merge
import excel "Tract Level Income Data (2020).xlsx", firstrow clear
gen tract_code = substr(GEO_ID, 10, 13)

save "cleaned_Tract Level Income Data (2020)", replace

* Merge race and income data into HOLC voting data
cd "$INPUT_PATH/Merge"
use "HOLC_Voting_Merged.dta", clear

capture drop _merge
merge 1:1 tract_code using "$INPUT_PATH/Covariates/cleaned_Census Tract Population Data (2020)"
drop if _merge == 2

capture drop _merge
merge 1:1 tract_code using "$INPUT_PATH/Covariates/cleaned_Tract Level Income Data (2020)"
drop if _merge == 2

* generate race proportion data
foreach var of varlist pop_white pop_black pop_asian {
	gen perc_`var' = `var' / pop_total
}

save "$INPUT_PATH/Merge/HOLC_Voting_Merged.dta", replace

