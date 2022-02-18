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

test_that("setting a label value works", {
  
  token = local_token()
  pid   = 105703 # rsysrev project
  aid   = 13458696
  lid   = "e5772423-7581-4a4a-a0d4-c8c356d2c297"
  uid   = 5804
  
  a.pre  = rsr::get_answers(pid) |> 
    filter(user_id==uid,lid==.env$lid,aid==.env$aid) |> 
    pull(answer)=="true"
  
  
  res    = rsr::review(pid=pid, aid=aid, lid=lid, answer=!a.pre)
  
  a.post = rsr::get_answers(pid) |> 
    filter(user_id==uid,lid==.env$lid,aid==.env$aid) |> 
    pull(answer)=="true"
  
  expect_true(all(is.logical(c(a.pre,a.post))))
  expect_true(res$status=="complete")
  expect_true(a.pre != a.post)
})

test_that("concordance is correct", {
  # tok   = local_token()
  pid   = 43140
  tbls  = rsr::get_answers_list(pid,token)
  
  # no conflicts in 43140
  concs = c("concordant","resolved","single")
  expect_setequal(tbls$basic$consensus,concs)
  
  # resolved examples
  tbls$basic |> inner_join(tbls$Actor,by="aid") |> with({
    expect_equal(conc.status.x,conc.status.y)
  })
  test.aid = 11161239
  
  expect_equal(
    tbls$basic |> filter(aid==11161239) |> pull(conc.status),
    "resolved")
})















