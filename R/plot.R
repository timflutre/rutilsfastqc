##' Plot FastQC
##'
##' Creates a bar plot with the number of sequences per entry in a set of zip archives generated by FastQC.
##' To be used after extractFastqcNreads().
##' @param x return value from extractFastqcNreads()
##' @param main an overall title for the plot
##' @param cex numeric character expansion factor for x-axis labels
##' @return nothing
##' @author Timothee Flutre [cre,aut]
##' @export
plotFastqcNreads <- function(x, main="", cex=1){
  stopifnot(is.vector(x), is.numeric(x), ! is.null(names(x)))
  par(mar=c(10, 7, 4, 1))
  bp <- barplot(sort(x), xaxt="n", xlab="", ylab="Number of sequences",
                main=main)
  axis(1, at=bp, labels=FALSE)
  text(bp, par("usr")[3], srt=45, adj=1.1, labels=names(sort(x)),
       xpd=TRUE, cex=cex)
}

##' Plot FastQC
##'
##' Plot the number, or percentage, of sequences per quality score with one curve per dataset.
##' To be used after extractFastqcQuals().
##' @param qual return value from extractFastqcQuals()
##' @param perc value of perc used when qual was generated by extractFastqcQuals()
##' @param ylim left and right limits of the y-axis (will be min and max of qual by default)
##' @param max.datasets.per.plot max number of datasets on the same plot
##' @param main an overall title for the plot
##' @param legend.x x coordinate to position the legend (no legend if NULL)
##' @param legend.y y coordinate to position the legend
##' @param legend.cex numeric character expansion factor for legend labels
##' @param add.2nd.yaxis add a 2nd y-axis on the right side of the plot
##' @return nothing
##' @author Timothee Flutre [cre,aut], Nicolas Rode [ctb]
##' @export
plotFastqcNbseqQual <- function(qual,
                                perc=FALSE,
                                ylim=NULL,
                                max.datasets.per.plot=25,
                                main="Quality control",
                                legend.x="topleft",
                                legend.y=NULL,
                                legend.cex=1,
                                add.2nd.yaxis=TRUE){
  stopifnot(is.matrix(qual),
            ! is.null(rownames(qual)))

  xlab <- "Phred quality"
  ylab <- "Number of sequences"
  if(perc)
    ylab <- "Percentage of sequences"

  ## determine the lowest and highest qualities for the x-axis
  lowest.qual <- NA
  for(j in 1:ncol(qual)){
    if(any(! is.na(qual[,j]))){
      lowest.qual <- j
      break
    }
  }
  highest.qual <- NA
  for(j in ncol(qual):1){
    if(any(! is.na(qual[,j]))){
      highest.qual <- j
      break
    }
  }
  xlim <- c(lowest.qual, highest.qual)

  ## determine the lowest and highest counts for the y-axis
  lowest.count <- min(qual[,lowest.qual])
  highest.count <- max(qual[,lowest.qual])
  for(j in lowest.qual:highest.qual){
    lowest.count <- min(lowest.count, qual[,j], na.rm=TRUE)
    highest.count <- max(highest.count, qual[,j], na.rm=TRUE)
  }
  if(is.null(ylim))
    ylim <- c(lowest.count, highest.count)

  ## plot the data
  if(nrow(qual) <= max.datasets.per.plot){ # show all datasets on a single plot
    plot(x=0, y=0, xlim=xlim, ylim=ylim,
         xlab=xlab, ylab=ylab, main=main,
         type="n", bty="n")
    for(i in 1:nrow(qual)){
      idx <- which(! is.na(qual[i,]))
      points(x=idx, y=qual[i, idx], col=i, pch=(1:25)[i %% 25], type="b")
    }
    if(add.2nd.yaxis)
      axis(side=4)
    if(! is.null(legend.x))
      legend(x=legend.x, y=legend.y, cex=legend.cex, bty="n",
             legend=rownames(qual),
             col=1:nrow(qual),
             pch=1:min(25, nrow(qual)))
  } else{ # show all datasets on several plots
    nb.plots <- ceiling(nrow(qual) / max.datasets.per.plot)
    for(plot.id in 1:nb.plots){
      plot(x=0, y=0, xlim=xlim, ylim=ylim,
           xlab=xlab, ylab=ylab, main=main,
           type="n", bty="n")
      subset.idx.rows <- ((plot.id-1)*max.datasets.per.plot+1):(plot.id*max.datasets.per.plot)
      subset.idx.rows <- subset.idx.rows[subset.idx.rows %in% 1:nrow(qual)]
      for(i in subset.idx.rows){
        j <- i - (plot.id-1) * max.datasets.per.plot
        idx <- which(! is.na(qual[i,]))
        points(x=idx, y=qual[i, idx], col=j, pch=(1:25)[j %% 25], type="b")
      }
      if(add.2nd.yaxis)
        axis(side=4)
      if(! is.null(legend.x))
        legend(x=legend.x, y=legend.y, cex=legend.cex, bty="n",
               legend=rownames(qual)[subset.idx.rows],
               col=(1:max.datasets.per.plot)[1:length(subset.idx.rows)],
               pch=1:min(25, max.datasets.per.plot)[1:length(subset.idx.rows)])
    }
  }
}

##' Plot FastQC
##'
##' Plot a variable content (adapter or N) as percentage along the sequences per entry in a set of zip archives generated by FastQC.
##' To be used after extractFastqcAdpContents() or extractFastqcBaseNs().
##' @param content return value from extractFastqcAdpContents() or extractFastqcBaseNs()
##' @param max.datasets.per.plot max number of datasets on the same plot
##' @param lowest.perc lowest percentage of content for the y-axis
##' @param highest.perc highest percentage of content for the y-axis
##' @param ylab a title for the y axis
##' @param main an overall title for the plot
##' @param legend.x x coordinate to position the legend (no legend if NULL)
##' @param legend.y y coordinate to position the legend
##' @param legend.cex numeric character expansion factor for legend labels
##' @param add.2nd.yaxis add a 2nd y-axis on the right side of the plot
##' @return nothing
##' @author Timothee Flutre [cre,aut], Nicolas Rode [ctb]
##' @export
plotFastqcContent <- function(content,
                              max.datasets.per.plot=25,
                              lowest.perc=NULL,
                              highest.perc=NULL,
                              ylab="Content (%)",
                              main="Quality control",
                              legend.x="topleft",
                              legend.y=NULL,
                              legend.cex=1,
                              add.2nd.yaxis=TRUE){
  stopifnot(is.matrix(content),
            ! is.null(rownames(content)),
            ! is.null(colnames(content)))

  xlab <- "Positions (bp)"

  ## determine the range of positions for the x-axis
  positions <- sapply(strsplit(colnames(content), "-"),
                      function(x){as.numeric(x[1])})
  xlim <- c(positions[1], positions[length(positions)])

  ## determine the lowest and highest content percentage for the y-axis
  if(is.null(lowest.perc))
    lowest.perc <- min(c(content), na.rm=TRUE)
  if(is.null(highest.perc))
    highest.perc <- max(c(content), na.rm=TRUE)
  ylim <- c(lowest.perc, highest.perc)

  ## plot the data
  if(nrow(content) <= max.datasets.per.plot){ # show all datasets on a single plot
    plot(x=0, y=0, xlim=xlim, ylim=ylim,
         xlab=xlab, ylab=ylab, main=main,
         type="n", bty="n")
    for(i in 1:nrow(content)){
      idx <- which(! is.na(content[i,]))
      points(x=positions[idx], y=content[i, idx],
             col=i, pch=(1:25)[i %% 25], type="b")
    }
    if(add.2nd.yaxis)
      axis(side=4)
    if(! is.null(legend.x))
      legend(x=legend.x, y=legend.y, cex=legend.cex, bty="n",
             legend=rownames(content),
             col=1:nrow(content),
             pch=1:min(25, nrow(content)))
  } else{ # show all datasets on several plots
    nb.plots <- ceiling(nrow(content) / max.datasets.per.plot)
    for(plot.id in 1:nb.plots){
      plot(x=0, y=0, xlim=xlim, ylim=ylim,
           xlab=xlab, ylab=ylab, main=main,
           type="n", bty="n")
      subset.idx.rows <- ((plot.id-1)*max.datasets.per.plot+1):(plot.id*max.datasets.per.plot)
      subset.idx.rows <- subset.idx.rows[subset.idx.rows %in% 1:nrow(content)]
      for(i in subset.idx.rows){
        j <- i - (plot.id-1) * max.datasets.per.plot
        points(x=positions, y=content[i,], col=j, pch=(1:25)[j %% 25], type="b")
      }
      if(add.2nd.yaxis)
        axis(side=4)
      if(! is.null(legend.x))
        legend(x=legend.x, y=legend.y, cex=legend.cex, bty="n",
               legend=rownames(content)[subset.idx.rows],
               col=(1:max.datasets.per.plot)[1:length(subset.idx.rows)],
               pch=1:min(25, max.datasets.per.plot)[1:length(subset.idx.rows)])
    }
  }
}

##' Plot FastQC
##'
##' Plot the distribution of sequence lengths per entry in a set of zip archives generated by FastQC.
##' To be used after extractFastqcSeqLengths().
##' @param seq.length return value from extractFastqcSeqLengths()
##' @param max.datasets.per.plot max number of datasets on the same plot
##' @param lowest.len lowest sequence length for the y-axis
##' @param highest.len highest sequence length for the y-axis
##' @param main an overall title for the plot
##' @param ylab label for the y-axis
##' @param legend.x x coordinate to position the legend (no legend if NULL)
##' @param legend.y y coordinate to position the legend
##' @param legend.cex numeric character expansion factor for legend labels
##' @param add.2nd.yaxis add a 2nd y-axis on the right side of the plot
##' @return nothing
##' @author Timothee Flutre [cre,aut], Nicolas Rode [ctb]
##' @export
plotFastqcSeqLengths <- function(seq.length,
                                 max.datasets.per.plot=25,
                                 lowest.len=NULL,
                                 highest.len=NULL,
                                 main="Quality control",
                                 ylab="Number of sequences",
                                 legend.x="topleft",
                                 legend.y=NULL,
                                 legend.cex=1,
                                 add.2nd.yaxis=TRUE){
  stopifnot(is.matrix(seq.length),
            ! is.null(rownames(seq.length)),
            ! is.null(colnames(seq.length)))

  xlab <- "Sequence lengths (bp)"

  ## determine the range of lengths for the x-axis
  lengths <- sapply(strsplit(colnames(seq.length), "-"),
                    function(x){as.numeric(x[1])})
  xlim <- c(lengths[1], lengths[length(lengths)])

  ## determine the lowest and highest counts of seq lengths for the y-axis
  if(is.null(lowest.len)){
    lowest.len <- min(c(seq.length))
    if(is.infinite(lowest.len))
      stop("did you give log10(seq.length)? maybe use also lowest.len=0")
  }
  if(is.null(highest.len))
    highest.len <- max(c(seq.length))
  ylim <- c(lowest.len, highest.len)

  ## plot the data
  if(nrow(seq.length) <= max.datasets.per.plot){ # show all datasets on a single plot
    plot(x=0, y=0, xlim=xlim, ylim=ylim,
         xlab=xlab, ylab=ylab, main=main,
         type="n", bty="n")
    for(i in 1:nrow(seq.length))
      points(x=lengths, y=seq.length[i,], col=i, pch=(1:25)[i %% 25], type="b")
    if(add.2nd.yaxis)
      axis(side=4)
    if(! is.null(legend.x))
      legend(x=legend.x, y=legend.y, cex=legend.cex, bty="n",
             legend=rownames(seq.length),
             col=1:nrow(seq.length),
             pch=1:min(25, nrow(seq.length)))
  } else{ # show all datasets on several plots
    nb.plots <- ceiling(nrow(seq.length) / max.datasets.per.plot)
    for(plot.id in 1:nb.plots){
      plot(x=0, y=0, xlim=xlim, ylim=ylim,
           xlab=xlab, ylab=ylab, main=main,
           type="n", bty="n")
      subset.idx.rows <- ((plot.id-1)*max.datasets.per.plot+1):(plot.id*max.datasets.per.plot)
      subset.idx.rows <- subset.idx.rows[subset.idx.rows %in% 1:nrow(seq.length)]
      for(i in subset.idx.rows){
        j <- i - (plot.id-1) * max.datasets.per.plot
        points(x=lengths, y=seq.length[i,], col=j, pch=(1:25)[j %% 25], type="b")
      }
      if(add.2nd.yaxis)
        axis(side=4)
      if(! is.null(legend.x))
        legend(x=legend.x, y=legend.y, cex=legend.cex, bty="n",
               legend=rownames(seq.length)[subset.idx.rows],
               col=(1:max.datasets.per.plot)[1:length(subset.idx.rows)],
               pch=1:min(25, max.datasets.per.plot)[1:length(subset.idx.rows)])
    }
  }
}
