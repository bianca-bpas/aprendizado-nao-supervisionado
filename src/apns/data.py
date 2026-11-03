import pandas as pd


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
