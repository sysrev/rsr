#' #' tidy_answers
#' #' returns a list for each project label
#' #' @param pid sysrev project id
#' #' @export
#' tidy_answers = function(pid){
#'   lbls  = get_labels(pid)
#'   get_answers(pid) |>
#'     group_by(short_label,value_type) %>%
#'     {setNames(group_split(.),group_keys(.)[[1]])} |>
#'     purrr::map( ~ tidy_answers_internal(.,lbls))
#' }
#'
#' tidy_answers_internal = function(tb,value_type){
#'   vt = unique(tb$value_type)
#'   if(length(vt) > 1){ stop("tb must be a tibble with a single value type") }
#'
#'   tidyfn = switch(vt,
#'                   boolean     = tidy.answers.boolean,
#'                   categorical = tidy.answers.basic,
#'                   string      = tidy.answers.basic,
#'                   group       = tidy.answers.group)
#'
#'   tidyfn(tb,lbls)
#' }
#'
#'
#'
#' tidy.answers.basic = function(tb,labels){
#'   tb |> mutate(answer = pbsapply(answer,parse_json,USE.NAMES = F,simplify = T))
#' }
#'
#' tidy.answers.boolean = function(tb,labels){
#'   tb |> mutate(answer = case_when(answer=="true"~T,answer=="false"~F,NULL))
#' }
#'
#' tidy.answers.group = function(tb,labels){
#'
#'   loid = labels |> filter(lid == tb$lid[1]) |> pull(label_id_local)
#'   lids = labels |> select(lid,root_label_id_local) |> filter(root_label_id_local==loid) |> pull(lid)
#'   lidn = labels |> select(short_label,root_label_id_local) |> filter(root_label_id_local==loid) |> pull(short_label)
#'
#'   convert.row = function(answer.json){
#'     answer.list  = fromJSON(answer.json)$labels
#'     extract.rows = function(lid){ tibble(map(answer.list,lid)) }
#'
#'     quietly(map_dfc)(lids,extract.rows) |> pluck("result") |>
#'       magrittr::set_colnames(lidn) |>
#'       rowwise() |> mutate(across(everything(),~paste(.x,collapse=";"))) |> ungroup()
#'   }
#'
#'   dt |> mutate(answer = pblapply(answer,convert.row)) |> unnest(answer) |> tibble()
#' }
