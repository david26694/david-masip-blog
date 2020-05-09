args <- commandArgs(trailingOnly = TRUE)
library(rmarkdown)

render(args[1], md_document(variant = 'gfm', preserve_yaml=TRUE))