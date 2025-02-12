####                              Definitions and Packages                        ####

### Presets ###

input_file_latest <- "C:/Users/jb000299/OneDrive - Defra/RESTRICTED_DL_FIF_Data_Folder/Data/Large Grants/FTF All theme data @07FEB2025.csv" # Filepath to latest data

input_file_previous <- "C:/Users/jb000299/OneDrive - Defra/RESTRICTED_DL_FIF_Data_Folder/Data/Large Grants/FTF scheme data @02OCT2024.csv" # Filepath to previous data

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

ftf_raw_latest <- read.csv(input_file_latest) %>%                           # Read in input file
                  clean_names() %>%                                         # Converts names to snake case
                  mutate(across(.cols = intersect(date_cols, colnames(.)),  # Only apply to columns that exist in the data
                  .fns = ~ as.Date(.x, format = "%d/%m/%Y")))               # Converts all date columns to date format  


### Recode the application status according to RPA methods

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


### Count of projects by Sub-Scheme

ftf_latest_count <- ftf_raw_latest %>%
  group_by(ftf_sub_scheme) %>%                                                
  summarise(count = n())

print(ftf_latest_count)


### Count of projects by Sub-Scheme and Application Stage


ftf_latest_summary <- ftf_raw_latest %>%
  group_by(ftf_sub_scheme, application_stage_recoded) %>%                                                 # Summarise by scheme and application stage
  summarise(count = n(), .groups = "drop") %>%                                                            # Count number in each grouping
  pivot_wider(names_from = application_stage_recoded, values_from = count, values_fill = list(count = 0)) # Convert count from a list to a table

print(ftf_latest_summary)


### Load and clean previous data ###

ftf_raw_previous <- read.csv(input_file_previous) %>%                         # Read in input file
                    clean_names() %>%                                         # Converts names to snake case
                    mutate(across(.cols = intersect(date_cols, colnames(.)),  # Only apply to columns that exist in the data
                                  .fns = ~ as.Date(.x, format = "%d/%m/%Y"))) # Converts all date columns to date format

### Recode the application status according to RPA methods

ftf_raw_previous <- ftf_raw_previous %>%
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


### Count of projects by Sub-Scheme


ftf_previous_count <- ftf_raw_previous %>%
  group_by(ftf_sub_scheme) %>%                                                
  summarise(count = n())

print(ftf_previous_count)


### Count of projects by Sub-Scheme and Application Stage


ftf_previous_summary <- ftf_raw_previous %>% 
  group_by(ftf_sub_scheme, application_stage_recoded) %>%                                                 # Summarise by scheme and application stage
  summarise(count = n(), .groups = "drop") %>%                                                            # Count number in each grouping
  pivot_wider(names_from = application_stage_recoded, values_from = count, values_fill = list(count = 0)) # Convert count from a list to a table

print(ftf_previous_summary)




####                              Compare Latest and Previous Data                ####

###  Group and count for previous data ###

ftf_raw_previous_summary <- ftf_raw_previous %>%
  group_by(ftf_sub_scheme, application_stage_recoded) %>%
  summarise(previous_count = n(), .groups = "drop")


### Group and count for latest data ###

ftf_raw_latest_summary <- ftf_raw_latest %>%
  group_by(ftf_sub_scheme, application_stage_recoded) %>%
  summarise(latest_count = n(), .groups = "drop")


### Join grouped data and measure differences ###

comparison_table <- ftf_raw_previous_summary %>%
  full_join(ftf_raw_latest_summary, by = c("ftf_sub_scheme", "application_stage_recoded")) %>%
  mutate(
    difference = coalesce(latest_count, 0) - coalesce(previous_count, 0),  # Difference, treating NAs as 0
    across(c(previous_count, latest_count), ~coalesce(.x, 0)),             # Replace NAs with 0 for count columns
    difference_label = case_when(
      difference > 0 ~ paste("+", difference),                             # If positive, add "+" before the number
      difference == 0 ~ as.character(difference),                          # If zero, just display the number
      TRUE ~ as.character(difference)))                                    # If negative, just display the number


### Cleanup ###

remove(ftf_raw_previous_summary)
remove(ftf_raw_latest_summary)
