
# author: Arvid Harder, code modified from Shuyang Yao and Lu Yi
# dependencies: assumes slurm and ldsc are installed available through module load
# TODO: incorporate container
# Wraps compute_chrom_ldscores.sh that compues ldscores per chromosome


# Reference files
plink_ref="workflow/reference_data/sldsc_ref/1000G_EUR_Phase3_plink/1000G.EUR.QC"
hm_snp="workflow/reference_data/sldsc_ref/hm_snp.txt"

# bedfile is first argument
bedfile=$1
celltype_name=$(basename $bedfile .bed)
outdir="workflow/ldscores/$celltype_name"


echo Creating ldscores for $celltype_name
echo results are saved in $outdir
#
echo Showing the first ten rows of $bedfile
head $bedfile

# run as array job
sbatch \
--output workflow/slurm/$celltype_name-ldscores-%A_%a.out \
--array=1-22 \
scripts/compute_chrom_ldscores.sh $bedfile $outdir $plink_ref $hm_snp

