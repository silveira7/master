### Beginning of the script ==================================================

rm(list = ls())

source("Functions.R")

##============================================================================
## => IMPORT ALCP STRESS GROUPS DATA
##============================================================================

sg_alcp = import_sg_data("../Data/Raw_Data_ALCP_Stress_Groups.csv")

sg_alcp = split_filenames(sg_alcp)

sg_alcp %<>% select(!audiofile)

sg_alcp %<>% filter(speaker != "JosileideS", speaker != "LuciaI")

glimpse(sg_alcp)

##============================================================================
## => IMPORT SP2010 STRESS GROUPS DATA
##============================================================================

sg_sp2010 = import_sg_data("../Data/Raw_Data_SP2010_Stress_Groups.csv")

sg_sp2010 = split_filenames(sg_sp2010)

sg_sp2010 %<>% select(!audiofile)

glimpse(sg_sp2010)

##============================================================================
## => FILTER BY CHUNKS SAMPLE
##============================================================================

chunks_alcp_sampled = readRDS("../Objects/Chunks_ALCP_Sampled.rds")
chunks_sp2010_sampled = readRDS("../Objects/Chunks_SP2010_Sampled.rds")

sg_alcp_sampled = sg_sample(chunks_alcp_sampled, sg_alcp)
sg_sp2010_sampled = sg_sample(chunks_sp2010_sampled, sg_sp2010)

# Checking
setdiff(sort(unique(as.character(sg_alcp_sampled$chunk))),
sort(unique(as.character(chunks_alcp_sampled$chunk))))

setdiff(sort(unique(as.character(sg_sp2010_sampled$chunk))),
sort(unique(as.character(chunks_sp2010_sampled$chunk))))

##============================================================================
## => MERGE ALCP AND SP2010 TIBBLES
##============================================================================

sg_sampled = sg_alcp_sampled %>%
    add_row(sg_sp2010_sampled)

glimpse(sg_sampled)

##============================================================================
## => INSERT SOCIAL DATA IN ALCP
##============================================================================

sg_alcp_sampled = get_social_data(sg_alcp_sampled, alcp_social_data)

glimpse(sg_alcp_sampled)

##============================================================================
## => EXPORT OBJECTS
##============================================================================

saveRDS(sg_alcp_sampled, "../Objects/SG_ALCP_Sampled.rds")
saveRDS(sg_sp2010_sampled, "../Objects/SG_SP2010_Sampled.rds")
saveRDS(sg_sampled, "../Objects/SG_Sampled.rds")

### End of the script ========================================================