args <- commandArgs(trailingOnly = TRUE)
library(rmarkdown)

# Consider changing variant to gfm
render(args[1], md_document(variant = 'markdown_github', preserve_yaml = TRUE))