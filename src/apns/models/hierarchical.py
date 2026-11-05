from typing import Self

import numpy as np
import pandas as pd

from scipy.cluster.hierarchy import cut_tree, linkage

from apns.models import treinable_model


class HierarchicalCentroid(treinable_model.ITreinableModel):
    def __init__(self, n_clusters: int):
        self.n_clusters = n_clusters
        self.linkage_matrix_: np.ndarray | None = None
        self.n_samples_: int | None = None
        self.labels_: np.ndarray | None = None

    @classmethod
    def create(cls, n_clusters: int) -> Self:
        return cls(n_clusters=n_clusters)

    def fit(self, x: pd.DataFrame | np.ndarray) -> Self:
        x = np.asarray(x, dtype=float)
        self.n_samples_ = len(x)
        self.linkage_matrix_ = linkage(
            x,
            method="centroid",
            metric="euclidean",
        )
        self.labels_ = None
        return self

    def fit_predict(self, x: pd.DataFrame | np.ndarray) -> np.ndarray:
        self.fit(x)
        return self.get_clusters(self.n_clusters)

    def get_clusters(self, k: int | None = None) -> np.ndarray:
        if k is None:
            k = self.n_clusters
        labels = cut_tree(
            self.linkage_matrix_,
            n_clusters=k,
        ).flatten()
        self.labels_ = labels
        return labels