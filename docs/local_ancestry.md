# Copilot adjusted tutorial to run local ancestry

## Prepare Input Data

Format: gnomix requires phased VCF files for both reference and query samples. You’ll need to:
- Convert CRAM → BAM (if needed)
- BAM → VCF (using bcftools or GATK)
- Phase the VCF (with SHAPEIT, Eagle, or similar)\
**All samples (reference and query) must be in the same genome build (hg38).**

Some sources:\
[Gnomad v3](https://gnomad.broadinstitute.org/downloads#v3-hgdp-1kg)\
[GDP FTP](https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGDP/data/)

Reference Panel:\
Merge your 22 Native Americans, 22 Iberians, and 22 Yoruba samples into a phased multi-sample VCF (or keep them as separate files and merge after phasing).
Create a sample map file that maps each individual to their population label.

Genetic Map:\
Download an hg38 genetic map (TSV format: chr, SNP pos, genetic pos). Example maps are available [here](https://github.com/AI-sandbox/gnomix/tree/main/demo/data).

## Train the .pkl Model
You need to run gnomix in training mode. Otherwise, test the [GNOMAD.pkl](https://gnomad.broadinstitute.org/downloads#v4-genetic-ancestry-group-classification)
BTW we should infer it on three-hybrid model.

Example command:
```bash
python3 gnomix.py
    <query_file.vcf.gz>
    <output_folder>
    <chr_number>
    <phase_status>
    <genetic_map_file.tsv>
    <reference_panel.vcf.gz>
    <sample_map.txt>
```
- query_file.vcf.gz: VCF file with samples you want to analyze (can be same as reference if you want to test, or a held-out set);
- output_folder: Where to store model and results;
- chr_number: Chromosome number (e.g., 22);
- phase_status: True if phased; False otherwise (should be True!);
- genetic_map_file.tsv: The recombination map;
- reference_panel.vcf.gz: VCF with all reference haplotypes (your 66 samples);
- sample_map.txt: Tab-delimited file mapping sample IDs to ancestry labels.

This will train a model and output the .pkl model file in the output directory.

## Run Inference (Analysis) with the Trained Model
Once the model is trained, you can use it to analyze query samples (new admixed individuals).

Example command:
```bash
python3 gnomix.py
    <query_file.vcf.gz>
    <output_folder>
    <chr_number>
    <phase_status>
    <path_to_trained_model/model_chm_<chr_number>.pkl>
```

## Summary of Steps
- Download and prepare phased VCFs for all reference samples (Native Americans from HGDP, Iberians and Yoruba from 1000 Genomes).
- Create a sample map file (sample ID <tab> ancestry label).
- Obtain or generate a genetic map for hg38.
- Train the model using the gnomix training command (see above).
- Run inference on query samples using the trained .pkl model.
- Analyze the output (ancestry segments, per individual).

For more details, consult the gnomix [README.md](https://github.com/AI-sandbox/gnomix/blob/main/README.md) and the [demo.ipynb](http://lattes.cnpq.br/7146147647060117) notebook.

Must-be tested:\
[Flare-pipe](https://github.com/sdtemple/flare-pipeline)\
[kalis](https://kalis.louisaslett.com/)
