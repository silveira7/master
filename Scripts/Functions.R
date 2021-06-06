##============================================================================
## => LIBRARIES
##============================================================================

library(tidyverse)
library(magrittr)
library(ggpubr)
library(gridExtra)

##============================================================================
## => IMPORT ALCP SOCIAL DATA
##============================================================================

alcp_social_data <- read_csv(
    "../Data/ALCP_Social_Data.csv",
    locale = locale(decimal_mark = ","),
    col_types = cols(
        "PERFIL" = col_factor(ordered = F),
        "SEXO" = col_factor(ordered = F),
        "FAIXA.ETARIA" = col_factor(ordered = T),
        "ESCOLARIDADE" = col_factor(
            levels = c("analfabeto",
                       "fund1",
                       "fund2",
                       "medio"),
            ordered = T
            ),
        "INDICE.SOCIO" = col_double(),
        "IDADE.MIGRACAO2" = col_factor(
            levels = c("19-", "20+"),
            ordered = T
            ),
        "TEMPO.SP2" = col_factor(
            levels = c("9-", "10+"),
            ordered = T
            ),
        "PROP.VIDA.SP2" = col_factor(
            levels = c("ate1quarto",
                       "de1a2quartos",
                       "maismetade"),
            ordered = T
            )
        )
    )

alcp_social_data %<>% select(
    PARTICIPANTE,
    PERFIL,
    SEXO,
    FAIXA.ETARIA,
    ESCOLARIDADE,
    INDICE.SOCIO,
    IDADE.MIGRACAO2,
    TEMPO.SP2,
    PROP.VIDA.SP2
    )
 
##============================================================================
## => CHUNKS IMPORT FUNCTION
##============================================================================

# Function to import the datasets with prosodic variables of chunks

import_chunks_data = function(filename) {
    tibble = read_csv(
        filename,
        col_types = cols(
            .default = col_double(),
            "audiofile" = col_character(),
            "chunk" = col_character(),
            "f0med" = col_integer(),
            "f0min" = col_integer(),
            "f0max" = col_integer(),
            "cvint" = col_integer()
            )
        )
    tibble %<>% select(!chunk)
    return(tibble)
}

##============================================================================
## => STRESS GROUPS IMPORT TIBBLE
##============================================================================

import_sg_data = function(filename) {
    tbl = read_csv(
        filename,
        col_types = cols(
            .default = col_integer(),
            audiofile = col_character(),
            sg_dur_norm = col_double()
            )
        )
}

##============================================================================
## => IMPORT SYLLABLES TIBBLE
##============================================================================

import_syl_data = function(filename) {
  tbl = read_csv(
    filename,
    col_types = cols(
      duration_ms = col_integer(),
      z = col_double(),
      filteredz = col_double(),
      boundary = col_factor(),
      order = col_integer()
    )
  )
  tbl %<>% select(!chunk)
}

##============================================================================
## SPLIT FILENAMES
##============================================================================

split_filenames = function(tibble) {
  for (x in 1:nrow(tibble)) {
    if (x == 1) {
      tmp_tibble = tribble( ~ corpus, ~ speaker, ~ chunk)
    }
    filename = tibble[[x, 1]]
    parts = unlist(str_split(filename, "_"))
    tmp_tibble %<>%
      add_row(
        corpus = str_trim(parts[1]),
        speaker = str_trim(parts[2]),
        chunk = str_trim(parts[3])
      )
  }
  extended_tibble = tibble %>%
    add_column(tmp_tibble, .before = 1)
  return(extended_tibble)
}

##============================================================================
## => SAMPLE TOKENS
##============================================================================

sample_tokens = function(tibble, n) {
  speakers = unique(tibble$speaker)
  for (x in 1:length(speakers)) {
    speaker_rows = tibble %>% filter(speaker == speakers[x])
    n_tokens = nrow(speaker_rows)
    if (n_tokens > n) {
      chosen_tokens = sample(n_tokens, n)
      selected_rows = speaker_rows[chosen_tokens, ]
      if (x == 1) {
        new_tibble = selected_rows
      }
      else {
        new_tibble %<>% add_row(selected_rows)
      }
    }
    else {
      if (x == 1) {
        new_tibble = speaker_rows
      }
      else {
        new_tibble %<>% add_row(speaker_rows)
      }
    }
  }
  
  return(new_tibble)
}

##============================================================================
## => CHECK SAMPLING
##============================================================================

check_tokens = function(tibble) {
  speakers = unique(tibble$speaker)
  print(speakers)
  for (x in 1:length(speakers)) {
    speaker_rows = tibble %>%
      filter(speaker == speakers[x])
    n_tokens = nrow(speaker_rows)
    cat(speakers[x], "   \t", n_tokens, "\n")
  }
}

##============================================================================
## => GET SOCIAL DATA
##============================================================================

get_social_data = function(tbl, tbl_social) {
    new_tbl = tibble()
    for (x in 1:nrow(tbl)) {
        for (y in 1:nrow(tbl_social)) {
            if (tbl[x, 2] == tbl_social[y, 1]) {
                merged_row = add_column(tbl[x, ], tbl_social[y, ])
                if (x == 1) {
                    new_tbl %<>% add_column(merged_row)
                }
                else {
                    new_tbl %<>% add_row(merged_row)
                }
            }
        }
    }
    return(new_tbl)
}

##============================================================================
## => FILTER SG DATA TO CHUNK SAMPLE
##============================================================================

sg_sample = function(chunks_tbl, sg_tbl) {
  groups = vector()
  
  for (x in 1:nrow(chunks_tbl)) {
     group = str_c(chunks_tbl[x, 1:3], collapse = "_")
     groups[x] = group
  }
  
  fst <- T
  
  for (y in 1:nrow(sg_tbl)) {
    group = str_c(sg_tbl[y, 1:3], collapse = "_")
    if (group %in% groups) {
      if (fst) {
        new_tbl = sg_tbl[y, ]
        fst <- F
      }
      else {
        new_tbl %<>% add_row(sg_tbl[y, ])
      }
    }
  }
  
  return(new_tbl)
}

##============================================================================
## => BOXPLOTS IN BATCHES
##============================================================================

create_boxplots <- function(df, vd_list, vi_list) {
  plots <- list()
  n = 0
  for (i in 1:length(vd_list)) {
    for (j in 1:length(vi_list)) {
      n = n + 1
      p <- ggplot(df, aes(
          x = .data[[ vi_list[j] ]],
          y = .data[[ vd_list[i] ]],
          fill = .data[[ vi_list[j] ]]
          )
      ) +
      geom_boxplot(notch = T, show.legend = F) +
        theme_classic()
      
      ylim1 = boxplot.stats(df[[vd_list[i]]])$stats[c(1, 5)]
      
      p1 <- p + coord_cartesian(ylim = ylim1*1.05)
      plots[[n]] <- p1
    }
  }
  return(plots)
}

##============================================================================
## => CREATE PLOTS GRID FOR SOCIAL VARIABLES
##============================================================================

grid_plots_social <- function(plots_list, num, n_col, n_row) {
  gridlist <- list()
  for (i in 1:(length(plots_list) / num)) {
    if (i == 1) {
      x <- 1
      y <- num
    }
    else {
      x <- x + num
      y <- y + num
    }
    p <- do.call("grid.arrange", c(plots_list[x:y], 
                                   ncol = n_col, 
                                   nrow = n_row))
    gridlist[[i]] <- p
  }
  return(gridlist)
}

### End of the script ========================================================