# fig_3a.R
# Fig3A: tSNE of neuronal cells, colored by cluster-level significance of schizophrenia (scz2022) SNP-heritability enrichment.
#-- Using **large loom and tSNE files** from Siletti et al, Science 2023 paper; download link provided below
#-- loom file (adult_human_20221007.loom): can be downloaded from https://storage.cloud.google.com/linnarsson-lab-human/adult_human_20221007.loom
#-- t-SNE coordinates (neuron_tsne.csv.gz): from the authors of the paper Siletti et al, Science 2023. Provided at the current repository under: /workflow/neuron_tsne.csv.gz

library(data.table)
library(tidyverse)
library(loomR)
library(here)
library(ggplot2)

# 1. Get cell ID and cluster from the loom file
lfile <- connect(filename = "adult_human_20221007.loom", #-- **User need to download the loom file and specify the path here** --#
                 mode = "r", skip.validate = TRUE)
lfile

CellID <- lfile[["col_attrs/CellID"]][]
Cluster <- lfile[["col_attrs/Clusters"]][] # used to link to Supercluster
dat <- cbind(CellID, Cluster) %>% as.data.frame()

# Link to Superclusters  
library(readxl)
CT_annot <- read_excel(here("data/silleti_table_s2.xlsx")) %>%
  filter(is.na(Cluster)==F) %>%
  mutate(Cluster_ID=paste("V",Cluster+1,sep=""),
         Cluster=as.character(Cluster),
         Supercluster_ID=gsub("-","_",Supercluster),
         Supercluster_ID=gsub(" ","_",Supercluster_ID))
CT_annot1 <- CT_annot %>% select(Cluster, Supercluster)

dat <- dat %>%
  left_join(CT_annot1, by="Cluster")

# 2. Map to cell tSNE coordinates
dat.tsne <- fread(here("workflow/neuron_tsne.csv.gz"))
dat <- dat %>%
  inner_join(dat.tsne, by=c("CellID"="V1"))


# 3. Get cluster ID for significant clusters of trait (schizophrenia)

dat.cluster.res <- read_xlsx(here("data/supplemental-tables.xlsx"), sheet = "TableS8") %>%
  filter(Phenotype=="scz2022") %>%
  separate(col=Cluster,into=c("V1","Cluster0"),sep=" \\(", remove=F) %>%
  mutate(Cluster0=as.character(gsub(")","",Cluster0)),
         minuslog10P=-log10(P)) %>%
  select(Cluster0, minuslog10P, if.sig.fdr)

# 4. plot: tSNE of different Superclusters, with labels

#- prepare supercluster labels
mylab <- dat %>%
  group_by(Supercluster) %>%
  summarise(TSNE1=mean(TSNE1),
            TSNE2=mean(TSNE2)) %>%
  ungroup() %>%
  mutate(TSNE1=ifelse((Supercluster=="Miscellaneous"),TSNE1-15, TSNE1),
         TSNE2=ifelse((Supercluster=="Miscellaneous"),TSNE2+14, TSNE2))

#- prepare for colors
dat1 <- dat %>%
  left_join(dat.cluster.res, by=c("Cluster"="Cluster0")) %>%
  mutate(minuslog10P=ifelse(if.sig.fdr=="yes", minuslog10P,NA))

#- plot
p1 <- ggplot(dat1 %>% mutate(tmp="not sig. (FDR)"),
             aes(x=TSNE1, y=TSNE2, color=minuslog10P, fill=tmp)) +
  geom_point(alpha=.1, size=.1) +
  theme_classic()+
  scico::scale_color_scico(palette = "lajolla", 
                           na.value = "#E5E5E5", midpoint = 5,
                           name="scz2022\n-log10(P)")+
  xlab("tSNE1") + ylab("tSNE2") + 
  scale_fill_manual(values=NA, name="") +
  guides(fill=guide_legend(override.aes=list(fill="#E5E5E5",
                                             size=2))) +
  annotate(geom="text", x=mylab$TSNE1, y=mylab$TSNE2, label=mylab$Supercluster,
           color="black") +
  theme(legend.position="bottom", legend.box = "horizontal")

ggsave(p1,
       filename = here("workflow/figures/3a_tSNE_overall_scz2022.pdf"),
       width = 10, height=10.5)

#--- end ---#