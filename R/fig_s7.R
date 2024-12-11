library(data.table)
library(here)
library(ggplot2)

sc_data <- read_tsv(here("data/supercluster_data.tsv"))
# to get colors
hue_pal()(5)
colors <- c(
  "Original" = "black", 
  "bip2021" = "#F8766D",
  "educational_attainment" = "#A3A500",
  "iq" = "#00BF7D",
  "mdd2019" = "#00B0F6",
  "neuroticism" = "#E76BF3"
)

original <- readxl::read_xlsx("Supplementary_Datasets.xlsx", sheet = 6) |> 
  filter(label == "scz2022") |> 
  mutate(
    gwa2 = "Original", 
    sig = if_else(if.sig.fdr=="yes", "Yes", "No"),
    Name = janitor::make_clean_names(Supercluster),
  ) |> 
  select(Coefficient_P_value = P, sig, gwa2, Name) |> 
  filter(Name %in% sc_data$Name)

bind_rows(sc_data, original) |> 
  ggplot(aes(Name, -log10(Coefficient_P_value),alpha = sig, fill = gwa2 )) +
  geom_col(position = position_dodge()) +
  coord_flip() +
  geom_hline(yintercept = -log10(0.05/31)) +
  theme_light() +
  labs(
    # title = glue::glue("GWAS-by-subtraction with Scizophrenia as index trait")
    fill = "Trait subtracted",
    alpha = "FDR significant",
    y = "-log10(P)"
  ) +
  scale_fill_manual(values = colors)

ggsave("workflow/figures/supercluster_barplot.png", dpi = 300, height =7, width =10)
