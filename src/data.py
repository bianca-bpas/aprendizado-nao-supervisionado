import pandas as pd


def carregar_iris():
    """Carrega e valida a base Iris padrão."""

    iris = pd.read_csv("data/iris.data.csv")

    X = iris.iloc[:, 0:4]
    y = iris.iloc[:, -1]

    assert len(y) == len(X), "X e y possuem tamanhos diferentes."

    # Verificar valores ausentes
    assert not X.isna().any().any(), "Existem valores ausentes em X."
    assert not y.isna().any(), "Existem rótulos ausentes em y."

    # Verificar distribuição das espécies
    assert y.nunique() == 3, "Quantidade inesperada de espécies."
    
    return X, y


if __name__ == "__main__":
    X, y = carregar_iris()

    print("Dimensões de X:", X.shape)
    print("Quantidade de rótulos:", len(y))
    print("\nCaracterísticas:")
    print(X.head())

    print("\nDistribuição das espécies:")
    print(y.value_counts().sort_index())
    