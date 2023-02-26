/*******************************************************************************
Class: 				ECO375 Winter 2023
Project: 			Feasibility Plan
Name: 				Jia Jun (Jacob) Li 1006824750

Date Created: 		Feb 25 2023
Last Updated:		Feb 25 2023
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

* load dta of shapefile to HOLC crosswalk


cd "$INPUT_PATH/Voting_census_block"
