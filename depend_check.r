depend_check = function(package) {  
  base = as.character(as.data.frame(utils::installed.packages(priority="base"))$Package)  
  ap = as.data.frame(available.packages())  
  deps = strsplit(as.character(ap$Depends[ap$Package==package]), ",")  
  imps = strsplit(as.character(ap$Imports[ap$Package==package]), ",")  
  reqs = gsub(" ", "", gsub("[\n]", "", c(unlist(deps), unlist(imps))))  
  pac = ver_req = inst_ver = is_base = vector("character", length(reqs))
  
  for (ii in seq_len(length(reqs))) {
    pac[ii] = gsub("\\s*\\([^\\)]+\\)", "", reqs[ii])    
    tmp_ver = regmatches(reqs[ii], gregexpr("(?<=\\().*?(?=\\))", reqs[ii], perl=T))[[1]]    
    if (length(tmp_ver) == 0) tmp_ver = ""     
    ver_req[ii] = tmp_ver    
    tryCatch({
      inst_ver[ii] = as.character(utils::packageVersion(pac[ii]))
    },
    error=function(cond) {
      inst_ver[ii] = "not found"
    })    
    is_base[ii] = pac[ii] %in% base
  }
  
  return(data.frame(
    package = pac,
    version_required = ver_req,
    version_installed = inst_ver,
    is_base = is_base
  ))
}
