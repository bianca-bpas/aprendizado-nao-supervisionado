from typing import Protocol, Self

import numpy as np
import pandas as pd


class ITrainableModel(Protocol):
    def fit(self, x: pd.DataFrame | np.ndarray) -> Self: ...


class IPredictiveModel(ITrainableModel, Protocol):
    @classmethod
    def create(cls, n_clusters: int, random_state: int) -> Self: ...

    def predict(self, x: pd.DataFrame | np.ndarray) -> np.ndarray: ...


class ITransductiveModel(ITrainableModel, Protocol):
    def fit_predict(self, x: pd.DataFrame | np.ndarray) -> np.ndarray: ...


ITreinableModel = ITrainableModel
