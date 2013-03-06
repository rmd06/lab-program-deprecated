# csvFromEvent convert a ".event" plain text file into ".srt.csv" file, with proper data structure
csvFromEvent <- function(ffnInput="", ffnOutput="")
{
    # initializing input file selection
    if (ffnInput=="")
    {
        ffnInput <- choose.files()
        if ( is.na(ffnInput) )
        {
            print("File selection has been canceled.")
            return(NULL)
        }
    }
    
    # check filename integrety
    basefnInput <- basename(ffnInput)
    if (grepl("^[.~]", basefnInput) | !grepl("[.]event$", basefnInput))
    {
        print("Wrong filename. Filename should end with '.event' and not start with '.' or '~'.")
        return(NULL)
    }

    # read into data frame, skipping line 1, which has unknown meaning
    dfRaw <- read.table(ffnInput, stringsAsFactors=FALSE, skip=1)
    
    # add labels to the columns
    dfRaw <- dfRaw[, c(1,3,4)]
    colnames(dfRaw) <- c("noCatg", "start_s", "end_s")
    
    # translate categories 
    dfLabel <- data.frame(text=c("orientation", "wing extension", "tapping", "probiscis extension", "rejection", "attempt copulation", "latency", "latency to copulation", "courtship bout"), noCatg=c(1, 2, 3, 4, 5, 6, 7, 8, 9))
    
    dfCourtship <- merge(dfLabel, dfRaw, by="noCatg")
    
    # transform into mili sec, strip off useless columns
    dfCourtship$start_miliSec <- dfCourtship$start_s * 1000
    dfCourtship$end_miliSec <- dfCourtship$end_s * 1000
    dfCourtship$interval_miliSec <- dfCourtship$end_miliSec - dfCourtship$start_miliSec
    dfCourtship <- dfCourtship[with(dfCourtship, order(start_miliSec)),]
    dfCourtship <- dfCourtship[c("text", "start_miliSec", "end_miliSec", "interval_miliSec")]

    # prepare output file, write to .srt.csv file
    # get bare filename from input(base filename), i.e. strip the last .*
    barefnInput <- sub("[.][^.]*$", "\\1", basefnInput, perl=T)
    
    ffnOutput <- paste("./", barefnInput, ".srt.csv", sep="")
    if (!file.exists(ffnOutput))
    {
        write.csv(dfCourtship, file=ffnOutput, row.names=FALSE)
        print(paste("Output done for", barefnInput))
    } else {
        print("WARNING: Output not saved -- CSV file already exists!")
    }
}

# csvFromEventBatch applies csvFromEvent function recursively to a dir
csvFromEventBatch <- function(indir="", outdir="")
{
    # initializing directory selection
    if (indir=="")
    {
        indir <- choose.dir()
        if ( is.na(indir) )
        {
            print("Directory selection has been canceled.")
            return(NULL)
        }
    }
    
    if (outdir=="")
    {
        outdir <- indir
    }
    
    # reading file list
    flistEventFile <- list.files(path=indir, pattern="*.event", full.names=TRUE)
    if ( identical(flistEventFile, character(0)) ) 
    {
        print("No .event file detected.")
        return(NULL)
    }
    nFile <- length(flistEventFile)
    
    
    for ( iFile in 1:nFile )
    {
        csvFromEvent(ffnInput=flistEventFile[iFile])
    }
}
