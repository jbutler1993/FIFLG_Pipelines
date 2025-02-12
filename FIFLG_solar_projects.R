####                              Definitions and Packages                        ####

### Presets ###

input_file_latest <- "C:/Users/jb000299/OneDrive - Defra/RESTRICTED_DL_FIF_Data_Folder/Data/Large Grants/FTF All theme data @07FEB2025.csv" # Filepath to latest data

date_cols <- c("hardcopy_oa_received_date", "hardcopy_application_received_date", "date_of_oa_decision", "application_due_date", "full_application_appraisal_start_date", "fa_decision", "gfa_sent_date", "gfa_returned_date", "date_of_withdrawal")  # List all date columns


### Load packages ###

usePackage <- function(p) # Function created that checks for library, installing if not present
{
  if (!is.element(p, installed.packages()[, 1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

usePackage("dplyr")
usePackage("readxl")  # read_excel
usePackage("janitor") # snake_case
usePackage("tidyr")   # table transpose



####                              Load and Clean Data                             ####


### Load and clean latest data ###

ftf_raw_latest <- read.csv(input_file_latest) %>%                               # Read in input file
  clean_names() %>%                                                             # Converts names to snake case
  mutate(across(.cols = intersect(date_cols, colnames(.)),                      # Only apply to columns that exist in the data
                .fns = ~ as.Date(.x, format = "%d/%m/%Y")))                     # Converts all date columns to date format  


### Recode the application status according to RPA methods - recode list from Grant Services

ftf_raw_latest <- ftf_raw_latest %>%
  mutate (application_stage_recoded = case_when(
    application_stage == "All Claims Rejected Project" ~ "FA Rejected",     
    application_stage == "Application Approved" ~ "FA Approved",         
    application_stage == "Application in appraisal " ~ "FA Outstanding", 
    application_stage == "Application Received" ~ "FA Outstanding", 
    application_stage == "Application rejected" ~ "FA Rejected",
    application_stage == "Contracted" ~ "FA Approved",
    application_stage == "FA Completeness Check Failed" ~ "FA Rejected", 
    application_stage == "FA withdrawn" ~ "FA Withdrawn", 
    application_stage == "OA Completeness Check Failed" ~ "OA Rejected", 
    application_stage == "OA endorsed/proceed to Full Application" ~ "OA Approved", 
    application_stage == "OA In process" ~ "OA Outstanding", 
    application_stage == "OA Received" ~ "OA Outstanding", 
    application_stage == "OA Rejected" ~ "OA Rejected", 
    application_stage == "OA withdrawn " ~ "OA Withdrawn", 
    application_stage == "Project Closed" ~ "FA Approved", 
    application_stage == "Recovery" ~ "FA Approved", 
    application_stage == "Terminated (Project Never started)" ~ "FA Withdrawn", 
    application_stage == "Withdrawn" ~ "FA Withdrawn", 
    TRUE ~ "Unknown"
  ))


####                              Isolate Solar data                             ####

### Reduce dataset to Productivity Round Two applications

ftf_prodr2_latest <- ftf_raw_latest %>%
  filter(ftf_sub_scheme == "FTF-Productivity Round 2")                          # Filter by Sub-Scheme to Productivity Round Two

ftf_prodr2_count <- ftf_prodr2_latest %>%                                       # Count number of applications
  summarise(count = n())

print(ftf_prodr2_count)                                                         # Count number of applications - verify it's the correct amount


### Cleanup

remove(ftf_raw_latest)
remove(ftf_prodr2_count)


### Pick out the Solar projects

ftf_prodr2_solar <- ftf_prodr2_latest %>%                                       # Search for applications containing Solar-specific phrases in their descriptions (not case sensitive) 
  filter(grepl("solar|battery|batteris|pv panel|pv panels|inverter|utility meter|grid connection|powerdiverter", description_of_project, ignore.case = TRUE)) %>%
  filter(!is.na(hardcopy_application_received_date))                            # Filter to applications that have a Full Application Received Date
