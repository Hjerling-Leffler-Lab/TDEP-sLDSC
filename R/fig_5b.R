library(data.table)
library(here)
library(ggplot2)

df <- fread(here("data/df_p5b_regionDot_2replications.tsv"))

p<- ggplot(df,
              aes(x=mean_rep1, y=mean_rep2, color=region_broad)) +
  geom_point(alpha=.8) +
  geom_abline(intercept = 0, slope = 1, linetype="dashed", color="grey") +
  geom_errorbar(aes(ymin=mean_rep2-sd_rep2, ymax=mean_rep2+sd_rep2), 
                position=position_dodge(0.05),alpha=0.1)+
  geom_errorbarh(aes(xmin=mean_rep1-sd_rep1, xmax=mean_rep1+sd_rep1),
                 position=position_dodge(0.05),alpha=0.1)+
  theme_classic()+
  scale_alpha_manual(values=c(1,.5,.5,1)) +
  annotate(geom = "text", label=expression('corr'['Amyg/Hipp']*'='), x=55, y=81,color="black") +
  annotate(geom = "text", label=round(cor_ah$estimate,2), x=70, y=81.5,color="black") +
  annotate(geom = "text", label=paste("p=",round(cor_ah$p.value,2)), x=60, y=78,color="black") +
  xlab("Runs, Rep.1") +
  ylab("Runs, Rep.2") +
  guides(color=guide_legend(title=""),
         alpha="none") +
  geom_text_repel(data=subset(b3, region_broad %in% c("Amygdala","Hippocampus")), 
                  aes(label=Region),size=3, segment.color = NA, show.legend = F,
                  position = position_nudge_repel(x = 0.01, y = 0.01))

pdf(file=here("workflow/figures/5b_regionDot_2replications.pdf"), height = 3, width = 4)
p
dev.off()