library(here)
library(tidyverse)



# required data: ----------------------------------------------------------

# create with read_loom.py
gene_expr <- read_tsv(here("workflow/reference_data/adult_human_20221007.agg.tsv"))


valid_genes  <- read_tsv(here("data/valid_genes.tsv.gz"))

# from: https://github.com/linnarsson-lab/adult-human-brain
clusters_to_superclusters <- readxl::read_xlsx(here("data/siletti_table_s2.xlsx")) |> 
    select(superclusters = 2, cluster = 1) |> 
    drop_na()


# start processing --------------------------------------------------------

expr_long <-
    gene_expr |>
    rename(ensgid = 1) |> 
    separate_wider_delim(ensgid, delim = ".", names = c("ensgid", "version"), too_few = "align_start") |> 
    # restrict expression matrix to valid genes: 18,090 genes
    semi_join(valid_genes, by = "ensgid") |> 
    select(-version) |> 
    pivot_longer(-ensgid, names_to = "cluster", values_to = "expr")



# join with clusters to superclusters mapping, and make clusters range from 1-462 and named V[cluster]
expr_long <- inner_join(mutate(expr_long, cluster = as.numeric(cluster)), clusters_to_superclusters, by = "cluster") |> 
  # make it 1-based
  mutate(cluster = cluster + 1) |> 
  mutate(cluster = paste0("V",cluster))


calculate_specificity <- function(tbl, celltype, gene_col = "ensgid") {
    tbl  |> 
        # calculate the total expression of each gene in each cell-type
        dplyr::group_by(.data[[celltype]], .data[[gene_col]]) |> 
        dplyr::summarise(total_exp = sum(expr)) |> 
        # in each celltype, scale to 1TPM
        dplyr::group_by(.data[[celltype]])  |>
        dplyr::mutate(exp_tpm = total_exp*1000000 / sum(total_exp))  |>
        dplyr::group_by(.data[[gene_col]])  |>
        dplyr::mutate(specificity = exp_tpm / sum(exp_tpm))  |>
        dplyr::ungroup()
        # dplyr::filter(exp_tpm > 1)

}

create_bedfile <- function(spec_df, celltype, gene_ref) {
  # in our original code we select top 10% by doing round(n() * 0.1)
  # the ideal way would be to use dplyr::slice_max(prop = 0.1)
  # but the rounding does not give identical results
  
  gene_n_map <- spec_df |> 
    dplyr::group_by(.data[[celltype]]) |> 
    dplyr::filter(exp_tpm > 1) |> 
    mutate(n_genes_to_keep = round(n()*0.1)) |> 
    distinct(.data[[celltype]],n_genes_to_keep)
  
  # create a list for each celltype
  nested <- nest_by(spec_df, .data[[celltype]]) |> 
    inner_join(gene_n_map, by = celltype)
  
  map2(nested$data, nested$n_genes_to_keep, \(df, n_genes) 
              dplyr::filter(df, exp_tpm > 1) |>
                dplyr::slice_max(specificity, n = {{ n_genes }}) |> 
                dplyr::inner_join(gene_ref, by = "ensgid") |> 
                dplyr::select(chr,start,end,ensgid)) |>  
    set_names(janitor::make_clean_names(nested[[celltype]]))
  
}
  


# superclusters -----------------------------------------------------------

# calculate specificity and make bedfiles
spec_df <- calculate_specificity(expr_long, celltype = "superclusters")
bedfiles_sc <- create_bedfile(spec_df, celltype = "superclusters", gene_ref = valid_genes)

# Write out 
fs::dir_create("workflow/bedfiles/superclusters")
purrr::iwalk(bedfiles_sc, \(df, name) readr::write_tsv(df, paste0("workflow/bedfiles/superclusters", "/", name, ".bed"), col_names = FALSE))



# clusters ----------------------------------------------------------------

spec_df_clusters <- calculate_specificity(expr_long, celltype = "cluster") 
bedfiles_clusters <- create_bedfile(spec_df_clusters, celltype ="cluster", gene_ref = valid_genes)

# Write out
fs::dir_create("workflow/bedfiles/clusters")
purrr::iwalk(bedfiles_clusters, \(df, name) readr::write_tsv(df, paste0("workflow/bedfiles/clusters", "/", name, ".bed"), col_names = FALSE))
