from typing import Self

import fcmeans
import numpy as np
import pandas as pd

from apns.models import treinable_model


# TODO verify that the parameters are as required in the specs
# TODO verify that the FCM implementation is as required
class FuzzyKMeans(treinable_model.ITreinableModel):
    def __init__(self, model: fcmeans.FCM):
        self._model = model

    @classmethod
    def create(cls, n_clusters: int, random_state: int) -> Self:
        return cls(
            fcmeans.FCM(
                n_clusters=n_clusters,
                random_state=random_state,
            )
        )

    def fit(self, x: pd.DataFrame | np.ndarray) -> Self:
        self._model.fit(x)
        return self

    def predict(self, x: pd.DataFrame | np.ndarray) -> np.ndarray:
        return self._model.predict(x)
