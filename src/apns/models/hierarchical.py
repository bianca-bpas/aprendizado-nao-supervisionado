import numpy as np
import pandas as pd

from scipy.cluster.hierarchy import cut_tree, linkage

from apns.models import treinable_model


class HierarchicalCentroid(treinable_model.ITreinableModel):
    def __init__(self, n_clusters: int):
        self.n_clusters = n_clusters
        self.linkage_matrix_ = None
        self.n_samples_ = None

    @classmethod
    def create(cls, n_clusters: int, random_state: int):
        return cls(n_clusters=n_clusters)

    def fit(self, x: pd.DataFrame | np.ndarray) -> None:
        x = np.asarray(x, dtype=float)
        self.n_samples_ = len(x)
        self.linkage_matrix_ = linkage(
            x,
            method="centroid",
            metric="euclidean"
        )

    def predict(self, x: pd.DataFrame | np.ndarray) -> np.ndarray:
        x = np.asarray(x)
        
        return self.get_clusters(self.n_clusters)

    def get_clusters(self, k):
        labels = cut_tree(
            self.linkage_matrix_,
            n_clusters=k
        ).flatten()

        return labels