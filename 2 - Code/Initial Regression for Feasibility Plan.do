/*******************************************************************************
Class: 				ECO375 Winter 2023
Project: 			Feasibility Plan
Name: 				Jia Jun (Jacob) Li 1006824750
Name:				Benjamin Lee 1007236475

Date Created: 		Feb 27 2023
Last Updated:		Feb 27 2023
*******************************************************************************/

* Set up global directories and log file
// global PATH "C:/Users/lijia/OneDrive - University of Toronto/Documents/School/1-5 ECO375/ECO375 Project/"w
// global OUTPUT_PATH "$PATH/3 - Output"
// global INPUT_PATH "$PATH/1 - Data"

* Directories for Ben
global PATH "/Users/benlee/Documents/GitHub/eco375"
global OUTPUT_PATH "$PATH/3 - Output"
global INPUT_PATH "$PATH/1 - Data"

capture log close
log using "$OUTPUT_PATH/feas_plan_log", replace text

cd "$INPUT_PATH/Merge"

* Load collapsed data for regression
use "HOLC_cleaned_collapsed.dta", clear

* Scatter plot
scatter tract_dvoteshare perc_tract_d if perc_tract_d <= 1

* Regression
regress tract_dvoteshare perc_tract_d if perc_tract_d <= 1, robust
