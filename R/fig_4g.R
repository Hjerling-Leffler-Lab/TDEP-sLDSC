# fig_4g.R
# Fig4G: ring/piecharts of the amygdala

myregion="Amygdala"

library(data.table)
library(tidyverse)
library(ggplot2)
library(scico)
library(cowplot)
library(readxl)
library(here)
source(here("R/order_data.R"))

#- 0. check cluster and supercluster properties of inhibitory and excitatory
meta <- read_excel(here("data/silleti_table_s2.xlsx"))
table(meta$`Neurotransmitter auto-annotation`)
m1 <- meta %>% 
  group_by(Supercluster, `Neurotransmitter auto-annotation`) %>%
  summarise(n_cluster=n()) %>% ungroup()

#- 1. prepare data
excitatory <- data.frame(
  Supercluster=c(
    "Upper-layer intratelencephalic",
    "Deep-layer intratelencephalic",
    "Deep-layer near-projecting",
    "Deep-layer corticothalamic and 6b",
    "Hippocampal CA1-3",
    "Hippocampal CA4",
    "Hippocampal dentate gyrus",
    "Amygdala excitatory",
    "Thalamic excitatory",
    #"Mammillary body", # removed as not in HC or Amyg
    "Upper rhombic lip"#,
    #"Lower rhombic lip" # removed as not in HC or Amyg
  ),
  Class="excitatory")

inhibitory <- data.frame(
  Supercluster=c(
    "MGE interneuron", 
    "CGE interneuron",
    "LAMP5-LHX6 and Chandelier",
    "Medium spiny neuron",
    "Eccentric medium spiny neuron"#,
    #"Midbrain-derived inhibitory", # remove due to too low proportion in HC and Amyg
    #"Cerebellar inhibitory" # remove due to too low proportion in HC and Amyg
  ),
  Class="inhibitory"
)

mixed <- data.frame(
  Supercluster=c(
    "Splatter",
    "Miscellaneous"),
  Class="mixed"
)

# assign colors to each supercluster
supercl.color <-  rbind(excitatory, inhibitory, mixed) %>%
  mutate(sc.order=row_number())

library(colorspace)
supercl.color$sc.col <- c(
  # warm colors for 12 excitatory
  diverge_hcl(9, palette = "Cyan-Magenta")[c(9:6)],
  sequential_hcl(12, palette = "Sunset")[c(4:6)],
  sequential_hcl(8, palette = "Peach")[c(2,4,6)],
  #sequential_hcl(12, palette = "Sunset")[c(3:12)],
  # cold colors for 7 inhibitory
  sequential_hcl(7, palette = "Teal")[c(3,5,7)],
  sequential_hcl(7, palette = "Blues")[5:6],
  # neutral for miscellaneous and splatter
  "darkgrey","lightgrey"
)

a <- fread(here("data/n_neurons_cluster_roi_region.tsv")) %>%
  mutate(roi=gsub("Human ","",roi)) %>%
  filter(!roi%in%c("A35r","HTHso")) %>%
  filter(regions%in%c("Amygdala","Hippocampus")) %>%
  filter(!Supercluster%in%c("Midbrain-derived inhibitory","Cerebellar inhibitory")) %>% # remove superclusters with too few cells in regions of interest
  left_join(supercl.color, by="Supercluster")


#- 2. dataframe with scz significance
df.scz <- read_excel(here("data/supplemental-tables.xlsx"), sheet="TableS8") %>%
  rename(Trait=Phenotype) %>%
  separate(col=Cluster,into=c("V1","Cluster0"),sep=" \\(", remove=F) %>%
  mutate(Cluster0=as.integer(gsub(")","",Cluster0))) %>%
  filter(Trait=="scz2022") %>%
  select(Cluster0, P, Enrichment, P.fdr, if.sig.fdr)

#- 3. plot scz2022 relevance
df.p1 <- a %>% 
  filter(regions==myregion) %>%
  group_by(Class, Clusters, Supercluster, sc.col, sc.order) %>%
  summarise(Ncell=sum(n_cells_cluster)) %>%
  left_join(df.scz, by=c("Clusters"="Cluster0")) %>%
  mutate(minuslog10P=ifelse(if.sig.fdr=="yes",-log10(P),NA),
         Clusters=as.character(Clusters))
tb1 <- df.p1 %>%
  mutate(prop = Ncell / sum(df.p1$Ncell) *100) %>%
  mutate(ypos = cumsum(prop)- 0.5*prop) %>%
  arrange(sc.order, P)
tb1a <- tb1 %>%
  group_by(Supercluster) %>%
  mutate(rownr=row_number(),
         all_rownr=max(rownr),
         prop_supercluster=sum(prop)) %>%
  ungroup() %>%
  mutate(Supercluster2=ifelse(rownr==round((1+all_rownr)/2,0),Supercluster,"")) %>%
  mutate(Supercluster2=ifelse(prop_supercluster>1,Supercluster2,"")) %>%
  select(-rownr,-all_rownr) %>%
  mutate(region=myregion)
p1a <- ggplot(tb1a, aes(x="",y=prop, fill=minuslog10P)) +
  geom_col() +
  coord_polar(theta = "y") +
  theme_void() +
  scico::scale_fill_scico(palette = "lajolla",na.value = "#E5E5E5", midpoint = 5,
                          name=expression('scz2022, -log'[10]*'(P)')) +
  guides(fill = "none") +
  scale_y_continuous(breaks = tb1a$ypos, labels = tb1a$Supercluster2) +
  theme(plot.title = element_text(hjust=0.5),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()) +
  labs(title="scz2022 enrichment significance\n")


# supercluster composition plot
df.p2 <- tb1 %>%
  group_by(Supercluster, Class, sc.col, sc.order) %>%
  summarise(prop_supercluster=sum(prop)) %>%
  ungroup() %>%
  arrange(sc.order) %>%
  mutate(Supercluster2=ifelse(prop_supercluster>1,Supercluster,"")) %>%
  mutate(region=myregion)

supercl.color2 <- supercl.color %>% filter(Supercluster%in%unique(df.p2$Supercluster))
p2a <- ggplot(df.p2, aes(x="",y=prop_supercluster, fill=reorder(Supercluster, -sc.order))) +
  geom_col() +
  coord_polar(theta = "y") +
  theme_void() +
  scale_fill_manual(values=rev(supercl.color2$sc.col)) +
  guides(fill = guide_legend(reverse = TRUE, 
                             title="Superclusters",
                             size=6)) +
  scale_y_continuous(breaks = df.p2$ypos, labels = df.p2$Supercluster2) +
  theme(plot.title = element_text(hjust=0.5),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()) +
  labs(title="Composition\n")

p3a <- ggplot(df.p2, aes(x="",y=prop_supercluster, fill=reorder(Class, -sc.order))) +
  geom_col() +
  coord_polar(theta = "y") +
  theme_void() +
  scale_fill_manual(values=rev(c("salmon","skyblue1","grey"))) +
  guides(fill = guide_legend(reverse = TRUE, 
                             title="Super.cl.type",
                             size=6)) +
  scale_y_continuous(breaks = df.p2$ypos, labels = df.p2$Supercluster2) +
  theme(plot.title = element_text(hjust=0.5),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()) +
  labs(title="Exc. and Inh.\n")

pdf(file = here("workflow/figures/4g_amygdala.pdf"),
    width = 20,
    height = 6,
    onefile=FALSE)
plot_grid(p1a, p2a, p3a, labels = c(''), ncol = 3, rel_widths = c(1,.9,.4))
dev.off()

