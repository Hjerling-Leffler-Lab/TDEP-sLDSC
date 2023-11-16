library(googledrive)
library(here)


fs::dir_create("workflow/ldscores")

drive_deauth()
drive_download(as_id("1nobTU0aBbcLvK9VDYLMRf-00hKWFD7tl"), path = "workflow/ldscores/superclusters.tar")
utils::untar(here("workflow/ldscores/superclusters.tar"))