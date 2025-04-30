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
usePackage("stringr")



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
    application_stage == "Project Closed" ~ "Closed", 
    application_stage == "Recovery" ~ "FA Approved", 
    application_stage == "Terminated (Project Never started)" ~ "FA Withdrawn", 
    application_stage == "Withdrawn" ~ "FA Withdrawn", 
    TRUE ~ "Unknown"
  ))

ftf_fa_approved <- ftf_raw_latest %>%
  filter(application_stage_recoded %in% c("FA Approved", "Closed"))

ftf_fa_approved$marker <- "None"

ftf_fa_approved <- ftf_fa_approved %>%
  mutate(
    sum_of_full_application_grant_amount_requested = as.numeric(
      gsub("£|,", "", sum_of_full_application_grant_amount_requested)
    )
  )



### Water Round One - Reservoir Marker

ftf_fa_approved <- ftf_fa_approved %>%
  mutate(
    marker = ifelse(
      ftf_sub_scheme == "FTF-Water" &
        str_detect(
          description_of_project,
          regex("Construction of dam walls|Overflow/spillway|Synthetic liner|Abstraction point|Engineer fees|Fencing|Filtration equipment|Irrigation pump|Pipework|Pumphouse|Underground water|Electricity installation for pumphouse|Water meter|Water storage tanks",
                ignore_case = TRUE)
        ),
      "Reservoir",
      marker  # keep existing values if condition not met
    )
  )


### Water Round One - Irrigation Marker

ftf_fa_approved <- ftf_fa_approved %>%
  mutate(
    marker = ifelse(
      ftf_sub_scheme == "FTF-Water" &
        str_detect(
          description_of_project,
          regex("Boom|Trickle|Ebb and flow|Capillary bed|Sprinklers|Mist",
                ignore_case = TRUE)
        ),
      "Irrigation",
      marker  # keep existing values if condition not met
    )
  )

### Slurry Round One - Slurry Stores

ftf_fa_approved <- ftf_fa_approved %>%
  mutate(
    marker = ifelse(
      ftf_sub_scheme == "FTF-Slurry Infrastructure" &
        str_detect(
          description_of_project,
          regex("Above-ground steel slurry store|Precast circular concrete slurry store|Store using precast rectangular concrete panels",
                ignore_case = TRUE)
        ),
      "Slurry Store",
      marker  # keep existing values if condition not met
    )
  )

### Productivty Round One - Robotic Milker

ftf_fa_approved <- ftf_fa_approved %>%
  mutate(
    marker = ifelse(
      ftf_sub_scheme == "FTF-Productivity" &
        str_detect(
          description_of_project,
          regex("Voluntary robotic milking system",
                ignore_case = TRUE)
        ),
      "Robotic Milker",
      marker  # keep existing values if condition not met
    )
  )


### Adding Value Round One - Processing Equipment/Machinery

ftf_fa_approved <- ftf_fa_approved %>%
  mutate(
    marker = ifelse(
      ftf_sub_scheme == "FTF-Productivity" &
        str_detect(
          description_of_project,
          regex("Processing equipment or machinery",
                ignore_case = TRUE)
        ),
      "Processing",
      marker  # keep existing values if condition not met
    )
  )



ftf_fa_approved <- ftf_fa_approved %>%
  filter(marker != "None")

### Count by applications

summary <- ftf_fa_approved %>%
  group_by(marker, application_stage_recoded) %>%
  summarise(
    count = n(),
    total_grant_requested = sum(sum_of_full_application_grant_amount_requested, na.rm = TRUE),
    .groups = "drop"
  )
