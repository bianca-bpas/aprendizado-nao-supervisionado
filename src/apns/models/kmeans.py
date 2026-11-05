from typing import Self

import numpy as np
import pandas as pd
import sklearn.cluster

from apns.models import treinable_model


class KMeans(treinable_model.ITreinableModel):
    def __init__(self, model: sklearn.cluster.KMeans):
        self._model = model

    @classmethod
    def create(cls, n_clusters: int, random_state: int) -> Self:
        return cls(
            sklearn.cluster.KMeans(
                n_clusters=n_clusters,
                init="random",
                random_state=random_state,
                n_init=1,
            )
        )

    def fit(self, x: pd.DataFrame | np.ndarray) -> Self:
        self._model.fit(x)
        return self

    def predict(self, x: pd.DataFrame | np.ndarray) -> np.ndarray:
        return self._model.predict(x)
