from pathlib import Path

import numpy as np
import pandas as pd

from apns import metrics
from apns.models import dbscan
from apns.models import treinable_model
from apns.visualization import plot_dbscan_metrics


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
    plots.silhouette_fig.write_html(figures_dir / "dbscan_silhouette.html")
    plots.noise_fig.write_html(figures_dir / "dbscan_noise.html")
    plots.silhouette_fig.write_image(figures_dir / "dbscan_silhouette.png")
    plots.noise_fig.write_image(figures_dir / "dbscan_noise.png")

    return all_results


