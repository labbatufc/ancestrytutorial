# QC for SNP Array Pangenomix

`zcat global_analysis_axiom.vcf.gz`
`zcat global_analysis_axiom.vcf.gz | head -n 100`
`bcftools view -i 'INFO/CR>=99 && INFO/HetSO>=-0.1 && INFO/HomRO>=0.6 && INFO/FLD>=3.6' \
global_analysis_axiom.vcf.gz -Oz -o global_analysis_axiom.filtered.vcf.gz`

Se der errado
```bash
bcftools view -h > header.txt
bcftools view -h global_analysis_axiom.vcf.gz > header.txt
# modifique de String para Float
vim header.txt #(para editar aperte i | para salvar e fechar esc :wq)
cat header.txt 
cp global_analysis_axiom_float.vcf global_analysis_axiom_float2.vcf
bcftools reheader -h header.txt -o global_analysis_axiom_float2.vcf global_analysis_axiom_float.vcf
#checagem
vim global_analysis_axiom_float2.vcf
bgzip -c global_analysis_axiom_float2.vcf > global_analysis_axiom_float.vcf.gz
bcftools index -t global_analysis_axiom_float.vcf.gz
```
Before
```
[1]SN    [2]id   [3]key  [4]value
SN      0       number of samples:      87
SN      0       number of records:      868045
SN      0       number of no-ALTs:      0
SN      0       number of SNPs: 845732
SN      0       number of MNPs: 24
SN      0       number of indels:       22737
SN      0       number of others:       116
SN      0       number of multiallelic sites:   1630
SN      0       number of multiallelic SNP sites:       1011
```
Antes
```
SN      0       number of samples:      87
SN      0       number of records:      578901
SN      0       number of no-ALTs:      0
SN      0       number of SNPs: 565311
SN      0       number of MNPs: 2
SN      0       number of indels:       13587
SN      0       number of others:       1
SN      0       number of multiallelic sites:   1
SN      0       number of multiallelic SNP sites:       1
```

# Preparo das referências
git clone https://github.com/Atkinson-Lab/LAI-sims-accuracy.git

`wget https://datasetgnomad.blob.core.windows.net/dataset/release/3.1/secondary_analyses/hgdp_1kg_v2/f2_fst/hgdp_tgp.bed`
`wget https://datasetgnomad.blob.core.windows.net/dataset/release/3.1/secondary_analyses/hgdp_1kg_v2/f2_fst/hgdp_tgp.bim`
`wget https://datasetgnomad.blob.core.windows.net/dataset/release/3.1/secondary_analyses/hgdp_1kg_v2/f2_fst/hgdp_tgp.fam`

Rode o script `1_merge.sh`

