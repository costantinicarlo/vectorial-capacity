library(testthat)
library(shiny)

repo_root <- normalizePath(test_path("..", ".."), mustWork = TRUE)

load_script <- function(filename) {
  environment <- new.env(parent = globalenv())
  sys.source(file.path(repo_root, filename), envir = environment)
  environment
}

output_html <- function(value) {
  if (is.list(value) && !is.null(value$html)) {
    return(as.character(value$html))
  }
  as.character(value)
}

set_default_inputs <- function(session, m_current = 10) {
  session$setInputs(
    p = 0.8,
    h = 0.5,
    g = 2.5,
    n = 12,
    D = 80,
    b = 0.3,
    c = 0.5,
    m_current = m_current
  )
}

test_that("classical vectorial-capacity calculation is numerically correct", {
  app <- load_script("app.R")

  testServer(app$server, {
    set_default_inputs(session)

    expected_a <- 0.5 / 2.5
    expected_mu <- -log(0.8)
    expected_C <- 10 * expected_a^2 * 0.8^12 / expected_mu

    expect_equal(params()$a, expected_a, tolerance = 1e-12)
    expect_equal(params()$mu, expected_mu, tolerance = 1e-12)
    expect_equal(c_current(), expected_C, tolerance = 1e-12)
    expect_equal(c_current(), 0.12318433820968594, tolerance = 1e-12)
  })
})

test_that("scenario reproduction number is C times b times c times D", {
  app <- load_script("app.R")

  testServer(app$server, {
    set_default_inputs(session)

    expected_R <- c_current() * 0.3 * 0.5 * 80

    expect_equal(r_current(), expected_R, tolerance = 1e-12)
    expect_equal(r_current(), 1.478212058516231, tolerance = 1e-12)
    expect_match(output_html(output$R_current), "scenario reproduction number")
    expect_match(
      output_html(output$R_current),
      "\\(R=1.48\\)",
      fixed = TRUE
    )
  })
})

test_that("human biting rate is m times per-mosquito human blood-feeding rate", {
  app <- load_script("app.R")

  testServer(app$server, {
    set_default_inputs(session)

    expect_equal(hbr_current(), 10 * (0.5 / 2.5), tolerance = 1e-12)
    expect_equal(hbr_current(), 2, tolerance = 1e-12)
    expect_match(output_html(output$HBR_current), "human biting rate")
    expect_match(
      output_html(output$HBR_current),
      "\\(\\mathrm{HBR}=2.000\\)",
      fixed = TRUE
    )
  })
})

test_that("critical mosquito density returns R exactly equal to one", {
  app <- load_script("app.R")

  testServer(app$server, {
    set_default_inputs(session)
    par <- params()

    m_star <- critical_vector_density(
      par$mu, par$D, par$b, par$c, par$a, par$p, par$n
    )
    C_star <- vectorial_capacity(m_star, par$a, par$p, par$n, par$mu)
    R_star <- scenario_reproduction_number(C_star, par$b, par$c, par$D)

    expect_equal(m_star, 6.76492925516897, tolerance = 1e-12)
    expect_equal(R_star, 1, tolerance = 1e-12)
    expect_match(output_html(output$criticalM), "Critical mosquito density")
    expect_match(
      output_html(output$criticalM),
      "\\(R=1\\)",
      fixed = TRUE
    )
  })
})

test_that("critical HBR returns the unit transmission threshold", {
  app <- load_script("app.R")

  testServer(app$server, {
    set_default_inputs(session)
    par <- params()

    hbr_star <- critical_hbr(
      par$mu, par$D, par$b, par$c, par$a, par$p, par$n
    )
    m_star <- hbr_star / par$a
    C_star <- vectorial_capacity(m_star, par$a, par$p, par$n, par$mu)
    R_star <- scenario_reproduction_number(C_star, par$b, par$c, par$D)

    expect_equal(hbr_star, 1.352985851033794, tolerance = 1e-12)
    expect_equal(R_star, 1, tolerance = 1e-12)
    expect_match(output_html(output$criticalHBR), "Critical human biting rate")
    expect_match(
      output_html(output$criticalHBR),
      "\\(\\mathrm{HBR}^*=1.35\\)",
      fixed = TRUE
    )
  })
})

test_that("expected infectious lifespan metric has the intended interpretation", {
  app <- load_script("app.R")

  testServer(app$server, {
    set_default_inputs(session)
    par <- params()

    expected_per_emergent_mosquito <- par$p^par$n / par$mu
    expected_conditional_remaining_life <- 1 / par$mu

    expect_equal(
      expected_per_emergent_mosquito,
      0.3079608455242148,
      tolerance = 1e-12
    )
    expect_equal(
      expected_conditional_remaining_life,
      4.481420117724551,
      tolerance = 1e-12
    )
    expect_match(output_html(output$e), "per mosquito at emergence")
    expect_match(
      output_html(output$e),
      "\\(p^n/\\mu\\)",
      fixed = TRUE
    )
  })
})

test_that("main app handles zero human blood feeding without failing", {
  app <- load_script("app.R")

  testServer(app$server, {
    session$setInputs(
      p = 0.8,
      h = 0,
      g = 2.5,
      n = 12,
      D = 80,
      b = 0.3,
      c = 0.5,
      m_current = 10
    )

    expect_equal(c_current(), 0)
    expect_equal(hbr_current(), 0)
    expect_equal(r_current(), 0)
    expect_match(
      output_html(output$criticalM),
      "no finite critical mosquito density"
    )
    expect_match(output_html(output$criticalHBR), "undefined")
    expect_silent(output$CPlot)
  })
})

test_that("zero mosquito density produces zero C, HBR and R", {
  app <- load_script("app.R")

  testServer(app$server, {
    set_default_inputs(session, m_current = 0)

    expect_equal(c_current(), 0)
    expect_equal(hbr_current(), 0)
    expect_equal(r_current(), 0)
    expect_match(
      output_html(output$C_current),
      "\\(C=0.000",
      fixed = TRUE
    )
    expect_match(
      output_html(output$HBR_current),
      "\\(\\mathrm{HBR}=0.000\\)",
      fixed = TRUE
    )
    expect_match(
      output_html(output$R_current),
      "\\(R=0.00\\)",
      fixed = TRUE
    )
  })
})

test_that("zero transmission probabilities or infectious duration imply R equals zero", {
  app <- load_script("app.R")

  testServer(app$server, {
    session$setInputs(
      p = 0.8,
      h = 0.5,
      g = 2.5,
      n = 12,
      D = 0,
      b = 0.3,
      c = 0.5,
      m_current = 10
    )

    expect_equal(r_current(), 0)
    expect_match(
      output_html(output$criticalM),
      "no finite critical mosquito density"
    )
    expect_match(output_html(output$R_regime), "no transmission")
  })
})
