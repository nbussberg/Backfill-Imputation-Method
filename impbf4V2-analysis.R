# Metadata ---------------------------------------------------------------------

# Code written by: Kelly Donovan and Nicholas Bussberg
# Last Update: 2026-06-29
# Filename: impbf4V2-analysis.R

# Purpose of this script:
  # analyze backfilled datasets


# Setup ------------------------------------------------------------------------
rm(list=ls())

options(width = 80)

filename <-"impbf4V2-analysis"

sink(paste(filename, ".log", sep = "")) # create log file to store output

# R version
R.version.string


# Project Code -----------------------------------------------------------------

## 0 Load functions and data ---------------------------------------------------

# Load packages

library(dplyr)

# Read in data

coral_data <- readRDS(file = "impbf1-NGOM-Desmo.RDS")
backfill_wide_counts <- readRDS(file = "impbf3V3-backfill-counts-wide.RDS")
raw_wide_counts <- readRDS(file = "impbf3V3-raw-counts-wide.RDS")


## 1 Pre-backfilled data -------------------------------------------------------

# select year columns for counts (ChatGPT was used to generate ideas)
pre_year_data <- raw_wide_counts[, as.character(1960:2017)]

# flatten into one vector
pre_all_values <- unlist(pre_year_data)

# count totals
pre_total_NAs <- sum(pre_all_values == 0, na.rm = TRUE)    # number of 0s
  # reminder: though coded as 0 count, data was presence-only. 
    # Thus, 0's in the wide format represent NAs. 

pre_total_present <- sum(pre_all_values > 0, na.rm = TRUE) # number of >0 cells

# create summary table
pre_summary <- data.frame(pre_NA = pre_total_NAs,
                          pre_present = pre_total_present) |> 
  mutate(pre_total = pre_NA + pre_present,
         pre_NA_prop = pre_NA / pre_total,
         pre_present_prop = pre_present / pre_total)

pre_summary


## 2 Post-backfilled data -------------------------------------------------------

# select year columns for counts (ChatGPT was used to generate ideas)
post_year_data <- backfill_wide_counts[, as.character(1960:2017)]

# flatten into one vector
post_all_values <- unlist(post_year_data)

# count totals
post_total_NAs <- sum(post_all_values == 0, na.rm = TRUE)    # number of 0s
# reminder: though coded as 0 count, data was presence-only. 
# Thus, 0's in the wide format represent NAs. 

post_total_present <- sum(post_all_values > 0, na.rm = TRUE) # number of >0 cells

# create summary table
post_summary <- data.frame(post_NA = post_total_NAs,
                           post_present = post_total_present) |> 
  mutate(post_total = post_NA + post_present,
         post_NA_prop = post_NA / post_total,
         post_present_prop = post_present / post_total)

post_summary

# count of values backfilled
count_backfilled <- post_total_present - pre_total_present
count_backfilled

# proportion of non-missing values that are original values
pre_summary$pre_present / post_summary$post_present

# proportion of values backfilled in final dataset
count_backfilled / post_summary$post_total


## 3 Pre-backfilled data by species --------------------------------------------

# select year columns for counts (ChatGPT was used to generate ideas)
pre_year_Dp <- raw_wide_counts[raw_wide_counts$Species=="pertusum", 
                                 as.character(1960:2017)]
pre_year_Dd <- raw_wide_counts[raw_wide_counts$Species=="dianthus", 
                               as.character(1960:2017)]

# flatten into one vector
pre_all_Dp <- unlist(pre_year_Dp)
pre_all_Dd <- unlist(pre_year_Dd)

# count totals
pre_total_Dp_NAs <- sum(pre_all_Dp == 0, na.rm = TRUE)    # number of 0s
pre_total_Dd_NAs <- sum(pre_all_Dd == 0, na.rm = TRUE)    # number of 0s
# reminder: though coded as 0 count, data was presence-only. 
# Thus, 0's in the wide format represent NAs. 

pre_total_present_Dp <- sum(pre_all_Dp > 0, na.rm = TRUE) # number of >0 cells
pre_total_present_Dd <- sum(pre_all_Dd > 0, na.rm = TRUE) # number of >0 cells

# create summary table
pre_summary_Dp <- data.frame(pre_NA = pre_total_Dp_NAs,
                          pre_present = pre_total_present_Dp) |> 
  mutate(pre_total = pre_NA + pre_present,
         pre_NA_prop = pre_NA / pre_total,
         pre_present_prop = pre_present / pre_total)
pre_summary_Dd <- data.frame(pre_NA = pre_total_Dd_NAs,
                             pre_present = pre_total_present_Dd) |> 
  mutate(pre_total = pre_NA + pre_present,
         pre_NA_prop = pre_NA / pre_total,
         pre_present_prop = pre_present / pre_total)

pre_summary_Dp
pre_summary_Dd


## 4 Post-backfilled data by species -------------------------------------------

# select year columns for counts (ChatGPT was used to generate ideas)
post_year_Dp <- backfill_wide_counts[backfill_wide_counts$Species=="pertusum", 
                                     as.character(1960:2017)]
post_year_Dd <- backfill_wide_counts[backfill_wide_counts$Species=="dianthus", 
                                     as.character(1960:2017)]

# flatten into one vector
post_all_Dp <- unlist(post_year_Dp)
post_all_Dd <- unlist(post_year_Dd)


# count totals
post_total_Dp_NAs <- sum(post_all_Dp == 0, na.rm = TRUE)    # number of 0s
post_total_Dd_NAs <- sum(post_all_Dd == 0, na.rm = TRUE)    # number of 0s
# reminder: though coded as 0 count, data was presence-only. 
# Thus, 0's in the wide format represent NAs. 

post_total_present_Dp <- sum(post_all_Dp > 0, na.rm = TRUE) # number of >0 cells
post_total_present_Dd <- sum(post_all_Dd > 0, na.rm = TRUE) # number of >0 cells

# create summary table
post_summary_Dp <- data.frame(post_NA = post_total_Dp_NAs,
                           post_present = post_total_present_Dp) |> 
  mutate(post_total = post_NA + post_present,
         post_NA_prop = post_NA / post_total,
         post_present_prop = post_present / post_total)

post_summary_Dd <- data.frame(post_NA = post_total_Dd_NAs,
                              post_present = post_total_present_Dd) |> 
  mutate(post_total = post_NA + post_present,
         post_NA_prop = post_NA / post_total,
         post_present_prop = post_present / post_total)

post_summary_Dp
post_summary_Dd

# count of values backfilled
count_backfilled_Dp <- post_total_present_Dp - pre_total_present_Dp
count_backfilled_Dd <- post_total_present_Dd - pre_total_present_Dd

count_backfilled_Dp
count_backfilled_Dd

# proportion of non-missing values that are original values
pre_summary_Dp$pre_present / post_summary_Dp$post_present
pre_summary_Dd$pre_present / post_summary_Dd$post_present

# proportion of values backfilled in final dataset
count_backfilled_Dp / post_summary_Dp$post_total
count_backfilled_Dd / post_summary_Dd$post_total


## 5 Backfill relative to counts -----------------------------------------------
  # Note: this analysis factors in counts, not only presence as before

# total individual count in original data
original_count <- coral_data |> 
  count(Species) |> 
  summarize(Total = sum(n))
original_count

# total individual count, post-backfill
orig_and_bf_count <- backfill_wide_counts |> 
  summarize(Total = sum(total))
orig_and_bf_count

# number of backfilled counts
bf_count <- orig_and_bf_count - original_count
bf_count

# number of locations+years with no counts (e.g., missing)
zero_counts <- sum(backfill_wide_counts == 0)
zero_counts

# total number of counts
total_count <- bf_count + original_count + zero_counts
total_count

# proportion of zero counts
zero_counts / total_count

# proportion of original counts
original_count / total_count

# proportion of backfill counts
bf_count / total_count

# proportion of non-zero counts
(total_count - zero_counts) / total_count


## 6 Backfill relative to counts for each species ------------------------------
# Note: this analysis factors in counts, not only presence as before

# total individual count in original data
species_original_count <- coral_data |> 
  count(Species, name = "original_n") 
species_original_count

# total individual count, post-backfill
species_orig_and_bf_count <- backfill_wide_counts |>
  group_by(Species) |> 
  summarize(Total = sum(total), .groups = "drop")
species_orig_and_bf_count

# combine both summaries side by side
species_summary <- full_join(species_original_count, 
                             species_orig_and_bf_count, 
                             by = "Species") |> 
  mutate(prop_original = original_n / Total,
         prop_backfilled = (Total - original_n) / Total)
species_summary



# close log
sink()
