#Files

## [FIFLG_summary_pipeline](https://github.com/jbutler1993/FIFLG_Pipelines/blob/main/FIFLG_summary_pipeline.R)
A high-level count of projects by Application Stage and Sub-Scheme, comparing between the latest and previous iterations.

> [!NOTE]
> Packages used: dplyr, readxl, janitor

### Code Operations
- [ ] Load .csv files from SharePoint
- [ ] Clean names
- [ ] Convert date columns to date format
- [ ] Group both extracts by Sub-Scheme and Application Stage
- [ ] Calculate differences in grouped count across previous and latest data
- [ ] Produce a summary table of changes to totals between extracts
