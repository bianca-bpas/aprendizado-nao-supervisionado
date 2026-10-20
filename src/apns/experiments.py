import pandas as pd

from apns import metrics
from apns.data import padronizar_iris
from apns.models import dbscan
from apns.models import treinable_model


def _evaluate_fitted_model(
    model: treinable_model.ITreinableModel,
    x: pd.DataFrame,
    y: pd.Series,
    parameters: dict[str, object],
) -> dict[str, object]:
    model.fit(x)
    clusters = model.predict(x)

    return {
        **parameters,
        "silhouette": metrics.calcular_silhueta(x, clusters),
        "rand_score": metrics.calcular_ari(y, clusters),
    }


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
    return pd.DataFrame(
        [
            _evaluate_fitted_model(
                model,
                x,
                y,
                {
                    "model_name": dbscan.DBSCAN.__name__,
                    "eps": eps,
                    "minpts": minpts,
                    "distance": distance,
                },
            )
        ]
    )


def evaluate_dbscan_original_and_standardized(
    x: pd.DataFrame,
    y: pd.Series,
    eps: float,
    minpts: int,
    distance: str = "euclidean",
) -> dict[str, pd.DataFrame]:
    datasets = {
        "original": x,
        "standardized": padronizar_iris(x),
    }
    results = {
        name: evaluate_dbscan_model(
            x=dataset,
            y=y,
            eps=eps,
            minpts=minpts,
            distance=distance,
        )
        for name, dataset in datasets.items()
    }
    results["x_standardized"] = datasets["standardized"]

    return results
