# testthat::test_that("tidying answers works", {
#     # TODO add some checks on results
#     rsr::get_answers(81395) |>
#       filter(user_id==139) |>
#       rsr::tidy_answers(81395)
# })

# testthat::test_that("creating a tidy list works", {
#   # complicated entries
#   complicated = rsr::get_answers(81395) |> rsr::list_answers()  
#   # saveRDS(complicated,"inst/test_obj/test-tidy/complicated.RDS")
#   cached      = readRDS("inst/test_obj/test-tidy/complicated.RDS")
#   assertthat::assert_that(purrr::is_empty(waldo::compare(complicated,cached)))
  
#   # this one has some weird empty tables
#   emptytables <- rsr::get_answers(70431) |> rsr::list_answers()
#   # saveRDS(emptytables,"inst/test_obj/test-tidy/emptytables.RDS")
#   cached      = readRDS("inst/test_obj/test-tidy/emptytables.RDS")
#   assertthat::assert_that(purrr::is_empty(waldo::compare(emptytables,cached)))
# })
