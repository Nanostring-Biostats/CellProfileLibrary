# Title : rdata_generator.R
# Author: Maddy Griswold
# Date  : December 2, 2021

## README

# This script ensures the same format is used for all user submitted profile matrices
# To use this script, three files need to be updated.
#
# 1. Fill in the template_metaDataFile for your species
# 2. Add sheet to the CellTypes excel file, both columns can be the same if no suggested bins
# 3. run create_profile_matrix() from SpatialDecon v1.4+ and provide generated matrix,
#       or provide a gene x cellType matrix (csv). 
#
# The RData file will be generated in the correct species and age folder using this script


metaDataFile <- "BoneMarrow/testing_datasets_metadata.csv"
matrixFile <- "BoneMarrow/BoneMarrow_profileMatrix.csv"

cellTypeFile <- "RatAdult_CellTypes.xlsx"
tissueSheet <- "BoneMarrow_RatTest"

# if fetal data, what embryonic day is it? 
# set to NULL if not fetal
embryonicDay <- NULL 

CellProfileLibraryFolder <- "../"    # location of CellProfileLibrary folder  


################################################################################
###################### DO NO EDIT SCRIPT AFTER THIS POINT ######################
################################################################################


# install & load packages
required_packages <- c('readxl', 'stringr', 'crayon')

for (pkg in required_packages) {
  if (!pkg %in% installed.packages()){
    install.packages(pkg, quiet = TRUE)
  } 
  library(pkg, character.only = TRUE)
}


## Read in files ##
metadata <- read.table(metaDataFile, sep = ",", header= T, check.names = F, skip = 2)
profile_matrix <- read.table(matrixFile, header = T, sep = ",", row.names = 1, 
                             stringsAsFactors = F, check.names = F)
cellGroups <- read_xlsx(path = cellTypeFile, sheet = tissueSheet, skip = 1)[,-1]

## separate metadata ## 
name <- metadata$`Profile Matrix`
species <- metadata$Species
tissue <- metadata$Tissue
age <- metadata$`Age Group`

# add fetal age
if(age == "Fetal" & species != "Human"){
  if(is.null(embryonicDay)){
    stop("Please provide embryonic day of dataset.")
  }
  if(!startsWith(embryonicDay, "E")){
    embryonicDay <- paste0("E", embryonicDay)
  }
  
  age <- paste0(age, "/", embryonicDay)
}

## Format profile_matrix ##

# remove genes with only 0 counts
if(any(rowSums(profile_matrix) == 0)){
  w2rm <- which(rowSums(profile_matrix) == 0)
  
  print(paste(length(w2rm), "genes are dropped with all 0 counts"))
  
  profile_matrix <- profile_matrix[-w2rm,]
}

# change colnames to be consistent with downstream analysis
colnames(profile_matrix) <- gsub("\\W", ".", colnames(profile_matrix))
colnames(profile_matrix) <- gsub("\\.$", "", colnames(profile_matrix))
colnames(profile_matrix) <- gsub(pattern = "\\.pos\\.", "+", colnames(profile_matrix))
colnames(profile_matrix) <- gsub(pattern = "\\.neg\\.", "-", colnames(profile_matrix))

profile_matrix <- as.matrix(profile_matrix)
  
## Format cellTypeBins ##

# fill in NA Main Cell Types
for(i in which(is.na(cellGroups$`Main Cell Types`))){
  cellGroups$`Main Cell Types`[i] <- cellGroups$`Main Cell Types`[i-1]
}

# ensure continuity between profile matrix and Granular names
cellGroups$Granular <- gsub("\\W", ".", cellGroups$Granular)
cellGroups$Granular <- gsub("_", ".", cellGroups$Granular)
cellGroups$Granular <- gsub("\\.$", "", cellGroups$Granular)
cellGroups$Granular <- gsub(pattern = "\\.pos\\.", "+", cellGroups$Granular)
cellGroups$Granular <- gsub(pattern = "\\.neg\\.", "-", cellGroups$Granular)

# get Main Cell Types
group_names <- unique(cellGroups$`Main Cell Types`)

# make list from Main Cell Types
groupList <- list()
for(i in group_names){
  groupList[[i]] <- cellGroups$Granular[cellGroups$`Main Cell Types` == i]
}

cellGroups <- groupList
rm(groupList)

# change list names to be consistent with downstream analysis
group_names <- gsub(pattern = "\\.pos", "+", group_names) #change .pos to +
group_names <- gsub(pattern = "\\.neg", "-", group_names) #change .neg to +

group_names <- gsub("\\.", " ", group_names)              #change . to spaces
group_names <- str_trim(group_names)                      #remove leading/trailing whitespace
group_names <- str_squish(group_names)                    #remove multipe whitespace
group_names <- gsub("s$", "", group_names)                #remove trailing s (cell"s")
group_names <- gsub("cell", "", group_names)              #remove trailing word cell (beta "cell")
group_names <- str_trim(group_names)                      #remove leading/trailing whitespace

names(cellGroups) <- group_names

# check cell type bins to profile matrix cell type names
if(sum(lengths(cellGroups)) > ncol(profile_matrix) | !all(colnames(profile_matrix) %in% unlist(cellGroups))){
  if(!all(colnames(profile_matrix) %in% unlist(cellGroups))){
    missingCT <- colnames(profile_matrix)[which(!colnames(profile_matrix) %in% unlist(cellGroups))]
    print(paste("WARNING:", paste(missingCT, collapse = ", "), "are not included in given cell type bins. Continuing with no cell type bins"))
  }else{
    print("WARNING: binned_cellTypes has more cell types than the given profile matrix, check if spaces in cell types are changed to . like cell.type.1. Continuing with no cell type bins")
  }
  
  cellGroups <- as.list(colnames(profile_matrix))
  names(cellGroups) <- colnames(profile_matrix)
}

if(endsWith(CellProfileLibraryFolder, "/")){
  CellProfileLibraryFolder <- str_sub(CellProfileLibraryFolder, 1, nchar(CellProfileLibraryFolder)-1)
}
    
profileName <- paste0(tissue,"_",name)

rdata_fileName <- paste0(paste(CellProfileLibraryFolder, species, age, 
                               profileName,sep = "/"),
                         ".RData")
num <- 2

while(file.exists(rdata_fileName)){
  warning(paste0("The profile name \"", profileName,"\" has already been taken. It has been saved with a number appended. 
          This file will not be accepted as a duplicate, please change the \"Profile Matrix\" name in the metadata file and either rerun script or edit file name manually to match new Profile Name"))
  
  profileName <- paste0(tissue,"_",name, "(", num, ")")
  
  rdata_fileName <- paste0(paste(CellProfileLibraryFolder, species, age,
                                 profileName, sep = "/"),
                           ".RData")
  num <- num + 1
}

if(profileName != tissueSheet){
  warning(paste0("The xlsx sheet name does not match what will be the profile matrix name. Please change sheet name to \"", profileName, "\" or 
                 change metadata \"Profile Name\" to match xlsx sheet name \"", tissueSheet, "\""))
}

if(!dir.exists(paste(CellProfileLibraryFolder, species, sep = "/"))){
  stop(paste0("You are creating a folder for a new species. If this is your intent, please create a folder called \"", species, "\" in the \"CellProfileLibrary\" folder. 
              After creating the folder, please make a  _datasets_metadata.csv file following the format of the Mouse folder."))
}else{
  if(!file.exists(paste(CellProfileLibraryFolder, species, paste0(species, "_datasets_metadata.csv"), sep = "/"))){
    stop(paste0("Please make a ", species, "_datasets_metadata.csv file following the format of the Mouse folder in the \"", species, "\" folder" ))
  }
}

if(!dir.exists(paste(CellProfileLibraryFolder, species, age, sep = "/"))){
  stop(paste0("You are creating a folder for a new age group. If this is your intent, please create a folder called \"", age, "\" in the \"", species, "\" folder.
              After creating the folder, please make a  _CellTypes.xlsx file following the format of the Mouse folder."))
}else{
  if(!file.exists(paste(CellProfileLibraryFolder, species, paste0(species, age, "_CellTypes.xlsx"), sep = "/"))){
    stop(paste0("Please make a ", species, age, "_CellTypes.xlsx file following the format of the Mouse folder in the \"", species, "\" folder" ))
  }
}

save(cellGroups, metadata, profile_matrix, file = rdata_fileName, precheck = TRUE)
 
cat(green(paste("RData file was succesfully created at this location:", rdata_fileName)))
