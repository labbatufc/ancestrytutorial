for CHR in {1..22}; do
  in_vcf="ALL.chr${CHR}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.vcf.gz"
  out_vcf="reference_chr${CHR}_1000g.subset.vcf.gz"

  bcftools view -S ref.samples -O z -o "$out_vcf" "$in_vcf"
  tabix -p vcf "$out_vcf"

  echo "Chr${CHR} subset done: $out_vcf"
done

