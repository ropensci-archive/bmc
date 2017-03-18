context("bmc_xml")

test_that("bmc_xml", {
  tt <- bmc_xml()
  
  expect_is(tt, "list")
})
