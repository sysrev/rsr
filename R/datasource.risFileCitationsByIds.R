#' Title
#' @import dplyr
#' @param datasource.ids the ids to get ris information from
#' @param token a token with read priveleges
#' @return dataframe for ris citations
datasource.risFileCitationsByIds <- function(datasource.ids,token=keyring::key_get("sysrev.token")){
  dsrcQ    <- sprintf("{risFileCitationsByIds(ids:[%s]){A1,A2,A3,A4,AB,AD,AN,AU,AV,BT,C1,C2,
                         C3,C4,C5,C6,C7,C8,CA,CN,CT,CY,DA,DO,DP,ED,EP,ET,ID,IS,J1,J2,JA,JF,JO,
                         KW,L1,L2,L3,L4,LA,LB,LK,M1,M2,M3,N1,NV,OP,PB,PP,PY,RI,RN,RP,SE,SN,SP,
                         ST,T1,T2,T3,TA,TI,TT,TY,U1,U2,U3,U4,U5,UR,VL,VO,Y1,Y2,id}}",
                         paste(datasource.ids,collapse=","))
  entities <- datasource.graphql(dsrcQ,token)$risFileCitationsByIds
  dframes  <- purrr::map(entities,function(entity){
    as.data.frame(purrr::map(entity,function(l){
      if(length(l) == 0){as.character(NA)}else{paste(l,collapse=";")}
    }))
  })

  df <- do.call(rbind,dframes)
  df <- df[colSums(!is.na(df))>0]
  df <- dplyr::mutate_all(df,as.character)
  dplyr::mutate(df,datasource.id = as.numeric(id))
}
