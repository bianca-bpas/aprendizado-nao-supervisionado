import pandas as pd

from apns import metrics
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
