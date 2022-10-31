"""compare ROI based analysis with FAST and AR1"""

import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path
import pandas as pd
from rich import print

debug = False

root_dir = Path(__file__).parents[3]
input_dir = root_dir.joinpath(
    "outputs", "derivatives", "bidspm-stats", "derivatives", "bidspm-groupStats"
)
print(root_dir)

model = "TissueConfounds"  # Model 3 : visual, auditory, hand regions
# model = "default"  # Model 1 : olfactory regions

if model == "TissueConfounds":
    input_file_ar1 = input_dir.joinpath("group_model-3_psc.tsv")
    input_file_fast = input_dir.joinpath("group_model-3_desc-FAST_psc.tsv")

elif model == "default":
    input_file_ar1 = input_dir.joinpath("group_model-1_psc.tsv")
    input_file_fast = input_dir.joinpath("group_model-1_desc-FAST_psc.tsv")

fast = pd.read_csv(input_file_fast, sep="\t")
ar1 = pd.read_csv(input_file_ar1, sep="\t")

subjects = fast["subject"].unique()
roi = fast["roi"].unique()
hemi = fast["hemi"].unique()
contrast = fast["contrast"].unique()

ar1_velues = []

combined_data = {
    "subjects": [],
    "roi": [],
    "hemi": [],
    "contrast": [],
    "ar1": [],
    "fast": [],
}

for i, s in enumerate(subjects):

    if debug and i > 5:
        break

    for j, r in enumerate(roi):

        if debug and j > 5:
            break

        print(f"sub {s} roi {r}")

        for h in hemi:
            for c in contrast:
                this_filter = (
                    (fast["subject"] == s)
                    & (fast["roi"] == r)
                    & (fast["hemi"] == h)
                    & (fast["contrast"] == c)
                )

                ar1_value = ar1.psc_abs_max[this_filter].values
                fast_value = fast.psc_abs_max[this_filter].values

                if ar1_value.size > 0 and fast_value.size > 0:
                    combined_data["subjects"].append(s)
                    combined_data["roi"].append(r)
                    combined_data["hemi"].append(h)
                    combined_data["contrast"].append(c)
                    combined_data["ar1"].append(ar1_value[0])
                    combined_data["fast"].append(fast_value[0])

combined_df = pd.DataFrame(combined_data)


sns.set_theme(style="dark")

# Draw a scatter plot while assigning point colors and sizes to different
# variables in the dataset
fig, ax = plt.subplots(figsize=(12, 12))
sns.despine(fig, left=True, bottom=True)

sns.scatterplot(
    x="fast",
    y="ar1",
    data=combined_df,
    hue="subjects",
    palette="ch:r=-.2,d=.3_r",
    hue_order=subjects,
    linewidth=0,
    ax=ax,
)

sns.histplot(x="fast", y="ar1", data=combined_df, bins=50, pthresh=0.1, cmap="mako")
sns.kdeplot(x="fast", y="ar1", data=combined_df, levels=6, color="w", linewidths=1)

MAX = max(combined_df.ar1.max(), combined_df.fast.max())
MIN = min(combined_df.ar1.min(), combined_df.fast.min())

plt.xlim([MIN, MAX])
plt.ylim([MIN, MAX])

plt.plot(
    [MIN, MAX],
    [MIN, MAX],
    color="black",
    marker="o",
    linestyle="dashed",
    linewidth=2,
    markersize=12,
)

fig.suptitle("FAST vs AR1")
fig.show()
fig.savefig("output.png", bbox_inches="tight")
