#!/bin/bash

# Base PLINK prefix
BASE=hgdp_tgp
REF_DIR=LAI-sims-accuracy/reference_ids
OUT_DIR=subset_refs

mkdir -p $OUT_DIR

for group in afr amr eur; do
    echo "Processing $group..."

    ref_file=${REF_DIR}/${group}_rfmix.txt
    keep_full=${OUT_DIR}/${group}.fam.full
    keep_file=${OUT_DIR}/keep_${group}.txt
    out_prefix=${OUT_DIR}/${group}

    # Match IIDs to full .fam lines
    awk 'NR==FNR {ids[$1]; next} ($2 in ids)' $ref_file ${BASE}.fam > $keep_full

    # Extract FID and IID
    cut -d' ' -f1,2 $keep_full > $keep_file

    # Subset PLINK files
    ../plink --bfile $BASE --keep $keep_file --make-bed --out $out_prefix
done

echo "Merging all subsets into one final dataset..."

# Merge all three groups using PLINK
# First copy AMR as base
cp ${OUT_DIR}/amr.bed ${OUT_DIR}/merged.bed
cp ${OUT_DIR}/amr.bim ${OUT_DIR}/merged.bim
cp ${OUT_DIR}/amr.fam ${OUT_DIR}/merged.fam

# Create merge list
echo -e "${OUT_DIR}/afr\n${OUT_DIR}/eur" > ${OUT_DIR}/merge_list.txt

# Merge remaining two groups
../plink --bfile ${OUT_DIR}/merged --merge-list ${OUT_DIR}/merge_list.txt --make-bed --out ${OUT_DIR}/final_reference

echo "Done. Final merged reference is in ${OUT_DIR}/final_reference.{bed,bim,fam}"

