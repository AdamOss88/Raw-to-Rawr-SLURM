loessErrfun_mod4 <- function(trans) {
  # This is a function that LearnError can use to set Loess
  # It sets weights, span and degree while also enforcing monotonicity
  
  # Ensure correct input and create matrix to be filled
  qq <- as.numeric(colnames(trans))
  est <- matrix(0, nrow=0, ncol=length(qq))
  
  # Do all comparisons between nucleotide transversions (i.e. A>C and C>A)
  for(nti in c('A','C','G','T')) {
    for(ntj in c('A','C','G','T')) {
      # A comparison is not necessary when A>A or T>T: there is no change
      if(nti != ntj) {
        # Title of the comparison (i.e. A2C or G2T)
        errs <- trans[paste0(nti,'2',ntj),]
        # Total transition rate of one nucleotide to all others
        tot <- colSums(trans[paste0(nti,'2',c('A','C','G','T')),])
        # 1 psuedo-count for each err, but if tot=0 will give NA
        rlogp <- log10((errs+1)/tot) 
        rlogp[is.infinite(rlogp)] <- NA
        # Put all of the above in one frame
        df <- data.frame(q=qq, errs=errs, tot=tot, rlogp=rlogp)
        
        # original
        # ###! mod.lo <- loess(rlogp ~ q, df, weights=errs) ###!
        # mod.lo <- loess(rlogp ~ q, df, weights=tot) ###!
        # #        mod.lo <- loess(rlogp ~ q, df)
        
        # jonalim's solution
        # https://github.com/benjjneb/dada2/issues/938
        
        # Perform the customised Loess model
        mod.lo <- loess(rlogp ~ q, df, weights = log10(tot),degree = 1, span = 0.95)
        
        # Use the model to predict the error rates
        pred <- predict(mod.lo, qq)
        maxrli <- max(which(!is.na(pred)))
        minrli <- min(which(!is.na(pred)))
        pred[seq_along(pred)>maxrli] <- pred[[maxrli]]
        pred[seq_along(pred)<minrli] <- pred[[minrli]]
        
        # Store the predictions in the overarching matrix
        est <- rbind(est, 10^pred)
      } # if(nti != ntj)
    } # for(ntj in c('A','C','G','T'))
  } # for(nti in c('A','C','G','T'))
  
  # HACKY (enforces fixed max and min rates)
  MAX_ERROR_RATE <- 0.25
  MIN_ERROR_RATE <- 1e-7
  est[est>MAX_ERROR_RATE] <- MAX_ERROR_RATE
  est[est<MIN_ERROR_RATE] <- MIN_ERROR_RATE
  
  # Enforce monotonicity
  # https://github.com/benjjneb/dada2/issues/791
  estorig <- est
  est <- est %>%
    data.frame() %>%
    dplyr::mutate_all(dplyr::funs(dplyr::case_when(. < X40 ~ X40,
                                                   . >= X40 ~ .))) %>% as.matrix()
  rownames(est) <- rownames(estorig)
  colnames(est) <- colnames(estorig)
  
  # Expand the error matrix with the self-transition probabilities
  err <- rbind(1-colSums(est[1:3,]), est[1:3,],
               est[4,], 1-colSums(est[4:6,]), est[5:6,],
               est[7:8,], 1-colSums(est[7:9,]), est[9,],
               est[10:12,], 1-colSums(est[10:12,]))
  rownames(err) <- paste0(rep(c('A','C','G','T'), each=4), '2', c('A','C','G','T'))
  colnames(err) <- colnames(trans)
  # Return
  return(err)
}
