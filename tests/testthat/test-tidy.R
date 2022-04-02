library(testthat)

test_that("tidying answers works", {
    # TODO add some checks on results
    rsr::get_answers(81395) |>
      filter(user_id==139) |>
      rsr::tidy_answers(81395)
})

test_that("creating a tidy list works", {
  tbls <- rsr::get_answers(81395) |> rsr::list_answers()
})
