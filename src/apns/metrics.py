from sklearn.metrics import (
    adjusted_rand_score,
    silhouette_score,
)


def calcular_silhueta(X, labels, metric="euclidean"):
    """Calcula a silhueta quando há pelo menos dois grupos válidos."""
    labels = list(labels)
    grupos = set(labels)

    if len(grupos) < 2 or len(grupos) >= len(labels):
        return None

    return silhouette_score(X, labels, metric=metric)


def calcular_ari(y_real, labels):
    """Compara os agrupamentos com os rótulos reais."""
    return adjusted_rand_score(y_real, labels)
