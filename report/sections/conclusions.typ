#let conclusions = [

  = Conclusões <sec:conclusoes>

  A análise mostrou que os métodos de agrupamento tendem a selecionar $k = 2$ pela silhueta, formando um grupo bem definido para _setosa_ e reunindo _versicolor_ e _virginica_. K-Means, Fuzzy K-Means e Kernel Fuzzy K-Means obtiveram silhueta próxima de 0,580 e ARI próximo de 0,568; o EM obteve o melhor ARI do estudo em $k = 3$ (0,904), embora $k = 2$ tenha sido favorecido pela silhueta e pelo BIC.

  O K-Medoids favoreceu $k = 2$ pela silhueta (0,608) e $k = 3$ pelo ARI (0,665). O Hierárquico Centroid Linkage selecionou $k = 2$ pela silhueta e obteve ARI 0,568. O DBSCAN selecionou `eps` = 0,7 e `minpts` = 5, com silhueta 0,610, ARI 0,573 e cobertura de 94,7%. Configurações com baixa cobertura alcançaram métricas superiores, mas não representam uma segmentação comparável da base completa.

  Nas reduções de dimensionalidade, a PCA concentrou 95,8% da variância nas duas primeiras componentes e obteve trustworthiness 0,978. O Kernel PCA selecionou $gamma = 0,05$ pela maior trustworthiness (0,976); em $gamma = 0,25$, a silhueta interna foi maior (0,667), mas a trustworthiness foi menor (0,932). O t-SNE selecionou perplexidade 20 pela trustworthiness (0,990) e atingiu o limite de 1000 iterações sem confirmar convergência formal. O UMAP obteve a maior trustworthiness do grid (0,980) com `n_neighbors` = 15 e `min_dist` = 0,5.

  Assim, não houve um método universalmente superior. A interpretação dos resultados deve combinar silhueta, ARI, cobertura e preservação de vizinhanças: a separação da _setosa_ é consistente, enquanto _versicolor_ e _virginica_ permanecem parcialmente sobrepostas. Permanecem limitações relacionadas à validação externa, à estabilidade das execuções e à comparabilidade de métricas calculadas com distâncias diferentes.
]