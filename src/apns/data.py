import pandas as pd
from sklearn.preprocessing import StandardScaler


def carregar_iris(path: str = "data/iris.data.csv"):
    """Carrega e valida a base Iris padrão."""

    iris = pd.read_csv(
        path,
        names=["sepal_length", "sepal_width", "petal_length", "petal_width", "species"],
    )

    X = iris.iloc[:, 0:4]
    y = iris.iloc[:, -1]

    assert not X.isna().any().any()
    assert not y.isna().any()
    return X, y


def padronizar_iris(x: pd.DataFrame) -> pd.DataFrame:
    """Padroniza as características da base Iris para média zero e desvio um."""
    scaler = StandardScaler()
    x_scaled = scaler.fit_transform(x)

    return pd.DataFrame(x_scaled, columns=x.columns, index=x.index)
