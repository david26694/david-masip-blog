# %% Load libraries
import pandas as pd
from palmerpenguins import load_penguins
# %%

df_py = load_penguins()
df_py
# %% Count based on 1 column
(
    df_py
    .groupby("species")
    .size()
    .to_frame()
    .reset_index()
    .rename(columns={0: 'n'})
)
# %% Count based on 2 columns
(
    df_py
    .groupby(["species", "island"])
    .size()
    .to_frame()
    .reset_index()
    .rename(columns={0: 'n'})
)
# %% Manny aggregates per column


def flatten_cols(df_py):
    df_py.columns = [' '.join(col).strip() for col in df_py.columns.values]
    return df_py

(
    df_py
    .groupby(["species", "island"], as_index=False)
    .agg({
        "bill_length_mm": ["mean", "median"],
        "flipper_length_mm": ["count"]
    })
    .pipe(flatten_cols)
)

# %% Group by filter (having)
(
    df_py
    .groupby(["species", "island"], as_index=False)
    .filter(lambda x: len(x) > 70)
)

# %% Group by mutate
mean_bill_length = (
    df_py
    .loc[:, ["species", "island", "bill_length_mm"]]
    .groupby(["species", "island"], as_index=False)
    .transform(lambda x: x.mean())
)

df_py["mean_bill_length"] = mean_bill_length

# %% Count relative
full_counts = (
    df_py
    .groupby(["species", "island"])
    .size()
    .to_frame()
    .reset_index()
    .rename(columns={0: 'n'})
)

agg_counts = (
    full_counts
    .groupby("species")
    .transform(lambda x: x.sum())["n"]
)

full_counts["agg_counts"] = agg_counts

full_counts["fraction"] = full_counts["n"] / full_counts["agg_counts"]

full_counts

# %% Agg with two columns
(
    df_py
    .groupby("species")
    .apply(lambda d: (d["bill_depth_mm"] / d["bill_length_mm"]).mean())
    .to_frame()
    .reset_index()
    .rename(columns={0: "depth_length_ratio"})
)
