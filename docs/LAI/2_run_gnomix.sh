#Take care of this parsing in utils.py
#gen_map_df.columns = ["chm","pos","pos_cm"]

PY=python3   # your env's python
GNX_OUT="gnomix_results"
REF_LABELS_TSV="IBSYRIPEL.smap"
for CHR in {1..22}; do
  echo "[5/${CHR}] G-Nomix train+infer chr${CHR}"
  Q="refphased/ALL.chr${CHR}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.vcf.gz" 
  MAP="maps_hg38/chr${CHR}.tsv"
  REF="refphased/reference_chr${CHR}_1000g.subset.vcf.gz"
  # run this with the right env (3.7)
      "${PY}" ../local/gnomix/gnomix.py \
      "${Q}" \
      "${GNX_OUT}" \
      ${CHR} \
      False \
      "${MAP}" \
      "${REF}" \
      "${REF_LABELS_TSV}"
done
