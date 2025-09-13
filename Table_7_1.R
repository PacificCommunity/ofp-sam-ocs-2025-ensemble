require(posterior)
require(adnuts)
require(tidyverse)
require(tidybayes)
require(data.table)
require(patchwork)
source("R/get-zhou-ref-points.r")
source("R/plot_funs.R")

# MCMC ensemble outputs ----
load("data/mcmc_ensemble.rda")

## Table 7.1; plus additional metrics reported in SC recommendations ----
refpts <-
posterior::as_draws(mcmc) %>% 
  subset_draws(variable = c('SR_LN*',
                            'NatM.*',
                            'SR_surv_zfrac.*',
                            '^Init.*',
                            'annF_MSY',
                            'F_2023',
                            'SSB_Initial',
                            'Bratio_2023'), regex = T) %>% 
  mutate(SSB = Bratio_2023*SSB_Initial,
         F = F_2023 * annF_MSY,
         `$F(y^-1)$` = F) %>%
  rename(`$SB/SB_0$`=Bratio_2023,
         `$F_{MSY}$` = annF_MSY,
         `Initial F` = InitF_seas_1_flt_1F_NonTarLL,
         M = NatM_uniform_Fem_GP_1,
         `$SSB (t)$`= SSB) %>%
  mutate(`$F/F_{MSY}$`=F_2023
         ) %>% 
  select(-SSB_Initial, -F_2023, -F) %>%
  posterior::summarise_draws(default_summary_measures())

refpts$variable[refpts$variable == "SR_LN(R0)"] <- "ln(R0)"
refpts$variable[refpts$variable == "$F/F_{MSY}$"] <- "Frecent/Fmsy"
refpts$variable[refpts$variable == "Initial F"] <- "Finit"
refpts$variable[refpts$variable == "$SB/SB_0$"] <- "SBrecent/SB0"
refpts$variable[refpts$variable == "SR_surv_zfrac"] <- "zfrac"

rows <- c("SBrecent/SB0", "Frecent/Fmsy", "Finit", "ln(R0)", "M", "zfrac")
refpts <- refpts[match(rows, refpts$variable),]
refpts[-1] <- round(refpts[-1], 2)
names(refpts) <- c("Variable", "Mean", "Median", "SD", "MAD", "5%", "95%")

write.csv(refpts, "Table_7_1.csv", quote=FALSE, row.names=FALSE)
