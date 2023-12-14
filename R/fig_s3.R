library(tidyverse)
library(data.table)
library(here)
library(rstatix)
library(skimr)


here("data/supercluster_gene_specificity.tsv.gz")
# === basic graph (median expression x fraction of genes expressed)
a <- read_tsv(here("data/supercluster_gene_specificity.tsv.gz")) %>%
  select(ensgid = ENSGID, Supercluster_ID, tpm = exp_tpm_supercluster, specificity) %>%
  mutate(
    Supercluster_ID = tolower(Supercluster_ID),
    spec = ifelse(tpm > 1, specificity, NA)
  ) %>%
  group_by(Supercluster_ID) %>%
  mutate(topDecile = spec > quantile(spec, 0.9, na.rm = T)) %>%
  ungroup() %>%
  filter(is.na(spec) == FALSE) %>% # NB !
  select(ensgid, Supercluster_ID, tpm, spec, topDecile)


b1 <- readxl::read_xlsx(here("data/supplemental-tables.xlsx"), sheet = "TableS2") %>%
  mutate(order = row_number()) %>%
  select(Supercluster, Supercluster_ID, Neuron, Neuron_type, order)

b2 <- a %>%
  group_by(Supercluster_ID) %>%
  summarise(p90 = quantile(spec, 0.9)) %>%
  ungroup()
b <- inner_join(b1, b2)
blist <- b %>%
  distinct(Neuron_type) %>%
  mutate(lbl = ifelse(Neuron_type == "-", "non-neuronal", Neuron_type))

adescr <- inner_join(a, b) %>%
  group_by(Supercluster, topDecile) %>%
  get_summary_stats(tpm) %>%
  ungroup() %>%
  pivot_wider(id_cols = Supercluster, names_from = topDecile, values_from = median) %>%
  mutate(diff = `TRUE` - `FALSE`) %>%
  inner_join(b)
adescr %>%
  group_by(Neuron, Neuron_type) %>%
  get_summary_stats(diff)

ggplot(data = a, aes(x = log2(tpm + 1), y = log10(spec))) +
  facet_wrap(~Supercluster_ID, ncol = 5) +
  geom_point(aes(color = topDecile, size = topDecile, alpha = topDecile)) +
  scale_color_manual(values = c("lightgrey", "darkgreen")) + # order F T
  scale_size_manual(values = c(0.1, 0.15)) +
  scale_alpha_manual(values = c(0.1, 0.15)) +
  geom_smooth() +
  labs(x = "Gene expression, log2(TPM+1)", y = "Expression proportion (log10)") +
  theme_classic() +
  theme(legend.position = "none", aspect.ratio = 0.8)


ggsave(filename = "workflow/figures/fig_s3.pdf", height = 16, width = 16, dpi = 300)


