## Overview

This repo contains a library of "cell profile matrices" - matrices giving the average expression profiles of all cell types found in a tissue. 
Each matrix in the library was derived from a single scRNA-seq experiment. These matrices can be used with cell type deconvolution packages like SpatialDecon to get cell type proportions or identities. 

![SpatialDecon_workflow](https://user-images.githubusercontent.com/40255151/128901535-54a8d912-d7ea-4774-9b71-46f396f6bce3.PNG)


Each RData file contains 3 file types:
	
  1. Cell Profile Matrix 
	
  2. Cell Groups 
	
  3. Dataset Metadata 

## File Types

**Cell Profile Matrix**: Average expression profile of all cell types found in a tissue. 

![cellProfileMatrix](https://user-images.githubusercontent.com/40255151/126808635-a3c6c839-5872-4995-a870-6def7137ffb6.png)

**Cell Groups**: Suggested binning of cell types for simpiler figures. In this example,there are six different hepatacyte cell types that can be collapsed into one group. Some datasets have more than one suggested grouping depending on aggressiveness in binning. The less aggressive binning is the default with the additional ones having "_binType" appended to the variable name.

![cellTypeBin](https://user-images.githubusercontent.com/40255151/126808762-c92983ae-9ed2-46fe-990b-73d633824a70.png)


**Metadata**: Includes database, tissue, age, and paper info

## Usage

These matrices can be downloaded directly. 

In addition, they can be downloaded within an R session using the "download_profile_matrix" function from the SpatialDecon package v1.4+. 


## Details on methods 

  "Matrices were generated using published datasets that had annotated cell types in human and mouse. Datasets were normalized, by total gene count, if raw data was used otherwise the publication’s normalization used. These datasets were filtered for cells expressing (count > 0) at least 100 genes and only calculated cell type profiles for cell types with 15+ viable cells. Profiles were created by taking the average expression of each gene across all viable cells of each cell type. The gene list was subset for genes that were expressed at least one cell type and was present in NanoString’s GeoMx Human Whole Transcriptome Atlas or Mouse Whole Transcriptome Atlas in addition to GeoMx COVID-19 Immune Response Atlas spike-in depending on dataset. A function to create custom profile matrices from scRNA-seq data using this method was realeased in SpatialDecon v1.4.

  Cell Groups were made using dataset’s cell annotations if applicable. Other groupings were made when original cell types were differentiated by numbers (“gamma-delta T cells 1” and “gamma-delta T cells 2”), different high genes (“Endothelial cell_Cldn5 high” and “Endothelial cell_Tm4sf1 high”), or specific gene expression (“MARCO- macrophage” and “MARCO+ macrophage”). When straight-forward groupings were not present cell types were also grouped by similarly named cell types (“lymphatic endothelial cell” and “maternal endothelial cell”) but this was done sparingly as not to oversimplify the data. These groupings are optional and can be changed by the user if they see fit."

## Archival info

For versions of SpatialDecon <= v1.3 and the SpatialDecon plugin, csv files can be downloaded manually from the archive branch in this repository or the profile matrix in the RData file can be converted to a csv. 
```
load(".RData file")
write.csv(x = profile_matrix, file = "outputFileLocation/matrixName.csv", 
          row.names = TRUE, quote = FALSE)
```

