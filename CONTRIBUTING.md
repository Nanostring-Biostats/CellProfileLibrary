# Instructions for adding a user submitted cell profile matrix.  

Thank you for investing your time in contributing to our profile matrix repository! Any contribution you make can be downloaded by users of SpatialDecon or other cell type deconvolution algorithms. 

In this guide you will get an overview of the contribution workflow from forking, merging and syncing the original repository, creating the custom profile matrix RData file, and putting in a pull request.

Use the table of contents icon <img src="userSubmission/images/table-of-contents.png" width="25" height="25" /> on the top left corner of this document to get to a specific section of this guide quickly.

If you have already created a branch on a forked reposititory, you can skip to **5. Adding a custom profile matrix to repository**. 

# Forking CellProfileLibrary to create personal branch

### 1. Fork the CellProfileLibrary repository. This creates a local version of the repository in your GitHub account.

<p align="center">
  <img src="userSubmission/images/forking.png">
</p>

Your GitHub repository should now say that it is a forked repository

<p align="center">
  <img src="userSubmission/images/forked.png">
</p>


<br>

Some steps are different if you are using a command line interface (CLI) or GitHub Desktop. These steps are split by method.
## CLI
### 2. Clone the forked repository 
- Copy the HTTPS link from **your forked** CellProfileLibrary repository 

<p align="center">
  <img src="userSubmission/images/clone_CLI_underline_maddygriz.png">
</p>
    
- Clone repository and change into that directory 

        git clone [forked https]
        git cd CellProfileLibrary

<p align="center">
  <img src="userSubmission/images/clone_CLI_freya.png">
</p>

### 3. Sync forked master branch

To pull changes from original repository, you need to add the original Git repository as an upstream repository.

- Copy the HTTPS link from the **Nanostring-Biostats** CellProfileLibrary repository

<p align="center">
  <img src="userSubmission/images/clone_CLI_underline.png">
</p>

- Add a remote branch that points to the original repository

        git remote add upstream https://github.com/Nanostring-Biostats/CellProfileLibrary.git

<p align="center">
    <img src="userSubmission/images/upstream_CLI_freya.png">
</p>    

- Fetch all of the branches from the original repository 

        git fetch upstream
    
<p align="center">
    <img src="userSubmission/images/fetch_CLI.png">
</p>
    
- merge any upstream changes with your forked repository

        git merge upstream/master

<p align="center">
    <img src="userSubmission/images/merge_CLi.png">
</p>

### 4. Create a branch
It is best practice to work on a different branch than master. 
- `git branch` shows all branches with an `*` on the current working branch 

<br>

        git branch         
        git checkout -b [new branch name]
        git branch

<p align="center">
    <img src="userSubmission/images/newbranch_CLI.png">
</p>
   
    

<br><br>

## GitHub Desktop
### 2. Clone the forked repository 
- Open with GitHub Desktop and follow their instructions

<p align="center">
    <img src="userSubmission/images/clone_desktop_underline.png">
</p>

- Choose To contribute to the parent project

<p align="center">
    <img src="userSubmission/images/branch_type_desktop.png">
</p>

     
### 3. Sync forked master branch
To pull changes from original repository, you need to add the original Git repository as an upstream repository.

- by choosing to contribute to the parent project, the steps of `adding the remote upstream branch` and `fetching` it are automatically done for you

- merge any upstream changes with your forked repository

<p align="center">
    <img src="userSubmission/images/merge_desktop.png">
</p>
<p align="center">
    <img src="userSubmission/images/merge_branch_desktop.png">
</p>

### 4. Create a branch
It is best practice to work on a different branch than master.

<p align="center">
    <img src="userSubmission/images/newbranch_desktop.png">
</p>
<p align="center">
    <img src="userSubmission/images/newbranch_naming_desktop.png">
</p>
<p align="center">
    <img src="userSubmission/images/newbranch_proof_desktop.png">
</p>

<br>

## GitHub Website 
You can also fetch and merge from the website.
<p align="center">
    <img src="userSubmission/images/fetch_website.png">
</p>

# 5. Adding a custom profile matrix to repository 
After you have set up the forked repository, you are ready to add your own profile matrix.

Most of the files needed for these steps are located in the `userSubmission/` folder

1. Run create_profile_matrix() in SpatialDecon v1.4+ 
    - This function requires a single cell count matrix and an annotation sheet with each cell's unique identifier and it's corresponding cell type
    - Run this function with outDir set so that a file is saved to your local machine. 
2. Update template_metadata.csv file
    - Choose corresponding species template metadata file and fill out the sections
3. Add sheet to correct species and age_group CellTypes.xlsx file
    - Follow the format of the other sheets
    - Title and sheet name must match the name of the created profile matrix RData file
        - will follow this format from metadata file *tissue*_*profileMatrix*
4. Run rdata_generator.R script
    - This script will generate the RData file in the correct location depicted from the metadata information
    - This script has a couple of variables to fill out at the top
        - **metaDataFile** - file path to template metadata csv file
        - **matrixFile** - file path to profile matrix file generated from create_profile_matrix()
        - **cellTypeFile** - file path to cellType xlsx file
        - **tissueSheet** - name of sheet in cellTypeFile for profile matrix
        - **embryonicDay** - if embryonic data, what embryonic day 
        - **CellProfileLibraryFolder** - file path to local version of CellProfileLibrary folder
    - If your profile matrix is from a new species or age_group, there will be a couple of "errors" in the script that will walk you through how to correctly add these new folders and corresponding files
5. If there are no errors or warnings when running rdata_generator.R, please add the row from the template metadata file to the corresponding species metadata.csv file. 
6. Run rdata_test_script.R
    - This is a test script to determine if your RData file is valid and located in the correct folder as well as checks on the corresponding species and age_group files: CellTypes.xslx and metadata.csv. 
    - These are the same checks that NanoString will perform on your data before merging it in. If all tests pass, you are ready to put in a pull request.

<br>

### 6. Push changes
After adding your changes to your branch, you can commit and push the changes to GitHub.
#### CLI
- commit your changes to your branch
    - -m = message. This message will be attached to the commit on GitHub

            git commit -m "Add [profile_name] matrix"

- push changes to GitHub

            git push origin [add-your-branch-name]


#### GitHub Desktop
- commit your changes to your branch

<p align="center">
    <img src="userSubmission/images/commit_desktop.png">
</p>

- push changes to GitHub
<p align="center">
    <img src="userSubmission/images/push_desktop.png">
</p>

<br>

### 7. Make PR
- On GitHub, click on Compare & pull request to open a pull request 
<p align="center">
    <img src="userSubmission/images/PR_github.png">
</p>

- To complete your pull request, make sure that the *head* repository is your personal repo and that the *base* repo is the Nanosting-Biostats one. 
- If there are merge conflicts, please resolve those before creating a PR. 
- In the message, write the new profile matrix you are adding to the repo
- Hit Create pull request
<p align="center">
    <img src="userSubmission/images/PR_merge_github.png">
</p>

After creating a pull request, NanoString will take a look at the request and either merge it in or request changes from you. We will be running the same test script that is avaliable to you, so if that runs on your end your profile matrix will most likely be added without any additional questions. 

<br>

# Thank you for your contribution! 


helpful links:

- https://docs.github.com/en/github-cli
- https://docs.github.com/en/desktop
- https://github.com/firstcontributions/first-contributions
- https://www.dataschool.io/how-to-contribute-on-github/
- https://www.freecodecamp.org/news/how-to-make-your-first-pull-request-on-github-3/
