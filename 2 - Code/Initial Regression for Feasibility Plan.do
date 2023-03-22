/*******************************************************************************
Class: 				ECO375 Winter 2023
Project: 			Feasibility Plan
Name: 				Jia Jun (Jacob) Li 1006824750
Name:				Benjamin Lee 1007236475

Date Created: 		Feb 27 2023
Last Updated:		Mar 14 2023
*******************************************************************************/

// Directories for Jacob
global PATH "C:/Users/lijia/OneDrive - University of Toronto/Documents/School/1-5 ECO375/ECO375 Project/"
global OUTPUT_PATH "$PATH/3 - Output"
global INPUT_PATH "$PATH/1 - Data"

// * Directories for Ben
// global PATH "/Users/benlee/Documents/GitHub/eco375"
// global OUTPUT_PATH "$PATH/3 - Output"
// global INPUT_PATH "$PATH/1 - Data"

cd "$OUTPUT_PATH"

capture log close
log using "$OUTPUT_PATH/feas_plan_log", replace text

cd "$INPUT_PATH/Merge"

* Load collapsed data for regression
use "HOLC_Voting_Merged.dta", clear

* Scatter plot
scatter tract_dvoteshare perc_tract_d if tract_holc_share > 0.8

* Regression
regress tract_dvoteshare perc_tract_d if tract_holc_share > 0.8, robust

* Robustness check -- does changing the tract_holc_share cutoff affect results?
quietly
foreach min_perc of numlist 0 5:100 {
	eststo robustness_`min_perc': reg tract_dvoteshare perc_tract_d if tract_holc_share*100 >= `min_perc', robust
}
esttab robustness_* using "$OUTPUT_PATH/min_tract_holc_share_robustness.csv", se star(* 0.10 ** 0.05 *** 0.01) replace

drop _est_robustness*

* Robustness check -- does changing the way we measure redlining affect results?
eststo robustness2_d: regress tract_dvoteshare perc_tract_d if tract_holc_share > 0.9
gen perc_tract_c_plus_d = perc_tract_c + perc_tract_d
eststo robustness2_c_plus_d: regress tract_dvoteshare perc_tract_c_plus_d if tract_holc_share > 0.9
eststo robustness2_c_and_d: regress tract_dvoteshare perc_tract_c perc_tract_d if tract_holc_share > 0.9
eststo robustness2_b_c_d: regress tract_dvoteshare perc_tract_a perc_tract_c perc_tract_d if tract_holc_share > 0.9

esttab robustness2_* using "$OUTPUT_PATH/redlining_measure_robustness.csv", se star(* 0.10 ** 0.05 *** 0.01) replace

noisily
* Regression with covariates
regress tract_dvoteshare perc_tract_d _yr_median perc_pop_white perc_pop_black ///
perc_pop_asian if tract_holc_share > 0.9, robust

* Regression with covariates and city fixed effects
encode city, generate(city2)
encode state, generate(state2)

regress tract_dvoteshare perc_tract_d _yr_median perc_pop_white perc_pop_black ///
perc_pop_asian i.city if tract_holc_share > 0.9, robust

log close
