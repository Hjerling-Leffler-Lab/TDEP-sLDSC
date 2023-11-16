#!/bin/bash
#SBATCH --mem=3gb
#SBATCH --time=0:30:00


# parse arguments
# ----------------------------------------------------------------------------
bedfile=$1
workdir=$2
plink_ref=$3
hm_snp=$4

echo using bedfile: $bedfile
echo using workdir: $workdir
echo using plink_ref: $plink_ref
echo using hm_snp: $hm_snp

# recommend to run with slurm array, easy to parallelize across chromosomes
# else pass the index as argument 5
if [ -n "$SLURM_ARRAY_TASK_ID" ]; then
    echo "Running on SLURM cluster with array index $SLURM_ARRAY_TASK_ID"
    chr=$SLURM_ARRAY_TASK_ID
else
    echo "Running locally with chromosome $5"
    chr=$5
fi
# create the path for to annotation file
annot_file=${workdir}/baseline.$chr.annot.gz
echo using annot_file: $annot_file

# create workdir if it doesn't exist
if [ ! -d "$workdir" ]; then
    mkdir -p $workdir
fi
# ----------------------------------------------------------------------------

# assumes that computation cluster uses module system
echo Calculating LDscores for chromosome $chr, saving results to: $workdir
module unload python
module load ldsc

# make ldscores
make_annot.py --bed-file $bedfile --bimfile $plink_ref.$chr.bim --annot-file $annot_file
ldsc.py --l2 --bfile ${plink_ref}.$chr --ld-wind-cm 1 --annot $annot_file --thin-annot --out $workdir/baseline.$chr --print-snps $hm_snp