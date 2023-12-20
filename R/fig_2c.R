# filename: fig_2c.R
# Fig2C_Supercluster_MDDsubtypes.R

library(data.table)
library(tidyverse)
library(ggplot2)
library(scico)
library(rcartocolor)
library(readxl)
library(here)
source(here("R/order_data.R"))

dat <- fread(here("data/PlotDF_Supercluster_MDD.tsv")) %>%
  filter(!Trait %in% c("early_onset_nordic", "early_onset_nordic_without_ukb"))

### keep only traits for main plot ###

dat1 <- dat %>% 
  filter(MDD_group %in% c("Reference", "Impair","Recurrence","Suicidality","PPD"))
dat1$Supercluster <- factor(dat1$Supercluster,
                            levels=rev(order_ct))

dat1$Trait2 <- factor(dat1$Trait2, levels=order_traits_mdd2)


p1a <- ggplot(dat1, aes(Trait2, Supercluster)) + 
  geom_point(aes(fill = minuslog10P, size = if.sig.fdr, color=if.sig.fdr), alpha = .85, shape = 21) +
  theme(panel.background = element_rect(fill = "transparent"),
        axis.text.x=element_text(angle = 30, hjust=1),
        legend.key = element_rect(fill = "transparent"))+
  scico::scale_fill_scico(palette = "lajolla", midpoint=5, name=expression('-log'[10]*'(P)'))+
  scale_size_manual(values = c(1.5,4.5), name="Sig.(FDR)")+
  scale_color_manual(values=c("lightgrey","black"), name="Sig.") + 
  guides(color="none", fill="none", size="none") + 
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
       file=here("workflow/figures/2c_MDDsubtypes.pdf"),
       width=6.5, height = 7, dpi=300)

#--- end ---#

