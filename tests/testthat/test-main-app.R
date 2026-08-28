library(testthat)
library(shiny)

repo_root <- normalizePath(test_path("..", ".."), mustWork = TRUE)

load_script <- function(filename) {
  environment <- new.env(parent = globalenv())
  sys.source(file.path(repo_root, filename), envir = environment)
  environment
}

test_that("main app handles zero biting without failing", {
  app <- load_script("app.R")

  testServer(app$server, {
    session$setInputs(
      p = 0.8, h = 0, g = 2.5, n = 12,
      D = 80, b = 0.3, c = 0.5, m_current = 10
    )

    expect_equal(c_current(), 0)
    expect_match(output$criticalM, "no finite critical vector density")
    expect_silent(output$CPlot)
  })
})

test_that("main app reports zero vector density as zero transmission", {
  app <- load_script("app.R")

  testServer(app$server, {
    session$setInputs(
      p = 0.8, h = 0.5, g = 2.5, n = 12,
      D = 80, b = 0.3, c = 0.5, m_current = 0
    )

    expect_equal(c_current(), 0)
    expect_match(output$C_current, "C = 0")
    expect_match(output$R0_current, "R₀ = 0")
  })
})
