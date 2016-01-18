---
layout: post
title: "R Helper Functions for Indeed.com Searches"
author: bryan
date: 2016-01-18
comment: true
categories: [Articles]
published: true
noindex: false
output:
  md_document:
    variant: markdown_github
---

If you need job listing data, Indeed.com is a natural choice. It is one of the most popular job sites on the Internet and has listings from a wide range of industries. Indeed has APIs for things like affiliate widgets, but nothing that allows one to directly download a list of job results. Fortunately, the URL structure and site layout is fairly straighforward and lends itself to webscraping.

The following functions wrap [rvest](https://cran.r-project.org/web/packages/rvest/index.html) capabilites for use on Indeed.com. A write up of the project that required these, including more detailed examples, will follow at some point. For now, I think the use of these functions is straightforward enough without much documentation. If not, email me or ask questions in the comments.

[GitHub repo is here](https://github.com/bryancshepherd/IndeedJobSearchFunctions.git). <br> <br>

#### Get the job results - this may take a couple of minutes

``` r
jobResultsList = getJobs("JavaScript", nPages=10, includeSponsored = FALSE, showProgress = FALSE)
head(jobResultsList[["JavaScript"]][["Titles"]], 5)
```

    ## [1] "Frontend Software Engineer"                        
    ## [2] "Web Developer Front End HTML CSS"                  
    ## [3] "Sr. HTML5/JS Engineer"                             
    ## [4] "Web & Mobile Software Engineer"                    
    ## [5] "Software Engineer, JavaScript - Mobile - SNEI - SF"

``` r
head(jobResultsList[["JavaScript"]][["Summaries"]], 5)
```

    ## [1] "Expert in JavaScript, D3, AngularJS. The name ThousandEyes was born from two big ideas:...."                                                                       
    ## [2] "CSS, HTML, JavaScript:. Knowledge of JavaScript is handy. Web Developer Front End Programming...."                                                                 
    ## [3] "Hand coded JavaScript. Javascript, HTML 5, CSS 3, Angular. Xavient Information System is seeking a HTML/Javascript Developer with at least 3 year of expert..."    
    ## [4] "At least 1 year experience in applying knowledge of Javascript framework. Java, JSP, Servlets, Javascript Frameworks, HTML, Cascading Style Sheets (CSS),..."      
    ## [5] "Skilled JavaScript, HTML/CSS developer. Software Engineer, JavaScript - Mobile - SNEI - SF. 2+ years of single page web application development experience with..."

<br>

#### Collapse all of the terms into a large list and remove stopwords

``` r
cleanedJobData = cleanJobData(jobResultsList)
head(cleanedJobData[["JavaScript"]][["Titles"]], 5)
```

    ## [1] "frontend"  "software"  "engineer"  "web"       "developer"

``` r
head(cleanedJobData[["JavaScript"]][["Summaries"]], 5)
```

    ## [1] "expert"     "javascript" "d3"         "angularjs"  "name"

<br>

#### Create ordered wordlists for titles and descriptions

``` r
orderedTables = createWordTables(cleanedJobData)
head(orderedTables[["JavaScript"]][["Titles"]], 5)
```

    ##         Var1 Freq
    ## 27 developer   56
    ## 34  engineer   35
    ## 81       web   34
    ## 33       end   30
    ## 37     front   29

``` r
head(orderedTables[["JavaScript"]][["Summaries"]], 5)
```

    ##           Var1 Freq
    ## 264 javascript  129
    ## 107        css   45
    ## 230       html   43
    ## 538        web   41
    ## 173 experience   39

<br>

#### Create a flat file from the aggregated data for easier manipulation and plotting

``` r
flatFile = createFlatFile(orderedTables)
head(flatFile, 5)
```

    ##   searchTerm resultType resultTerms Freq   Percent
    ## 1 JavaScript     Titles   developer   56 15.642458
    ## 2 JavaScript     Titles    engineer   35  9.776536
    ## 3 JavaScript     Titles         web   34  9.497207
    ## 4 JavaScript     Titles         end   30  8.379888
    ## 5 JavaScript     Titles       front   29  8.100559
