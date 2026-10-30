from apns import data
from apns.experiments import evaluate_dbscan_model


def main() -> None:
    X, y = data.carregar_iris("data/iris.data.csv")

    print("Dimensões de X:", X.shape)
    print("Quantidade de rótulos:", len(y))
    print("\nDistribuição das espécies:")
    print(y.value_counts().sort_index())

    ''' {DBSCAN}
    aumentar eps aumenta o raio de vizinhança. em geral, mais pontos passam a ser alcançáveis e regiões podem se unir
    aumentar minpts aumenta a  quantidade mínima de pontos necessária para formar uma região densa. em geral, fica mais difícil formar regiões e alguns pontos podem virar ruído
    '''
    # TODO verificar a escala dos atributos e padronizar os dados (StandardScaler)

    eps_values = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0]
    minpts_values = [3, 5, 7, 10, 15]

    for eps in eps_values:
        for minpts in minpts_values:
            dbscan_results = evaluate_dbscan_model(
                x=X,
                y=y,
                eps=eps,
                minpts=minpts,
                distance="euclidean",
            )

            print("\nResultado do DBSCAN:")
            print(dbscan_results.to_string(index=False))
            

if __name__ == "__main__":
    main()
