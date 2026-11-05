from apns import data
from apns.experiments import (
    export_dbscan_results,
    export_hierarchical_results,
    export_kmedoids_results,
    test_kmedoids_model,
)


def main() -> None:
    X, y = data.carregar_iris("data/iris.data.csv")

    print("Dimensões de X:", X.shape)
    print("Quantidade de rótulos:", len(y))
    print("\nDistribuição das espécies:")
    print(y.value_counts().sort_index())

    """ {DBSCAN}
    aumentar eps aumenta o raio de vizinhança. em geral, mais pontos passam a ser alcançáveis e regiões podem se unir
    aumentar minpts aumenta a  quantidade mínima de pontos necessária para formar uma região densa. em geral, fica mais difícil formar regiões e alguns pontos podem virar ruído
    """

    eps_values = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0]
    minpts_values = [3, 5, 7, 10, 15]
    export_dbscan_results(
        x=X,
        y=y,
        eps_values=eps_values,
        minpts_values=minpts_values,
        distance="euclidean",
    )
    print("\nResultados e gráficos do DBSCAN exportados.")

    """ {K-Medoids}
    """
    test_kmedoids_model(X, metric="cityblock")
    export_kmedoids_results(
        x=X,
        y=y,
        metric="cityblock",
        max_n_cluster=5,
        max_iter=10,
    )
    print("\nResultados e gráficos do K-Medoids exportados.")

    export_hierarchical_results(
        x=X,
        y=y,
        max_n_cluster=5,
        max_iter=1,
    )
    print("\nResultados e gráfico do agrupamento hierárquico exportados.")


if __name__ == "__main__":
    main()
