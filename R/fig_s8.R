#- fig_s8.R
# Supplementary figure for fMRI analyses

library(data.table)
library(tidyverse)
library(ggplot2)
library(here)

#- panel A. model AUC
df.mod <- fread(here("data/dfS8a.modAUC.tsv"))

p1 <- ggplot(df.mod,
             aes(x=Run,y=AUC, color=as.character(fold), 
                 shape=group, 
             )) +
  geom_point() +
  stat_smooth(method="loess", formula=y~x, alpha=.1, size=.5) +
  theme_classic() +
  guides(color="none") +
  geom_hline(yintercept = 0.5, color="darkgrey", linetype="dashed") +
  facet_wrap(~fold, nrow=1)

pdf(file=here("workflow/figures/s8a.modAUC.pdf"), width = 15, height=4)
p1
dev.off()

#- panel B. number of appearance
df.Region2 <- fread(here("data/dfS8b.Region.tsv"))
p2 <- ggplot(df.Region2 %>%
               mutate(regions2=ifelse(regions%in%c("Amygdala","BasalForebrain","Hippocampus"),
                                      regions,
                                      "Cortex")),
             aes(x=Run, y=reorder(Region, n_sum), fill=regions2, alpha=as.character(n))) +
  geom_tile() +
  theme_classic() +
  ylab("Regions (ranked by total number of apperance)") +
  scale_alpha_manual(values = c(0.2,0.4,0.6,0.8,1), name="Apperance per run") +
  guides(fill=guide_legend(title="Broad region"))

pdf(file=here("workflow/figures/s8b.Region.pdf"), height = 10)
p2 
dev.off()

#- panel C. pie-chart of all regions
df.hist.region <- fread(here("data/df5b.hist.region.tsv")) # input data same as main figure 5b
df.pie.region <- df.hist.region %>%
  group_by(regions2) %>%
  summarise(region_freq=n()) %>%
  ungroup()
p3 <- ggplot(df.pie.region,
             aes(x="", y=region_freq, fill=regions2)) +
  geom_bar(stat="identity",width = 1) +
  coord_polar("y", start = 0) +
  theme_void() +
  theme_classic() +
  guides(fill=guide_legend(title="")) +
  theme(axis.ticks.x = element_line(color="black"),
        axis.title = element_blank(),
        axis.text = element_text(size = 10), 
        panel.background = element_rect(fill = "white"))
pdf(file=here("workflow/figures/s8c.pie.allRegions.pdf"), height = 10)
p3 + labs(title="fig_s8c all 76 regions")
dev.off()

#- panel D. pie-chart of the top 20 regions
df.pie.region.top20.model <- df.hist.region %>%
  slice_max(order_by=n_model, n=20) %>%
  group_by(regions2) %>%
  summarise(region_freq=n()) %>%
  ungroup()
p4 <- ggplot(df.pie.region.top20.model,
             aes(x="", y=region_freq, fill=regions2)) +
  geom_bar(stat="identity",width = 1) +
  coord_polar("y", start = 0) +
  theme_void() +
  theme_classic() +
  guides(fill=guide_legend(title="")) +
  theme(axis.ticks.x = element_line(color="black"),
        axis.title = element_blank(),
        axis.text = element_text(size = 10), 
        legend.position = "none",
        panel.background = element_rect(fill = "white"))
pdf(file=here("workflow/figures/s8d.pie.top20Regions.pdf"), height = 10)
p4 + labs(title="fig_s8c top 20 regions")
dev.off()

#- panel E. heatmap
mymx <- fread(here("data/dfS8e.heatmap.matrix.tsv"))
pdf(file=here("workflow/figures/s8e.Edge.heatmap.pdf"), height = 10, width = 12)
heatmap(as.matrix(mymx), scale="none")
dev.off()

#- panel F. density plot
FImx_long_AUCweighted_sumFolds <- fread(here("data/dfS8f.Edge_strength.tsv"))
mythreshold=quantile(FImx_long_AUCweighted_sumFolds$FI_edges_scaled_AUCweighted_sum_normalized_sum,0.995)
p5 <- ggplot(data=FImx_long_AUCweighted_sumFolds,
             aes(x=FI_edges_scaled_AUCweighted_sum_normalized_sum))+
  geom_histogram(aes(y=..density..), colour="black", fill="white")+
  geom_density(alpha=.2, fill="#FF6666") +
  geom_vline(xintercept = mythreshold)  +
  theme_classic() + 
  annotate(geom="text", x=mythreshold, y=0.15, label="top 0.5% cutoff")

pdf(file=here("workflow/figures/s8f.Edge.density.pdf"), height = 5, width = 5)
p5
dev.off()

#--- end ---#