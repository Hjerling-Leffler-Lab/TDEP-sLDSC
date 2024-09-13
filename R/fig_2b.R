# plot: fig_2b.R
# fig 2B: conditional_analysis

library(tidyverse)
library(data.table)
library(scico)
library(rstatix)
library(here)
library(readxl)
source(here("R/order_data.R"))

# ------------------------------------------------------------------------------

all <- fread(here("data/data_2b.tsv"))

main_res <- read_tsv(here("data/PlotDF_Supercluster.tsv")) %>% 
  filter(dataset_name == "scz2022_eur") %>% 
  adjust_pvalue("P","P.adj",method="fdr") %>%
  # match up variable names
  select(Supercluster_ID, P, P.adj, Supercluster)%>% 
  mutate(adjusted_for = Supercluster, Category=Supercluster)

tmp <- main_res %>%
  distinct(Supercluster_ID, Supercluster)
all <- all %>% 
  rename(Category0=Category,
         adjusted_for0=adjusted_for) %>%
  left_join(tmp, by=c("Category0"="Supercluster_ID")) %>%
  filter(Supercluster%in%order_ct2) %>%
  rename(Category=Supercluster) %>%
  left_join(tmp, by=c("adjusted_for0"="Supercluster_ID")) %>%
  filter(Supercluster%in%order_ct2) %>%
  rename(adjusted_for=Supercluster)

# restrict to top left corner
processed <- 
  all %>% 
  rename(z = `Coefficient_z-score`) %>% 
  mutate(P =1-pnorm(z)) %>% 
  group_by(Category) %>% 
  rstatix::adjust_pvalue("P", method = "fdr") %>%
  bind_rows(main_res) %>% select(-Supercluster, -Supercluster_ID) %>%
  filter(Category %in% order_ct2 & adjusted_for %in% order_ct2) %>%
  mutate(
    Category = factor(Category, levels = rev(order_ct2)),
    adjusted_for = factor(adjusted_for, levels = order_ct2)
  ) %>% 
  mutate(fdr_sig = if_else(P.adj < 0.05,"Yes", "No"))

processed %>%  
  ggplot(aes(adjusted_for,Category)) + 
  geom_point(aes(fill = -log10(P), 
                 size = fdr_sig,
                 color = fdr_sig), alpha = .85, shape = 21) +
  theme(
    panel.background = element_rect(fill = "transparent"),
    axis.text.x=element_text(angle = 45, hjust=1)
    ) +
  scico::scale_fill_scico(palette = "lajolla", midpoint=5, name=expression('-log'[10]*'(P)')) +
  scale_color_manual(values=c("grey","black"), name="Sig.") +
  labs(
    y = "Supercluster",
    x = "Conditioned on",
    size = "Sig.(FDR)"
  )+
  guides(color="none", fill="none", size="none") 


# ggsave(here("workflow/figures/2b_conditional_supercluster_SCZ.pdf"), width=6, height =5.8)

#--- end ---#