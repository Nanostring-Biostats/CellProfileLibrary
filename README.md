## Overview

This repo contains a library of "cell profile matrices" - matrices giving the average expression profiles of all cell types found in a tissue. 
Each matrix in the library was derived from a single scRNA-seq experiment.
(The "lung_plus_neutrophils" matrix is an exception - it is an amalgam of two cell profile matrices.)

For details on the generation of these matrices, see Danaher & Kim (2020), "Advances in mixed cell deconvolution enable quantification of cell types in spatially-resolved gene expression data."


## Usage

These matrices can be downloaded directly. 

In addition, they can be downloaded within an R session using the "download_profile_matrix" function from the SpatialDecon package. 


## Details on methods from Danaher & Kim (2020)

From the Methods section of Danaher & Kim, "Advances in mixed cell deconvolution enable quantification of cell types in
spatial transcriptomic data":

"27 single cell RNA-seq studies were downloaded from The Broad Institute Single Cell Portal. For raw gene expression (GE) matrices, cells were removed if they fell below the inflection point, were considered empty by emptyDrops22, had a gene count above 2.5x average gene count, or had a percentage of mitochondrial genes > 0.05. Genes were removed if they appeared in less than 2 cells or had low biological significance as measured by scran23. Cells were clustered and marker genes identified using Seurat24. Clustered marker genes were compared to PanglaoDB18 marker genes (ubiquitousness index < 0.1, sensitivity > 0.6, specificity < 0.4, canonical marker). Cell clusters were named according to the PanglaoDB cell type with the most overlapping marker genes. All cell cluster names were manually reviewed for correctness. When data sets had already been annotated with cell type calls, the existing cell type calls were retained. Only cell clusters with more than 10 cells were reported. Each cell cluster's profile was reported as the arithmetic mean of its cells' expression profiles."
