
# How to generate LDscores for custom annotation
This codechunk assumes you have run the (R script)[R/00.create_bedfiles.R] to generate bedfiles

```{bash}
# pwd is project root. Getting ldscores for one cell-type
sh scripts/cell-type-ldscores.sh workflow/bedfiles/superclusters/amygdala_excitatory.bed

```

# Generating ldscores for all bedfiles
This will run 492 (461 + 31) array jobs, each with 22 subjobs,
for a total of 10824 (492*22) jobs requiring 1 core and 3gb memory. 
```
all_bedfiles=$(find workflow/bedfiles/{clusters,superclusters} -type f -name '*bed')

# Iterate over each bed file in clusters and superclusters
for file in $all_bedfiles; do
    echo "Processing file: $file"
    
    # Run the script for each bed file
    # sh scripts/cell-type-ldscores.sh $file
done

```


# Running stratified LDscore regression for 1 trait x 1 cell-type


```
workflow/results/s-ldsc
#workflow/sumstats/scsz2022_eur.sumstats.gz
sh scripts/s-ldsc.sh data/scz2022_eur.sumstats.gz workflow/ldscores/amygdala_excitatory

```