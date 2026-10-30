import numpy as np
import pandas as pd

from apns import metrics
from apns.models import dbscan
from apns.models import treinable_model


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


