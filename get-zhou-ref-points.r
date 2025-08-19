## Flim and Fcrash, corresponding to highest F value resulting in
## 0.5SBmsy and highest F value where yield is 0 on yield curve (i.e. stock crashes)

get_Fcrash <- function(wmod) {

    Fmsy <- filter(wmod$derived_quants, Label=="annF_MSY")$Value 
    ey <- wmod$equil_yield
#   with(filter(ey[,c('Tot_Catch', 'Fmult')], Tot_Catch>0.0000001), plot(Fmult, Tot_Catch, xlim=c(0, 2.5*Fmsy)))
    Fc1 <- filter(ey[,c('Tot_Catch', 'Fmult')], Tot_Catch>0.0000001, Fmult<4*Fmsy) %>% arrange(-Fmult) # last two points with catches above 0
    Fc1 <- Fc1[1:2,]
#   with(Fc1, points(Fmult, Tot_Catch, pch=19, col='blue'))
    sl <- with(Fc1, (Tot_Catch[2]-Tot_Catch[1])/(Fmult[2]-Fmult[1])) # get line 
    int <- Fc1$Tot_Catch[2]-sl*Fc1$Fmult[2]
    Fcrash <- -int/sl #and extend to x-axis to get Fcrash
#   abline(h=0)
#   abline(v=Fcrash)
#   points(Fcrash, 0, pch=19, col='red')
    Fcrash
}

get_Flim <- function(wmod) {

    Fmsy <- filter(wmod$derived_quants, Label=="annF_MSY")$Value     
    SBmsy <- filter(wmod$derived_quants, Label=="SSB_MSY")$Value/2 ## half of SBmsy
    ey <- filter(wmod$equil_yield[,c('Fmult', 'Tot_Catch', 'SSB')], Fmult %between% c(Fmsy, 4*Fmsy)) %>% arrange(SSB) ## only keep descending limb

    ### two points closest to SBmsy/2 on each end    
    vup <- tail(filter(ey, SSB<SBmsy),1)
#    with(vup, points(Fmult, SSB, pch=19, col='red'))    
    vdwn <- head(filter(ey, SSB>SBmsy),1)
    S1 <- rbind(vup, vdwn)
#    with(vdwn, points(Fmult, SSB, pch=19, col='red'))        
    intsb <- with(S1, approxfun(SSB, Fmult))
    intsb(SBmsy) ## Flim

}

    

