library(data.table)
library(here)
library(ggplot2)

df <- fread(here("data/df.5ef_FI_AH1vs0.tsv"))

p2 <- ggplot(df,
             aes(x=FI_edges_scaled_AUCweighted_sum_sum,
                 fill=AmygHipp_char,
                 color=AmygHipp_char)) +
  geom_histogram(bins=30,aes(y=..density..), alpha=0.5,
                 position="identity")+
  geom_density(alpha=.2) +
  theme_classic() +
  scale_fill_manual(values=c("#00BFC4","salmon"))+
  scale_color_manual(values=c("#00BFC4","salmon"))+
  xlab("Feature importance per connection") +
  guides(fill=guide_legend(title="Amyg./Hipp. \nconnection"),
         color=guide_legend(title="Amyg./Hipp. \nconnection")) +
  annotate(geom="text", x=90, y=0.01, 
           label=paste("p=",mytest$p.value,sep=""))
p2

pdf(file=here("workflow/figures/5f_cobre_FI.pdf"), height = 3, width = 4)
p2
dev.off()