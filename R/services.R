#' list services available for given project
#' @inheritParams common_params
#' @export
service_list = function(pid){
  tibble(service="en_tox",status="active",description="NER for toxicology",reference="https://github.com/ontox-hu/...") |>
    rbind(tibble(service="export_answers",status="active",description="export answers to excel",reference="https://github.com/sysrev/service-export-answers"))
}

#' Run a service within the context of a given project
#' @param service name of the service to run
#' @param ... arguments to run service
#' @inheritParams common_params
#' @export
service_run = function(pid,service,...){
  get_entities = function(text){
    req = POST("http://127.0.0.1:5000/predict_entity",body = list(text=text),encode = "json")
    res = content(req)$entities
    purrr::map_dfr(res,\(e){
      context = substr(text,max(e[[2]]-20,0),min(e[[3]]+20,nchar(text)))
      tibble(value=e[[1]], start=e[[2]], end=e[[3]], entity=e[[4]], context)
    })
  }
  dplyr::bind_rows(get_entities(...))
}
