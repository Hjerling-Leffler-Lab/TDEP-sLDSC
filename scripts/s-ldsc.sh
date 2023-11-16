# #!/bin/bash
# #SBATCH --job-name=stratified-ldscore-regresssion
# #SBATCH --time=00:30:00
# #SBATCH --mem=4gb

# path to ldsc munged sumstats
sumstats=$1
# path to folder with ldscores
celltype=$2

out=${3:-workflow/results/s-ldsc/}
mkdir -p $out
# filepath logic
celltype_name=$(basename "$celltype")
gwas_name=$(basename "$sumstats" .sumstats.gz)

out_file=$out/${gwas_name}_X_${celltype_name}


# reference files
baseline="workflow/reference_data/sldsc_ref/1000G_EUR_Phase3_baseline/baseline."
weights="workflow/reference_data/sldsc_ref/1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC."
freq="workflow/reference_data/sldsc_ref/1000G_Phase3_frq/1000G.EUR.QC."


echo computing stratified heritability for $gwas_name in $celltype_name
# OBS - need to fix annot file
module unload python && module load ldsc
ldsc.py --h2 $sumstats --ref-ld-chr $baseline,$celltype/baseline. --w-ld-chr $weights --overlap-annot --frqfile-chr $freq --print-coefficients --out $out_file