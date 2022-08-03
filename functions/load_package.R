# load package function
# K L Purves

## Checks if packages exists from a list of packages
## any that don't will be installed.  
## Prints the package version to screen so version can be checked in markdowns.

load_packages <- function(package_list) {

  installed_packages <- package_list %in% rownames(installed.packages())

  if (any(installed_packages == FALSE)) {
    install.packages(package_list[!installed_packages],repos = "https://www.stats.bris.ac.uk/R/")
  }
  
  # Packages loading
  invisible(lapply(package_list, library, character.only = TRUE))
  versions <- sapply(package_list,packageVersion)
  
  print("This project uses the following packages:")
  return(versions)
  
}

