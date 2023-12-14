import pandas as pd
import loompy as lp

# connect to loom file
ds = lp.connect("workflow/data/adult_human_20221007.agg.loom")

# Create a DataFrame from the count matrix
gene_names = ds.ra['Accession']

# aggregated at the cluster level
cell_names = ds.ca['Clusters'] 

# raw matrix
count_matrix = ds[:,:]

# convert to pandas
df = pd.DataFrame(count_matrix, index=gene_names, columns=cell_names)

# write as tsv
df.to_csv("workflow/data/adult_human_20221007.agg.tsv", sep="\t")

