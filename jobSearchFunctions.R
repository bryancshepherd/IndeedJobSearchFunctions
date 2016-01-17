# Purpose: Get job titles and summaries of results for Indeed.com searches
# Author: Bryan Shepherd
# Twitter: @bryancshepherd
# Github: bryancshepherd

# install.packages("rvest")
# install.packages("tm")
# install.packages("wordcloud")
library("rvest")
library("tm")
library("wordcloud")
library("ggplot2")


# Function to get a list of job postings for a given term and number of pages
# There are usually 5 sponsored and 10 unsponsored listings per page
# There's an argument for not including sponsored results, as their influence will increase as more pages are parsed
getJobs = function(terms, nPages, includeSponsored=FALSE) {
  
  jobResults = {}
  for (term in terms) {
    allTitles = NULL
    allSummaries = NULL
    for (i in 1:(nPages)) {
      
      # The URL for the first page of results has a different structure than the rest
      if (i == 1) {
        indeed = read_html(paste0("http://www.indeed.com/jobs?q=", term, "&l=")) 
      } else {
        indeed = read_html(paste0("http://www.indeed.com/jobs?q=", term, "&start=", (i*10)-10))
      }
      
      # Grab the sponsored job titles
      sponsoredTitles = indeed %>% html_nodes(".jobtitle") %>% html_attr("title")
      
      # Grab the unsponsored titles
      otherTitles = indeed %>% html_nodes(".jobtitle") %>% html_nodes("a") %>% html_attr("title")
      
      # Grap the job summaries (does not require separate sponsored and unsponsored pulls)
      tempSummaries = indeed %>% html_nodes(".summary") %>% html_text() %>% gsub("\n", "", .)
      
      if (includeSponsored == TRUE) {
        # Merge the sponsored and unsponsored titles, attempting to keep the order
        sponsoredTitles[4:13] = otherTitles
        tempTitles = sponsoredTitles
        
      } else {
        tempTitles = otherTitles
        tempSummaries = tempSummaries[4:13]
      }
      
      # Keep a running vector of the titles
      allTitles = append(allTitles, tempTitles)
      
      # All of the summaries (unsponsored and sponsored) can be pulled at once.
      allSummaries = append(allSummaries, tempSummaries)
      
    }
    jobResults[[term]] = list(Titles = allTitles, Summaries = allSummaries)
  }
  return(jobResults)
}


# Collapse all of the terms into a large list and remove stopwords
cleanJobData = function(jobDataList) {
  
  cleanedJobsList = {}
  
  for (i in 1:length(jobDataList)) {
    
    for (j in 1:length(jobDataList[[i]])) {
      
      # Break up the indicidual vectors and combine them into one large list of words
      tempTermList = strsplit(paste(tolower(jobDataList[[i]][[j]]), collapse=" "), "\\W+", perl = TRUE)
      
      # Remove common stopwords
      tempTermList = tempTermList[[1]][!(tempTermList[[1]] %in% stopwords("en"))]
      
      cleanedJobsList[[names(jobDataList)[i]]][[names(jobDataList[[i]])[j]]] = tempTermList
    }
  }
  return(cleanedJobsList)
}

# Create ordered word frequency tables 
createWordTables = function (jobData) {
  
  wordTables = {}
  
  for (i in 1:length(jobData)) {
    
    for (j in 1:length(jobData[[i]])) {
      
      tempTermTable = as.data.frame(table(jobData[[i]][[j]], useNA = "always"), stringsAsFactors = FALSE)
      tempTermTable = tempTermTable[order(tempTermTable$Freq, decreasing=TRUE),]
      wordTables[[names(jobData)[i]]][[names(jobData[[i]])[j]]] = tempTermTable     
      
    }
  }
  
  return(wordTables)
}

# Take the output from the wordTables function and create a flat file
createFlatFile = function(wordTables) {
  
  for (i in 1:length(wordTables)) {
    for (j in 1:length(wordTables[[i]])) {
      if (exists('tempFlatFile')) {
        tempFlatFile = rbind(tempFlatFile, data.frame(searchTerm = names(wordTables)[i], 
                                                      resultType = names(wordTables[[i]])[j], 
                                                      resultTerms = wordTables[[i]][[j]][[1]], 
                                                      Freq = wordTables[[i]][[j]][[2]],
                                                      Percent = (wordTables[[i]][[j]][[2]]/sum(wordTables[[i]][[j]][[2]]))*100,
                                                      stringsAsFactors = FALSE))
        
      } else {
        tempFlatFile = data.frame(searchTerm = names(wordTables)[i], 
                              resultType = names(wordTables[[i]])[j], 
                              resultTerms = wordTables[[i]][[j]][[1]], 
                              Freq = wordTables[[i]][[j]][[2]], 
                              Percent = (wordTables[[i]][[j]][[2]]/sum(wordTables[[i]][[j]][[2]]))*100,
                              stringsAsFactors = FALSE)
      }  
    }
  }
  
  return(tempFlatFile)
}


