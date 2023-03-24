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

clear all
set linesize 240
capture log close
log using "$OUTPUT_PATH/regression_analysis_log", replace text

cd "$INPUT_PATH/Merge"

* Load collapsed data for regression
use "HOLC_Voting_Covariates.dta", clear
drop _merge
replace _yr_median = _yr_median / 1000


* label dataset
foreach var of varlist perc_tract_a-perc_tract_d{
	local name = "Grade " + strupper(substr("`var'", 12, 1)) + " share"
	label variable `var' "`name'" 
}
label variable city "City"
label variable state "State"
label variable tract_dvoteshare "Dem vote share"
label variable _yr_median "Median income ('000s)"
label variable median_age "Median age"
label variable male_female_ratio "M-F ratio"
label variable perc_less_hs_total "Less HS share"
label variable perc_hs_total "HS share"
label variable perc_somecol_total "Some college share"
label variable perc_bach_total "Bachelor's share"
label variable perc_pop_white "White share"
label variable perc_pop_black "Black share"
label variable perc_pop_asian "Asian share"

* Scatter plot
twoway(scatter tract_dvoteshare perc_tract_d if tract_holc_share > 0.9)
graph export "$OUTPUT_PATH\baseline_scatter.png", as(png) replace

* Generate summary statistics
eststo sum_stat: estpost sum perc_tract_a-perc_tract_d tract_dvoteshare median_age male_female_ratio perc_less_hs_total-perc_pop_asian if tract_holc_share > 0.9
esttab sum_stat using "$OUTPUT_PATH\sum_stat.tex", cells("count(fmt(%8.0f)) mean(fmt(%8.3g)) sd(fmt(%8.3g)) min(fmt(%8.3g)) max(fmt(%8.3g))") /// 
label nodepvar nonumbers nomtitles booktabs replace

* Regression
eststo reg_baseline: regress tract_dvoteshare perc_tract_d if tract_holc_share > 0.9, robust
esttab reg_baseline using "$OUTPUT_PATH/base_regression.tex", ///
se star(* 0.10 ** 	0.05 *** 0.01) replace booktabs label
estadd local city_controls "No"


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
* Regression with selected covariates
regress tract_dvoteshare perc_tract_d _yr_median perc_pop_white perc_pop_black ///
perc_pop_asian if tract_holc_share > 0.9, robust

* Regression with selected covariates and city fixed effects
encode city, generate(city2)
gen perc_tract_d_sq = perc_tract_d^2
gen perc_tract_d_cu = perc_tract_d^3
label variable perc_tract_d_sq "Grade D squared"
label variable perc_tract_d_cu "Grade D cubed"

#delimit ;
perc_tract_d_cu _yr_median perc_pop_white-perc_pop_asian median_age i.city2 
if tract_holc_share > 0.9, cluster(city2);

eststo reg_linear: regress tract_dvoteshare perc_tract_d _yr_median
perc_hs_total-perc_pop_asian median_age i.city2 
if tract_holc_share > 0.9, cluster(city2);

eststo reg_quad: regress tract_dvoteshare perc_tract_d perc_tract_d_sq _yr_median
perc_hs_total-perc_pop_asian  median_age i.city2 
if tract_holc_share > 0.9, cluster(city2);

eststo reg_cube: regress tract_dvoteshare perc_tract_d perc_tract_d_sq 
perc_tract_d_cu _yr_median perc_hs_total-perc_pop_asian median_age i.city2 
if tract_holc_share > 0.9, cluster(city2);

estadd local city_controls "Yes": reg_linear reg_quad reg_cube reg_no_educ; 
#delimit cr

* Export regressions
#delimit ;
esttab reg_* using "$OUTPUT_PATH/main_regressions.tex", 
	se star(* 0.10 ** 	0.05 *** 0.01) ar2 replace booktabs label
	drop(*.city2)
	stats(city_controls N r2_a, slabel("City fixed effects" "Observations" "Adjusted R2"));
#delimit cr

log close
