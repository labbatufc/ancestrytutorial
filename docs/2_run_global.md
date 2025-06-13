# Fazendo merge com as referências
```
../plink --vcf global_analysis_axiom.filtered.vcf.gz --make-bed --out global_analysis_axiom
mkdir merge
cd merge
../plink --vcf ../global_analysis_axiom.filtered.vcf.gz --maf 0.01 --chr 1-22,X,Y,MT --make-bed --out global_analysis_axiom
../plink --bfile global_analysis_axiom --bmerge final_reference --make-bed --out samples_hgdp
../plink --bfile samples_hgdp --geno 0.05 --biallelic-only strict --maf 0.01 --hwe 1e-6  --make-bed --out samples_hgdp_1
../plink --bfile samples_hgdp_1 --indep-pairwise 50 5 0.1 --make-bed --out samples_hgdp_pruned
sed -i 's/a551315-4486081-061425-577/GC_NEM/g' samples_hgdp_pruned.fam
awk '{
    if ($1 ~ /YRI/) print "AFR";
    else if ($1 ~ /IBS/) print "EUR";
    else if ($1 ~ /Maya|Pima|Surui|Karitiana|Colombian/) print "AMR";
    else print "0";
}' samples_hgdp_pruned.fam > hgdp_pruned.pop
sed -i 's/0/-/g' hgdp_pruned.pop
./admixture samples_hgdp_pruned.bed 3 --supervised -j70 --bootstrap=100
../plink --bfile samples_hgdp_pruned       --pca 20       --out pca_pruned
```
