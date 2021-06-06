rm(list = ls())

source("Functions.R")

## IMPORT ALCP SYLLABLES DATA =================================================

syl_alcp = import_syl_data("Raw_Prosodic_Data_ALCP_Syllables.csv")

syl_alcp = split_filenames(syl_alcp)

syl_alcp %<>% select(!audiofile)

syl_alcp %<>% filter(speaker != "JosileideS", speaker != "LuciaI")

glimpse(syl_alcp)
    
## IMPORT SP2010 SYLLABLES DATA ===============================================

syl_sp2010 = import_syl_data("Raw_Prosodic_Data_SP2010_Syllables.csv")

syl_sp2010 = split_filenames(syl_sp2010)

syl_sp2010 %<>% select(!audiofile)

glimpse(syl_sp2010)

## FILTER BY CHUNKS SAMPLE ====================================================

chunks_alcp_sampled = readRDS("Objects/Chunks_ALCP_Sampled.rds")
chunks_sp2010_sampled = readRDS("Objects/Chunks_SP2010_Sampled.rds")

syl_alcp_sampled = sg_sample(chunks_alcp_sampled, syl_alcp)
syl_sp2010_sampled = sg_sample(chunks_sp2010_sampled, syl_sp2010)

glimpse(syl_alcp_sampled)
glimpse(syl_sp2010_sampled)

## MERGE ALCP AND SP2010 TIBBLES ==============================================

syl_sampled = syl_alcp_sampled %>%
    add_row(syl_sp2010_sampled)

oglimpse(syl_sampled)

## INSERT SOCIAL DATA IN ALCP =================================================

syl_alcp_sampled = get_social_data(syl_alcp_sampled, alcp_social_data)

glimpse(syl_alcp_sampled)

## EXPORT OBJECTS =============================================================

saveRDS(syl_alcp_sampled, "Objects/Syllables_ALCP_Sampled.rds")
saveRDS(syl_sp2010_sampled, "Objects/Syllables_SP2010_Sampled.rds")
saveRDS(syl_sampled, "Objects/Syllables_Sampled.rds")
