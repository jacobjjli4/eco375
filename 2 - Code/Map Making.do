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

clear all
set linesize 240
capture log close
log using "$OUTPUT_PATH/map_log", replace text

cd "$INPUT_PATH/Mapping"

import delimited using "uscities.csv"
duplicates drop city, force
drop city_ascii state_name-county_name population-id
rename state_id state

save "city_lat_lon.dta", replace

cd "$INPUT_PATH/Merge"
use "HOLC_voting_covariates.dta", clear
drop if tract_dem_total == .
drop if pop_white == .
drop if _yr_median == .
drop if median_age == .
drop if male_female_ratio == .
drop if perc_less_hs_total == .

duplicates drop city, force

cd "$INPUT_PATH/Mapping"
merge 1:1 city state using "city_lat_lon.dta", gen(merge2)
drop if merge2 == 2
drop tract_code-perc_tract_d tract_dem_total-perc_pop_asian

// save "HOLC_cities_lat_lon.dta", replace

shp2dta using s_22mr22, database(s_22mr22) ///
	coordinates(s_22mr22_coord.dta) genid(id) replace

use "s_22mr22.dta", clear
spmap using s_22mr22_coord.dta if id <56 & id!=1 & id!=13 & id!=4 &id!=39 & id!=54 & id!=46, id(id) fcolor(gs14) ocolor(gs5) point(data(HOLC_cities_lat_lon.dta) xcoord(lng) ycoord(lat) ocolor(navy) fcolor(ltblue) osize(medium))

log close
