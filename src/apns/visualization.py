from dataclasses import dataclass

import pandas as pd
import plotly
import plotly.express as px

px.defaults.height = 480  # pyright: ignore[reportAttributeAccessIssue]
px.defaults.width = 640  # pyright: ignore[reportAttributeAccessIssue]


@dataclass
class KMeansLikeMetrics:
    rand_score_fig: plotly.graph_objs.Figure
    silhouette_fig: plotly.graph_objs.Figure
    best_metrics_per_n_clusters: pd.DataFrame


# TODO require a pandera/typed d
def plot_kmeans_like_metrics(df_metrics: pd.DataFrame, model_name: str):
    # TODO rename labels
    # TODO decide if this is the best plot
    # TODO decide if its desirable to see teh distrbution of metrics per iteration or if a simple line plot of the .max() does the job
    rand_score_fig = px.box(
        df_metrics,
        x="k",
        y="rand_score",
        boxmode="group",
        points="all",
        title=f"{model_name} Rand Index",
    )

    silhouette_fig = px.box(
        df_metrics,
        x="k",
        y="silhouette",
        boxmode="group",
        points="all",
        title=f"{model_name} Silhouette Score",
    )

    best_values = df_metrics.groupby(["k", "model_name"])[
        ["silhouette", "rand_score"]
    ].max()
    best_values = best_values.rename(
        columns={
            "silhouette": "Max silhouette",
            "rand_score": "Max Rand Index",
        }
    )

    return KMeansLikeMetrics(
        rand_score_fig=rand_score_fig,
        silhouette_fig=silhouette_fig,
        best_metrics_per_n_clusters=best_values,
    )
