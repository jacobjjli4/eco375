/*******************************************************************************
Class: 				ECO375 Winter 2023
Project: 			Feasibility Plan
Name: 				Jia Jun (Jacob) Li 1006824750

Date Created: 		Feb 25 2023
Last Updated:		Feb 26 2023
*******************************************************************************/

clear all
set more off

* Set up global directories and log file
global PATH "C:/Users/lijia/OneDrive - University of Toronto/Documents/School/1-5 ECO375/ECO375 Project/"
global OUTPUT_PATH "$PATH/3 - Output"
global INPUT_PATH "$PATH/1 - Data"
cd "$INPUT_PATH/Tracts_2020_HOLC"


* capture does exception handling
capture log close
log using "$OUTPUT_PATH/jacob_test_log", replace text

* convert shapefile of HOLC to census tract crosswalk into dta format
shp2dta using Tracts_2020_HOLC, database(Tracts_2020_HOLC) ///
	coordinates(Tracts_2020_HOLC_coord) genid(id) replace

* load dta created above
use Tracts_2020_HOLC.dta

* clean data
gen tract_code1 = substr(GISJOIN, 2, 2)
gen tract_code2 = substr(GISJOIN, 5, 3)
gen tract_code3 = substr(GISJOIN, 9, 6)
egen tract_code = concat(tract_code*)
drop tract_code1-tract_code3

save Tracts_2020_HOLC_cleaned

cd "$INPUT_PATH/Voting_census_block"
clear all
import delimited "2021blockgroupvoting.csv"
tostring blockgroup_geoid, replace format("%14.0f")

replace blockgroup_geoid = "0" + blockgroup_geoid if strlen(blockgroup_geoid)==11
replace blockgroup_geoid = substr(blockgroup_geoid, 1, 10)

egen tract_dem_total = total(dem), by(tract_code)
egen tract_rep_total = total(rep), by(tract_code)
egen tract_lib_total = total(lib), by(tract_code)
egen tract_oth_total = total(oth), by(tract_code)
duplicates drop tract_code, force

