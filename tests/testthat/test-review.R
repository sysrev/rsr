local_token <- function(){
  old.token = Sys.getenv("SYSREV_TOKEN")
  token     = Sys.getenv("SYSREV_TEST_TOKEN")

  Sys.setenv(SYSREV_TOKEN = token)
  withr::defer_parent({Sys.setenv(SYSREV_TOKEN = old.token)})
  token
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
