args <- commandArgs(trailingOnly = TRUE)
library(rmarkdown)

render(args[1], md_document(variant = 'markdown_github', preserve_yaml = TRUE))