# Metadata ---------------------------------------------------------------------

# Code written by: Kelly Donovan and Nicholas Bussberg
# Last Update: 2026-02-16
# Filename: impbf1V2-data_cleaning.R

# Purpose of this script:
  # clean NOAA data into a dataset of only Desmophyllum spp. corals


# Setup ------------------------------------------------------------------------
rm(list=ls())

options(width = 80)

filename <-"impbf1V2-data_cleaning"

sink(paste(filename, ".log", sep = "")) # create log file to store output

# R version
R.version.string


# Project Code -----------------------------------------------------------------

## 0 Load functions and data ---------------------------------------------------

# Load packages

library(readr)
library(dplyr)
library(stringr)

# Read in NOAA dataset
full_NOAA <- read_csv("deep_sea_corals_1f3c_25e3_1631.csv")


## 1 Data wrangling ------------------------------------------------------------

# Remove columns
NOAA_cols <- full_NOAA  |> 
  select(-Subclass, - ImageURL, -Subfamily, -EventID, -VerbatimSize,
         -Temperature, -MaximumSize, -MinimumSize, -SamplingEquipment,
         -DataProvider, -Station, -ShallowFlag, -Repository)

# Remove non-Cnidarians
table(NOAA_cols$Phylum)
only_Cnidaria <- NOAA_cols |>
  filter(Phylum != "Porifera", Phylum != "Chordata")
table(only_Cnidaria$Phylum)

# Convert latitude, longitude, and depth to numeric (also narrow lat/long range)
clean_latlongdepth <- only_Cnidaria |>
  mutate(latitude = as.numeric(latitude)) |>
  filter(latitude >= 8 & latitude <=41) |>
  mutate(longitude = as.numeric(longitude)) |>
  filter(longitude >= -98 & longitude <=-60) |>
  mutate(DepthInMeters = as.numeric(DepthInMeters))

# If Species is NA, replace with 2nd or 3rd word in ScientificName
  # ChatGPT was used to help generate initial ideas for code
table(clean_latlongdepth$Species, useNA = "ifany")
clean_species <- clean_latlongdepth |> 
  mutate(word_count = str_count(ScientificName, "\\S+"),
         Species = ifelse(is.na(Species) & word_count == 2,
                          word(ScientificName, 2),
                          ifelse(is.na(Species) & word_count == 3,
                                 word(ScientificName, 3),
                                 Species))) |>
  select(-word_count) 
table(clean_species$Species, useNA = "ifany")

# Confirm no Genus is NA for ScientificNames with Desmophyllum as genus
table(clean_species[clean_species$ScientificName %in% 
                      c("Desmophyllum", "Desmophyllum dianthus",
                        "Desmophyllum hourigani", 
                        "Desmophyllum pertusum"),]$Genus, useNA = "ifany")

# Remove any observations with NAs in lat, long, depth
clean_NA <- clean_species |> 
  filter(!is.na(latitude), !is.na(longitude), !is.na(DepthInMeters))
summary(clean_NA$latitude)
summary(clean_NA$longitude)
summary(clean_NA$DepthInMeters)

# Keep only observations >=1960, Northern Gulf, and D. dianthus & pertusum
NGOM_Desmo <- clean_NA |> 
  filter(gisMEOW == "Northern Gulf of Mexico", ObservationYear >= 1960,
         Species == "dianthus" | Species == "pertusum") 
  
# check filter cleaning
table(NGOM_Desmo$gisMEOW, useNA = "ifany")
table(NGOM_Desmo$Species, useNA = "ifany")
table(NGOM_Desmo$ObservationYear, useNA = "ifany")

# Keep only necessary vars
NGOM_Desmo <- NGOM_Desmo |> 
  select(latitude, longitude, DepthInMeters, ObservationYear, Genus, Species)


## 2 Save data -----------------------------------------------------------------

saveRDS(NGOM_Desmo, "impbf1-NGOM-Desmo.RDS")


# close log
sink()



