### README for Backfill Imputation Method Manuscript Code ###

This file provides instructions on how to reproduce the results in the associated manuscript.

## Manuscript Information ## 
Manuscript title: Missing Data Imputation Method for Deep-Sea Corals: Utilizing Growth Rates to Backfill Values 

Authors: Kelly M. Donovan (2003kellyd@gmail.com), Nicholas W. Bussberg (nbussberg@elon.edu)

## Directory Requirements ## 
1.	All R scripts, including functions, should be placed in the same working directory
2.	Working directory should be set prior to running the code
3.	The source data file, “deep_sea_corals_1f3c_25e3_1631.csv”, should be placed in the same working directory as the R scripts. 

## Software and Package Requirements ## 
R version 4.4.2 was used to run the analyses.

The packages "dplyr", “ggplot2”, “ggtext”, “patchwork”, “readr”, “stringr” and “tidyr” are required. Install the listed packages before running the executable scripts. 

## Data Information ## 
The data used is from the National Oceanic and Atmospheric Administration’s (NOAA) Deep-Sea Coral and Sponge Dataset. The data was pulled from NOAA’s website on February 10, 2025. The dataset name is: deep_sea_corals_1f3c_25e3_1631.csv. 

## Scripts and Code Execution ## 
The code will run start to finish when sorted in alpha-numeric order. Note that when each file is Sourced with Echo in R, the file will generate a txt file with the extension .log. These files simply capture the input and output using the sink() function in R.

Here is the list of scripts (in run order) and what they do. Note that some Warnings will be generated, but the output is still created as needed.

1.	impbf1V2-data_cleaning.R - cleans and wrangles original NOAA data to appropriate ecoregion, years, and species. 

2.	impbf2-sim_scenarios.R - creates small, simulated examples to test the backfilling method to ensure it works as intended.
- Running this code is optional if you do not want to see simulations.

4.	impbf3V3-backfill.R - implements the backfilling method on the cleaned NOAA dataset from impbf1. 

5.	impbf4V2-analysis.R - analyzes the backfilled NOAA dataset from impbf3.

6.	impbf5V4-tiled_heatmap.R - creates the tiled heatmap used in the paper.
- There are two versions of the script embedded within it. The first (uncommented-out, first half) is designed to run on Windows. The second (commented-out, at bottom) is designed to run on Mac. Due to font choices, code could not be created that was compatible on both operating systems.

## References ## 
National Oceanic and Atmospheric Administration (NOAA), Deep Sea Coral Research and Technology Program (DSCRTP) [2024]. Observations of Deep-Sea Coral and Sponge Occurrences from NOAA's National Database for Deep-sea Corals and Sponges, 1842-Present, version [20241219-1] (NCEI Accession 0145037). NOAA National Centers for Environmental Information. Archived data: https://www.ncei.noaa.gov/archive/accession/0145037. Access portal: https://www.ncei.noaa.gov/maps/deep-sea-corals-portal/. Accessed 2025-02-10.

Note: ChatGPT was used in the development of code in some of the R scripts. Comments are left in the scripts to indicate how ChatGPT was used. 
