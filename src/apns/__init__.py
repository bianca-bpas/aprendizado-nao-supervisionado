from apns import data
from apns.experiments import evaluate_dbscan_model


def main() -> None:
    X, y = data.carregar_iris("data/iris.data.csv")

    print("Dimensões de X:", X.shape)
    print("Quantidade de rótulos:", len(y))
    print("\nDistribuição das espécies:")
    print(y.value_counts().sort_index())

    dbscan_results = evaluate_dbscan_model(
        x=X,
        y=y,
        eps=0.5,
        minpts=5,
        distance="euclidean",
    )
    print("\nResultado do DBSCAN:")
    print(dbscan_results.to_string(index=False))


if __name__ == "__main__":
    main()
