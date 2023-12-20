# filename: fig_4b.R
# Fig 4B: results for Trait by brain dissections. Traits and dissections with any signals were plotted.

library(data.table)
library(tidyverse)
library(scico)
library(rcartocolor)
library(ggplot2)
library(readxl)
library(here)
source(here("R/order_data.R"))

df2 <- read_xlsx(here("data/supplemental-tables.xlsx"), sheet = "TableS10") %>%
  rename(Trait=Phenotype, regions=Brain_region) %>%
  mutate(regions2=gsub("Paleocortex","Paleo_cortex",regions),
         regions2=gsub("_","\n",regions2),
         if.sig.fdr.weightedSum=ifelse(FDR<0.05,"yes","no")) 
df2$disorder_type = factor(df2$disorder_type, 
                           levels=c('psychiatric',
                                    'brain traits',
                                    'structural MRI',
                                    'neurological',
                                    'control'))
df2$Trait = factor(df2$Trait,
                   level=order_final_traits)

# extract only psychiatric and brain traits and regions with any significance to plot
tmp <- df2 %>% filter(if.sig.fdr.weightedSum=="yes") %>%
  distinct(Brain_anatomic_dissection)
tmp1 <- df2 %>% 
  filter(if.sig.fdr.weightedSum=="yes") %>%
  distinct(Trait)

# plot
p <- ggplot(df2 %>% filter(Brain_anatomic_dissection%in%tmp$Brain_anatomic_dissection) %>% filter(Trait%in%tmp1$Trait) %>%
              mutate(regions2=gsub("Hypothalamus","HTH",regions2)),
            aes(Trait, Brain_anatomic_dissection)) + 
  geom_point(aes(fill = -log10(P_for_weighted_sum_Z), size = if.sig.fdr.weightedSum, color=if.sig.fdr.weightedSum), alpha = .85, shape = 21) +
  theme(panel.background = element_rect(fill = "transparent"),
        axis.text.x=element_text(angle = 30, hjust=1),
        legend.key = element_rect(fill = "transparent"))+
  scale_fill_gradientn(colours = c("white", "darkblue"), name=expression('-log'[10]*'(P)')) +
  scale_color_manual(values=c("lightgrey","black"), name="Sig.") + 
  facet_grid(fct_relevel(regions2,order_regions2)~disorder_type, 
             scales = "free", 
             space = "free") +
  guides(color="none") + labs(size = "FDR sig.")+ ylab("")+xlab("")+
  guides(size=guide_legend(override.aes=list(color=c("lightgrey","black")))) 

ggsave(p,
       file=here("workflow/figures/4b_dissections_traits.pdf"),
       width = 4.5, height=19)

#--- end ---#