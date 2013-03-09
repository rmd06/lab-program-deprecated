## reads in and parse .srt subtitle to a data frame

lines <- readLines("testdata4.srt")

# append at the end an "empty line" to compensate for those not having one already
lines <- c(lines, "")

idTimeLines <- grep("^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]", lines)
idEmptyLines <- grep("^$", lines)

# one time line correspond to one subtitle
nSubtitles <- length(idTimeLines)

# initiate subtitle data holder, a data frame
dfSubtitles <- data.frame(text = rep("", nSubtitles), start_miliSec = rep(NA, nSubtitles), end_miliSec = rep(NA, nSubtitles), stringsAsFactors=FALSE)

for (iSubtitle in nSubtitles)
{
    # get the start and end time
    thisTimeLine <- lines[idTimeLines[iSubtitle]]
    mixedTime <- unlist(strsplit(thisTimeLine, " --> "))
    
    dfSubtitles[iSubtitle, "start_miliSec"] <- msFromSrtTime(mixedTime[1])
    dfSubtitles[iSubtitle, "end_miliSec"] <- msFromSrtTime(mixedTime[2])
    
    # get the text, i.e. from the next line to just before the first empty line
    idTextStartLine <- idTimeLines[iSubtitle] + 1
    idTextEndLine <- min(idEmptyLines[idEmptyLines > idTimeLines[iSubtitle]]) - 1
    if (idTextStartLine == idTextEndLine)
    {
        dfSubtitles[iSubtitle, "text"] <- lines[idTextStartLine]
    } else if (idTextStartLine < idTextEndLine) {
        dfSubtitles[iSubtitle, "text"] <- paste(lines[(idTextStartLine:idTextEndLine)],sep="",collapse="\n")
    }
    
}

msFromSrtTime <- function(srtTime = "")
{
    miliSec <- NULL
    if (grepl("^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]$", srtTime))
    {
        timeVector <- unlist(strsplit(srtTime, "[:,]"))
        miliSec <- as.integer(timeVector[4]) + 
                   as.integer(timeVector[3])*1000 + 
                   as.integer(timeVector[2])*60*1000 +
                   as.integer(timeVector[1])*60*60*1000
    }
    return miliSec
}
