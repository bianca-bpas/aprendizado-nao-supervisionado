import json
from pathlib import Path

import numpy as np
import pandas as pd

from apns import metrics
from apns.models import dbscan
from apns.models import hierarchical
from apns.models import kmedoids
from apns.models import treinable_model
from apns.visualization import (
    plot_cluster_assignments,
    plot_dbscan_metrics,
    plot_hierarchical_dendrogram,
    plot_kmedoids_inertia,
    plot_kmedoids_silhouette,
)


def evaluate_kmeanslike_model(
    x,
    y,
    model_cls: type[treinable_model.ITreinableModel],
    max_n_cluster=5,
    max_iter=10,
):
    results = []
    for k in range(1, max_n_cluster + 1):
        for iter in range(max_iter):
            model = model_cls.create(n_clusters=k, random_state=iter)
            model.fit(x)

            clusters = model.predict(x)
            silhouete = metrics.calcular_silhueta(x, model.predict(x))
            results.append(
                {
                    "model_name": model_cls.__name__,
                    "iter": iter,
                    "k": k,
                    "silhouette": silhouete,
                    "rand_score": metrics.calcular_ari(y, clusters),
                }
            )
    return pd.DataFrame(results)


def evaluate_hierarchical_model(
    x: pd.DataFrame,
    y: pd.Series,
    max_n_cluster: int = 5,
    max_iter: int = 10,
) -> pd.DataFrame:
    return evaluate_kmeanslike_model(
        x=x,
        y=y,
        model_cls=hierarchical.HierarchicalCentroid,
        max_n_cluster=max_n_cluster,
        max_iter=max_iter,
    )


def export_hierarchical_results(
    x: pd.DataFrame,
    y: pd.Series,
    max_n_cluster: int = 5,
    max_iter: int = 10,
    results_dir: Path | None = None,
) -> pd.DataFrame:
    results = evaluate_hierarchical_model(
        x=x,
        y=y,
        max_n_cluster=max_n_cluster,
        max_iter=max_iter,
    )

    if results_dir is None:
        project_root = Path(__file__).resolve().parents[2]
        results_dir = project_root / "results"

    tables_dir = results_dir / "tables"
    figures_dir = results_dir / "figures"
    tables_dir.mkdir(parents=True, exist_ok=True)
    figures_dir.mkdir(parents=True, exist_ok=True)

    results.to_csv(tables_dir / "hierarchical_metrics.csv", index=False)

    model = hierarchical.HierarchicalCentroid.create(
        n_clusters=2,
        random_state=0,
    )
    model.fit(x)
    dendrogram_fig = plot_hierarchical_dendrogram(model.linkage_matrix_)
    dendrogram_fig.savefig(figures_dir / "hierarchical_dendrogram.png")

    return results


def evaluate_kmedoids_model(
    x: pd.DataFrame,
    y: pd.Series,
    metric: str = "cityblock",
    max_n_cluster: int = 5,
    max_iter: int = 10,
) -> pd.DataFrame:
    results = []
    for k in range(1, max_n_cluster + 1):
        for iteration in range(max_iter):
            model = kmedoids.KMedoids.create(
                n_clusters=k,
                metric=metric,
                random_state=iteration,
            )
            model.fit(x)

            clusters = model.predict(x)
            results.append(
                {
                    "model_name": kmedoids.KMedoids.__name__,
                    "iter": iteration,
                    "k": k,
                    "metric": metric,
                    "silhouette": metrics.calcular_silhueta(
                        x,
                        clusters,
                        metric=metric,
                    ),
                    "inertia": model.inertia_,
                    "rand_score": metrics.calcular_ari(y, clusters),
                    "labels": json.dumps(clusters.tolist()),
                }
            )
    return pd.DataFrame(results)


def test_kmedoids_model(
    x: pd.DataFrame,
    metric: str = "cityblock",
) -> kmedoids.KMedoids:
    model = kmedoids.KMedoids.create(
        n_clusters=2,
        metric=metric,
        random_state=0,
    )
    model.fit(x)
    return model


def select_best_kmedoids_by_k(results: pd.DataFrame) -> pd.DataFrame:
    best_indices = results.groupby("k")["inertia"].idxmin()
    return results.loc[best_indices].sort_values("k").reset_index(drop=True)


def select_best_kmedoids_configuration(results: pd.DataFrame) -> pd.DataFrame:
    valid_results = results.dropna(subset=["silhouette"])
    best_index = valid_results["silhouette"].idxmax()
    return results.loc[[best_index]].reset_index(drop=True)


def export_kmedoids_results(
    x: pd.DataFrame,
    y: pd.Series,
    metric: str = "cityblock",
    max_n_cluster: int = 5,
    max_iter: int = 10,
    results_dir: Path | None = None,
) -> pd.DataFrame:
    results = evaluate_kmedoids_model(
        x=x,
        y=y,
        metric=metric,
        max_n_cluster=max_n_cluster,
        max_iter=max_iter,
    )

    if results_dir is None:
        project_root = Path(__file__).resolve().parents[2]
        results_dir = project_root / "results"

    tables_dir = results_dir / "tables"
    figures_dir = results_dir / "figures"
    tables_dir.mkdir(parents=True, exist_ok=True)
    figures_dir.mkdir(parents=True, exist_ok=True)

    results.to_csv(tables_dir / "kmedoids_metrics.csv", index=False)
    best_by_k = select_best_kmedoids_by_k(results)
    best_configuration = select_best_kmedoids_configuration(results)
    best_by_k.to_csv(tables_dir / "kmedoids_best_by_k.csv", index=False)
    best_configuration.to_csv(
        tables_dir / "kmedoids_best_configuration.csv",
        index=False,
    )

    silhouette_fig = plot_kmedoids_silhouette(results)
    silhouette_fig.savefig(figures_dir / "kmedoids_silhouette.png")
    inertia_fig = plot_kmedoids_inertia(results)
    inertia_fig.savefig(figures_dir / "kmedoids_inertia.png")
    kmedoids_labels = json.loads(best_configuration.iloc[0]["labels"])
    clusters_fig = plot_cluster_assignments(
        x,
        kmedoids_labels,
        "K-Medoids: melhor agrupamento por silhueta",
    )
    clusters_fig.savefig(figures_dir / "kmedoids_clusters.png")

    return results


def evaluate_dbscan_model(
    x: pd.DataFrame,
    y: pd.Series,
    eps: float,
    minpts: int,
    distance: str = "euclidean",
) -> pd.DataFrame:
    model = dbscan.DBSCAN.create(
        eps=eps,
        minpts=minpts,
        distance=distance,
    )

    model.fit(x)
    clusters = model.predict(x)
    n_clusters = len(set(clusters) - {-1})
    pontos_validos = clusters != -1
    n_ruido = int(np.sum(~pontos_validos))
    silhouete = (
        None
        if n_clusters < 2
        else metrics.calcular_silhueta(
            x.loc[pontos_validos],
            clusters[pontos_validos],
        )
    )

    return pd.DataFrame(
        [
            {
                "model_name": dbscan.DBSCAN.__name__,
                "eps": eps,
                "minpts": minpts,
                "distance": distance,
                "n_clusters": n_clusters,
                "n_ruido": n_ruido,
                "silhouette": silhouete,
                "rand_score": metrics.calcular_ari(y, clusters),
                "labels": json.dumps(clusters.tolist()),
            }
        ]
    )


def export_dbscan_results(
    x: pd.DataFrame,
    y: pd.Series,
    eps_values: list[float],
    minpts_values: list[int],
    distance: str = "euclidean",
    results_dir: Path | None = None,
) -> pd.DataFrame:
    results = [
        evaluate_dbscan_model(
            x=x,
            y=y,
            eps=eps,
            minpts=minpts,
            distance=distance,
        )
        for eps in eps_values
        for minpts in minpts_values
    ]
    all_results = pd.concat(results, ignore_index=True)

    if results_dir is None:
        project_root = Path(__file__).resolve().parents[2]
        results_dir = project_root / "results"

    tables_dir = results_dir / "tables"
    figures_dir = results_dir / "figures"
    tables_dir.mkdir(parents=True, exist_ok=True)
    figures_dir.mkdir(parents=True, exist_ok=True)

    plots = plot_dbscan_metrics(all_results)
    all_results.to_csv(tables_dir / "dbscan_metrics.csv", index=False)
    plots.silhouette_fig.savefig(figures_dir / "dbscan_silhouette.png")
    plots.noise_fig.savefig(figures_dir / "dbscan_noise.png")

    selected_result = evaluate_dbscan_model(
        x=x,
        y=y,
        eps=0.6,
        minpts=5,
        distance=distance,
    )
    selected_result.to_csv(
        tables_dir / "dbscan_selected_configuration.csv",
        index=False,
    )
    selected_labels = json.loads(selected_result.iloc[0]["labels"])
    selected_clusters_fig = plot_cluster_assignments(
        x,
        selected_labels,
        "DBSCAN: agrupamento selecionado",
    )
    selected_clusters_fig.savefig(figures_dir / "dbscan_clusters.png")

    return all_results
