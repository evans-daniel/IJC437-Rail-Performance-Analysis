# IJC437-Rail-Performance-Analysis

This is the repository for my IJC437 Report - a rail performance analysis of the UK passenger rail network.

## Overview of the Project
This project examined the association between rail usage and strain on the Office for Road and Rail (ORR's) Public Performance Measure (PPM) - the % of trains on time to their destination. 
Recent media has talked a lot about the decline of the UK passenger rail industry. This paper examined the performance of it, and aimed to create a prediction model of PPM given some basic operator metrics regarding passengers and other details. 

Two reseach questions were established:
  RQ1: To what extent does network usage and intensity affect PPM?

	RQ2: Can we reliably predict PPM using network usage and intensity factors?

## Data and Methodology 
Data was downloaded from the ORR Data Catalogue (https://dataportal.orr.gov.uk/data-table-catalogue/), extracted into excel, then cleaned and analysed in R. A tuned elastic net model was used within the R tidymodel and associated package workflow. Iniitally, other factors (e.g. funding statistics) were downloaded, extracted, and entered into R. This is because the data is shared with another IJC project, Data Visualisation. A repository for that project will be on my profile shortly. In order to retain ease of use, the code for cleaning and removing this data was preserved in this project. 

## Key findings 
- Overall passenger volume (passenger KMs) was a significant predictor of train punctuality within the UK passenger rail network, with punctuality and reliability decreasing for increased passenger KMs
- Operators can negate negative effects of this through proper planning, and can exceed what would be expected of them given how many employees the company has
- Punctuality and reliability is able to be broadly predicted with network usage and intensity metrics, as well as information about the operator’s employees and stations manage

## Running the analysis 
To run the analysis...
1. Download all files
2. Open the rpoj file
3. Open the master script and ensure all packages are installed
    If all packages are not, install missing packages with: install_packages("package_name")
4. Run the master script
5. You can now go into individual files to run individual scripts, lines, and analyses.

**You must run the master script first.** Individual files are unable to be ran before the master script as sourcing would be required, which would encounter errors with recursive calling of objects and scripts.
