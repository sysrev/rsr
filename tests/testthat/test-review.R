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
  local_token()

  pid   = 105703
  aid   = 13458696
  lid   = "e5772423-7581-4a4a-a0d4-c8c356d2c297"
  uid   = 5804

  ans = \(){get_answers(pid) |> filter(user_id==uid,lid==lid,aid==aid) |> pull(answer)=="true"}

  ans.pre  = ans()
  res      = review(pid=pid, aid=aid, lid=lid, answer=!ans.pre)
  ans.post = ans()

  expect_true(all(is.logical(c(ans.pre,ans.post))))
  expect_true(res$setLabels)
  expect_true(ans.pre != ans.post)
})

# TODO waiting on sysrev permissions update
# test_that("Landing page README should work", {
#   local_token()
#
#   # Create/get a sysrev project
#   sr = create_sysrev("rsr",get_if_exists=T)
#
#   # Import articles from pubmed with pmids
#   pmids=c(1000,10001)
#   create_source_pmids(sr,name="test",pmids=pmids)
#
#   # pull article data into R
#   art = get_articles(sr)
#
#   expect_true()
#   expect_true(res$setLabels)
#   expect_true(ans.pre != ans.post)
# })
