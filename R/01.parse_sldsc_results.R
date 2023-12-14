library(tidyverse)
library(fs)
library(googlesheets4)
library(here)
df <- read_sheet("https://docs.google.com/spreadsheets/d/13xrrUL0_0GdubNxm0Lod71CHemvzNLdUsVLG3xev9tk/edit#gid=0", sheet = "TableS3")
dir_ls(here("workflow")

prev <- df |> filter(Supercluster == "Amygdala excitatory" & label == "bmi")
new <- 
  read_tsv(here("workflow/results/s-ldsc/bmi2018_X_Amygdala_excitatory.results")) |> 
  filter(Category == "L2_1") |> 
  mutate(Z = Coefficient / Coefficient_std_error) |> 
  select(-2,-3,-4)


transform_pldsc_celltype <- function(df, fdr_method= "fdr") {
  df |> 
    mutate(p = 1-pnorm(coefficient_z_score)) |> 
    group_by(pheno) |> 
    rstatix::adjust_pvalue("p", "p.adj", {{ fdr_method }}) |> 
    mutate(
      log = -log10(p),
      sig = if_else(p.adj < 0.05, "yes", "no")
    )
}

