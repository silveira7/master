
rm(list = ls())

setwd("~/Dropbox/Mestrado/Scripts")

source("Functions.R")

##============================================================================
## => IMPORT ALCP CHUNKS DATA
##============================================================================

chunks_alcp <- import_chunks_data("../Data/Raw_Data_ALCP_Chunks.csv")

chunks_alcp <- split_filenames(chunks_alcp)

chunks_alcp %<>% select(!audiofile)

chunks_alcp %<>% filter(speaker != "JosileideS", speaker != "LuciaI")

glimpse(chunks_alcp)

##============================================================================
## => IMPORT SP2010 CHUNKS DATA
##============================================================================

chunks_sp2010 <- import_chunks_data("../Data/Raw_Data_SP2010_Chunks.csv")

chunks_sp2010 <- split_filenames(chunks_sp2010)

chunks_sp2010 %<>% select(!audiofile)

glimpse(chunks_sp2010)

##============================================================================
## => SAMPLING
##============================================================================

chunks_alcp_sampled <- sample_tokens(chunks_alcp, 30)
chunks_sp2010_sampled <- sample_tokens(chunks_sp2010, 10)

glimpse(chunks_alcp_sampled)
glimpse(chunks_sp2010_sampled)

check_tokens(chunks_alcp_sampled)
check_tokens(chunks_sp2010_sampled)

##============================================================================
## => MERGE ALCP AND SP2010 TIBBLES
##============================================================================

chunks_sampled <- chunks_alcp_sampled %>%
  add_row(chunks_sp2010_sampled)

glimpse(chunks_sampled)

##============================================================================
## => INSERT SOCIAL DATA IN ALCP
##============================================================================

chunks_alcp_sampled <- get_social_data(chunks_alcp_sampled,
                                       alcp_social_data)

colnames(chunks_alcp_sampled)

chunks_alcp_sampled %<>% select_at(vars(1:3, 27:34, 3:25))

glimpse(chunks_alcp_sampled)

##============================================================================
## => EXPORT OBJECTS
##============================================================================

# WARNING! Run only if you want to overwrite current samples.

saveRDS(chunks_alcp_sampled, file = "../Objects/Chunks_ALCP_Sampled.rds")
saveRDS(chunks_sp2010_sampled, file = "../Objects/Chunks_SP2010_Sampled.rds")
saveRDS(chunks_sampled, file = "../Objects/Chunks_Sampled.rds")

### End of the script ========================================================