from dataclasses import dataclass

import matplotlib.pyplot as plt
import pandas as pd
import plotly
import plotly.express as px
from scipy.cluster.hierarchy import dendrogram
from matplotlib.figure import Figure

px.defaults.height = 480  # pyright: ignore[reportAttributeAccessIssue]
px.defaults.width = 640  # pyright: ignore[reportAttributeAccessIssue]


@dataclass
class KMeansLikeMetrics:
    rand_score_fig: plotly.graph_objs.Figure
    silhouette_fig: plotly.graph_objs.Figure
    best_metrics_per_n_clusters: pd.DataFrame


@dataclass
class DBSCANMetrics:
    silhouette_fig: Figure
    noise_fig: Figure
    metrics: pd.DataFrame


def plot_iris_data(
    x: pd.DataFrame,
    y: pd.Series,
    title: str = "Iris Dataset",
) -> plotly.graph_objs.Figure:
    iris = x.copy()
    iris["species"] = y.to_numpy()

    return px.scatter_matrix(
        iris,
        dimensions=x.columns,
        color="species",
        title=title,
        labels={column: column.replace("_", " ").title() for column in x.columns},
    )


def plot_kmedoids_silhouette(df_resultados: pd.DataFrame) -> Figure:
    figure, axis = plt.subplots(figsize=(8, 5))
    axis.plot(
        df_resultados["k"],
        df_resultados["silhouette"],
        marker="o",
    )
    axis.set_xlabel("Número de clusters (k)")
    axis.set_ylabel("Silhouette")
    axis.set_title("K-medoids: Silhouette × k")
    axis.set_xticks(range(1, 6))
    axis.grid()
    figure.tight_layout()
    return figure


def plot_kmedoids_inertia(df_resultados: pd.DataFrame) -> Figure:
    figure, axis = plt.subplots(figsize=(8, 5))
    axis.plot(
        df_resultados["k"],
        df_resultados["inertia"],
        marker="o",
    )
    axis.set_xlabel("Número de clusters (k)")
    axis.set_ylabel("Inertia")
    axis.set_title("K-medoids: Inertia × k")
    axis.set_xticks(sorted(df_resultados["k"].unique()))
    axis.grid()
    figure.tight_layout()
    return figure


def plot_cluster_assignments(
    x: pd.DataFrame,
    labels,
    title: str,
) -> Figure:
    figure, axis = plt.subplots(figsize=(8, 5))
    scatter = axis.scatter(
        x.iloc[:, 0],
        x.iloc[:, 1],
        c=labels,
        cmap="tab10",
        edgecolors="black",
        linewidths=0.3,
    )
    axis.set_xlabel(x.columns[0])
    axis.set_ylabel(x.columns[1])
    axis.set_title(title)
    figure.colorbar(scatter, ax=axis, label="Rótulo do cluster")
    figure.tight_layout()
    return figure


def plot_hierarchical_dendrogram(
    linkage_matrix,
    title: str = "Agrupamento hierárquico: dendrograma",
) -> Figure:
    figure, axis = plt.subplots(figsize=(12, 6))
    dendrogram(linkage_matrix, ax=axis)
    axis.set_xlabel("Observações")
    axis.set_ylabel("Distância")
    axis.set_title(title)
    figure.tight_layout()
    return figure


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


def plot_dbscan_metrics(
    df_metrics: pd.DataFrame,
    model_name: str = "DBSCAN",
):
    silhouette_metrics = df_metrics.dropna(subset=["silhouette"])
    silhouette_fig, silhouette_axis = plt.subplots(figsize=(8, 5))
    for minpts, group in silhouette_metrics.groupby("minpts"):
        group = group.sort_values("eps")
        silhouette_axis.plot(
            group["eps"],
            group["silhouette"],
            marker="o",
            label=f"min_samples={minpts}",
        )
    silhouette_axis.set_xlabel("eps")
    silhouette_axis.set_ylabel("Silhouette")
    silhouette_axis.set_title(f"{model_name}: Silhouette por eps")
    silhouette_axis.grid()
    silhouette_axis.legend()
    silhouette_fig.tight_layout()

    noise_fig, noise_axis = plt.subplots(figsize=(8, 5))
    for minpts, group in df_metrics.groupby("minpts"):
        group = group.sort_values("eps")
        noise_axis.plot(
            group["eps"],
            group["n_ruido"],
            marker="o",
            label=f"min_samples={minpts}",
        )
    noise_axis.set_xlabel("eps")
    noise_axis.set_ylabel("Pontos de ruído")
    noise_axis.set_title(f"{model_name}: Pontos de ruído por eps")
    noise_axis.grid()
    noise_axis.legend()
    noise_fig.tight_layout()

    return DBSCANMetrics(
        silhouette_fig=silhouette_fig,
        noise_fig=noise_fig,
        metrics=df_metrics,
    )
