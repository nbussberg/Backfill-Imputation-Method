# Metadata ---------------------------------------------------------------------

# Code written by: Kelly Donovan and Nicholas Bussberg
# Last Update: 2026-04-27
# Filename: impbf5V3-tiled_heatmap.R

# Purpose of this script:
  # create tiled heatmap to illustrate backfill method

# NOTE 1: The uncommented code (first half of script) is designed to generate
  # the graph for Windows users. The commented-out code (bottom of script) is 
  # designed for Mac users. 

# NOTE 2: ChatGPT was used to generate code ideas for the graph


# Setup ------------------------------------------------------------------------
rm(list=ls())

options(width = 80)

filename <-"impbf5V3-tiled_heatmap"

sink(paste(filename, ".log", sep = "")) # create log file to store output

# R version
R.version.string


# Project Code -----------------------------------------------------------------

## 0 Load functions and data ---------------------------------------------------

# Load packages

# library(readr)
library(dplyr)
library(ggplot2)
library(patchwork)
library(tidyr)
library(ggtext)

# Read in data

coral_data <- readRDS(file = "impbf1-NGOM-Desmo.RDS")
backfill_counts <- readRDS(file = "impbf3-backfill-counts-long.RDS")


## All code that follows that is uncommented is designed to generate the graph
  # for Windows users. Mac users can find code at the bottom of the script that
  # will generate the graph on Macs. ##

# Change variable "Species" to encode italics (idea from ChatGPT)

coral_data <- coral_data |>
  mutate(Species = recode(Species,
                          "dianthus" = "*D. dianthus*",
                          "pertusum" = "*D. pertusum*"))
backfill_counts <- backfill_counts |>
  mutate(Species = recode(Species,
                          "dianthus" = "*D. dianthus*",
                          "pertusum" = "*D. pertusum*"))


## 1 Pre-backfilled graph ------------------------------------------------------

# prep data
coral_binned_pre <- coral_data |>
  group_by(Species, ObservationYear) |>
  summarise(Count = n(), .groups = "drop") |>
  mutate(CountBin = case_when(Count <= 25 ~ "1–25",
                              Count <= 50 ~ "26–50",
                              Count > 50 ~ ">50"),
         CountBin = factor(CountBin, levels = c("1–25", "26–50", ">50")))

# plot
pre <- ggplot(coral_binned_pre, aes(x = ObservationYear, y = Species)) +
  geom_tile(aes(fill = CountBin), width = 1, height = 0.8) +
  scale_fill_manual(values = c("1–25" = "turquoise",
                               "26–50" = "steelblue",
                               ">50" = "darkblue"),
                    name = "Coral Count") +
  scale_x_continuous(breaks = seq(1960, 2020, by = 10),
                     labels = paste0(seq(1960, 2020, by = 10)),
                     limits = c(1960, 2022)) +
  labs(x = "", y = "Pre-Backfill") +
  theme_minimal(base_size = 14) +
  theme(axis.text.y = element_markdown(),
        plot.title = element_markdown())
pre


## 2 Post-backfilled graph -----------------------------------------------------

# prep data 
coral_binned_post <- backfill_counts |>
  group_by(Species, ObservationYear) |>
  summarise(Count = sum(count, na.rm = TRUE), .groups = "drop") |>
  mutate(CountBin = case_when(Count <= 25 ~ "1–25",
                              Count <= 50 ~ "26–50",
                              Count > 50 ~ ">50"),
         CountBin = factor(CountBin, levels = c("1–25", "26–50", ">50")))

# plot
post <- ggplot(coral_binned_post, aes(x = ObservationYear, y = Species)) +
  geom_tile(aes(fill = CountBin), width = 1, height = 0.8) +
  scale_fill_manual(values = c("1–25" = "turquoise",
                               "26–50" = "steelblue",
                               ">50" = "darkblue"),
                    name = "Coral Count") +
  scale_x_continuous(breaks = seq(1960, 2020, by = 10),
                     labels = paste0(seq(1960, 2020, by = 10)),
                     limits = c(1960, 2022)) +
  labs(x = "Observation Year", y = "Post-Backfill") +
  theme_minimal(base_size = 14) +
  theme(axis.text.y = element_markdown())
post


pdf(file = paste(filename, ".pdf", sep = ""), height = 4.5, width = 9)
(pre / post) + plot_layout(guides = "collect") & theme(legend.position = "bottom")
dev.off()




# close log
sink()



## Following code is designed to generate the graph for Mac users ##

# ## 1 Pre-backfilled graph ------------------------------------------------------
# 
# # prep data
# coral_binned_pre <- coral_data |>
#   group_by(Species, ObservationYear) |>
#   summarise(Count = n(), .groups = "drop") |>
#   mutate(CountBin = case_when(Count <= 25 ~ "1–25",
#                               Count <= 50 ~ "26–50",
#                               Count > 50 ~ ">50"),
#          CountBin = factor(CountBin, levels = c("1–25", "26–50", ">50")))
# 
# # plot
# pre <- ggplot(coral_binned_pre, aes(x = ObservationYear, y = Species)) +
#   geom_tile(aes(fill = CountBin), width = 1, height = 0.8) +
#   scale_fill_manual(values = c("1–25" = "turquoise",
#                                "26–50" = "steelblue",
#                                ">50" = "darkblue"),
#                     name = "Coral Count") +
#   scale_x_continuous(breaks = seq(1960, 2020, by = 10),
#                      labels = paste0(seq(1960, 2020, by = 10)),
#                      limits = c(1960, 2022)) +
#   scale_y_discrete(labels = c(expression(italic("D. dianthus")),
#                               expression(italic("D. pertusum")))) +
#   labs(x = "", y = "Pre-Backfill") +
#   theme_minimal(base_size = 14) +
#   theme(axis.text.y = element_markdown(),
#         plot.title = element_markdown())
# pre
# 
# 
# ## 2 Post-backfilled graph -----------------------------------------------------
# 
# # prep data
# coral_binned_post <- backfill_counts |>
#   group_by(Species, ObservationYear) |>
#   summarise(Count = sum(count, na.rm = TRUE), .groups = "drop") |>
#   mutate(CountBin = case_when(Count <= 25 ~ "1–25",
#                               Count <= 50 ~ "26–50",
#                               Count > 50 ~ ">50"),
#          CountBin = factor(CountBin, levels = c("1–25", "26–50", ">50")))
# 
# # plot
# post <- ggplot(coral_binned_post, aes(x = ObservationYear, y = Species)) +
#   geom_tile(aes(fill = CountBin), width = 1, height = 0.8) +
#   scale_fill_manual(values = c("1–25" = "turquoise",
#                                "26–50" = "steelblue",
#                                ">50" = "darkblue"),
#                     name = "Coral Count") +
#   scale_x_continuous(breaks = seq(1960, 2020, by = 10),
#                      labels = paste0(seq(1960, 2020, by = 10)),
#                      limits = c(1960, 2022)) +
#   scale_y_discrete(labels = c(expression(italic("D. dianthus")),
#                               expression(italic("D. pertusum")))) +
#   labs(x = "Observation Year", y = "Post-Backfill") +
#   theme_minimal(base_size = 14) +
#   theme(axis.text.y = element_markdown())
# post
# 
# 
# pdf(file = paste(filename, ".pdf", sep = ""), height = 4.5, width = 9)
# (pre / post) + plot_layout(guides = "collect") & theme(legend.position = "bottom")
# dev.off()



