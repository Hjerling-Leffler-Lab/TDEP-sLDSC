library(tidyverse)
library(ggplot2)
library(here)
library(readxl)
library(scico)
source(here("R/order_data.R"))

df <- read_xlsx(here("data/supplemental-tables.xlsx"), sheet = "TableS3")


df$Supercluster <- factor(df$Supercluster, levels=rev(order_ct))

# test code blow
df |> 
  mutate(disorder_type = fct_relevel(
      disorder_type,
      "psychiatric",
      "brain traits",
      "neurological",
      "structural MRI",
      "control")
  ) |> 
  ggplot(aes(
    x = label, 
    y = Supercluster,
    fill = -log10(P), 
    size = if.sig.fdr,
    color = if.sig.fdr
    )) + 
  geom_point(alpha = .85, shape = 21) +
  theme(
    panel.background = element_rect(fill = "transparent"),
    axis.text.x = element_text(angle = 30, hjust=1),
    legend.key = element_rect(fill = "transparent")
    ) +
  scale_fill_scico(
    palette = "lajolla", 
    midpoint = 5,
    direction = -1,
    name = expression('-log'[10]*'(P)')
    ) + 
  facet_grid(~disorder_type, scales = "free_x", space = "free_x") +
  scale_size_manual(values = c(1.5, 5))+
  scale_color_manual(values = c("no" = "grey","yes" = "black")) + 
  labs(
    size = "Sig.(FDR)",
    x = "",
    y = ""
    ) +
  guides(color = "none") + 
  guides(size = guide_legend(override.aes = list(color=c("lightgrey","black")))) 




ggsave(
  filename = here("workflow/figures/1a.pdf"),
  width = 16, 
  height = 7.5, 
  dpi =300
  )
