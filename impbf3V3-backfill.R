# Metadata ---------------------------------------------------------------------

# Code written by: Kelly Donovan and Nicholas Bussberg
# Last Update: 2026-06-29
# Filename: impbf3V3-backfill.R

# Purpose of this script:
  # apply backfill approach to Desmophyllum corals in NOAA dataset

# Note: ChatGPT was used to help generate code for backfill method

# Setup ------------------------------------------------------------------------
rm(list=ls())

options(width = 80)

filename <-"impbf3V3-backfill"

sink(paste(filename, ".log", sep = "")) # create log file to store output

# R version
R.version.string


# Project Code -----------------------------------------------------------------

## 0 Load functions and data ---------------------------------------------------

# Load packages

library(dplyr)
library(tidyr)

# Read in data

coral_data <- readRDS(file = "impbf1-NGOM-Desmo.RDS")


## 1 Parameter setup -----------------------------------------------------------

# growth table for the two species 
growth_table <- data.frame(backfill_years = c(13, 64), 
                           Genus = c("Desmophyllum", "Desmophyllum"),
                           Species = c("pertusum", "dianthus"))
  # backfill_years represents how many years to backfill for that species
    # number of years to backfill was determined from lit review of the species

# create range of years in dataset
year_range <- data.frame(ObservationYear = 1960:max(coral_data$ObservationYear))

num_years <- length(year_range$ObservationYear)
min_year <- min(year_range$ObservationYear)
max_year <- max(year_range$ObservationYear)

# modify backfill years if the value extends beyond the valid year range
growth_table <- growth_table |>
  mutate(backfill_years = ifelse(backfill_years > num_years - 1, 
                                 num_years - 1, backfill_years))


## 2 Expand dataset ------------------------------------------------------------
  # Since dataset contains presence-only observations, it must be expanded to 
    # include all locations+years that could have data (which are missing)

# create all combinations of coral locations × years
expanded_data <- coral_data |>
  distinct(latitude, longitude, DepthInMeters, Genus, Species) |>
  tidyr::crossing(year_range)

# count how many corals are in each location in each year
data_counts <- coral_data |>
  group_by(latitude, longitude, DepthInMeters, Genus, Species, ObservationYear) |>
  summarise(count = n(), .groups = "drop")

# merge expanded and count datasets; fill unobserved combinations with 0s
data_full <- expanded_data |>
  left_join(data_counts, by = c("latitude", "longitude", "DepthInMeters", 
                                "Genus", "Species", "ObservationYear")) |>
  mutate(count = replace_na(count, 0))

# create wide format version of counts for review
raw_wide_counts <- data_full |>
  pivot_wider(names_from = ObservationYear, values_from = count) |>
  mutate(total = rowSums(across(`1960`:`2017`)))


## 3 Backfill procedure --------------------------------------------------------

# merge growth table with data_full
data_full <- data_full |>
  left_join(growth_table, by = c("Genus", "Species"))

# implement backfilling method
backfilled_rows <- data_full |>
  filter(count > 0) |> 
  rowwise() |>
  mutate(backfill_years_list = list((ObservationYear - backfill_years):(ObservationYear - 1))) |>
  unnest(backfill_years_list) |>
  filter(backfill_years_list >= min_year) |>
  mutate(ObservationYear = backfill_years_list)


# combine original data with backfilled, 
  # then consider overlaps by taking the max count for unique location+year+species
data_backfilled <- bind_rows(data_full, backfilled_rows) |>
  group_by(latitude, longitude, DepthInMeters, Genus, Species, ObservationYear) |>
  summarise(count = max(count), .groups = "drop")

# create wide format version of counts for review
data_wide_counts_backfilled <- data_backfilled |>
  pivot_wider(names_from = ObservationYear,
              values_from = count,
              values_fill = 0) |>
  mutate(total = rowSums(across(`1960`:`2017`)))


## 4 Save data -----------------------------------------------------------------

saveRDS(data_wide_counts_backfilled, "impbf3V3-backfill-counts-wide.RDS")
saveRDS(data_backfilled, "impbf3V3-backfill-counts-long.RDS")
saveRDS(raw_wide_counts, "impbf3V3-raw-counts-wide.RDS")



# close log
sink()

