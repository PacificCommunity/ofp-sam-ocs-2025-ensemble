# OCS 2025 MCMC Analysis

Download OCS 2025 assessment report:

- **Stock assessment of oceanic whitetip shark in the Western and Central Pacific Ocean: 2025**\
  **[WCPFC-SC21-2025/SA-WP-08](https://meetings.wcpfc.int/node/26650)**

Download OCS 2025 diagnostic model:

- Clone the **[ocs-2025-diagnostic](https://github.com/PacificCommunity/ofp-sam-ocs-2025-diagnostic)** repository or download as **[main.zip](https://github.com/PacificCommunity/ofp-sam-ocs-2025-diagnostic/archive/refs/heads/main.zip)** file

Download OCS 2025 MCMC analysis:

- Clone the **[ocs-2025-mcmc](https://github.com/PacificCommunity/ofp-sam-ocs-2025-mcmc)** repository or download as **[main.zip](https://github.com/PacificCommunity/ofp-sam-ocs-2025-mcmc/archive/refs/heads/main.zip)** file

## MCMC results

The stock assessment [report](https://meetings.wcpfc.int/node/26650) describes the MCMC analysis of the Stock Synthesis diagnostic model (Section 2.4.10), as well as the MCMC results (Section 3.1.5).

The [MCMC_plots.R](MCMC_plots.R) script reads the posterior draws from the `mcmc_ensemble.rda` file and produces plots that can be found in the stock assessment report.

Running the command `Rscript MCMC_plots.R` produces [Rplots.pdf](Rplots.pdf) that contains the following plots:

Plot | Figure | Notes
---- | ------ | ----------------------
   1 |     37 | Refpts by Growth
   2 |     35 | Refpts by LF_weight
   3 |     39 | Refpts by Disc
   4 |     36 | Refpts by Beta
   5 |     42 | F time series
   6 |     44 | SB/SB0 time series
   7 |      - | RecDev time series
   8 |     45 | Multipanel time series
   9 |     38 | Time series by Growth
  10 |     40 | Time series by Disc
  11 |     46 | Majuro
