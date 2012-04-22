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
    # sumCourtshipCsv will analyze a .srt.csv file for a summary of each provided category by each provided time length 
    
    nTL <- length(listTL)
    nCatg <- length(listCatg)  
    fn <- basename(csvfile)
    
    b<-read.csv(file=csvfile, header=T)
    
    # get start time
    TS <- b[b$text=='latency', 'start_miliSec']
    # re-calibrate time using start time
    b$start_miliSec <- b$start_miliSec - TS
    b$end_miliSec <- b$end_miliSec - TS
    
    # initialize summary data frame
    # dfCatg <- data.frame(filename = rep(fn, nCatg*nTL), category = rep("", nCatg*nTL), total_time = rep("", nCatg*nTL), time_percent = rep(NA, nCatg*nTL), occurence = rep(NA, nCatg*nTL), stringsAsFactors=FALSE)
    dfCatg <- createCourtshipDf(nCatg*nTL)
    
    # iterate through each time lenght and each category, putting info. one by one
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

sumCourtshipDir <- function(csvDir="", out=TRUE, outfile=paste(csvDir, "/summary.csv", sep=""), listTL=as.integer(c(60000, 120000, 180000, 240000, 300000)), listCatg=c('wing_extension', 'orientation'), na.zero=FALSE)
{
    # sumCourtshipDir will calculate and return a summary of analysed srt files (the csvs)
    # it also output csv summary files
    
    # initializing directory selection
    if (csvDir=="")
    {
        csvDir <- choose.dir()
        if ( is.na(csvDir) ) 
        {
            print("Directory selection has been canceled.")
            return(NULL)
        }
        outfile <- paste(csvDir, "/summary.csv", sep="")
    }
    
    # reading file list
    listCsv <- list.files(path=csvDir, pattern="*.srt.csv", full.names=TRUE)
    if ( identical(listCsv, character(0)) ) 
    {
        print("No .srt.csv file detected.")
        return(NULL)
    }
    nFile <- length(listCsv)

    # preparing Time Length list (a vector of time points) and Category list (a vector of behaviorial tags)
    nTL= length(listTL)
    nCatg=length(listCatg)
    
    # initialize and prepare the output data frame
    sumCsv <- createCourtshipDf(nFile*nTL*nCatg)
    
    # iterate through each csv file, calculating each summary, then inject them to blocks of previously prepared data frame
    for ( iFile in 1:nFile )
    {
        print(paste("Begin processing", listCsv[iFile], "..."))
        
        sumCsv[((iFile-1)*nTL*nCatg+1):(iFile*nTL*nCatg), ] <- sumCourtshipCsv(listCsv[iFile], listTL, listCatg)
        
        print("...done.")
    }
    
    # Copy a NA=0 version
    sumCsvNoNA <- sumCsv
    sumCsvNoNA[is.na(sumCsvNoNA$time_percent), 'time_percent'] <- 0L
    sumCsvNoNA[is.na(sumCsvNoNA$occurence), 'occurence'] <- 0L
    
    # save to files
    if (out)
    {
        outfileNoNA <- paste(csvDir, "/summary_noNA.csv", sep="")
        write.csv(sumCsv, file=outfile, row.names=FALSE)
        write.csv(sumCsvNoNA, file=outfileNoNA, row.names=FALSE)
        print(paste("written to file", outfile, "and", outfileNoNA))
    }
    
    if (na.zero)
        print("All NAs converted to 0.")
        return(sumCsvNoNA)
    else
        return(sumCsv)
}

sumCatgForAll <- function(dfSumCourtship)
{
    # sumCatgForAll will do summary statistics on each category for each time length
    # NOTE: Treat NA cautiously. This summary is based on ?mean(..., na.rm=FALSE)
    
    # first, get all the categories and time lengths
    factoredSum <- dfSumCourtship
    # factoredSum$filename <- factor(factoredSum$filename)
    factoredSum$category <- factor(factoredSum$category)
    factoredSum$total_time <- factor(factoredSum$total_time)
    
    listCatg <- levels(factoredSum$category)
    nCatg <- length(listCatg)
    
    # sort time length for a bit nicer-looking output
    listTL <- as.character(sort(as.integer(levels(factoredSum$total_time))))
    nTL <- length(listTL)
    
    # initialize data frame for summary, structure as follows
    # category  total_time  mean_time_percent  sem_time_percent  mean_occurence sem_occurence
    nRow <- nCatg*nTL
    sumDf <- data.frame(category=rep("",nRow), total_time=rep("",nRow), mean_time_percent=rep(NA, nRow), sem_time_percent=rep(NA,nRow), mean_occurence=rep(NA,nRow), sem_occurence=rep(NA,nRow), stringsAsFactors=FALSE)
    
    # inject the summaries one by one
    for ( iCatg in 1:nCatg)
    {
        for ( iTL in 1:nTL )
        {
            sumDf[(iCatg-1)*nTL+iTL, 'category'] <- listCatg[iCatg]
            sumDf[(iCatg-1)*nTL+iTL, 'total_time'] <- listTL[iTL]
            
            tmpDfSum <- dfSumCourtship[(dfSumCourtship$category==listCatg[iCatg])&(dfSumCourtship$total_time==listTL[iTL]), ]
            
            tmpTimePercent <- tmpDfSum$time_percent
            sumDf[(iCatg-1)*nTL+iTL, 'mean_time_percent'] <- mean(tmpTimePercent)
            sumDf[(iCatg-1)*nTL+iTL, 'sem_time_percent'] <- sd(tmpTimePercent)/sqrt(sum(!is.na(tmpTimePercent)))
            
            tmpOccurence <- tmpDfSum$occurence
            sumDf[(iCatg-1)*nTL+iTL, 'mean_occurence'] <- mean(tmpOccurence)
            sumDf[(iCatg-1)*nTL+iTL, 'sem_occurence'] <- sd(tmpOccurence)/sqrt(sum(!is.na(tmpOccurence)))
            
            tmpDfSum <- NULL
            tmpTimePercent <- NULL
            tmpOccurence <- NULL
        }
    }
    
    return(sumDf)
}

readCourtshipLatency <- function(latencyText="latency", csvDir="", out=TRUE, outfile=paste(csvDir, "/", latencyText, ".csv", sep=""))
{
    # initializing directory selection
    if (csvDir=="")
    {
        csvDir <- choose.dir()
        if ( is.na(csvDir) )
        {
            print("Directory selection has been canceled.")
            return(NULL)
        }
        outfile <- paste(csvDir, "/", latencyText, ".csv", sep="")
    }
    
    # reading file list
    listCsv <- list.files(path=csvDir, pattern="*.srt.csv", full.names=TRUE)
    if ( identical(listCsv, character(0)) ) 
    {
        print("No .srt.csv file detected.")
        return(NULL)
    }
    nFile <- length(listCsv)
    
    latencyDf <- data.frame(filename=rep("", nFile), latency=rep(NA, nFile), stringsAsFactors=FALSE)
    colnames(latencyDf)[2] <- latencyText
    
    
    for ( iFile in 1:nFile )
    {
        print(paste("Reading", listCsv[iFile], "..."))
        
        tmpDf <- read.csv(file=listCsv[iFile], header=TRUE)
        tmpDf <- tmpDf[tmpDf$text==latencyText, c('start_miliSec', 'end_miliSec')]
        
        latencyDf[iFile, 'filename'] <- basename(listCsv[iFile])
        
        if ( (!is.null(tmpDf))&(nrow(tmpDf)==as.integer(1)) )
        {
            latencyDf[iFile, latencyText] <- tmpDf[, 'end_miliSec'] - tmpDf[, 'start_miliSec']
        }
        
        print("...done.")
    }
    
    if (out)
    {
        write.csv(latencyDf, file=outfile, row.names=FALSE)
        print(paste("Written results to file", outfile))
    }
    
    return(latencyDf)
    
}

unblindCourtshipCsv <- function(summaryCsv="", unblindCsv="")
{
    # initializing file selection
    if (summaryCsv=="")
    {
        summaryCsv <- choose.files(caption="Select SUMMARY csv file")
        if ( identical(summaryCsv, character(0)) ) 
        {
            print("File selection has been canceled.")
            return(NULL)
        }
    }
    
    if (unblindCsv=="")
    {
        unblindCsv <- choose.files(caption="Select UNBLIND csv file")
        if ( identical(unblindCsv, character(0)) ) 
        {
            print("File selection has been canceled.")
            return(NULL)
        }
    }
    
    sumDf <- read.csv(file=summaryCsv, stringsAsFactors=F)
    unblind <- read.csv(file=unblindCsv, stringsAsFactors=F)
    
    unblind_data <- merge(sumDf, unblind, by='filename')
    if ('total_time' %in% colnames(unblind_data) )
    {
        unblind_data <- transform(unblind_data, total_time = as.character(as.integer(total_time)))
    }
#    unblind_data <- transform(unblind_data, total_time = as.character(total_time))
    
    return(unblind_data)
}

sumForOneCatg <- function(dfSumCourtship, catg='courtship')
{
    # sumForOneCatg will do summary statistics on each experiment group for each time length
    # NOTE: Treat NA cautiously. This summary is based on ?mean(..., na.rm=FALSE)
    
    # first, get all the exp. groups and time lengths
    factoredSum <- dfSumCourtship[dfSumCourtship$category==catg,]
    # factoredSum$filename <- factor(factoredSum$filename)
    factoredSum$exp_group <- factor(factoredSum$exp_group)
    factoredSum$total_time <- factor(factoredSum$total_time)
    
    listGroup <- levels(factoredSum$exp_group)
    nGroup <- length(listGroup)
    
    # sort time length for a bit nicer-looking output
    listTL <- as.character(sort(as.integer(levels(factoredSum$total_time))))
    nTL <- length(listTL)
    
    # initialize data frame for summary, structure as follows
    # exp_group  total_time  mean_time_percent  sem_time_percent  mean_occurence sem_occurence
    nRow <- nGroup*nTL
    sumDf <- data.frame(exp_group=rep("",nRow), total_time=rep("",nRow), mean_time_percent=rep(NA, nRow), sem_time_percent=rep(NA,nRow), mean_occurence=rep(NA,nRow), sem_occurence=rep(NA, nRow), stringsAsFactors=FALSE)
    
    # inject the summaries one by one
    for ( iGroup in 1:nGroup)
    {
        for ( iTL in 1:nTL )
        {
            sumDf[(iGroup-1)*nTL+iTL, 'exp_group'] <- listGroup[iGroup]
            sumDf[(iGroup-1)*nTL+iTL, 'total_time'] <- listTL[iTL]
            
            tmpDfSum <- dfSumCourtship[(dfSumCourtship$exp_group==listGroup[iGroup])&(dfSumCourtship$total_time==listTL[iTL]), ]
            
            tmpTimePercent <- tmpDfSum$time_percent
            sumDf[(iGroup-1)*nTL+iTL, 'mean_time_percent'] <- mean(tmpTimePercent)
            sumDf[(iGroup-1)*nTL+iTL, 'sem_time_percent'] <- sd(tmpTimePercent)/sqrt(sum(!is.na(tmpTimePercent)))
            
            tmpOccurence <- tmpDfSum$occurence
            sumDf[(iGroup-1)*nTL+iTL, 'mean_occurence'] <- mean(tmpOccurence)
            sumDf[(iGroup-1)*nTL+iTL, 'sem_occurence'] <- sd(tmpOccurence)/sqrt(sum(!is.na(tmpOccurence)))
            
            tmpDfSum <- NULL
            tmpTimePercent <- NULL
            tmpOccurence <- NULL
        }
    }
    
    return(sumDf)
}

sumAndUnblindCourtshipDir <- function(csvDir="", out=FALSE, listCatg=c('courtship'), listTL=as.integer(c(60000, 120000, 180000, 240000, 300000)), na.zero=TRUE)
{
    # sumAndUnblindCourtshipDir will summarize all the *.srt.csv files, and add exp_group info into all the lines in summary(unblinding). 
    
    # initializing directory selection
    if (csvDir=="")
    {
        csvDir <- choose.dir()
        if ( is.na(csvDir) )
        {
            print("Directory selection has been canceled.")
            return(NULL)
        }
    }

    unblindCsv <- paste(csvDir, "/unblind.csv", sep="")
    
    sumDf <- sumCourtshipDir(csvDir=csvDir, out=out, listCatg=listCatg, listTL=listTL, na.zero=na.zero)
    unblind <- read.csv(file=unblindCsv, stringsAsFactors=F)
    
    print("Adding experimental group info (Unblinding)...")
    unblind_data <- merge(sumDf, unblind, by='filename')
    if ('total_time' %in% colnames(unblind_data) )
    {
        unblind_data <- transform(unblind_data, total_time = as.integer(total_time))
    }
    
    print("...added.")
    
    if (out)
    {
        outfile <- paste(csvDir, "/unblindedsummary.csv", sep="")
        write.csv(unblind_data, file=outfile, row.names=FALSE)
        print(paste("Written results to file", outfile))
    }
    
    return(unblind_data)
}

readAndUnblindCourtshipLatency <- function(csvDir="", out=FALSE, latencyText="latency", no.na=FALSE, na.to=0L)
{
    # readAndUnblindCourtshipLatency will summarize all the *.srt.csv files, and add exp_group info into all the lines in summary(unblinding). 
    
    # initializing directory selection
    if (csvDir=="")
    {
        csvDir <- choose.dir()
        if ( is.na(csvDir) )
        {
            print("Directory selection has been canceled.")
            return(NULL)
        }
    }

    unblindCsv <- paste(csvDir, "/unblind.csv", sep="")
    
    latencyDf <- readCourtshipLatency(csvDir=csvDir, latencyText=latencyText, out=FALSE)
    unblind <- read.csv(file=unblindCsv, stringsAsFactors=F)
    
    print("Adding experimental group info (Unblinding)...")
    unblind_data <- merge(latencyDf, unblind, by='filename')
    
    print("...added.")
    
    if (no.na && is.numeric(na.to) && (length(na.to)==1) )
    {
        print("Converting NAs...")
        noNA <- unblind_data
        noNA[is.na(noNA[colnames(noNA)==latencyText]), latencyText] <- na.to
        print(paste("...all NAs are now converted to", na.to))
        return(noNA)
    }
    
    if (out)
    {
        if ( no.na && is.numeric(na.to) && (length(na.to)==1) )
        {
            noNAfile <- paste(csvDir, "/unblinded", latencyText, "noNA.csv", sep="")
            write.csv(noNA, file=noNAfile, row.names=FALSE)
            print(paste("Written results to file", noNAfile))
        }
        else
        {
            outfile <- paste(csvDir, "/unblinded", latencyText, ".csv", sep="")
            write.csv(unblind_data, file=outfile, row.names=FALSE)
            print(paste("Written results to file", outfile))
        }
    }
    
    return(unblind_data)
}