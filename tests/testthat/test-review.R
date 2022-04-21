local_token <- function(envir=parent.frame()){
  old.st  = Sys.getenv("SYSREV_TOKEN")
  old.stt = Sys.getenv("SYSREV_TEST_TOKEN")
  tk      = ifelse(old.stt=='',yaml::read_yaml("~/.sr/credentials")$testtoken,old.stt)
  
  Sys.setenv(sysrev.testtoken=tk)
  Sys.setenv(SYSREV_TOKEN    =tk)
  withr::defer({ 
    Sys.setenv(sysrev.testtoken = old.stt)
    Sys.setenv(SYSREV_TOKEN     = old.st)
  },envir)
  
  tk
}

local_rsr <- function(){
  op = options(srplumber.url=glue::glue("http://0.0.0.0:5216"))
  withr::defer({ options(op) },envir)
}

test_that("setting a label value works", {
  
  token = local_token()
  pid   = 105703 # rsysrev project
  aid   = 13458696
  lid   = "e5772423-7581-4a4a-a0d4-c8c356d2c297"
  uid   = 5804
  
  a.pre  = rsr::get_answers(pid) |> 
    filter(user_id==uid,lid==.env$lid,aid==.env$aid) |> 
    arrange(desc(confirm_time)) |> pull(answer) |> 
    first() == "true"
  
  res    = rsr::review(pid=pid, aid=aid, lid=lid, answer=!a.pre)
  
  a.post = rsr::get_answers(pid) |> 
    filter(user_id==uid,lid==.env$lid,aid==.env$aid) |> 
    arrange(desc(confirm_time)) |> pull(answer) |> 
    first() == "true"
  
  expect_true(all(is.logical(c(a.pre,a.post))))
  expect_true(res$status=="complete")
  expect_true(a.pre != a.post)
})

test_that("can make predictions",{
  pid = 105703
  aid = c(13458696,13458698,13458697)
  lid = rep("e5772423-7581-4a4a-a0d4-c8c356d2c297",3)
  lbl.value = rep(T,3)
  pred = c(0.25,0.75,0.5)
  
  max.pred   = rsr::get_predictions(pid) |> pull(predict_run_id) |> max()
  rsr::create_predictions(pid = pid,aid = aid,lid = lid,lbl.value = lbl.value,pred = pred)
  max.pred.2 = rsr::get_predictions(pid) |> pull(predict_run_id) |> max()
  expect_gt(max.pred.2,max.pred)
})

# test_that("bad rsr::review error messages #18", {
#   pid = 119089
#   aid = 14866903
#   lid = "e9859059-2012-4b4e-87d8-95b96ff74b7b" # a category var with "1" and "2"
#   err = rsr::review(pid,aid,"",2,change = T, resolve = F)  
# })

# test_that("concordance is correct", {
#   token   = local_token()
#   pid     = 43140
#   tbls    = rsr::get_answers_list(pid,token)
#   
#   # no conflicts in 43140
#   concs = c("concordant","resolved","single")
#   expect_setequal(tbls$basic$consensus,concs)
#   
#   # resolved examples
#   tbls$basic |> inner_join(tbls$Actor,by="aid") |> with({
#     expect_equal(conc.status.x,conc.status.y)
#   })
#   test.aid = 11161239
#   
#   expect_equal(
#     tbls$basic |> filter(aid==11161239) |> pull(conc.status),
#     "resolved")
# })






for what it's worth, transforming the json sysrev generates for 'group' labels into tables is not that difficult, although our schema could be better. The difficult thing ends up being concordance and collapsing concordant answers into one answer. If that isn't important for phymdos, then writing your own list_answers should not be too difficult.








