# `depend_check()` :construction:

A simple function to check dependencies (as specified in the depends & imports sections within a DESCRIPTION file) for an R package and the current installed version.

## Usage

Copy and run the code within `depend_check.r`, this will create a function `depend_check()` in your global environment.

To check the the dependencies of an R package which is currently available, for example "dplyr";

```
> depend_check("dplyr")

#'       package version_required version_installed is_base
#' 1           R          >=3.4.0                     FALSE
#' 2    generics                              0.1.1   FALSE
#' 3        glue          >=1.3.2             1.6.2   FALSE
#' 4   lifecycle          >=1.0.1             1.0.3   FALSE
#' 5    magrittr            >=1.5             2.0.1   FALSE
#' 6     methods                              3.6.1    TRUE
#' 7          R6                              2.5.1   FALSE
#' 8       rlang          >=1.0.2             1.0.6   FALSE
#' 9      tibble          >=2.1.3             3.1.6   FALSE
#' 10 tidyselect          >=1.1.1             1.1.1   FALSE
#' 11      utils                              3.6.1    TRUE
#' 12      vctrs          >=0.4.1             0.5.1   FALSE
#' 13     pillar          >=1.5.1             1.6.4   FALSE
```

`package` contains the name of a dependency.
`version_required` specifies the version requirement if one exists.
`version_installed` specifies the current version of the required package that is installed, if applicable.
`is_base` specifies whether the required package is a 'base' package. These are not usually updated manually and are tied to the version of R that is being used.

## Assumptions & Limitations
This function does not offer much in the way of customisation, though aims to be simple to use and should fulfil the needs of a majority of R users.

The specified `package` will be sought from the users default CRAN mirror as per the behaviour of `install.packages`. 

`version_installed` returns the version found in the first library where the package is detected. If the user has packages installed in multiple libraries then they are not able to specify the order in which these are searched and the function will follow the order of the libraries returned by `.libPaths()`.

This function may be useful in resolving errors when trying to install packages, note however, that the documentation of `install.packages()` specifically states "You are advised to run `update.packages` before `install.packages` to ensure that any already installed dependencies have their latest versions.".

Recursive dependencies are not considered.

## Using `depend_check()` to resolve errors during installation.

Let's try to install the `dplyr` package (version 1.0.10) on a system with the `lifecycle` package (version 1.0.0) installed.

```
install.packages("dplyr")
```

OUTPUT;

```
ERROR: lazy loading failed for package ‘dplyr’
* removing ‘/home/a_user/R/x86_64-pc-linux-gnu-library/3.6/dplyr’
* restoring previous ‘/home/a_user/R/x86_64-pc-linux-gnu-library/3.6/dplyr’
Warning in install.packages :
  installation of package ‘dplyr’ had non-zero exit status
```

If we look back through the console output we can find the source of the issue.

```
Error in loadNamespace(j <- i[[1L]], c(lib.loc, .libPaths()), versionCheck = vI[[j]]) : 
  namespace ‘lifecycle’ 1.0.0 is being loaded, but >= 1.0.1 is required
Calls: <Anonymous> ... namespaceImportFrom -> asNamespace -> loadNamespace
Execution halted
```

All of the information we need to resolve the issue is contained in the console output, but often this may be incomprehensible to newer users, or during installations with multiple issues it can be difficult to spot the relevant parts of the error.

Using `depend_check("dplyr")` allows us easily identify the issue.

```
> depend_check("dplyr")

#'       package version_required version_installed is_base
#' 1           R          >=3.4.0                     FALSE
#' 2    generics                              0.1.1   FALSE
#' 3        glue          >=1.3.2             1.6.2   FALSE
#' 4   lifecycle          >=1.0.1             1.0.0   FALSE
#' 5    magrittr            >=1.5             2.0.1   FALSE
#' 6     methods                              3.6.1    TRUE
#' 7          R6                              2.5.1   FALSE
#' 8       rlang          >=1.0.2             1.0.6   FALSE
#' 9      tibble          >=2.1.3             3.1.6   FALSE
#' 10 tidyselect          >=1.1.1             1.1.1   FALSE
#' 11      utils                              3.6.1    TRUE
#' 12      vctrs          >=0.4.1             0.5.1   FALSE
#' 13     pillar          >=1.5.1             1.6.4   FALSE
```

We can see that `lifecycle` version >= 1.0.1 is required, but 1.0.0 is installed.

It's now easy to resolve the issue by installing `lifecycle` then `dplyr`.

```
install.packages("lifecycle")
install.packages("dplyr")
```

As a final point, it is important to remember that recursive dependencies are not considered. In the above example, if `lifecycle` itself was not installing because of its own dependencies not being fulfilled this would require resolution following the same example.
