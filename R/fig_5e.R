library(data.table)
library(here)
library(ggplot2)

df <- fread(here("data/df.5ef_FI_AH1vs0.tsv"))

p1 <- ggplot(df %>% 
               arrange(-FI_edges_scaled_AUCweighted_sum_sum) %>% 
               mutate(rowID=row_number()),
             aes(x=rowID, 
                 y=FI_edges_scaled_AUCweighted_sum_sum, 
                 fill=AmygHipp_char)) +
  geom_bar(stat="identity",size=.2, alpha=1)+
  scale_fill_manual(values=c("#00BFC4","salmon"),
                    name="Amyg./Hipp. \nconnection")+
  theme_classic() +
  ylab("Feature importance per connection") +
  xlab("Connections (ranked by feature importance)")

pdf(file=here("workflow/figures/5e_cobre_FI_rank.pdf"), height = 3, width = 4)
p1
dev.off()
