import numpy as np
import pandas as pd
import sklearn.cluster

from apns.models import treinable_model


class DBSCAN(treinable_model.ITreinableModel):
    def __init__(self, model: sklearn.cluster.DBSCAN):
        self._model = model

    @classmethod
    def create(cls, eps: float, minpts: int, distance: str) -> "DBSCAN":
        return cls(
            sklearn.cluster.DBSCAN(
                eps=eps,
                min_samples=minpts,
                metric=distance,
            )
        )

    def fit(self, x: pd.DataFrame | np.ndarray) -> None:
        self._model.fit(x)

    def predict(self, x: pd.DataFrame | np.ndarray) -> np.ndarray:
        return self._model.labels_
