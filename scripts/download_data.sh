# download linnarson scRNA data, aggregated by cluster-level cell-type
mkdir -p workflow/reference_data workflow/figures
wget -O workflow/reference_data/adult_human_20221007.agg.loom https://storage.googleapis.com/linnarsson-lab-human/adult_human_20221007.agg.loom


# download files for to use stratified LDscore regression

wget -O workflow/reference_data/sldsc_ref.tar.gz https://zenodo.org/records/8367200/files/sldsc_ref.tar.gz?download=1

tar -xvf workflow/reference_data/sldsc_ref.tar.gz -C workflow/reference_data/
