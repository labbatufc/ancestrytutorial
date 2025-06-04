# Global ancestry step by step

## 1. **Prepare Variant Data**
- **Collect VCFs** for All of Us participants, 1KGP, and HGDP, all on the same genome build (e.g., hg38).
- **Merge and Harmonize**:
  - Use PLINK 1.9 to merge the datasets.
  - Harmonize strand flips and variant IDs (custom scripts or tools like `bcftools +fixref`).
  - Keep only **biallelic variants** present in all datasets.
  - Remove variants with **>1% missingness** and **<1% minor allele frequency**.
  - Example PLINK command:
    ```bash
    plink --vcf all_samples.vcf.gz --double-id --biallelic-only strict --geno 0.01 --maf 0.01 --make-bed --out merged_harmonized
    ```

## 2. **LD Pruning**
- **Prune for linkage disequilibrium**:
  - Window size: 50, step size: 10, r² < 0.1
  - Example command:
    ```bash
    plink --bfile merged_harmonized --indep-pairwise 50 10 0.1 --out pruned
    plink --bfile merged_harmonized --extract pruned.prune.in --make-bed --out final_pruned
    ```

## 3. **Unsupervised Clustering (PCA and Clustering)**
- **PCA**:
  - Use FastPCA in PLINK 2.0:
    ```bash
    plink2 --bfile final_pruned --pca approx 100 --out all_pca
    ```
- **Analyze Clustering Tendency** (in R):
  - Use Hopkins statistic (`R` package: Hopkins)
  - K-nearest neighbor search (`R` package: FNN)
- **Kernel Density Estimation & Contour Extraction**:
  - Use `MASS` package in R for KDE on PCs 1-3
  - Use contour extraction functions
- **Density-Based Clustering (HDBSCAN)**:
  - Use HDBSCAN on first 5 PCs (`R` package: dbscan or Python package: hdbscan)
  - Parameters: `min_samples = 2000`, `min_cluster_size = 2500`
- **Visualization**:
  - Use `ggforce` in R for boundaries and cluster visualization

## 4. **Supervised Genetic Ancestry Inference**
- **Kinship Filtering**:
  - Use KING to remove related/duplicate reference samples:
    ```bash
    king -b final_pruned.bed --kinship --prefix king_output
    ```
  - Remove one of each pair of related samples.
- **Select Reference Sets**:
  - Use *non-admixed* representatives for 7 groups: African, American, East Asian, South Asian, West Asian, European, Oceanian.
  - For subcontinental inference, use population-specific references (see Supplementary Table 2 from the paper).
- **Merge and Harmonize (again, if new subsets)**:
  - Repeat steps from #1 for the specific reference sets.
- **PCA for Ancestry Inference**:
  - Run FastPCA on merged reference + participant data as above.
- **Run Rye**:
  - Use Rye for ancestry inference (see [Rye GitHub](https://github.com/bioinformed/rye)):
    ```bash
    rye run -i pca_input.txt -r reference_ancestry_labels.txt -p ancestry_proportions.txt
    ```
  - Rye uses the first 25 PCs and reference labels to infer ancestry fractions.
- **Visualization**:
  - Admixture-style plots using `geofacets` in R
  - Calculate entropy:  
    \( S = -\sum_{i} p_i \log_2 p_i \), where \( p_i \) is ancestry fraction

---

## 5. **Notes & Tips**
- **CRAM/BAM**: Not needed for analysis; use VCF or PLINK BED files.
- **Reference Populations**: Make sure to use the same reference labels and sets as in the paper for comparability.
- **Custom Scripts**: Used for harmonization (e.g., strand flipping, ID matching).
- **QC**: Always check for missingness, MAF, and relatedness before analysis.

---

## 6. **Summary Table**

| Step                | Tool(s)            | Key Command(s) or Package(s)                                             |
|---------------------|--------------------|--------------------------------------------------------------------------|
| Merge/harmonize     | PLINK/bcftools     | `plink --vcf ... --make-bed`, `bcftools +fixref`                         |
| LD pruning          | PLINK              | `plink --indep-pairwise ...`                                              |
| PCA                 | PLINK 2.0          | `plink2 --pca approx ...`                                                 |
| Clustering          | R/Python           | R: `dbscan`, Python: `hdbscan`, `Hopkins`, `FNN`, `MASS`, `ggforce`      |
| Kinship filtering   | KING               | `king -b ... --kinship`                                                   |
| Ancestry inference  | Rye                | `rye run -i ... -r ... -p ...`                                            |
| Visualization       | R                  | `geofacets`, admixture barplots, entropy calculation                     |

---
