if (!require(pacman)) { 
  install.packages("pacman", 
  repos = "http://cloud.r-project.org/")
}

pacman::p_load("googlesheets", "janitor", "fs")

gs_tools <- googlesheets::gs_key("1KUMSeq_Pzp4KveZ7pb5rddcssk1XBTiLHniD0d3nDqo")


tools_meta_general <- googlesheets::gs_read(
  ss = gs_tools, 
  ws = "METADATA",
  range = googlesheets::cell_rows(3:16),
  col_names = FALSE
) %>% 
  dplyr::mutate(X1 = gsub(":", "",X1)) %>% 
  dplyr::rename("VariableName" = "X1", 
                "VariableValue" = "X2")


tools_meta_variables <- googlesheets::gs_read(
  ss = gs_tools, 
  ws = "METADATA",
  range = googlesheets::cell_rows(17:41),
  col_names = FALSE
) %>%  
  dplyr::mutate(X1 = gsub("=", "",X1)) %>% 
  dplyr::rename("VariableName" = "X1", 
                "VariableDescription" = "X2")

tools_meta_phases <- googlesheets::gs_read(ss = gs_tools, 
                                            ws = "METADATA",
                                            range = googlesheets::cell_rows(43:75),
                                            col_names = TRUE) %>%  
                     janitor::clean_names()

tools_meta_phases <- tools_meta_phases %>% 
  tidyr::fill(research_phases_7)


tools_meta_resources <- googlesheets::gs_read(
  ss = gs_tools, 
  ws = "METADATA",
  range = "B76:C86",
  col_names = TRUE) %>%  
 janitor::clean_names()



data_header <- names(googlesheets::gs_read(ss = gs_tools, 
                                          ws = "DATA",
                                          col_names = TRUE, 
                                          skip = 1) %>% 
                           dplyr::select(-URL_1, -X14, -X23, -X24))

tools_data <- googlesheets::gs_read(ss = gs_tools, 
                                   ws = "DATA",
                                   col_names = TRUE, 
                                   skip = 1) %>% 
              dplyr::select(-URL_1, -X14, -X23, -X24) %>% 
              dplyr::filter(Reduce(`+`, lapply(., is.na)) != ncol(.)) %>% 
              dplyr::filter(!is.na(NAME), 
                            NAME != "\n")

tools_data <- tools_data[-1,]

names(tools_data) <- data_header

export_df_as_csv <- function(df_string, 
                          export_dir = "../datafiles/googlesheet_tools") {
  
  #df_string <- deparse(substitute(df))
if (! fs::dir_exists(export_dir)) {
  fs::dir_create(export_dir)
} 
  
export_path <-  file.path(export_dir, paste0(df_string, ".csv"))
print(sprintf("Exporting %s to %s", class(df), export_path))

readr::write_csv(x = get(df_string), 
                 path = export_path) 
}

export_data <- ls()[grep(pattern = "tools_", ls())]

for (dat in export_data) { export_df_as_csv(dat)}
