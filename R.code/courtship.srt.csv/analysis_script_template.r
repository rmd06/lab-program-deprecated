## 2012 Mar
## Analysis of wing extension and courtship bout. 

## Wing extension. 
## 1. wing extension occurence
## 2. wing extension average duration.

# load all the tools
source("e:\\experiment\\courtship.srt.csv\\summaryForCourtship.R")
source("e:\\experiment\\courtship.srt.csv\\helper01.R")
library(ggplot2)

# use convenient method "sumAndUnblindCourtshiopDir"
# to get occurence and total duration
udfWingExtension <- sumAndUnblindCourtshipDir(csvDir='.', listCatg=c("wing extension"), listTL=as.integer(c(300000)), out=FALSE, na.zero=TRUE)

# re-caculate average_duration
udfWingExtension$average_duration_ms <- udfWingExtension$time_percent * udfWingExtension$total_time / udfWingExtension$occurence

# TODO: plot occurance and average duration
# t1 <- summarySE(ua1, measurevar="time_percent", groupvars=c("exp_group","category","total_time"))

# p1<-ggplot(t1, aes(y=time_percent, x=exp_group))
# pd <- position_dodge(.1)
# pp <- p1 + geom_errorbar(aes(ymin=time_percent-se, ymax=time_percent+se), position=pd) + geom_bar()
# pp + opts(axis.title.x = theme_text(face="bold", colour="#990000", size=20), axis.text.x  = theme_text(angle=90, hjust=1.2, size=6))

## Courtship bout

# load all tools
source("e:\\experiment\\courtship.srt.csv\\summaryForCourtship.R")
source("e:\\experiment\\courtship.srt.csv\\helper01.R")
library(ggplot2)

# use convenient method "sumAndUnblindCourtshiopDir"
# to get occurence and total duration in the first 5 min
udfBout <- sumAndUnblindCourtshipDir(csvDir='.', listCatg=c("courtship bout"), listTL=as.integer(c(300000)), out=FALSE, na.zero=TRUE)

# re-caculate average_duration
udfBout$average_duration_ms <- udfBout$time_percent * udfBout$total_time / udfBout$occurence

# TODO: plot 

################
# e:\WGX\data\2012-04-04~2012-04-19

source("e:\\experiment\\R.code\\summaryForCourtship.R")
source("e:\\experiment\\R.code\\helper01.R")
library(ggplot2)

ua1 <- sumAndUnblindCourtshipDir(csvDir='.', listCatg=c('courtship'), listTL=as.integer(c(300000)), out=FALSE, na.zero=TRUE)

t1 <- summarySE(ua1, measurevar="time_percent", groupvars=c("exp_group","category","total_time"))

p1<-ggplot(t1, aes(y=time_percent, x=exp_group))
pd <- position_dodge(.1)
pp <- p1 + geom_errorbar(aes(ymin=time_percent-se, ymax=time_percent+se), position=pd) + geom_bar()
pp + opts(axis.title.x = theme_text(face="bold", colour="#990000", size=20), axis.text.x  = theme_text(angle=90, hjust=1.2, size=6))

## 
source("e:\\experiment\\R.code\\summaryForCourtship.R")
source("e:\\experiment\\R.code\\helper01.R")
library(ggplot2)

ua <- sumAndUnblindCourtshipDir(csvDir='.', listCatg=c('courtship'), listTL=as.integer(c(60000, 120000, 180000, 240000, 300000)), out=FALSE, na.zero=TRUE)

t <- summarySE(ua, measurevar="time_percent", groupvars=c("exp_group","category","total_time"))

p<-ggplot(t, aes(x=total_time, y=time_percent, colour=exp_group))
pd <- position_dodge(.1)
p + geom_errorbar(aes(ymin=time_percent-se, ymax=time_percent+se), position=pd) +
   geom_line(position=pd) +
   geom_point(position=pd)

#####
## latency to copulation
source("e:\\experiment\\R.code\\summaryForCourtship.R")
source("e:\\experiment\\R.code\\helper01.R")
library(ggplot2)

ulc <- readAndUnblindCourtshipLatency(csvDir='.', latencyText="latency to copulation",no.na=T,na.to=300000L)

t2 <- summarySE(ulc, measurevar="latency to copulation", groupvar=c("exp_group"))
colnames(t2)[colnames(t2)=="latency to copulation"] <- "latency_to_copulation"

p2 <- ggplot(t2, aes(x=exp_group, y=latency_to_copulation))
pd <- position_dodge(.1)
pp2 <- p2 + geom_errorbar(aes(ymin=latency_to_copulation-se, ymax=latency_to_copulation+se), position=pd) + geom_bar()
pp2 + opts(axis.title.x = theme_text(face="bold", colour="#990000", size=20), axis.text.x  = theme_text(angle=90, hjust=1, size=10))

# latency
source("e:\\experiment\\R.code\\summaryForCourtship.R")
source("e:\\experiment\\R.code\\helper01.R")
library(ggplot2)

ul <- readAndUnblindCourtshipLatency(csvDir='.', latencyText="latency",no.na=T,na.to=0L)

t3 <- summarySE(ul, measurevar="latency", groupvar=c("exp_group"))

p3 <- ggplot(t3, aes(x=exp_group, y=latency))
pd <- position_dodge(.1)
pp3 <- p3 + geom_errorbar(aes(ymin=latency-se, ymax=latency+se), position=pd) + geom_bar()
pp3 + opts(axis.title.x = theme_text(face="bold", colour="#990000", size=20), axis.text.x  = theme_text(angle=90, hjust=1, size=10))

#####
# Non-cumulative
# smaller bins

source("e:/experiment/courtship.srt.csv/summaryForCourtship.R")
source("e:/experiment/courtship.srt.csv/helper01.R")
library(ggplot2)

binSizeMs <- 5000
nBin <- 20
l <- c((1:nBin)*binSizeMs)

ua0 <- sumAndUnblindCourtshipDir2(csvDir='./', listCatg=c('courtship'), listTL=l, out=FALSE, na.zero=TRUE)

t0 <- summarySE(ua0, measurevar="time_percent", groupvars=c("exp_group","category","total_time"))

# anova
# Tukey's Test
ua0c <- ua0
ua0c$exp_group <- as.factor(ua0$exp_group)

TukeyHSD(aov(time_percent~exp_group,data=ua0c[ua0c$total_time==l[3],]))

TukeyHSD(aov(time_percent~exp_group,data=ua0c[ua0c$total_time==l[2],]))

# plot
pd <- position_dodge(.1)
p0 <- ggplot(data=t0, aes(x=total_time, y=time_percent)) +
    facet_grid(. ~ exp_group) +
    geom_line(position=pd, size=1.15) +
    geom_errorbar(aes(ymin=time_percent-se, ymax=time_percent+se), position=pd, width=0.3*10000) +
    geom_point(position=pd, shape=21, colour="black", size=2.5) +
    scale_fill_manual(values=c("white","black")) +
#    scale_x_continuous(limits=c(0, 330000), breaks=c(60000,120000,180000,240000,300000), labels=c("1 min","2 min","3 min","4 min","5 min")) +
    scale_y_continuous("Non-Cumulative Courtship Index", limits=c(0,1)) +
    theme_bw() +
    opts(
        axis.title.x = theme_blank(),
        axis.title.y = theme_text(size=12, angle=90, vjust=0.3), 
        legend.title = theme_blank(),
        legend.key = theme_blank()
    )
# p0

pd <- position_dodge(.1)
p01 <- ggplot(data=t0, aes(x=total_time, y=time_percent, color=exp_group)) +
    geom_line(position=pd, size=1.15) +
    geom_errorbar(aes(ymin=time_percent-se, ymax=time_percent+se), position=pd, width=0.3*10000) +
    geom_point(position=pd, shape=21, size=2.5) +
#    scale_fill_manual(values=c("white","black")) +
#    scale_x_continuous(limits=c(0, 330000), breaks=c(60000,120000,180000,240000,300000), labels=c("1 min","2 min","3 min","4 min","5 min")) +
    scale_y_continuous("Non-Cumulative Courtship Index", limits=c(-0.05,1)) +
    theme_bw() +
    opts(
        axis.title.x = theme_blank(),
        axis.title.y = theme_text(size=12, angle=90, vjust=0.3), 
        legend.title = theme_blank(),
        legend.key = theme_blank()
    )
p01


