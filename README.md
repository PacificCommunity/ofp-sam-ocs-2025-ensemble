# OCS 2025 Ensemble Results

Download OCS 2025 assessment report:

- **Stock assessment of oceanic whitetip shark in the Western and Central Pacific Ocean: 2025**\
  **[WCPFC-SC21-2025/SA-WP-08](https://meetings.wcpfc.int/node/26650)**

Download OCS 2025 diagnostic model:

- Clone the **[ocs-2025-diagnostic](https://github.com/PacificCommunity/ofp-sam-ocs-2025-diagnostic)** repository or download as **[main.zip](https://github.com/PacificCommunity/ofp-sam-ocs-2025-diagnostic/archive/refs/heads/main.zip)** file

Download OCS 2025 ensemble results:

- Clone the **[ocs-2025-ensemble](https://github.com/PacificCommunity/ofp-sam-ocs-2025-ensemble)** repository or download as **[main.zip](https://github.com/PacificCommunity/ofp-sam-ocs-2025-ensemble/archive/refs/heads/main.zip)** file

## Uncertainty analysis

The stock assessment [report](https://meetings.wcpfc.int/node/26650) describes the MCMC method (2.4.10), uncertainty grid (2.4.11), and results (3.1.5 to 3.1.8).

The uncertainty analysis is based on an ensemble of 36 models with the following grid axes:

Axis               | Levels | Option
------------------ | ------ | -------------------
Growth and M prior |      2 | **Joung**, Seki
LF weighting       |      3 | Low, **Base**, High
SR beta            |      3 | 1, **2**, 4
Discard mortality  |      2 | **Medium**, High

## Ensemble results

The `mcmc_ensemble.rda` file contains the full ensemble results, based on 8 independent MCMC chains for each of the 36 grid models.

The [MCMC_plots.R](MCMC_plots.R) script reads the posterior draws from the `mcmc_ensemble.rda` file and produces plots that can be found in the stock assessment report.

Running the command `Rscript MCMC_plots.R` produces [Rplots.pdf](Rplots.pdf) that contains the following plots:

R plot | Report figure | Notes
------ | ------------- | ----------------------
1      | 37            | Refpts by Growth
2      | 35            | Refpts by LF_weight
3      | 39            | Refpts by Disc
4      | 36            | Refpts by Beta
5      | 42            | F time series
6      | 44            | SB/SB0 time series
7      | -             | RecDev time series
8      | 45            | Multipanel time series
9      | 38            | Time series by Growth
10     | 40            | Time series by Disc
11     | 46            | Majuro

Likewise, running the command `Rscript Table_7_1.R` produces the following CSV file:

Variable     | Mean | Median | SD   | MAD  |   5% |  95%
------------ | ---- | ------ | ---- | ---- | ---- | ----
SBrecent/SB0 | 0.06 | 0.06   | 0.01 | 0.01 | 0.04 | 0.08
Frecent/Fmsy | 1.07 | 1.19   | 0.25 | 0.28 | 0.73 | 1.39
Finit        | 0.21 | 0.21   | 0.03 | 0.04 | 0.16 | 0.27
ln(R0)       | 5.29 | 5.29   | 0.13 | 0.13 | 5.08 | 5.52
M            | 0.15 | 0.15   | 0.01 | 0.01 | 0.13 | 0.17
zfrac        | 0.93 | 0.93   | 0.03 | 0.03 | 0.87 | 0.97
