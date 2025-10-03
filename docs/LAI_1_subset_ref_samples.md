#Getting the references from 1000g
```{python}
import pandas as pd

panel = pd.read_csv("integrated_call_samples_v3.20130502.ALL.panel", sep=r"\s+", header=None, names=["Sample","Pop","Super","Sex"], engine="python")

pel = panel.query("Pop=='PEL'")[["Sample"]].assign(Ancestry="AMR")
ibs = panel.query("Pop=='IBS'")[["Sample"]].assign(Ancestry="EUR")
yri = panel.query("Pop=='YRI'")[["Sample"]].assign(Ancestry="AFR")

# Downsample IBS/YRI to the same size as PEL from the files you already made
pel_ids = pd.read_csv("pel.samples", header=None, names=["Sample"], sep="\t")
ibs_ids = pd.read_csv("ibs.samples", header=None, names=["Sample"], sep="\t")
yri_ids = pd.read_csv("yri.samples", header=None, names=["Sample"], sep="\t")

pel = pel.merge(pel_ids)
ibs = ibs.merge(ibs_ids)
yri = yri.merge(yri_ids)

smap = pd.concat([pel,ibs,yri], axis=0, ignore_index=True)
smap = smap.rename(columns={"Sample":"#Sample"})
smap.to_csv("IBSYRIPEL.smap", sep="\t", index=False)
print(smap.head())
```
