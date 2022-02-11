# Title : rdata_test_script.R
# Author: Maddy Griswold
# Date  : December 2, 2021

## README

# This script tests the RData file generated and submitted for PR.
#
# RData files that pass all of these tests will be approved by NanoString to be 
# included in the CellProfileLibrary. If a test does not pass, changes will be 
# requested before the PR can be merged.
#
# To run please provide the RDataFile to be tested and location of CellProfileLibrary folder

RDataFile <- "../Rat/Adult/BoneMarrow_RatTest.RData"

CellProfileLibraryFolder <- ".."    

################################################################################
###################### DO NO EDIT SCRIPT AFTER THIS POINT ######################
################################################################################

load(RDataFile)


# install & load packages
required_packages <- c('testthat', 'stringr', "readxl", "RCurl")

for (pkg in required_packages) {
  if (!pkg %in% installed.packages()){
    install.packages(pkg, quiet = TRUE)
  } 
  library(pkg, character.only = TRUE)
}


# get dataset location from file 
dataset <- as.character(str_split(RDataFile, "/", simplify = T))
if(dataset[length(dataset)-1] == "Fetal" & dataset[length(dataset)-2] == "Mouse"){
  dataset <- dataset[(length(dataset)-2):length(dataset)]
  names(dataset) <- c("Species", "Age", "Stage", "Dataset")
}else{
  dataset <- dataset[(length(dataset)-2):length(dataset)]
  names(dataset) <- c("Species", "Age", "Dataset")
}

dataset["matrix_name"] <- gsub(".RData", "", dataset["Dataset"])

# updated (December 7, 2021)
# check https://bioconductor.org/packages/release/BiocViews.html#___OrgDb for more
matchingSpecies <- c("Human"   = "org.Hs.eg.db" , "Mouse"     = "org.Mm.eg.db",
                     "Rat"     = "org.Rn.eg.db" , "Fly"       = "org.Dm.eg.db",
                     "Rhesus"  = "org.Mmu.eg.db", "Canine"    = "org.Cf.eg.db",
                     "Chimp"   = "org.Pt.eg.db" , "Zebrafish" = "org.Dr.eg.db",
                     "Bovine"  = "org.Bt.eg.db" , "Pig"       = "org.Ss.eg.db", 
                     "Chicken" = "org.Gg.eg.db" , "Worm"      = "org.Ce.eg.db",
                     "Xenopus" = "org.Xl.eg.dv" , "Mosquito"  = "org.Ag.eg.db")

# install and load organism specific gene database
speciesPackage <- matchingSpecies[dataset["Species"]]

if(is.na(speciesPackage)){
  stop(paste("Your desired species does not have a genome annotation on Bioconductor, please reach out directly if your species is not one of the following:
             ", paste(names(matchingSpecies), collapse = ", ")))
}

for (pkg in speciesPackage) {
  if (!pkg %in% installed.packages()){
    BiocManager::install(pkg)
  } 
  library(pkg, character.only = TRUE)
}


# get valid genes for specific species
x <- get(gsub(".db", "SYMBOL", speciesPackage))

# Get the gene symbol that are mapped to an entrez gene identifiers
mapped_genes <- mappedkeys(x)
# Convert to a list
genes <- unlist(as.list(x[mapped_genes]))

#species in metadata matches folder label
test_that("species in metadata matches folder label",{
  expect_identical(metadata$Species, as.character(dataset["Species"]))
})


if(!grepl("COVID",metadata$`Profile Matrix`)){
  #age in metadata matches folder label
  test_that("age in metadata matches folder label", {
    expect_identical(metadata$`Age Group`, as.character(dataset["Age"]))
  })
}

#check URLs in metadata are valid
# test_that("URLs in metadata are valid", {
#   expect_true(all(lapply(str_split(metadata$URL, ", ", simplify = T), 
#                          FUN =  url.exists) == TRUE))
# })

#genes in profile matrix are the same format as species panel genes
test_that("genes in profile matrix are valid organism genes", {
  expect_gte(length(which(rownames(profile_matrix) %in% genes))/nrow(profile_matrix), 0.8)
})

#check unique column names
test_that("unique cell types", {
  expect_false(any(duplicated(colnames(profile_matrix))))
})

#check for correct variable type 
test_that("profile matrix is made up of numeric values", {
  expect_true(all(lapply(profile_matrix, class) == "numeric"))
})

#check for correct variable type
test_that("profile matrix is a matrix", {
  expect_true(class(profile_matrix)[1] == "matrix")
})

#check for exact same columns
test_that("no cell type has exact same profile as another", {
  expect_false(any(cor(profile_matrix)[lower.tri(cor(profile_matrix))] == 1))
})

#check that no genes have no information
test_that("no genes contain only 0 counts", {
  expect_false(any(rowSums(profile_matrix) == 0))
})

#check that no cell types have no information
test_that("no cell types contain only 0 counts", {
  expect_false(any(colSums(profile_matrix) == 0))
})

#check that all cell types in cellGroups are in profile matrix
test_that("all granular cell types in cellGroups are in profile matrix", {
  expect_true(all(unlist(cellGroups) %in% colnames(profile_matrix)))
})

#check that all cell types in profile are in matrixcellGroups
test_that("all cell types in profile matrix are in cellGroups", {
  expect_true(all(colnames(profile_matrix) %in% unlist(cellGroups)))
})

#profile name in sheet of cellTypes.xlsx
test_that("profile name is a sheet in the correct cellTypes.xlsx",{
  expect_true(dataset["matrix_name"] %in% excel_sheets(path = paste(CellProfileLibraryFolder, 
                                                                    metadata$Species,
                                                                    paste0(metadata$Species,
                                                                           metadata$`Age Group`, 
                                                                           "_CellTypes.xlsx"),
                                                                    sep = "/")))
})

cellBins <- read_xlsx(path = paste(CellProfileLibraryFolder, 
                                   metadata$Species,
                                   paste0(metadata$Species,
                                          metadata$`Age Group`, 
                                          "_CellTypes.xlsx"), sep = "/"), 
                      sheet = dataset["matrix_name"])

#name at the top of the sheet matches profile name
test_that("name at top of sheet in cellTypes.xlsx matches profile name",{
 expect_true(gsub(pattern = " - |_", replacement = " ", names(cellBins)[1]) ==
               gsub(pattern = "_", replacement = " ", dataset["matrix_name"]))
})

#granular cell types in xlsx match that in RData cellGroups
test_that("granular cell types in xlsx match that in RData cellGroups",{
  expect_true(all(gsub("\\W|_|-", ".", cellBins[["...3"]][-1]) %in% 
                    gsub("\\W|_|-", ".", unlist(cellGroups))))
  expect_true(all(gsub("\\W|_|-", ".", unlist(cellGroups)) %in% 
                    gsub("\\W|_|-", ".", cellBins[["...3"]][-1])))
})

#binned cell types in xlsx match that in RData cellGroups
test_that("Binned cell types in xlsx match that in RData cellGroups",{
  expect_true(all(gsub("\\W", ".", unique(cellBins[["...2"]][!is.na(cellBins[["...2"]])][-1])) %in% 
                    gsub("\\W", ".", names(cellGroups))))
  expect_true(all(gsub("\\W", ".", names(cellGroups)) %in% 
                    gsub("\\W", ".", unique(cellBins[["...2"]][!is.na(cellBins[["...2"]])][-1]))))
})

#profile name does not end with (number)
test_that("profile name is not a duplicate, ends in a number",{
  expect_false(grepl(dataset["matrix_name"], pattern = "\\([0-9]+\\)"))
})

species_metadata <- read.table(paste(CellProfileLibraryFolder, metadata$Species, 
                                     paste0(metadata$Species, "_datasets_metadata.csv"),
                                     sep = "/"), header = TRUE, sep = ",",
                               stringsAsFactors = FALSE)

splitMatrixName <- str_split(dataset["matrix_name"], "_", simplify = T)

dataset["Tissue"] <- paste(splitMatrixName[,-ncol(splitMatrixName)], collapse = "_")
dataset["Profile Matrix"] <- splitMatrixName[,ncol(splitMatrixName)]

#metadata matches rdata name
test_that("tissue and Profile Name in metadata matches RData file name",{
  expect_true(metadata$`Profile Matrix` == dataset["Profile Matrix"])
  expect_true(metadata$Tissue == dataset["Tissue"])
})


#metadata in correct metadata file
test_that("metadata is in the correct species metadata file", {
  matchingMetadata <- which(species_metadata$Species == dataset["Species"] &
                              species_metadata$Profile.Matrix == dataset["Profile Matrix"] &
                              species_metadata$Tissue == dataset["Tissue"] &
                              species_metadata$Age.Group == dataset["Age"])
  expect_true(length(matchingMetadata) == 1)
})


