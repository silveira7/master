### Beginning of the script ==================================================

rm(list = ls())

source("Functions.R")

##============================================================================
## => IMPORT OBJECTS
##============================================================================

chunks_alcp_sampled = read_rds("../Objects/Chunks_ALCP_Sampled.rds")
glimpse(chunks_alcp_sampled)

chunks_sp2010_sampled = read_rds("../Objects/Chunks_SP2010_Sampled.rds")
glimpse(chunks_sp2010_sampled)

chunks_sampled = read_rds("../Objects/Chunks_Sampled.rds")
glimpse(chunks_sampled)

##============================================================================
## => COMPARISONS BETWEEN ALCP AND SP2010
##============================================================================

prosodic_variables <- c("f0sd", 
                        "sdf0peak", 
                        "f0peakwidth",
                        "f0peak_rate",
                        "sdtf0peak",
                        "df0posmean",
                        "df0negmean",
                        "df0sdpos",
                        "df0sdneg",
                        "sr"
)

chunks_boxplots <- create_boxplots(chunks_sampled, 
                                   prosodic_variables, 
                                   "corpus")

chunks_boxplots_grid <- do.call("grid.arrange", 
                                c(chunks_boxplots, ncol=5))

ggsave("../Plots/Chunks/Chunks_Bloxplots_Grids.png",
       chunks_boxplots_grid,
       width = 9,
       height = 6)

##============================================================================
## => SOCIAL VARIABLES
##============================================================================

social_variables = c("SEXO",
                     "FAIXA.ETARIA",
                     "ESCOLARIDADE",
                     "IDADE.MIGRACAO2",
                     "TEMPO.SP2",
                     "PROP.VIDA.SP2"
)


chunks_boxplots_social <- create_boxplots(chunks_alcp_sampled, 
                                          prosodic_variables, 
                                          social_variables)

chunks_boxplots_grid_social <- grid_plots_social(chunks_boxplots_social, 
                                                 num = 6,
                                                 n_col = 3,
                                                 n_row = 2)

for (i in 1:length(chunks_boxplots_grid_social)) {
    filename <- str_c("../Plots/Chunks/Chunks_Boxplot_Grid_Social_", i, ".png")
    ggsave(filename, chunks_boxplots_grid_social[[i]],
           width =9,
           height = 6
    )
}

### End of the script ========================================================