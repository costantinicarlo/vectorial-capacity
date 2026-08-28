# Vectorial Capacity & $R_0$ Explorer

An interactive Shiny application for exploring the Macdonald-Garrett-Jones framework of malaria transmission dynamics, focusing on vectorial capacity and the basic reproduction number ($R_0$).

## Overview

This educational tool allows users to manipulate entomological and epidemiological parameters to understand how vector control interventions affect malaria transmission potential. The app implements the classical Ross-Macdonald model framework that has guided malaria control policy for decades.

## Scope

### What This App Does

- **Visualizes vectorial capacity** as a function of vector density
- **Calculates $R_0$** (basic reproduction number) under different scenarios
- **Identifies critical thresholds** for transmission elimination
- **Compares intervention strategies** through preset scenarios
- **Shows vector survivorship** under exponential mortality

### What This App Does Not Do

- Model malaria incidence or prevalence over time
- Account for spatial heterogeneity or seasonal variation
- Include superinfection, immunity acquisition, or drug resistance
- Represent host heterogeneity in exposure or susceptibility
- Model genetic interventions in mechanistic detail

## Biological & Mathematical Background

### Vectorial Capacity ($C$)

The vectorial capacity represents the **daily rate at which future inoculations arise from a single infectious case**:

$$C = \frac{ma^2p^n}{\mu}$$

Where:

- **$m$**: vector density (vectors per host)
- **$a$**: human biting rate per vector per day (bites/vector/day)
- **$p$**: daily probability of vector survival (dimensionless)
- **$n$**: extrinsic incubation period (EIP) – days for parasite to develop in mosquito
- **$\mu$**: per-day mortality rate = $-ln(p)$ (1/day)

#### Interpretation

- **$m$**: How many vectors are available per host
- **$a^2$**: Two bites required (host → vector, then vector → host)
- **$p^n$**: Probability vector survives long enough to become infectious
- **$1/\mu$**: Expected remaining lifespan once infectious

### Basic Reproduction Number ($R_0$)

$R_0$ represents the **expected number of secondary infections arising from one primary infection** in a completely susceptible population:

$$R_0 = C \times b \times c \times D$$

Where:

- **$b$**: probability that a bite by an infectious mosquito infects a human
- **$c$**: probability that a bite on an infectious human infects a mosquito
- **$D$**: duration of human infectiousness (gametocytaemia) in days

#### Threshold Principle

- **$R_0 < 1$**: Transmission cannot be sustained (each case produces <1 secondary case)
- **$R_0 = 1$**: Threshold – transmission at equilibrium
- **$R_0 > 1$**: Transmission can be sustained (epidemic potential)

### Human Biting Rate ($a$)

The daily human biting rate is derived from:

$$a = \frac{h}{g}$$

Where:

- **$h$**: probability of feeding on host per gonotrophic cycle
- **$g$**: duration of gonotrophic cycle (days)

**Caveat**: This assumes all blood meals are successful and no more than one blood meal per cycle.

### Vector Mortality

The model assumes **exponential mortality** with constant hazard rate:

- **Survival function**: $S(t) = p^t$
- **Mortality rate**: $\mu = -ln(p)$
- **Life expectancy at emergence**: $E[T] = 1/\mu$ days
- **Expected infectious life per mosquito at emergence**: $E_{inf} = p^n/\mu$ days
- **Conditional remaining life after surviving the EIP**: $1/\mu$ days

## Installation & Usage

### Requirements

```r
install.packages(c("shiny", "testthat"))
```

### Running the App

Run the application from its directory so Shiny can resolve `www/` assets consistently.

**Option 1: From R/RStudio**

```r
library(shiny)
runApp("path/to/Vectorial-Capacity")
```

**Option 2: Directly from file**

Open [app.R](app.R) in RStudio and click "Run App"

**Option 3: Online**

Visit the deployed app at: <https://carlo-costantini.shinyapps.io/Vectorial_Capacity/>

## Using the App

### Parameters

#### Vector & Parasite Parameters

- **$p$** (0.5–0.99): Daily survival probability – small changes have large effects
- **$h$** (0–1): Probability of feeding on humans per cycle
- **$g$** (1–6 days): Gonotrophic cycle length
- **$n$** (8–50 days): Extrinsic incubation period (EIP)

#### Human & Infection Parameters

- **$D$** (0–200 days): Duration of gametocytaemia
- **$b$** (0–1): Mosquito → human transmission probability
- **$c$** (0–1): Human → mosquito transmission probability

#### Current Scenario

- **$m$** (0–200): Current vector density (vectors/host)

### Preset Scenarios

The app includes five illustrative scenarios motivated by common malaria-control strategies. Their parameter values are teaching examples, not empirical intervention-effect estimates:

1. **Baseline High Transmission**: Representative of holoendemic areas with *Anopheles gambiae*
2. **LLINs** (Long-Lasting Insecticidal Nets): Reduced host contact + modest mortality
3. **IRS** (Indoor Residual Spraying): Strong mortality increase
4. **Partial Immunity**: Shorter infectious period + reduced transmission efficiency
5. **Genetic/Larval Suppression**: Dramatic reduction in vector density

### Outputs

#### Plots

- **Vectorial Capacity _vs._ Vector Density**: Shows $C(m)$ on log scales with $R_0=1$ threshold
- **Survivorship Curve**: Shows $S(t) = p^t$ for first 30 days

#### Key Metrics

- **Critical vector density** for $R_0 = 1$
- **Critical human biting rate** for $R_0 = 1$
- **Expected infectious life per mosquito at emergence** (days)
- **Expected lifespan at emergence** (days)
- **Current $C$ and $R_0$** for chosen parameters
- **Transmission regime** classification

#### Summary Table

Displays all parameters and calculated values with units

## Interpreting Results

### Sensitivity Insights

Parameters do **not** contribute equally to $C$ or $R_0$:

- **Survival ($p$)** has exponential effects via $p^n$ and $\mu = -ln(p)$
- **Biting rate ($a$)** has quadratic effects via $a²$
- **Vector density ($m$)** has linear effects
- **Human infectious duration ($D$)** has a linear effect
- **EIP ($n$)** has a nonlinear effect through $p^n$

### Policy Implications

1. **Adult mortality can dominate transmission reductions** when survival is highly sensitive to insecticide exposure
2. **Multiple interventions** may be needed when baseline $R_0$ >> 1
3. **Vector density reduction** has a constant proportional effect in this linear model
4. **Behavior change** affecting biting rate ($a$) is highly impactful (quadratic effect)

## Caveats & Limitations

### Model Assumptions

- **Homogeneous mixing**: All hosts equally exposed
- **Constant parameters**: No seasonality or spatial variation
- **Exponential mortality**: Constant hazard, no senescence
- **No density dependence**: Larval ecology ignored
- **Equilibrium framework**: No transient dynamics
- **Single parasite strain**: No drug resistance or mixed infections

### Biological Simplifications

- Assumes one blood meal per gonotrophic cycle
- Ignores unsuccessful feeding attempts
- No explicit immunity dynamics
- No superinfection in vectors or hosts
- No vector or host age structure; age-dependent vector mortality is planned for a later release

## References

### Foundational Papers

1. **Garrett-Jones, C. & Grab, B. (1964).** The assessment of insecticidal impact on the malaria mosquito's vectorial capacity, from data on the proportion of parous females. *Bulletin of the World Health Organization*, 31:71-86.

2. **Macdonald, G. (1955).** The measurement of malaria transmission. *Proceedings of the Royal Society of Medicine*, 48:295-301.

3. **Ross, R. (1911).** *The Prevention of Malaria* (2nd ed.). London: John Murray.

### Modern Extensions

4. **Smith, D.L., Battle, K.E., Hay, S.I., Barker, C.M., Scott, T.W., & McKenzie, F.E. (2012).** Ross, Macdonald, and a theory for the dynamics and control of mosquito-transmitted pathogens. *PLoS Pathogens*, 8(4):e1002588.

5. **Brady, O.J., Godfray, H.C.J., Tatem, A.J., et al. (2016).** Vectorial capacity and vector control: reconsidering sensitivity to parameters for malaria elimination. *Transactions of the Royal Society of Tropical Medicine and Hygiene*, 110(2):107-117.

## File Structure

```
.
├── .gitignore                         # Repository exclusions
├── app.R                              # Shiny application
├── README.md                          # Documentation
├── Vectorial-Capacity.Rproj           # RStudio project
├── tests/testthat/test-main-app.R     # Main-app regression tests
└── www/Anopheles.jpg                  # Decorative image
```

## Testing and Reproducibility

Run the regression suite with:

```r
testthat::test_dir("tests/testthat")
```

For reproducible deployments, initialize `renv` and commit the generated `renv.lock`; the lockfile is intentionally not ignored.

## Contributing

This is an educational tool. Suggestions for improvements, additional preset scenarios, or clearer documentation are welcome.

## License

Educational use freely permitted. Please cite appropriately if used in teaching or research contexts.

---

**Standing on the shoulders of giants**: This app implements classical malaria epidemiology theory developed by Nobel Prize winner Ronald Ross, George Macdonald, Christopher Garrett-Jones, and many others who established the quantitative foundations of vector-borne disease control.
