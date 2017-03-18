context("bmc_search")

test_that("bmc_search", {
  tt <- bmc_search()
  
  expect_is(tt, "list")
})
