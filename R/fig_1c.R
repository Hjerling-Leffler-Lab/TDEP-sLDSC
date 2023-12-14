

library(data.table)
library(tidyverse)
library(ggplot2)
library(scico)
library(rcartocolor)
library(readxl)


dat <- 
  read_tsv(here("data/mdd_subtypes.tsv.gz")) |> 
  filter(!Trait %in% c("early_onset_nordic", "early_onset_nordic_without_ukb")) |> 
  count(Trait)

order_main <- read_excel("/Users/yaoshu/Proj/Adult_Brain_CT/data/sumstats/final_order.xlsx",
                         sheet=3)
order_all <- read_excel("/Users/yaoshu/Proj/Adult_Brain_CT/data/sumstats/final_order.xlsx",
                        sheet=4)

dat$Supercluster <- factor(dat$Supercluster,
                           levels=rev(c("Upper-layer intratelencephalic",
                                        "Deep-layer intratelencephalic",
                                        "Deep-layer near-projecting",
                                        "Deep-layer corticothalamic and 6b",
                                        "Hippocampal CA1-3",
                                        "Hippocampal CA4",
                                        "Hippocampal dentate gyrus",
                                        "Amygdala excitatory",
                                        "Thalamic excitatory",
                                        "MGE interneuron",
                                        "CGE interneuron",
                                        "LAMP5-LHX6 and Chandelier",
                                        "Medium spiny neuron",
                                        "Eccentric medium spiny neuron",
                                        "Splatter",
                                        "Midbrain-derived inhibitory",
                                        "Mammillary body",
                                        "Lower rhombic lip",
                                        "Upper rhombic lip",
                                        "Cerebellar inhibitory",
                                        "Miscellaneous",
                                        "Astrocyte",
                                        "Bergmann glia",
                                        "Choroid plexus",
                                        "Committed oligodendrocyte precursor",
                                        "Ependymal",
                                        "Fibroblast",
                                        "Microglia",
                                        "Oligodendrocyte precursor",
                                        "Oligodendrocyte",
                                        "Vascular")))

dat$Trait2 <- factor(dat$Trait2, levels=order_all$label_in_figure
                     # levels=c(
                     #   "mdd2019 (170.8k)",
                     #   "bip2021_type1 (25.1k)",
                     #   "bip2021_type2 (6.8k)",
                     #   "single_episode (21k)",
                     #   "recurrent (30.2k)",
                     #   "mild_impair (28.7k)",
                     #   "moderate_impair (29k)",
                     #   "severe_impair (25.8k)",
                     #   "without_suicidal_thought (37.1k)",
                     #   "with_suicidal_thought (41k)",
                     #   "mdd_ppd (17.3k)",
                     #   "atypical (2.9k)",
                     #   "non-atypical (46.9k)",
                     #   "mild (11.3k)",
                     #   "severe (7.9k)",
                     #   "no_comorbid-anxiety (16.5k)",
                     #   "comorbid_anxiety (24.5k)",
                     #   "early_onset (29.3k)",
                     #   "late_onset (27.8k)",
                     #   "mdd_ect (2.7k)")
)

p1 <- ggplot(dat, aes(Trait2, Supercluster)) + 
  geom_point(aes(fill = minuslog10P, size = if.sig.fdr, color=if.sig.fdr), alpha = .85, shape = 21) +
  theme(panel.background = element_rect(fill = "transparent"),
        axis.text.x=element_text(angle = 30, hjust=1),
        legend.key = element_rect(fill = "transparent"))+
  scico::scale_fill_scico(palette = "lajolla", midpoint=5, name=expression('-log'[10]*'(P)'))+
  scale_size_manual(values = c(1.5,4.5), name="FDR sig.")+
  scale_color_manual(values=c("lightgrey","black"), name="Sig.") + 
  guides(color="none") + 
  guides(size=guide_legend(override.aes=list(color=c("lightgrey","black")))) +
  ylab("") + xlab("") +
  facet_grid(~fct_relevel(MDD_group,
                          "Reference",
                          "Recurrence",
                          "Impair",
                          "Suicidality",
                          "PPD",
                          "Vegetative",
                          "Symptome",
                          "Anxiety",
                          "Onset",
                          "ECT"),
             scales = "free", space = "free") 
p1
ggsave(p1,
       file="./plot/Supercluster_MDDtraits_P_supplementary.pdf",
       width=11, height = 8)
ggsave(p1,
       file="./plot/Supercluster_MDDtraits_P_supplementary.png",
       width=11, height = 8, dpi=300)
ggsave(p1,
       file="./plot/Supercluster_MDDtraits_P_supplementary.jpeg",
       width=11, height = 8, dpi=300)


### keep only traits for main plot ###

dat1 <- dat %>% 
  filter(MDD_group %in% c("Reference", "Impair","Recurrence","Suicidality","PPD"))
dat1$Supercluster <- factor(dat1$Supercluster,
                            levels=rev(c("Upper-layer intratelencephalic",
                                         "Deep-layer intratelencephalic",
                                         "Deep-layer near-projecting",
                                         "Deep-layer corticothalamic and 6b",
                                         "Hippocampal CA1-3",
                                         "Hippocampal CA4",
                                         "Hippocampal dentate gyrus",
                                         "Amygdala excitatory",
                                         "Thalamic excitatory",
                                         "MGE interneuron",
                                         "CGE interneuron",
                                         "LAMP5-LHX6 and Chandelier",
                                         "Medium spiny neuron",
                                         "Eccentric medium spiny neuron",
                                         "Splatter",
                                         "Midbrain-derived inhibitory",
                                         "Mammillary body",
                                         "Lower rhombic lip",
                                         "Upper rhombic lip",
                                         "Cerebellar inhibitory",
                                         "Miscellaneous",
                                         "Astrocyte",
                                         "Bergmann glia",
                                         "Choroid plexus",
                                         "Committed oligodendrocyte precursor",
                                         "Ependymal",
                                         "Fibroblast",
                                         "Microglia",
                                         "Oligodendrocyte precursor",
                                         "Oligodendrocyte",
                                         "Vascular")))

# dat1$MDD_group <- factor(dat1$MDD_group, levels=order_main$label_in_figure
#                         #levels=c("Reference", "Impair","Recurrence","Suicidality","PPD")
#                         )

dat1$Trait2 <- factor(dat1$Trait2, levels=order_main$label_in_figure
                      # levels=c(
                      #   "mdd2019 (170.8k)",
                      #   "bip2021_type1 (25.1k)",
                      #   "bip2021_type2 (6.8k)",
                      #   "severe_impair (25.8k)",
                      #   "moderate_impair (29k)",
                      #   "mild_impair (28.7k)",
                      #   "recurrent (30.2k)",
                      #   "single_episode (21k)",
                      #   "with_suicidal_thought (41k)",
                      #   "without_suicidal_thought (37.1k)",
                      #   "mdd_ppd (17.3k)")
)


p1a <- ggplot(dat1, aes(Trait2, Supercluster)) + 
  geom_point(aes(fill = minuslog10P, size = if.sig.fdr, color=if.sig.fdr), alpha = .85, shape = 21) +
  theme(panel.background = element_rect(fill = "transparent"),
        axis.text.x=element_text(angle = 30, hjust=1),
        legend.key = element_rect(fill = "transparent"))+
  scico::scale_fill_scico(palette = "lajolla", midpoint=5, name=expression('-log'[10]*'(P)'))+
  scale_size_manual(values = c(1.5,4.5), name="Sig.(FDR)")+
  scale_color_manual(values=c("lightgrey","black"), name="Sig.") + 
  guides(color="none", fill="none", size="none") + 
  #guides(size=guide_legend(override.aes=list(color=c("lightgrey","black")))) +
  ylab("") + xlab("") +
  facet_grid(~fct_relevel(MDD_group,
                          "Reference",
                          "Recurrence",
                          "Impair",
                          "Suicidality",
                          "PPD"), 
             scales = "free_x", 
             space = "free_x") 
p1a
ggsave(p1a,
       file="./plot/Supercluster_MDDtraits_P.pdf",
       width=6.5, height = 7, dpi=300)
ggsave(p1a,
       file="./plot/Supercluster_MDDtraits_P.png",
       width=6.5, height = 7, dpi=300)
ggsave(p1a,
       file="./plot/Supercluster_MDDtraits_P.jpeg",
       width=6.5, height = 7, dpi=300)

#--- end ---#
