####                              Definitions and Packages                      ####

### Presets ###

bld23_path <- "C:/Users/jb000299/OneDrive - Defra/RESTRICTED_DL_ORIGINAL_RAW_DATA/BusinessData_2023.csv"                                    # Filepath to Business Level dataset 

largegrants_path <- "C:/Users/jb000299/OneDrive - Defra/RESTRICTED_DL_FIF_Data_Folder/Data/Large Grants/FTF All theme data @07FEB2025.csv"  # Filepath to FIF Large Grants dataset

avapplicants_path <- "C:/Users/jb000299/OneDrive - Defra/Desktop/20250305 - AVapplicants.csv"                                               # Filepath to Adding Value interview dataset

output_path <- "C:/Users/jb000299/OneDrive - Defra/Desktop/20250305 - enrichedAVapplicants.csv"                                             # Filepath for output file

### Load packages ###

usePackage <- function(p) # Function created that checks for library, installing if not present
{
  if (!is.element(p, installed.packages()[, 1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

usePackage("dplyr")   # Functions: select, rename
usePackage("utils")   # Functions: read.csv
usePackage("janitor") # Functions: clean_names




####                                 Load and clean the datasets                ####

bld23 <- utils::read.csv(bld23_path) %>%                       
  janitor::clean_names() %>%
  dplyr::select(business_id, sbi, number_of_holdings, robust, mft, pft, tenure, quota_type_name, livestock_unit, total_slr, slr_band, b99, h10) %>%
  dplyr::rename(horticulture_ha = b99) %>%
  dplyr::rename(area_used = h10)

largegrants_av <- utils::read.csv(largegrants_path) %>%
  janitor::clean_names() %>%
  dplyr::filter(ftf_sub_scheme == "FTF-Adding Value ") %>%
  dplyr::select(single_business_identifier_sbi, project_ref, business_size, employees, business_type) %>%
  dplyr::rename(sbi = single_business_identifier_sbi) %>%
  dplyr::distinct(sbi, .keep_all = TRUE)
  
largegrants_av$sbi <- as.numeric(largegrants_av$sbi)

avapplicants <- utils::read.csv(avapplicants_path) %>%                       
  janitor::clean_names() %>%
  dplyr::rename(sbi = single_business_identifier_sbi)




####                                Join the Datasets                           ####

enriched_avapplicants <- dplyr::left_join(avapplicants, largegrants_av, by = 'sbi')

enriched_avapplicants <- dplyr::left_join(enriched_avapplicants, bld23, by = 'sbi')




####                                Export the csv                              ####

utils::write.csv(enriched_avapplicants, output_path)
