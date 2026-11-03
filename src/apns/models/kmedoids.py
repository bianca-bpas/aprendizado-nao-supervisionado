import numpy as np
import pandas as pd
from sklearn_extra.cluster import KMedoids as SklearnKMedoids

from apns.models import treinable_model


class KMedoids(treinable_model.ITreinableModel):
    def __init__(self, model: SklearnKMedoids):
        self._model = model
        self.medoid_indices_: np.ndarray | None = None
        self.labels_: np.ndarray | None = None
        self.inertia_: float | None = None

    @classmethod
    def create(cls, n_clusters: int, metric: str, random_state: int) -> "KMedoids":
        return cls(
            SklearnKMedoids(
                n_clusters=n_clusters,
                metric=metric,
                method="alternate",
                init="heuristic",
                max_iter=300,
                random_state=random_state,
            )
        )

    def fit(self, x: pd.DataFrame | np.ndarray) -> None:
        self._model.fit(x)
        self.medoid_indices_ = self._model.medoid_indices_
        self.labels_ = self._model.labels_
        self.inertia_ = self._model.inertia_

    def predict(self, x: pd.DataFrame | np.ndarray) -> np.ndarray:
        return self._model.predict(x)
