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
  posterior::summarise_draws(default_summary_measures()) %>% 
  xtable::xtable() %>%
  xtable::print.xtable(include.rownames = F)


mmelt <- mcmc %>%
  reshape2::melt(id.vars=c('iter','chain', 'LF_weight', 'Growth', 'Disc', 'Beta'))



# Posteriors ----
plot_posts(mmelt, 'Growth')
plot_posts(mmelt, 'LF_weight')
plot_posts(mmelt, 'Disc')
plot_posts(mmelt, 'Beta')

# get FMSY
fmsy <- mmelt %>% 
  filter(grepl('annF_MSY',variable)) %>%
  median_qi(value) 

fmsy <- data.frame(Year = (1990:2024), fmsy)

load('data/OCS_model.Rdata')

## F plot ----

mmelt %>% 
  filter(grepl('^F_[0:9]*',variable)) %>% 
  mutate(Year = as.numeric(gsub('F_(.*)','\\1',variable)),
         Probability=value) %>% 
  group_by(Year) %>% 
  mutate(iter=1:n()) %>%
  inner_join(mmelt %>% 
               filter(grepl('annF_MSY',variable)) %>% 
               mutate(iter=1:n()) %>% rename(F=variable, fmsy=value)) %>%
  mutate(F=value*fmsy) %>%
  ggplot() + 
  stat_lineribbon(aes(x=Year,y=F)) + 
  geom_ribbon(data=fmsy,aes(x=Year,ymin=.lower, ymax=.upper), fill='skyblue',alpha=0.5) +
  geom_line(aes(x=Year), y=get_Fcrash(OCS_model), col='tomato') +
  geom_line(aes(x=Year), y=get_Flim(OCS_model), col='orange') +
  cowplot::theme_cowplot() + 
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.grid.major = element_line(colour='grey50', linetype = 3, size = 0.5)) + 
  scale_x_continuous(breaks=seq(1995,2023,2), limits = c(1995,2023))+
  scale_y_continuous('Fishing mortality', limits=c(0, 0.75)) 


## Biomass plot ----

mmelt %>% 
  filter(grepl('Bratio',variable)) %>% 
  mutate(Year = as.numeric(gsub('Bratio_(.*)','\\1',variable)),
         Probability=value) %>% 
  ggplot() + 
  tidybayes::stat_lineribbon(aes(x=Year,y=Probability)) + 
  cowplot::theme_cowplot() + 
  scale_x_continuous(breaks=seq(1995,2023,2))+
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.grid.major = element_line(colour='grey50', linetype = 3, size = 0.5)) + 
  scale_x_continuous(breaks=seq(1995,2023,2), limits = c(1995,2023))+
  scale_y_continuous(expression(SB/SB[0]),limits=c(0,0.5)) +
  geom_hline(yintercept = 0.04, col='orange', size=1.2) 

## Recr devs plot ----

mmelt %>% 
  filter(grepl('Main_RecrDev',variable)) %>% 
  mutate(Year = as.numeric(gsub('Main_RecrDev_(.*)','\\1',variable)),
         Probability=value) %>% 
  ggplot() + 
  tidybayes::stat_interval(aes(x=Year,y=exp(Probability))) + 
  cowplot::theme_cowplot() + 
  scale_x_continuous(breaks=seq(1994,2022,2))+
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.grid.major = element_line(colour='grey50', linetype = 3, size = 0.5)) + 
  scale_x_continuous(breaks=seq(1996,2022,2), limits = c(1995,2022))+
  scale_y_continuous(expression(R[Dev])) +
  geom_hline(yintercept = 1, col='black', size=1.2) 


# Trajectories by assumption ----

# Generate table
kb <-  mmelt %>%
  filter(grepl('Bratio_[0-9]{4}|^F_[0-9]{4}|^Recr_[0-9]{4}|Main_RecrDev_[0-9]{4}|SSB_[0-9]{4}',variable)) %>%
  mutate(Variable = gsub("(*.)_([0-9]{4})", "\\1",variable),
         Year = gsub(".*_.*([0-9]{4})", "\\1",variable)) %>%
  pivot_wider(-variable, names_from = Variable, values_from = value) %>%
  inner_join(mmelt %>% 
               filter(grepl('annF_MSY',variable)) %>% 
               rename(Fs=variable, fmsy=value)) %>%
  rename(`Fraction~of~unfished~SB~at~eq.`=Bratio,
         `SSB~(t)`= SSB,
         `Recr.~(1000~Indiv.)`=Recr) %>%
  mutate(`F/F[MSY]`=F,
         `Recr.~Dev.` = exp(Main_RecrDev),
         `F~(y^-1)` = F*fmsy) %>% select(-Main_RecrDev, -F, -Fs, -fmsy)

kbs <- kb %>% pivot_longer(-c('iter','chain','LF_weight','Growth','Disc','Beta','Year'), names_to = 'variable', values_to = 'value') %>%
  select(-iter, -chain, -LF_weight, -Growth, -Disc, -Beta) %>%
  group_by(variable, Year) %>%
  median_qi()

kbs$variable <- factor(kbs$variable, levels = unique(kbs$variable)[c(4,5,2,1,6,3)])
ggplot(kbs, aes(x=as.numeric(Year), y=value)) + 
  facet_wrap(~variable, scales = 'free_y',labeller = label_parsed) +
  geom_ribbon(aes(ymin=.lower, ymax=.upper), alpha = 0.2) +
  geom_line() +
  scale_color_discrete(guide='none') + 
  scale_y_continuous(limit=c(0,NA)) +
  cowplot::theme_cowplot() + 
  ylab('Value') +
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.grid.major = element_line(colour='grey80', linetype = 3, size = 0.5)) + 
  scale_x_continuous("Year", breaks=seq(1995,2023,2), limits = c(1995,2023))

## By Growth ----

kbss <- kb %>% pivot_longer(-c('iter','chain','LF_weight','Growth','Disc','Beta','Year'), names_to = 'variable', values_to = 'value') %>%
  select(-iter, -chain, -LF_weight, -Disc, -Beta) %>%
  group_by(variable, Growth, Year) %>%
  median_qi()

kbss$variable <- factor(kbss$variable, levels = levels(kbs$variable))
ggplot(kbss, aes(x=as.numeric(Year), y=value, group=Growth, fill=Growth, col=Growth)) + 
  facet_wrap(~variable, scales = 'free_y',labeller = label_parsed) +
  geom_ribbon(aes(ymin=.lower, ymax=.upper), alpha = 0.2) +
  geom_line() +  ylab('Value') +
  scale_color_discrete(guide='none') + 
  scale_y_continuous(limit=c(0,NA)) +
  cowplot::theme_cowplot() + 
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.grid.major = element_line(colour='grey50', linetype = 3, size = 0.5)) + 
  scale_x_continuous("Year", breaks=seq(1995,2023,2), limits = c(1995,2023))

## By Discard assumption ----

kbss <- kb %>% pivot_longer(-c('iter','chain','LF_weight','Growth','Disc','Beta','Year'), names_to = 'variable', values_to = 'value') %>%
  select(-iter, -chain, -LF_weight, -Growth, -Beta) %>%
  group_by(variable, Disc, Year) %>%
  median_qi()

kbss$variable <- factor(kbss$variable, levels = levels(kbs$variable))
ggplot(kbss, aes(x=as.numeric(Year), y=value, group=Disc, fill=Disc, col=Disc)) + 
  facet_wrap(~variable, scales = 'free_y',labeller = label_parsed) +
  geom_ribbon(aes(ymin=.lower, ymax=.upper), alpha = 0.2) +
  geom_line() +
  scale_color_discrete(guide='none') + 
  scale_y_continuous(limit=c(0,NA)) +
  cowplot::theme_cowplot() +   ylab('Value') +
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.grid.major = element_line(colour='grey50', linetype = 3, size = 0.5)) + 
  scale_x_continuous("Year", breaks=seq(1995,2023,2), limits = c(1995,2023))


# Majuro ----

kbm <- kb %>%  
  select(-iter, -chain, -LF_weight, -Growth, -Disc, -Beta) %>%
  group_by(Year) %>% 
  median_qi %>% 
  mutate(Year = as.numeric(Year))

# plot setup
mpal <- c('F.Fcrash'='salmon2', 'F.Flim'='lightsalmon1', 'F.Fmsy'='peachpuff2')

maxfm <- max(kbm$`F/F[MSY].upper`)*1.1
maxsb <- max(kbm$`Fraction~of~unfished~SB~at~eq..upper`)*1.1

Fmsy <- mmelt %>% 
       filter(grepl('annF_MSY',variable)) %>% 
       pull(value) %>% mean()
Fc <- get_Fcrash(OCS_model)/Fmsy
Fl <- get_Flim(OCS_model)/Fmsy

g1 <- ggplot(kbm , aes(`Fraction~of~unfished~SB~at~eq.`, `F/F[MSY]`)) +
  annotate('rect', xmin=0, xmax=10, ymin=0, ymax=1, fill='grey90') + 
  annotate('rect', xmin=0, xmax=10, ymin=1, ymax=maxfm, fill='peachpuff2') +
  annotate('rect', xmin=0, xmax=10, ymin=Fl, ymax=maxfm, fill='lightsalmon1') +
  annotate('rect', xmin=0, xmax=10, ymin=Fc, ymax=maxfm, fill='salmon2') +
  geom_vline(xintercept=1, size=1, colour='white',linetype=2) +      
  geom_hline(yintercept=1, size=1,linetype=2) +     
  geom_point(aes(col=Year)) +
  geom_line(aes(x=`Fraction~of~unfished~SB~at~eq.`, y=`F/F[MSY]`, col=Year)) +
  geom_pointrange(data=kbm %>% filter(Year==2023),
                  aes( ymin = `F/F[MSY].lower`,
                       ymax = `F/F[MSY].upper`,
                       col=Year), col=viridis::viridis(10)[8], linewidth=1.5) +
  geom_pointrange(data=kbm %>% filter(Year==2023),
                  aes(xmin=`Fraction~of~unfished~SB~at~eq..lower`, 
                      xmax=`Fraction~of~unfished~SB~at~eq..upper`,
                      col=Year), col=viridis::viridis(10)[8], linewidth=1.5) +
  scale_color_gradient('Year', low = 'grey60', high = 'grey20') +
  scale_x_continuous(expression(SB/SB[0]))+
  scale_y_continuous(expression(F/F[MSY]))+
  coord_cartesian(xlim=c(0,maxsb), ylim =c(0,maxfm),expand = 0) +
  theme(legend.position=c(0.74, 0.8),
        plot.title=element_text(size=20),
        legend.title=element_blank(),
        legend.background=element_blank()) + cowplot::theme_cowplot()

g1
