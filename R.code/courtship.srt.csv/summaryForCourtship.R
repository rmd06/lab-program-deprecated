createCourtshipDf <- function(nRows)
{
    df <- data.frame(filename = rep("", nRows), category = rep("", nRows), total_time = rep("", nRows), time_percent = rep(NA, nRows), occurence = rep(NA, nRows), stringsAsFactors=FALSE)
    
    return(df)
}

sumDfCourtshipByTL <- function(TL, textCatg, dfCourtship)
{
  # Return summary time length and occurence of a given 'category' in a courtship data frame
  
  ckCatg <- dfCourtship$text==textCatg
  if (sum(ckCatg, na.rm=TRUE)==0) 
    {
        sumDf <- data.frame(category = textCatg, total_time = TL, time_percent = NA, occurence = NA, stringsAsFactors=FALSE)
    }
  else
    {
        courtshipTextCatg <- dfCourtship[(dfCourtship$text==textCatg)&(dfCourtship$start_miliSec<TL), c('start_miliSec', 'end_miliSec', 'interval_miliSec')]
        
        if (sum(courtshipTextCatg$end_miliSec>TL, na.rm=TRUE)!=0)
        {
            courtshipTextCatg[courtshipTextCatg$end_miliSec>TL, 'end_miliSec'] <- TL
        }
        
        courtshipTextCatg[, 'interval_miliSec'] <- courtshipTextCatg[, 'end_miliSec'] - courtshipTextCatg[, 'start_miliSec']
      
        textCatgTime <- sum(courtshipTextCatg[, 'interval_miliSec'])/TL
        textCatgOccurence <- length(courtshipTextCatg[, 'interval_miliSec'])
      
        sumDf <- data.frame(category = textCatg, total_time = TL, time_percent = textCatgTime, occurence = textCatgOccurence, stringsAsFactors=FALSE)
    }
    
  return(sumDf)
}
 
sumCourtshipCsv <- function(csvfile, listTL=as.integer(c(60000, 120000, 180000, 240000, 300000)), listCatg=c('wing_extension', 'orientation'))
{
    nTL <- length(listTL)
    nCatg <- length(listCatg)  
    fn <- basename(csvfile)
    
    b<-read.csv(file=csvfile, header=T)
    TS <- b[b$text=='latency', 'start_miliSec']
  
    b$start_miliSec <- b$start_miliSec - TS
    b$end_miliSec <- b$end_miliSec - TS
    
    # dfCatg <- data.frame(filename = rep(fn, nCatg*nTL), category = rep("", nCatg*nTL), total_time = rep("", nCatg*nTL), time_percent = rep(NA, nCatg*nTL), occurence = rep(NA, nCatg*nTL), stringsAsFactors=FALSE)
    
    dfCatg <- createCourtshipDf(nCatg*nTL)
    
    for ( iCatg in 1:nCatg) 
        {
        for ( iTL in 1:nTL)
            {
                dfCatg[(iCatg-1)*nTL+iTL, 'filename'] <- fn
                
                tmpDfCatg <- sumDfCourtshipByTL(listTL[iTL], listCatg[iCatg], b)
                dfCatg[(iCatg-1)*nTL+iTL, 'category'] <- tmpDfCatg[, 'category']
                dfCatg[(iCatg-1)*nTL+iTL, 'total_time'] <- tmpDfCatg[, 'total_time']
                dfCatg[(iCatg-1)*nTL+iTL, 'time_percent'] <- tmpDfCatg[, 'time_percent']
                dfCatg[(iCatg-1)*nTL+iTL, 'occurence'] <- tmpDfCatg[, 'occurence']
                
                tmpDfCatg <- NULL
             }
         }
     
  return(dfCatg)
}
 
sumCourtshipDir <- function(csvDir="", outfile=paste(csvDir, "/summary.csv", sep=""), listTL=as.integer(c(60000, 120000, 180000, 240000, 300000)), listCatg=c('wing_extension', 'orientation'))
{
    if (csvDir=="")
    {
        csvDir <- choose.dir()
        outfile=paste(csvDir, "/summary.csv", sep="")
    }
    
    listCsv <- list.files(path=csvDir, pattern="*.srt.csv", full.names=TRUE)
    nFile <- length(listCsv)

    nTL= length(listTL)
    nCatg=length(listCatg)
    
    sumCsv <- createCourtshipDf(nFile*nTL*nCatg)
    for ( iFile in 1:nFile )
    {
        print(listCsv[iFile])
        
        sumCsv[((iFile-1)*nTL*nCatg+1):(iFile*nTL*nCatg), ] <- sumCourtshipCsv(listCsv[iFile], listTL, listCatg)
        
        print("...done.")
    }
    
    write.csv(sumCsv, file=outfile)
    print(paste("written to file", outfile))
    
    return(sumCsv)
}
