# %% Load libraries
import pandas as pd
from palmerpenguins import load_penguins
# %%

df_py = load_penguins()
df_py
# %% Hack your df
def _count(df, by):
    return (
        df
        .groupby(by)
        .size()
        .to_frame()
        .reset_index()
        .rename(columns={0: 'n'})
    )


def _agg_by_col(df, by, col, agg='sum', asc=False):
    return (
        df
        .groupby(by, as_index=False)
        [col]
        .agg(agg)
        .sort_values(by=col, ascending=asc)
    )


def _my_flatten_cols(self, how="_".join, reset_index=True):
    how = (lambda iter: list(iter)[-1]) if how == "last" else how
    self.columns = [how(filter(None, map(str, levels))) for levels in self.columns.values] \
                    if isinstance(self.columns, pd.MultiIndex) else self.columns
    return self.reset_index() if reset_index else self


def _mask(df, key, function):
    """Returns a filtered dataframe, by applying function to key"""
    return df[function(df[key])]


def _flatten_cols(df):
    df.columns = [
        ' '.join(col).strip() for col in df.columns.values
    ]
    return df


pd.DataFrame.my_flatten_cols = _my_flatten_cols
pd.DataFrame.mask = _mask
pd.DataFrame.flatten_cols = _flatten_cols
pd.DataFrame.count_rows = _count
pd.DataFrame.agg_by_col = _agg_by_col
# %%
# %% Count based on 1 column
(
    df_py
    .count_rows(["species", "island"])
)

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
