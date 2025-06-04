PANE 

Tutorial:\
https://lm-ut.github.io/PANE/articles/Tutorial.html

---

## **PANE Global Ancestry Analysis Workflow (1240K+HO Dataset)**

### 1. **Download and Prepare Data**
- Download the 1240K+HO dataset (version V52.2) in EIGENSTRAT format from [Allen Ancient DNA Resource](https://reich.hms.harvard.edu/allen-ancient-dna-resource-aadr-downloadable-genotypes-present-day-and-ancient-dna-data).
- Convert EIGENSTRAT to PLINK format using `convertf` if necessary.

### 2. **Sample Selection Based on Annotation**
- Use the `.anno` file and filter samples according to the following:
  - **Ancient samples:**  
    - `"Full date"` does **not** contain "present"
    - Latitude > 22, Longitude between -15 and 60
    - `"Group.ID"` does **not** contain "Ignore"
    - `"Assessment"` contains "PASS"
    - Remove duplicates
  - **Present-day Mbuti:**  
    - `"Genetic.ID"` contains "Mbuti"
    - `"Assessment"` contains "PASS"
  - **Modern Western Eurasian:**  
    - Latitude > 22, Longitude between -15 and 60
    - Exclude Uzbekistan, Kazakhstan, Algeria, Morocco, Tunisia, Libya, and certain Russian/other populations (as in Aneli et al.)
    - `"Group.ID"` does **not** contain "Ignore"
    - `"Assessment"` contains "PASS"
- Use `awk`, `grep`, or pandas (Python) to create sample keep-lists based on these criteria.

### 3. **Construct Sample Subsets**
- Use your keep-lists to filter the PLINK/EIGENSTRAT datasets:
    ```bash
    plink --bfile 1240K_HO --keep ancient_samples.txt --make-bed --out ancient_only
    plink --bfile 1240K_HO --keep modern_samples.txt --make-bed --out modern_only
    ```
- Add additional ancient or modern samples as needed (merge with `plink --bfile ... --bmerge ...`).

### 4. **SNP and Missingness Filtering on Moderns**
- Retain only autosomal SNPs:
    ```bash
    plink --bfile modern_only --chr 1-22 --make-bed --out modern_autosomes
    ```
- Remove monomorphic SNPs and those with >5% missing data:
    ```bash
    plink --bfile modern_autosomes --maf 0.00001 --geno 0.05 --make-bed --out modern_filtered
    ```

### 5. **Extract Modern SNPs from Ancients**
- Extract the filtered SNP list from moderns and apply to ancients:
    ```bash
    plink --bfile ancient_only --extract modern_filtered.bim --make-bed --out ancient_filtered
    ```

### 6. **Merge Modern and Ancient Datasets**
- Merge the filtered ancient and modern datasets:
    ```bash
    plink --bfile modern_filtered --bmerge ancient_filtered --make-bed --out merged_modern_ancient
    ```
- Remove ancient samples with <20,000 SNPs:
    ```bash
    plink --bfile merged_modern_ancient --mind 0.5 --make-bed --out merged_highSNP
    ```
    *(You may need to pre-identify and exclude these individuals based on missingness counts.)*

### 7. **Relatedness Filtering**
- Calculate IBD/kinship:
    ```bash
    plink --bfile merged_highSNP --genome --min 0.35 --out ibd
    ```
- Remove one individual from each pair with pi-hat ≥ 0.35 (keep the one with more SNPs).

### 8. **Remove Duplicated IDs**
- For duplicated sample IDs, retain the sample with the higher SNP count.

### 9. **PCA and Outlier Filtering**
- Run PCA with smartpca from EIGENSOFT:
    - Prepare a parameter file, e.g., `smartpca.par`:
        ```
        genotypename:    merged_final.eigenstratgeno
        snpname:         merged_final.snp
        indivname:       merged_final.ind
        evecoutname:     pca.evec
        evaloutname:     pca.eval
        numoutevec:      10
        lsqproject:      YES
        ```
    - Run:
        ```bash
        smartpca -p smartpca.par > smartpca.log
        ```
- Remove PCA outliers (using the EIGENSOFT outlier report or by visual inspection).

### 10. **Prepare Final Dataset for PANE**
- Ensure your final dataset is in EIGENSTRAT format. If not, convert using `convertf`.
- You should have:
    - `.geno`, `.snp`, `.ind` files for the final dataset.
    - PCA projections for ancient samples using the `lsqproject: YES` option.
    - The number of SNPs and samples should match the requirements (e.g., 4740 ancient, 1668 modern, 206,363 SNPs as in the reference).

### 11. **Run PANE**
- Follow the PANE documentation for input format and analysis.  
- Project admixed/ancient individuals onto PCs inferred from moderns if required.
- Run with the desired number of PCs (commonly 10, but test other values if evaluating performance).

---

### **Summary Table**

| Step                          | Tool        | Command/Notes                                                              |
|-------------------------------|------------|----------------------------------------------------------------------------|
| Annotation/sample filtering    | awk/pandas | Process .anno file, create keep-lists                                      |
| Sample selection              | PLINK      | `--keep`                                                                   |
| Merge/additional samples      | PLINK      | `--bmerge`                                                                 |
| Autosomes, missingness, MAF   | PLINK      | `--chr 1-22 --maf 0.00001 --geno 0.05`                                     |
| SNP extraction                | PLINK      | `--extract`                                                                |
| Merge ancient/modern          | PLINK      | `--bmerge`                                                                 |
| Kinship filtering             | PLINK      | `--genome --min 0.35`                                                      |
| Remove duplicates             | bash/pandas| Retain sample with more SNPs                                               |
| PCA & outlier removal         | smartpca   | EIGENSOFT, `lsqproject: YES`, 10+ PCs                                      |
| Format conversion             | convertf   | PLINK ↔ EIGENSTRAT                                                         |
| Running PANE                  | PANE       | Per PANE documentation                                                     |

---

If you want specific scripts for .anno processing, merging, or PCA commands, or guidance on running PANE, just ask!
