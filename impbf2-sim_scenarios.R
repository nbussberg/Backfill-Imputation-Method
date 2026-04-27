# Metadata ---------------------------------------------------------------------

# Code written by: Kelly Donovan and Nicholas Bussberg
# Last Update: 2026-03-24
# Filename: impbf2-sim_scenarios.R

# Purpose of this script:
  # create different scenarios to test backfill method on

# Note: ChatGPT was used to help generate code for backfill method

# Setup ------------------------------------------------------------------------
rm(list=ls())

options(width = 80)

filename <-"impbf2-sim_scnearios"

sink(paste(filename, ".log", sep = "")) # create log file to store output

# R version
R.version.string


# Project Code -----------------------------------------------------------------

## 0 Load functions and data ---------------------------------------------------

# Load packages

library(dplyr)
library(tidyr)


## 1 Scenario 1: only one species ----------------------------------------------

# create simulated dataset 
sim1 <- data.frame(latitude =      c(1, 1, 1, 2, 2, 3, 4, 5, 6, 7),
                   longitude =     c(1, 1, 1, 2, 2, 3, 4, 5, 6, 7),
                   DepthInMeters = c(1, 1, 1, 2, 2, 3, 4, 5, 6, 7),
                   ObservationYear = c(2015, 2015, 2011, 2016, 1997,
                                       1998, 2003, 2004, 1992, 2012),
                   Species = c("species1", "species1", "species1","species1", 
                               "species1", "species1", "species1", "species1", 
                               "species1", "species1"))

# create full range of years (also used in Scenario 2)
year_range <- data.frame(ObservationYear = 1990:2020)

# create all combinations of coral locations × years
expanded_sim1 <- sim1 |>
  distinct(latitude, longitude, DepthInMeters, Species) |>
  tidyr::crossing(year_range)

# count how many corals are in each location-year
sim1_counts <- sim1 |>
  group_by(latitude, longitude, DepthInMeters, Species, ObservationYear) |>
  summarise(count = n(), .groups = "drop")

# merge into expanded grid and fill 0s for unobserved combinations
sim1_full <- expanded_sim1 |>
  left_join(sim1_counts, by = c("latitude", "longitude", "DepthInMeters", 
                               "Species", "ObservationYear")) |>
  mutate(count = replace_na(count, 0))

# Create wide format version of counts
sim1_wide_counts <- sim1_full |>
  pivot_wider(names_from = ObservationYear, values_from = count) |>
  mutate(total = rowSums(across(`1990`:`2020`)))


# Backfill parameters
backfill_years <- 5
min_year <- min(year_range$ObservationYear) # also used in Scenario 2
max_year <- max(year_range$ObservationYear) # also used in Scenario 2


# Generate backfilled rows
backfilled_rows <- sim1_full |>
  filter(count > 0) |> 
  rowwise() |>
  mutate(backfill_years_list = list((ObservationYear - backfill_years):(ObservationYear - 1))) |>
  unnest(backfill_years_list) |>
  filter(backfill_years_list >= min_year) |>
  mutate(ObservationYear = backfill_years_list)


# Combine original + backfilled, summing overlaps
data_backfilled <- bind_rows(sim1_full, backfilled_rows) |>
  group_by(latitude, longitude, DepthInMeters, Species, ObservationYear) |>
  summarise(count = max(count), .groups = "drop")

# pivot to wide format for display
data_wide_counts_backfilled <- data_backfilled |>
  pivot_wider(names_from = ObservationYear,
              values_from = count,
              values_fill = 0)



## 1 Scenario 2: two species ---------------------------------------------------

# create simulated growth table
growth_table <- data.frame(backfill_years = c(5, 3), 
                           Genus = c("genus1", "genus2"),
                           Species = c("species1", "species2"))
  # backfill_years represents how many years to backfill for that species


# Create simulated data
sim2 <- data.frame(latitude =      c(1, 1, 1, 2, 2, 1, 1, 1, 3, 3),
                   longitude =     c(1, 1, 1, 2, 2, 1, 1, 1, 3, 3),
                   DepthInMeters = c(1, 1, 1, 2, 2, 1, 1, 1, 3, 3),
                   ObservationYear = c(2015, 2015, 2012, 2016, 1997,
                                       2015, 2015, 2012, 2016, 2014),
                   Genus = c("genus1", "genus1", "genus1", "genus1", "genus1", 
                             "genus2", "genus2", "genus2", "genus2", "genus2"),
                   Species = c("species1", "species1", "species1","species1", "species1", 
                               "species2", "species2", "species2", "species2", "species2"))

# Create all combinations of coral locations × years
expanded_sim2 <- sim2 |>
  distinct(latitude, longitude, DepthInMeters, Genus, Species) |>
  crossing(year_range)

# Count how many corals are in each location-year
sim2_counts <- sim2 |>
  group_by(latitude, longitude, DepthInMeters, Genus, Species, ObservationYear) |>
  summarise(count = n(), .groups = "drop")

# Merge into expanded grid and fill 0s for unobserved combinations
sim2_full <- expanded_sim2 |>
  left_join(sim2_counts, by = c("latitude", "longitude", "DepthInMeters", 
                               "Genus", "Species", "ObservationYear")) |>
  mutate(count = replace_na(count, 0))

# Create wide format version of counts
sim2_wide_counts <- sim2_full |>
  pivot_wider(names_from = ObservationYear, values_from = count) |>
  mutate(total = rowSums(across(`1990`:`2020`)))


# Backfill procedure -----------------------------------------------------------


# Merge growth information with data_full
sim2_full <- sim2_full |>
  left_join(growth_table, by = c("Genus", "Species"))

# Generate backfilled rows
backfilled2_rows <- sim2_full |>
  filter(count > 0) |> 
  rowwise() |>
  mutate(backfill_years_list = list((ObservationYear - backfill_years):(ObservationYear - 1))) |>
  unnest(backfill_years_list) |>
  filter(backfill_years_list >= min_year) |>
  mutate(ObservationYear = backfill_years_list)

# Combine original + backfilled, summing overlaps
data2_backfilled <- bind_rows(sim2_full, backfilled2_rows) |>
  group_by(latitude, longitude, DepthInMeters, Species, ObservationYear) |>
  summarise(count = max(count), .groups = "drop")

# pivot for viewing and checking
data2_wide_counts_backfilled <- data2_backfilled |>
  pivot_wider(names_from = ObservationYear,
              values_from = count,
              values_fill = 0)



# close log
sink()
