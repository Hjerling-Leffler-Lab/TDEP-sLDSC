

# Calculating enrichment of heritability in cell-types

First we need to download the scRNA data from Siletti et al, and to
download reference files for stratified LDScore regression

```{bash}
# setup our folder structure
mkdir -p workflow/reference_data workflow/figures workflow/bedfiles workflow/ldscores workflow/reference_data workflow/slurm workflow/sumstats workflow/results

# download linnarson scRNA data, aggregated by cluster-level cell-type
wget -O workflow/reference_data/adult_human_20221007.agg.loom https://storage.googleapis.com/linnarsson-lab-human/adult_human_20221007.agg.loom


# download files for to use stratified LDscore regression

wget -O workflow/reference_data/sldsc_ref.tar.gz https://zenodo.org/records/8367200/files/sldsc_ref.tar.gz?download=1

tar -xvf workflow/reference_data/sldsc_ref.tar.gz -C workflow/reference_data/
```

## Define specifically expressed genes

Run the [R script](R/00.create_bedfiles.R) to define 10% of specifically
expressed genes. The Rscript writes them to
workflow/bedfiles[cluster/superclusters]

```{bash}
# run python script to transform scRNA data to csv file
python scripts/read_loom.py
Rscript R/00.create_bedfiles.R

```

## Generating ldscores for all bedfiles

This step is not obligatory - you can also download the precomputed
LDscores. TBA: link here.

You can also derive them yourself using the bedfiles we generated in the
step above. Here we calculate ldscores for the 31 superclusters + 461
clusters. The code assumes loads LDSC with module load, and uses slurm
for HPC. edit to fit computational environment. This will run 492 (461 +
31) array jobs, each with 22 subjobs, for a total of 10824 (492\*22)
jobs requiring 1 core and 3gb memory.

```         
all_bedfiles=$(find workflow/bedfiles/{clusters,superclusters} -type f -name '*bed')

# Iterate over each bed file in clusters and superclusters
for file in $all_bedfiles; do
    echo "Processing file: $file"
    
    # Run the script for each bed file
    # sh scripts/cell-type-ldscores.sh $file
done
```

## Example of running stratified LDscore regression for 1 trait x 1 cell-type

To run S-LDSC, input GWAS summary statistics in the LDSC
[munged](https://github.com/bulik/ldsc) format. Here we store them in
workflow/sumstats/

```         
# the script takes two arguments: LDSC sumstats and directory with LDscores
sh scripts/s-ldsc.sh workflow/sumstats/bmi2018.sumstats.gz workflow/amygdala_excitatory
```

# Analyzing heritability enrichment

For the next steps we will use the precomputed results from the
supplementary tables click [here](celltype-analysis.md) for the part of
the analysis

# Todo for SY: Main figures

-   

-   Figure 1c: script for figure 1c (subtypes - not same as on drive)

-   Figure 1D: script for how data for figure 1d was derived (ridge
    plot)

-   Figure 2a & 2c: missing data script, figure script and data

-   Figure 4: ABC, data, scripts and figure scripts

-   Figure 5: ABC, data, scripts and figure scripts

# Supplementary:

-   for Pat: Need code for supplementary figures 3,4 (how did u generate
    input data?)

-   Shuyang: Figure S7 Figure S8, data, code to get data, code to get
    figure
