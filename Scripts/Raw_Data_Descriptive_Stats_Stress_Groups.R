### Beginning of the script ==================================================

rm(list = ls())

source("Functions.R")

##============================================================================
## => IMPORT OBJECTS
##============================================================================

sg_alcp_sampled = read_rds("../Objects/SG_ALCP_Sampled.rds")
glimpse(sg_alcp_sampled)

sg_sp2010_sampled = read_rds("../Objects/SG_SP2010_Sampled.rds")
glimpse(sg_alcp_sampled)

sg_sampled = read_rds("../Objects/SG_Sampled.rds")
glimpse(sg_sampled)

##============================================================================
## => COMPARISONS BETWEEN ALCP AND SP2010
##============================================================================

prosodic_variables <- c("sg_dur",
                        "vv_num",
                        "sg_dur_norm")

sg_boxplots <- create_boxplots(sg_sampled, 
                               prosodic_variables, 
                               "corpus")

sg_boxplots_grid <- do.call("grid.arrange", 
                                c(sg_boxplots, ncol=3))

ggsave("../Plots/Stress_Groups/SG_Bloxplots_Grids.png",
       sg_boxplots_grid,
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


sg_boxplots_social <- create_boxplots(sg_alcp_sampled, 
                                      prosodic_variables, 
                                      social_variables)

sg_boxplots_grid_social <- grid_plots_social(sg_boxplots_social, 
                                             num = 6,
                                             n_col = 3,
                                             n_row = 2)

for (i in 1:length(sg_boxplots_grid_social)) {
    filename <- str_c("../Plots/Stress_Groups/SG_Boxplot_Grid_Social_", i, ".png")
    ggsave(filename, sg_boxplots_grid_social[[i]],
           width =9,
           height = 6
    )
}

### End of the script ========================================================