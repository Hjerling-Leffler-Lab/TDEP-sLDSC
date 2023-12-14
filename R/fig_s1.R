library(tidyverse)
library(readxl)
library(here)
library(ggrepel)
library(skimr)
library(rstatix)


# read in data
a <- read_xlsx(
  here("data/supplemental-tables.xlsx"),
  sheet = "TableS1"
) %>%
  mutate(
    year = as.integer(year),
    pmid = as.integer(as.character(pmid))
  ) # intentional


b <- a %>%
  filter(primary_gwas == TRUE) %>%
  mutate(nLociQ = ntile(n_loci, 4) - 1)


### bits of analysis for Methods text and legend

cor_test(b, n, n_loci)
# var1  var2     cor statistic         p conf.low conf.high method
# n     n_loci  0.62      4.65 0.0000489    0.371     0.790 Pearson

cor_test(filter(b, trait_type == "binary"), ncas, n_loci)
# var1  var2     cor statistic      p conf.low conf.high method
# ncas  n_loci  0.73      4.04 0.00121    0.374     0.902 Pearson

cor_test(b, n, ldsc_h2)
# var1  var2      cor statistic     p conf.low conf.high method
# n     ldsc_h2 -0.23     -1.36 0.182   -0.517     0.109 Pearson

b %>%
  group_by(nLociQ) %>%
  get_summary_stats(n_loci) %>%
  select(nLociQ:max)
#   nLociQ variable     n   min   max
# 1      0 n_loci       9     3    13
# 2      1 n_loci       9    13    37
# 3      2 n_loci       9    40   103
# 4      3 n_loci       9   180  2705
btmp <- b %>%
  arrange(nLociQ, phenotype) %>%
  select(nLociQ, phenotype, everything())

### figure
ggplot(b, aes(x = ldsc_h2, y = log10(n), colour = disorder_type)) +
  geom_point(aes(size = nLociQ, alpha = 0.5)) +
  geom_text_repel(aes(label = phenotype), size = 2, nudge_y = 0.075) +
  labs(subtitle = "", x = "SNP-heritability", y = expression("Sample size, log"[10] * " scale")) +
  theme_classic() +
  guides(alpha = "none", size = "none")



ggsave(filename = "workflow/figures/s1.pdf", height = 8, width = 10, dpi = 300)
  

