import dataclasses
from pathlib import Path

import pandas as pd

from apns.data import (
    carregar_iris,
    carregar_iris_normalizado,
    normalizar_atributos,
)
from apns.experiments import (
    _prepare_results_directories,
    _save_figure,
    _save_table,
    _select_best_row,
    evaluate_em_model,
    evaluate_fuzzy_kmeans_model,
    evaluate_kernel_pca_grid,
    evaluate_kernel_pca_model,
    evaluate_kmeanslike_model,
    evaluate_pca_model,
    export_comparacao_algoritmos,
    export_dbscan_results,
    export_hierarchical_results,
    export_kernel_fuzzy_kmeans_results,
    export_kmedoids_results,
    export_tsne_results,
    export_umap_results,
    test_kmedoids_model,
)
from apns.models import treinable_model
from apns.models.gaussian_mixture import GaussianMixture
from apns.models.kmeans import KMeans
from apns.models.kmeans_fuzzy import KMeansFuzzy
from apns.visualization import (
    plot_component_scatter,
    plot_silhouette_by_k,
    plot_variance_explained,
)


@dataclasses.dataclass
class KMeansLikeConfig:
    cls: type[treinable_model.IKMeansLikeModel]
    prefix: str
    pretty_name: str


kmeans_like_configs = [
    KMeansLikeConfig(KMeans, "kmeans", "K-Means"),
    KMeansLikeConfig(KMeansFuzzy, "fuzzy_kmeans", "Fuzzy K-Means"),
    KMeansLikeConfig(GaussianMixture, "em", "EM"),
]


def _best_kmeanslike_per_k(rows: pd.DataFrame) -> pd.DataFrame:
    """Best run per k, minimizing the model objective. Pure: no I/O."""
    return (
        rows.loc[rows.groupby("k")["objective"].idxmin()]
        .sort_values("k")
        .reset_index(drop=True)
    )


def _best_fuzzy_per_k(rows: pd.DataFrame) -> pd.DataFrame:
    """Joint (k, m) search: min J_m per (k, m), then max silhouette per k.

    The smallest m wins silhouette ties, so the selection is deterministic.
    The returned frame has one row per k, which is what the Sil x k curve
    and the final k* selection need.
    """
    best_pm = rows.loc[
        rows.groupby(["k", "m"])["objective"].idxmin()
    ]
    return (
        best_pm.sort_values(
            ["k", "silhouette", "m"],
            ascending=[True, False, True],
        )
        .drop_duplicates("k")
        .sort_values("k")
        .reset_index(drop=True)
    )


def export_kmeans_like_results(
    configs: list[KMeansLikeConfig],
    results_dir: Path | None = None,
) -> dict[str, pd.DataFrame]:
    x, y = carregar_iris_normalizado()
    tables_dir, figures_dir = _prepare_results_directories(results_dir)

    fuzzy_m_values = [1.5, 2.0, 2.5]
    em_cov_types = ["spherical", "diag", "tied", "full"]

    best_by_model: dict[str, pd.DataFrame] = {}
    for config in configs:
        if config.cls is GaussianMixture:
            rows = evaluate_em_model(x, y, covariance_types=em_cov_types)
            # Per (k, cov_type): lowest -logLik over seeds (same family).
            # Per k: lowest BIC over cov_types (penalizes complexity).
            best_seed = rows.loc[
                rows.groupby(["k", "covariance_type"])["objective"].idxmin()
            ].reset_index(drop=True)
            best = (
                best_seed.loc[best_seed.groupby("k")["bic"].idxmin()]
                .sort_values("k")
                .reset_index(drop=True)
            )
        elif config.cls is KMeansFuzzy:
            rows = evaluate_fuzzy_kmeans_model(x, y, m_values=fuzzy_m_values)
            # Single joint search over (k, m): within each pair, the seed
            # with the lowest J_m wins (same scale); among the pairs, the
            # one with the highest silhouette wins. The Sil x k curve shows
            # the best m per k; k* is the k of the globally selected pair.
            best = _best_fuzzy_per_k(rows)
        else:
            rows = evaluate_kmeanslike_model(x, y, config.cls)
            best = _best_kmeanslike_per_k(rows)

        _save_table(rows, tables_dir, f"{config.prefix}_metrics.csv")
        _save_table(best, tables_dir, f"{config.prefix}_best_by_k.csv")
        _save_figure(
            plot_silhouette_by_k(best, config.pretty_name),
            figures_dir / f"{config.prefix}_silhouette.png",
        )

        best_by_model[config.pretty_name] = best

        chosen = _select_best_row(best, metric="silhouette")
        print(
            f"{config.pretty_name}: k*={int(chosen['k'])}, "
            f"silhueta={chosen['silhouette']:.4f}, ARI={chosen['ari']:.4f}"
        )

    return best_by_model


def export_pca_results(results_dir: Path | None = None) -> pd.DataFrame:
    x, y = carregar_iris_normalizado()
    tables_dir, figures_dir = _prepare_results_directories(results_dir)
    result = evaluate_pca_model(x, y)

    _save_table(result.variance, tables_dir, "pca_variance.csv")
    _save_table(result.components, tables_dir, "pca_components.csv")
    _save_table(result.metrics, tables_dir, "pca_embedding_metrics.csv")
    _save_figure(
        plot_variance_explained(
            result.variance,
            "PCA: variância explicada por componente",
        ),
        figures_dir / "pca_variance.png",
    )
    _save_figure(
        plot_component_scatter(
            result.embedding,
            y,
            x_label="Componente principal 1",
            y_label="Componente principal 2",
            title="PCA: duas primeiras componentes",
        ),
        figures_dir / "pca_scatter.png",
    )
    return result.variance


def export_kernel_pca_results(
    kernel: str = "rbf",
    gamma_values: list[float | None] | None = None,
    results_dir: Path | None = None,
) -> pd.DataFrame:
    if gamma_values is None:
        gamma_values = [0.05, 0.1, 0.25, 0.5, 1.0]
    x, y = carregar_iris_normalizado()
    tables_dir, figures_dir = _prepare_results_directories(results_dir)

    grid = evaluate_kernel_pca_grid(
        x, y, kernel=kernel, gamma_values=gamma_values
    )
    _save_table(grid, tables_dir, "kpca_metrics.csv")

    best_row = (
        grid.dropna(subset=["trustworthiness"])
        .sort_values(
            ["trustworthiness", "silhouette"],
            ascending=[False, False],
        )
        .iloc[0]
    )
    best_gamma = best_row["gamma"]
    result = evaluate_kernel_pca_model(x, y, kernel=kernel, gamma=best_gamma)

    _save_table(result.variance, tables_dir, "kpca_variance.csv")
    _save_table(result.metrics, tables_dir, "kpca_embedding_metrics.csv")
    _save_figure(
        plot_variance_explained(
            result.variance,
            f"Kernel PCA ({kernel}, gamma={best_gamma:g}): variância explicada",
            max_components=10,
        ),
        figures_dir / "kpca_variance.png",
    )
    _save_figure(
        plot_component_scatter(
            result.embedding,
            y,
            x_label="Componente kernel 1",
            y_label="Componente kernel 2",
            title=f"Kernel PCA ({kernel}, gamma={best_gamma:g}): duas primeiras componentes",
        ),
        figures_dir / "kpca_scatter.png",
    )
    print(
        f"Kernel PCA: melhor gamma={best_gamma:g}, "
        f"trustworthiness={best_row['trustworthiness']:.4f}, "
        f"silhueta interna={best_row['silhouette']:.4f}, "
        f"silhueta externa={best_row['external_silhouette']:.4f}"
    )
    return result.variance


def main() -> None:
    X, y = carregar_iris()
    X_normalizado = normalizar_atributos(X)

    print("Dimensões de X:", X.shape)
    print("Quantidade de rótulos:", len(y))
    print("\nDistribuição das espécies:")
    print(y.value_counts().sort_index())

    print("\n--- Executando K-Means, Fuzzy K-Means e Misturas Gaussianas (EM) ---")
    kmeans_like_results = export_kmeans_like_results(configs=kmeans_like_configs)

    print(
        "\n--- Executando os algoritmos de agrupamento DBSCAN, K-Medoids, UPGMC, Kernel Fuzzy K-Means ---"
    )

    """ {DBSCAN}
    aumentar eps aumenta o raio de vizinhança. em geral, mais pontos passam a ser alcançáveis e regiões podem se unir
    aumentar minpts aumenta a  quantidade mínima de pontos necessária para formar uma região densa. em geral, fica mais difícil formar regiões e alguns pontos podem virar ruído
    """

    eps_values = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0]
    minpts_values = [3, 5, 7, 10, 15]
    dbscan_results = export_dbscan_results(
        x=X_normalizado,
        y=y,
        eps_values=eps_values,
        minpts_values=minpts_values,
        distance="euclidean",
    )
    print("\nResultados e gráficos do DBSCAN exportados.")

    """ {K-Medoids}
    """
    test_kmedoids_model(X_normalizado, metric="cityblock")
    kmedoids_results = export_kmedoids_results(
        x=X_normalizado,
        y=y,
        metric="cityblock",
        max_n_cluster=5,
        max_iter=10,
    )
    print("\nResultados e gráficos do K-Medoids exportados.")

    hierarchical_results = export_hierarchical_results(
        x=X_normalizado,
        y=y,
        max_n_cluster=5,
    )
    print("\nResultados e gráfico do agrupamento hierárquico exportados.")

    kernel_fuzzy_kmeans_results = export_kernel_fuzzy_kmeans_results(
        x=X_normalizado,
        y=y,
        max_n_cluster=5,
        max_iter=10,
        m_values=[1.5, 2.0, 2.5],
        sigma2_values=[None, 0.5, 1.0, 2.0],
        n_init=5,
    )
    print("\nResultados do Kernel Fuzzy K-Means exportados.")

    comparison = export_comparacao_algoritmos(
        {
            **kmeans_like_results,
            "DBSCAN": dbscan_results,
            "K-Medoids": kmedoids_results,
            "Hierárquico": hierarchical_results,
            "Kernel Fuzzy K-Means": kernel_fuzzy_kmeans_results,
        }
    )
    print("\nComparação dos algoritmos:")
    print(comparison)

    print(
        "\n--- Executando os algoritmos de redução de dimensionalidade "
        "PCA, Kernel PCA, t-SNE e UMAP ---"
    )

    pca_variance = export_pca_results()
    print("\nVariância explicada por componente (PCA):")
    print(pca_variance)

    kernel_pca_variance = export_kernel_pca_results()
    print("\nResultados e gráfico do Kernel PCA exportados.")
    print(kernel_pca_variance)

    export_tsne_results(
        x=X_normalizado,
        y=y,
        perplexity_values=[5.0, 10.0, 20.0, 30.0],
    )
    print("\nResultados e gráfico do t-SNE exportados.")

    export_umap_results(
        x=X_normalizado,
        y=y,
        n_neighbors_values=[5, 10, 15, 30],
        min_dist_values=[0.0, 0.1, 0.5],
    )
    print("\nResultados e gráficos do UMAP exportados.")


if __name__ == "__main__":
    main()
