clean_str <- function(x){
  # Capitalize case
  x %>% str_to_title %>%  
    # Remove special characters (keeping only alphanumerics and spaces)
    str_remove_all("[^[:alnum:]|[:space:]]") %>%  
    # Remove of extra spaces
    str_replace_all(' +', ' ') %>% str_trim() %>% 
    # Remove trailing s
    str_replace_all('s$', ' ') %>% 
    str_trim() %>% 
    # Convert to ASCII, attempting to transliterate characters
    stringi::stri_trans_general("latin-ascii")
}

clean_name <- function(x){
  x %>% clean_str() %>% 
    str_remove_all("Company|\\bCo\\b|Inc|Llc|Group|Usa|Corporation") %>% # Remove uninformative strings
    str_trim()
}

add_latlng <- function(data){
  # x = address, e.g. x <- "1 Pepsi Way, Newburgh, NY 12550"
  #tidygeocoder::geo(x, method = "arcgis") %>% select(lat,long) #%>% as.numeric()
  
  # add lat/lng columns if missing
  if (!"lat" %in% names(data)) {
    data <- data %>% mutate(lat = NA_real_, lng = NA_real_)
  }
  if(any(is.na(data$lat))){ # calculate lat/long if missing
    
    x <- data %>% pull(Address) %>% enc2native()
    ll <- tidygeocoder::geo_combine(
      queries=list(list(method = 'census'), list(method='arcgis')),
      address=x, global_params = list(address='address'), long ="lng") %>% 
      select(-query)
    suppressWarnings({
      data <- data %>% mutate(across(c("lat", "lng"), as.numeric)) %>% 
        left_join(ll, by = join_by(Address == address), multiple = "any") %>% 
        mutate(lat = coalesce(lat.x, lat.y), lng = coalesce(lng.x, lng.y)) %>% 
        select(-c(lat.x, lat.y, lng.x, lng.y)) %>% relocate(lat, lng, .after = "Address")
    })
  }
  return(data)
}