
test_that("setting a label value works", {
  pid = 105703
  aid = 13458696
  lid = "e5772423-7581-4a4a-a0d4-c8c356d2c297"
  cat(get_srtoken())
  res = review(pid,aid,lid,lval = T)
  expect_true(res$setLabels)
})
