#------------------------------------------------------------------------------#
#------------------------     Essential libraries     -------------------------#
#------------------------------------------------------------------------------#
# Header ----
# Author: Kevin Yang
# Date created : January 20, 2023
# Purpose: To attach a list of essential libraries.
# v1.0
#
# Special considerations:
# - Currently the checkpoint package is used to ensure package reproducibility.
#   However, MRNA and the checkpoint package will be decommissioned as of July
#   2023, so future development will be to use miniCRAN to create a local
#   repository to attach libraries from.
#
# Update history:
#
#
#------------------------------------------------------------------------------#
# Checkpoint
library(checkpoint)
checkpoint("2019-02-01")

# Core libraries
library(tidyverse)

# Data access
library(olapR)
library(RODBC)
library(readxl)

# Data wrangling
library(reshape2)
library(lubridate)
library(magrittr)

# Data visualization
library(ggpubr)
library(RColorBrewer)
library(flextable)

# Data output
library(openxlsx)
library(knitr)

# Others
library(mailR)







