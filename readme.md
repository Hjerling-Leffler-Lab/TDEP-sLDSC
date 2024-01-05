# Calculating enrichment of heritability in cell-types

First we need to download the scRNA data from Siletti et al, and to download reference files for stratified LDScore regression

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

Run the [R script](R/00.create_bedfiles.R) to define 10% of specifically expressed genes. The Rscript writes them to workflow/bedfiles[cluster/superclusters]

```{bash}
# run python script to transform scRNA data to csv file
python scripts/read_loom.py
Rscript R/00.create_bedfiles.R

```

## Stratified LDscore regression

To replicate our results you can either download the precomputed LDscores here (TBD), or relcalculate them yourself.

Here we calculate ldscores for the 31 superclusters + 461 clusters. The example code uses slurm and the lmod system torun LDSC. \
Edit to fit your own computational environment.

This will run 492 (461 + 31) array jobs, each with 22 (chr1-22) subjobs, for a total of 10824 (492\*22) jobs requiring 1 core and 3gb memory, with less than 30 minute run time on our HPC.

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

To run S-LDSC, input GWAS summary statistics in the LDSC [munged](https://github.com/bulik/ldsc) format.

```         
# the script takes two arguments: LDSC sumstats and directory with LDscores
sh scripts/s-ldsc.sh workflow/sumstats/bmi2018.sumstats.gz workflow/amygdala_excitatory
```

