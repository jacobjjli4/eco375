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
replace male_female_ratio = male_female_ratio / 100


* label dataset
foreach var of varlist perc_tract_a-perc_tract_d{
	local name = "Grade " + strupper(substr("`var'", 12, 1)) + " share"
	label variable `var' "`name'" 
}
label variable city "City"
label variable state "State"
label variable tract_dvoteshare "Dem share"
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

* Generate variable that indicates if a tract has sufficient data for analysis
gen incl = 0
replace incl = 1 if tract_dem_total != . & pop_white != . & _yr_median != . & median_age != . & male_female_ratio != . & perc_less_hs_total != . & tract_holc_share > 0.9 & tract_holc_share < 1.05

* Scatter plot
twoway(scatter tract_dvoteshare perc_tract_d if incl == 1, msize(0.8) xtitle(, size(medlarge)) ytitle(, size(medlarge)))
graph export "$OUTPUT_PATH\dshare_scatter.png", as(png) replace
twoway(scatter tract_dvoteshare perc_tract_c if incl == 1, msize(0.8) xtitle(, size(medlarge)) ytitle(, size(medlarge)))
graph export "$OUTPUT_PATH\cshare_scatter.png", as(png) replace

* Generate summary statistics
eststo sum_stat: estpost sum perc_tract_a-perc_tract_d tract_dvoteshare _yr_median median_age male_female_ratio perc_less_hs_total-perc_pop_asian if incl == 1
eststo sum_stat_not: estpost sum tract_dvoteshare _yr_median median_age male_female_ratio perc_less_hs_total-perc_pop_asian if incl == 0

esttab sum_stat sum_stat_not using "$OUTPUT_PATH\sum_stat.tex", ///
cells("count(pattern(1 1) fmt(%8.0f)) mean(fmt(%8.2g) pattern(1 1)) sd(fmt(%8.2g) pattern(1 1)) min(fmt(%8.2g) pattern(1 1)) max(fmt(%8.2g) pattern(1 1))") /// 
label mtitles("Census tracts in study" "Census tracts not in study") nodepvar nonumbers booktabs replace

* Regression
eststo reg_baseline: regress tract_dvoteshare perc_tract_d if incl == 1, robust
esttab reg_baseline using "$OUTPUT_PATH/base_regression.tex", ///
se star(* 0.10 ** 	0.05 *** 0.01) replace booktabs label
estadd local city_controls "No"
estadd local cluster_se "No"


* Robustness check -- does changing the tract_holc_share cutoff affect results?
quietly
foreach min_perc of numlist 0 5:100 {
	eststo robustness_`min_perc': reg tract_dvoteshare perc_tract_d if tract_holc_share*100 >= `min_perc', robust
}
esttab robustness_* using "$OUTPUT_PATH/min_tract_holc_share_robustness.csv", se star(* 0.10 ** 0.05 *** 0.01) replace

drop _est_robustness*

* Robustness check -- does changing the way we measure redlining affect results?
eststo robustness2_d: regress tract_dvoteshare perc_tract_d if incl == 1
gen perc_tract_c_plus_d = perc_tract_c + perc_tract_d
eststo robustness2_c_plus_d: regress tract_dvoteshare perc_tract_c_plus_d if incl == 1
eststo robustness2_c_and_d: regress tract_dvoteshare perc_tract_c perc_tract_d if incl == 1
eststo robustness2_b_c_d: regress tract_dvoteshare perc_tract_a perc_tract_c perc_tract_d if incl == 1

esttab robustness2_* using "$OUTPUT_PATH/redlining_measure_robustness.csv", se star(* 0.10 ** 0.05 *** 0.01) replace

noisily
* Regression with selected covariates
regress tract_dvoteshare perc_tract_d _yr_median perc_pop_white perc_pop_black ///
perc_pop_asian if incl == 1, robust

* Regression with selected covariates and city fixed effects
encode city, generate(city2)
gen perc_tract_d_sq = perc_tract_d^2
gen perc_tract_d_cu = perc_tract_d^3
label variable perc_tract_d_sq "Grade D squared"
label variable perc_tract_d_cu "Grade D cubed"

gen perc_tract_c_sq = perc_tract_c^2
gen perc_tract_c_cu = perc_tract_c^3
label variable perc_tract_c_sq "Grade C squared"
label variable perc_tract_c_cu "Grade C cubed"

drop perc_tract_c_plus_d
global indep_vars perc_tract_d* perc_tract_c*

global controls _yr_median-male_female_ratio perc_hs_total-perc_pop_asian

#delimit ;
eststo reg_base_c_d: regress tract_dvoteshare perc_tract_d perc_tract_c
i.city2 if incl == 1, cluster(city2);
testparm i.city2;

eststo reg_all_cov_lin: regress tract_dvoteshare perc_tract_d perc_tract_c 
$controls i.city2 
if incl == 1, cluster(city2);

eststo reg_all_cov: regress tract_dvoteshare $indep_vars 
$controls i.city2 
if incl == 1, cluster(city2);

eststo reg_all_cov_no_c: regress tract_dvoteshare perc_tract_d perc_tract_d_sq 
perc_tract_d_cu $controls i.city2 
if incl == 1, cluster(city2);

scalar clust = e(N_clust);

estadd local city_controls "Yes": reg_base_c_d reg_all*; 
estadd local cluster_se "City": reg_base_c_d reg_all*;
estadd scalar clust: reg_base_c_d reg_all*;
#delimit cr

* Export regressions

#delimit ;
esttab reg_* using "$OUTPUT_PATH/main_regressions.tex", 
	se star(* 0.10 ** 	0.05 *** 0.01) ar2 replace booktabs label
	drop(*.city2)
	stats(city_controls cluster_se clust N r2_a, label("City fixed effects"
	"Clustered SE" "Clusters" "Observations" "Adjusted R$^2$"));
#delimit cr

* Create plots of marginal effects
global indep_vars c.perc_tract_d c.perc_tract_d#c.perc_tract_d c.perc_tract_d#c.perc_tract_d#c.perc_tract_d ///
c.perc_tract_c c.perc_tract_c#c.perc_tract_c c.perc_tract_c#c.perc_tract_c#c.perc_tract_c

regress tract_dvoteshare $indep_vars $controls ///
i.city2 if incl == 1, cluster(city2)
margins, at(perc_tract_d=(0(0.01)1))
marginsplot, recast(line) recastci(rarea) ytitle(Predicted Dem share, size(medlarge)) xtitle(, size(medlarge))
graph export "$OUTPUT_PATH\dshare_marginplot.png", as(png) replace

margins, at(perc_tract_c=(0(0.01)1))
marginsplot, recast(line) recastci(rarea) ytitle(Predicted value of Dem share, size(medlarge)) xtitle(, size(medlarge))
graph export "$OUTPUT_PATH\cshare_marginplot.png", as(png) replace

log close
