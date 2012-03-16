createCourtshipDf <- function(nRows)
{
    # createCourtshipDf will create an empty data frame for holding courtship summary
    df <- data.frame(filename = rep("", nRows), category = rep("", nRows), total_time = rep("", nRows), time_percent = rep(NA, nRows), occurence = rep(NA, nRows), stringsAsFactors=FALSE)
    
    return(df)
}

sumDfCourtshipByTL <- function(TL, textCatg, dfCourtship)
{
    #  sumDfCourtshipByTL will return summary about the given behavior category and occurence of _A_ given 'category' for _A_ given time length in a courtship data frame

    # if category does not exist, all the summary should be NA
    ckCatg <- dfCourtship$text==textCatg
    if (sum(ckCatg, na.rm=TRUE)==0) 
    {
        sumDf <- data.frame(category = textCatg, total_time = TL, time_percent = NA, occurence = NA, stringsAsFactors=FALSE)
    }
    else
    {
    # if category do exist, calculate interval for the time length provided
    
        # select useful columns for the given category (may well be many rows)
        courtshipTextCatg <- dfCourtship[(dfCourtship$text==textCatg)&(dfCourtship$start_miliSec<TL), c('start_miliSec', 'end_miliSec', 'interval_miliSec')]
        
        # truncate if any 'end' time exceeds the given time length
        if (sum(courtshipTextCatg$end_miliSec>TL, na.rm=TRUE)!=0)
        {
            courtshipTextCatg[courtshipTextCatg$end_miliSec>TL, 'end_miliSec'] <- TL
        }
        
        # re-calculate all the intervals
        courtshipTextCatg[, 'interval_miliSec'] <- courtshipTextCatg[, 'end_miliSec'] - courtshipTextCatg[, 'start_miliSec']
    
        # calculate the fraction of time of this category, in this time length
        textCatgTime <- sum(courtshipTextCatg[, 'interval_miliSec'])/TL
        # calculate the occurence of this behavior category (namely the number of rows)
        textCatgOccurence <- length(courtshipTextCatg[, 'interval_miliSec'])
      
        # re-structure and return the summary
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
 
sumCourtshipDir <- function(csvDir="", out=TRUE, outfile=paste(csvDir, "/summary.csv", sep=""), listTL=as.integer(c(60000, 120000, 180000, 240000, 300000)), listCatg=c('wing_extension', 'orientation'))
{
    # sumCourtshipDir will calculate and return a summary of analysed srt files (the csvs)
    # it also output csv summary files
    
    # initializing directory selection
    if (csvDir=="")
    {
        csvDir <- choose.dir()
        outfile <- paste(csvDir, "/summary.csv", sep="")
    }
    
    # reading file list
    listCsv <- list.files(path=csvDir, pattern="*.srt.csv", full.names=TRUE)
    nFile <- length(listCsv)

    # preparing Time Length list (a vector of time points) and Category list (a vector of behaviorial tags)
    nTL= length(listTL)
    nCatg=length(listCatg)
    
    # initialize and prepare the output data frame
    sumCsv <- createCourtshipDf(nFile*nTL*nCatg)
    
    # iterate through each csv file, calculating each summary, then inject them to blocks of previously prepared data frame
    for ( iFile in 1:nFile )
    {
        print(listCsv[iFile])
        
        sumCsv[((iFile-1)*nTL*nCatg+1):(iFile*nTL*nCatg), ] <- sumCourtshipCsv(listCsv[iFile], listTL, listCatg)
        
        print("...done.")
    }
    
    # Copy a NA=0 version    
    sumCsvNoNA <- sumCsv
    sumCsvNoNA[is.na(sumCsvNoNA$time_percent), 'time_percent'] <- 0
    sumCsvNoNA[is.na(sumCsvNoNA$occurence), 'occurence'] <- 0
    
    # save to files
    if (out)
    {
        outfileNoNA <- paste(csvDir, "/summary_noNA.csv", sep="")
        write.csv(sumCsv, file=outfile)
        write.csv(sumCsvNoNA, file=outfileNoNA)
        print(paste("written to file", outfile, "and", outfileNoNA))
    }
    
    return(sumCsv)
}

sumCatgForAll <- function(catg, dfSumCourtship)
{

}
