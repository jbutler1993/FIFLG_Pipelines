# :floppy_disk: Files

---

## [FIFLG_Solar Projects](https://github.com/jbutler1993/FIFLG_Pipelines/blob/main/FIFLG_solar_projects.R)
A high-level count of projects applying for Solar Items.

> [!NOTE]
> Packages used: dplyr, janitor, readxl

### Code Operations
- [ ] Load .csv files from SharePoint
- [ ] Clean names
- [ ] Recode Application Stages to those used in the Defra Grants Service Performance Report methods
- [ ] Convert date columns to date format
- [ ] Filter to Productivity Round Two applications
- [ ] Group both extracts by Sub-Scheme and Application Stage
- [ ] Filter to applications with a Full Application Receipt Date

---

## [FIFLG_summary_pipeline](https://github.com/jbutler1993/FIFLG_Pipelines/blob/main/FIFLG_summary_pipeline.R)
A high-level count of projects by Application Stage and Sub-Scheme, comparing between the latest and previous iterations.

> [!NOTE]
> Packages used: dplyr, janitor, readxl, tidyr

### Code Operations
- [ ] Load .csv files from SharePoint
- [ ] Clean names
- [ ] Recode Application Stages to those used in the Defra Grants Service Performance Report methods
- [ ] Convert date columns to date format
- [ ] Group both extracts by Sub-Scheme and display totals
- [ ] Group both extracts by Sub-Scheme and Application Stage
- [ ] Calculate differences in grouped count across previous and latest data
- [ ] Produce a summary table of changes to totals between extracts

---
