/*******************************************************************************
Class: 				ECO375 Winter 2023
Project: 			Feasibility Plan
Name: 				Jia Jun (Jacob) Li 1006824750
Name:				Benjamin Lee 1007236475

Date Created: 		Feb 25 2023
Last Updated:		Feb 26 2023
*******************************************************************************/

clear all
set more off

* Set up global directories and log file
// global PATH "C:/Users/lijia/OneDrive - University of Toronto/Documents/School/1-5 ECO375/ECO375 Project/"w
// global OUTPUT_PATH "$PATH/3 - Output"
// global INPUT_PATH "$PATH/1 - Data"

*Directories for Ben
global PATH "/Users/benlee/Documents/GitHub/eco375"
global OUTPUT_PATH "$PATH/3 - Output"
global INPUT_PATH "$PATH/1 - Data"

capture log close
log using "$OUTPUT_PATH/jacob_test_log", replace text

cd "$INPUT_PATH/Tracts_2020_HOLC"

* convert shapefile of HOLC to census tract crosswalk into dta format
shp2dta using Tracts_2020_HOLC, database(Tracts_2020_HOLC) ///
	coordinates(Tracts_2020_HOLC_coord) genid(id) replace

* load dta created above
use Tracts_2020_HOLC.dta

* clean data by removing extra 0s in the tract codes present in the original dataset
gen tract_code1 = substr(GISJOIN, 2, 2)
gen tract_code2 = substr(GISJOIN, 5, 3)
gen tract_code3 = substr(GISJOIN, 9, 6)
egen tract_code = concat(tract_code*)
drop tract_code1-tract_code3

egen perc_tract_a = total(SUM_Perc) if FIRST_holc == "A", by(tract_code)
egen perc_tract_b = total(SUM_Perc) if FIRST_holc == "B", by(tract_code)
egen perc_tract_c = total(SUM_Perc) if FIRST_holc == "C", by(tract_code)
egen perc_tract_d = total(SUM_Perc) if FIRST_holc == "D", by(tract_code)

save "Tracts_2020_HOLC_cleaned.dta", replace

* import and clean voting data
cd "$INPUT_PATH/Voting_census_block"
clear all
import delimited "2021blockgroupvoting.csv"
tostring blockgroup_geoid, replace format("%14.0f")

replace blockgroup_geoid = "0" + blockgroup_geoid if strlen(blockgroup_geoid)==11
gen tract_code = substr(blockgroup_geoid, 1, 11)

egen tract_dem_total = total(dem), by(tract_code)
egen tract_rep_total = total(rep), by(tract_code)
egen tract_lib_total = total(lib), by(tract_code)
egen tract_oth_total = total(oth), by(tract_code)
gen tract_vote_total = tract_dem_total + tract_rep_total + tract_lib_total + tract_oth_total
gen tract_dvoteshare = tract_dem_total / tract_vote_total
gen tract_rvoteshare = tract_rep_total / tract_vote_total
duplicates drop tract_code, force

drop rep-precincts
drop blockgroup_geoid

save 2021blockgroupvoting_cleaned, replace

* collapse HOLC data to tract level units of observation
use "$INPUT_PATH/Tracts_2020_HOLC/Tracts_2020_HOLC_cleaned.dta"
preserve
collapse (max) perc_tract_*, by(tract_code)
save "$INPUT_PATH/Tracts_2020_HOLC/HOLC_collapsed.dta", replace

restore

* merge datasets
use "$INPUT_PATH/Tracts_2020_HOLC/HOLC_collapsed.dta"
merge m:1 tract_code using "$INPUT_PATH/Voting_census_block/2021blockgroupvoting_cleaned.dta"

save "$INPUT_PATH/Merge/HOLC_Voting_Merged.dta", replace
