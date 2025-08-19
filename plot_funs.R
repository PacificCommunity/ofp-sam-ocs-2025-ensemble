
plot_posts <- function(mmelt, bys){
  
  plot_post <- function(mmelt, bys, var, lab, bw=0.01){
    
    lab <- sym(lab) 
   
     mmelt %>% 
      filter(grepl(var, variable)) %>%
      ggplot() + 
      geom_histogram(aes(x=value, fill=factor(!!sym(bys))), bins = 100, stat = 'density')+
      geom_density(aes(x=value),size=1.2, bw=0.01)+ 
      labs(x=lab)+
      scale_fill_discrete(bys) +
      cowplot::theme_cowplot() + 
      theme(panel.grid.major = element_line(colour='grey50', linetype = 3, size = 0.5)) 
    
  }
  g1 <- plot_post(mmelt, bys, 'InitF', 'Initial F')
  g2 <- plot_post(mmelt, bys, 'R0', 'R0')
  g3 <- plot_post(mmelt, bys, 'NatM', 'M')
  g4 <- plot_post(mmelt, bys, 'SR_surv_zfrac', 'Zfrac')
  g5 <- plot_post(mmelt, bys, 'F_2023', 'F/F[MSY] 2023')
  g6 <- plot_post(mmelt, bys, 'Bratio_2023', 'SB/SB[0] 2023')
  
  g1 +g2 + g3 + g4 + g5 + g6 + patchwork::plot_layout(guides = 'collect',ncol = 2)
  
}
