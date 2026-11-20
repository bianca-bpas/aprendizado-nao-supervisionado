#let results-and-discussions = [
  = Resultados e discussões

  == K-Means

  Foram realizadas 40 execuções, com $k in {2, 3, 4, 5}$ e dez sementes por valor de $k$, com a heurística de inicialização padrão _kmeans++_. Para cada $k$, foi selecionada a execução de menor SSE e, entre as quatro partições resultantes, o número de grupos foi escolhido por $k^* = "arg max"_k "Sil"(k)$. A @tab:kmeans resume os resultados.

  #figure(
    table(
      columns: 4,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*$k$*], [*Silhouette*], [*ARI*], [*SSE*]),
      table.hline(),
      [2], [0,580], [0,568], [223,7],
      [3], [0,459], [0,620], [141,0],
      [4], [0,387], [0,472], [114,4],
      [5], [0,343], [0,415], [91,1],
      table.hline(),
    ),
    caption: [K-Means (dados padronizados, `k-means++`): métricas da execução de menor SSE em cada $k$.],
    kind: table,
  ) <tab:kmeans>

  A silhueta é máxima em $k = 2$ (0,580), de modo que $k^* = 2$, e a partição correspondente tem ARI de 0,568 (@fig:kmeans-sil). Em $k = 2$ as dez sementes convergiram para a mesma solução, indicando a estabilidade desse particionamento.

  #figure(
    image("../imagens/kmeans_silhouette.png", width: 100%),
    caption: [Silhouette em função do número de clusters $k$ (K-Means).],
  ) <fig:kmeans-sil>

  A partição com $k^* = 2$ isola as 50 _setosa_ em um grupo e reúne as 100 observações de _versicolor_ e _virginica_ no outro. A silhueta reflete a separação da _setosa_, mas o ARI decorre da fusão entre _versicolor_ e _virginica_. A silhueta decresce de $k = 2$ até $k = 5$, enquanto o ARI é máximo em $k = 3$ (0,620), com silhueta de 0,459. A divergência entre os critérios é similar à observada no K-Medoids, em que a silhueta favorece 2 grupos, mas o ARI 3. Nessa partição de $k = 3$, a _setosa_ permanece isolada, mas 25 das 100 observações das outras espécies não pertencem ao respectivo grupo majoritário. Com $k = 4$ e $k = 5$, a _setosa_ passa a ser subdividida (27/23), acompanhada do decrescimento de ambas as métricas.

  == K-Medoids

  Foram realizadas 40 execuções, com $k in {2, 3, 4, 5}$ e dez sementes por valor de $k$. Para cada $k$, as execuções produziram soluções idênticas em silhueta, inércia, ARI e rótulos devido à inicialização heurística fixa utilizada pelo modelo. Assim, essas repetições representam determinismo da configuração, não estimativas independentes de estabilidade. A @tab:kmedoids resume os resultados.

  #figure(
    table(
      columns: 4,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*$k$*], [*Silhouette*], [*ARI*], [*Inércia*]),
      table.hline(),
      [2], [0,608], [0,531], [270,2],
      [3], [0,488], [0,665], [208,1],
      [4], [0,370], [0,611], [200,4],
      [5], [0,293], [0,492], [187,2],
      table.hline(),
    ),
    caption: [K-Medoids (distância city-block)],
    kind: table,
  ) <tab:kmedoids>

  A silhueta diminui com $k$ (@fig:kmed-sil), atingindo o máximo em $k = 2$ (0,608). Como neste método a silhueta foi calculada com a distância city-block, os valores não são diretamente comparáveis às silhuetas euclidianas dos demais métodos de agrupamento. A inércia também diminui continuamente (@fig:kmed-inercia). Entre $k = 2$ e $k = 3$, a queda é de 62,1 (23,0%); em seguida, passa a 7,7 (3,7%) e a 13,2 (6,6%), sem um cotovelo tão pronunciado.

  #figure(
    image("../imagens/kmedoids_silhouette.png", width: 100%),
    caption: [Silhouette em função do número de agrupamentos $k$ (K-Medoids).],
  ) <fig:kmed-sil>

  #figure(
    image("../imagens/kmedoids_inertia.png", width: 100%),
    caption: [Inércia em função do número de agrupamentos $k$ (K-Medoids).],
  ) <fig:kmed-inercia>

  A análise externa mostra que o ARI é máximo em $k = 3$ (0,665). Em todas as configurações, os 50 exemplares de _Iris setosa_ ficam isolados em um agrupamento, e as diferenças principais ocorrem na região de sobreposição entre _versicolor_ e _virginica_. Para $k = 2$, um agrupamento reúne as 50 _setosa_ e 2 _versicolor_, e o outro reúne 48 _versicolor_ e as 50 _virginica_. A silhueta elevada reflete a separação nítida da _setosa_ em relação ao restante. O ARI é menor porque a partição funde duas espécies.

  #figure(
    image("../imagens/kmedoids_clusters.png", width: 100%),
    caption: [Agrupamento por K-Medoids com $k = 3$, projetado em `petal_length` × `petal_width`; os rótulos indicam a espécie majoritária de cada grupo e os marcadores em formato `X` representam os medóides.],
  ) <fig:kmed-clusters>

  Para $k = 3$, a _setosa_ permanece isolada, mas a separação entre _versicolor_ e _virginica_ é menos precisa: o ARI é 0,665 e a silhueta é 0,488. A @fig:kmed-clusters apresenta essa configuração projetada em comprimento e largura das pétalas. Esse resultado é compatível com a fronteira difusa entre as duas espécies.

  Com $k = 4$ e $k = 5$, os grupos adicionais subdividem a região de _versicolor_ e _virginica_ sem corresponder a novas espécies. Em ambos os casos, a silhueta diminui e o ARI não supera o de $k = 3$.

  Os resultados mostram uma divergência entre os critérios: a silhueta favorece $k = 2$, enquanto o ARI favorece $k = 3$. Assim, $k = 2$ apresenta a melhor separação geométrica, mas $k = 3$ oferece o melhor compromisso com as espécies.

  == Fuzzy K-Means

  Foram realizadas 120 execuções, com $k in {2, 3, 4, 5}$ e $m in {1.5, 2.0, 2.5}$, dez sementes por combinação. Para cada par $(k, m)$, foi selecionada a execução de menor $J_m$. Em seguida, o par $(k, m)$ de maior silhueta foi escolhido, de modo que a curva $"Sil"(k)$ mostra o melhor $m$ para cada $k$. A @tab:fkm resume as quatro partições selecionadas por $k$.

  #figure(
    table(
      columns: 5,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*$k$*], [*$m$*], [*Silhouette*], [*ARI*], [*Objetivo ($J_m$)*]),
      table.hline(),
      [2], [1,5], [0,580], [0,568], [214,8],
      [3], [1,5], [0,459], [0,620], [131,3],
      [4], [2,0], [0,401], [0,588], [74,5],
      [5], [1,5], [0,339], [0,425], [81,2],
      table.hline(),
    ),
    caption: [Fuzzy K-Means (dados padronizados): por $k$, maior silhueta entre os valores de $m$; $J_m$ mínimo entre sementes para o $(k, m)$ selecionado.],
    kind: table,
  ) <tab:fkm>

  A silhueta decresce de 0,580 em $k = 2$ para 0,339 em $k = 5$ (@fig:fkm-sil). O par selecionado foi $(k = 2, m = 1,5)$, com silhueta 0,580 e ARI 0,568; em $k = 2$ os três valores de $m$ produzem a mesma partição e a mesma silhueta, e o empate foi resolvido pelo menor $m$. 

  #figure(
    image("../imagens/fuzzy_kmeans_silhouette.png", width: 100%),
    caption: [Silhouette em função do número de agrupamentos $k$ (Fuzzy K-Means), mostrando o melhor $m$ para cada $k$.],
  ) <fig:fkm-sil>


  Entre as partições selecionadas para cada $k$, o ARI é máximo em $k = 3$ (0,620 com $m = 1,5$), com silhueta 0,459, enquanto a partição de $k^* = 2$ isola as 50 _setosa_ perfeitamente, como no K-Means. O máximo global de ARI no grid é 0,630 ($k = 3$, $m = 2,0$, não incluso na tabela), mas esse par não maximiza a silhueta e não foi selecionado, pelos critérios especificados. Não houve variabilidade entre sementes em $k = 2$ e $k = 3$ para nenhum valor de $m$; em $k = 4$ e $k = 5$ houve mínimos locais, sobretudo em $k = 5$ com $m = 1,5$ (silhueta entre 0,339 e 0,395). Em $k = 3$, 25 das 150 observações (16,7%) ficam fora do grupo majoritário, e em $k = 4$ a _setosa_ passa a ser dividida (49/1).

  Além disso, embora a fuzzificação suavize as fronteiras, uma vez feito _crisp_, o particionamento para $k^*$ do Fuzzy K-Means foi idêntico ao do K-Means, e as métricas se mantêm muito próximas para $k > 2$. A diferença entre $m = 1,5$ e $m = 2,0$ é pequena (por exemplo, 0,459 contra 0,457 em $k = 3$), indicando baixa sensibilidade a $m$ neste conjunto.


  == Kernel Fuzzy K-Means

  Foram realizadas 480 execuções: 48 combinações de $k in {2, 3, 4, 5}$, $m in {1,5; 2,0; 2,5}$ e $sigma^2 in {"automático"; 0,5; 1,0; 2,0}$, com dez sementes por combinação e cinco inicializações internas por execução. Em cada combinação, a menor função objetivo entre as dez sementes identificou a melhor execução. Na @tab:kfkm, essa melhor execução é apresentada por $k$, junto da combinação $(m, sigma^2)$ de maior silhueta para aquele $k$.

  #figure(
    table(
      columns: 6,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*$k$*], [*$m$*], [*$sigma^2$*], [*Silhouette*], [*ARI*], [*Objetivo*]),
      table.hline(),
      [2], [1,5], [1,0], [0,580], [0,568], [76,72],
      [3], [2,5], [0,5], [0,540], [0,529], [24,87],
      [4], [1,5], [2,0], [0,398], [0,587], [34,46],
      [5], [2,5], [1,0], [0,374], [0,495], [10,29],
      table.hline(),
    ),
    caption: [Kernel Fuzzy K-Means: melhor combinação $(m, sigma^2)$ por $k$, segundo a silhueta, após a seleção da melhor semente pela função objetivo dentro de cada combinação.],
    kind: table,
  ) <tab:kfkm>

  A silhueta máxima entre as configurações ocorre em $k = 2$, com $m = 1,5$ e $sigma^2 = 1,0$. A configuração final apresenta silhueta de 0,5802 e ARI de 0,5681. As demais curvas decrescem até $k = 5$, e a única diferença relevante é $k = 4$, cujo ARI é 0,587, mas que não supera a silhueta de $k = 2$. O ARI foi utilizado somente como avaliação externa e não participou da escolha da configuração ou de $k^*$.

  #figure(
    image("../imagens/kernel_fuzzy_kmeans_silhouette.png", width: 100%),
    caption: [Silhouette por $k$ do Kernel Fuzzy K-Means, mostrando a melhor combinação $(m, sigma^2)$ por cada valor de $k$.],
  ) <fig:kfkm-sil>

  A configuração final separa perfeitamente as 50 observações de _setosa_ das demais espécies, conforme a @tab:kfkm-k2-contingencia. As confusões ficam concentradas entre _versicolor_ e _virginica_.

  #figure(
    table(
      columns: 3,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*Espécie*], [*Setosa*], [*Versicolor*]),
      table.hline(),
      [Setosa], [50], [0],
      [Versicolor], [0], [50],
      [Virginica], [0], [50],
      table.hline(),
    ),
    caption: [Contingência entre espécies reais e grupos da melhor configuração por silhueta com $k = 2$.],
    kind: table,
  ) <tab:kfkm-k2-contingencia>

  #figure(
    image("../imagens/kernel_fuzzy_kmeans_k2_silhouette_clusters.png", width: 100%),
    caption: [Melhor configuração por silhueta ($k = 2$, $m = 1,5$, $sigma^2 = 1,0$), projetada em `petal_length` × `petal_width`.],
  ) <fig:kfkm-k2-clusters>

  #figure(
    image("../imagens/kernel_fuzzy_kmeans_k2_silhouette_memberships.png", width: 100%),
    caption: [Graus de pertinência da melhor configuração por silhueta com $k = 2$.],
  ) <fig:kfkm-k2-pert>

  A @fig:kfkm-conv mostra a convergência da função objetivo da configuração final. O objetivo diminui até estabilizar em 76,718 após 18 iterações. Como os valores dependem de $m$ e de $sigma^2$, foram usados apenas para selecionar a melhor semente dentro de cada configuração e não para ordenar configurações diferentes.

  #figure(
    image("../imagens/kernel_fuzzy_kmeans_objective_convergence.png", width: 100%),
    caption: [Convergência da função objetivo da melhor configuração por silhueta ($k = 2$, $m = 1,5$, $sigma^2 = 1,0$).],
  ) <fig:kfkm-conv>

  Em síntese, a busca atual é similar ao procedimento do Fuzzy K-Means: dentro de cada tripla $(k, m, sigma^2)$, a função objetivo escolhe a melhor dentre as dez sementes; em seguida, a silhueta compara as combinações de parâmetros e seleciona o modelo final. Essa abordagem evita que diferenças de escala em $J_m$ decorrentes de $m$ ou $sigma^2$ favoreçam diretamente uma configuração.

  Para fins de comparação entre métodos de agrupamento, a tabela conjunta considera apenas as configurações selecionadas por silhueta, e deve-se considerar que a silhueta do K-Medoids usa distância city-block, enquanto os demais modelos usaram distância euclidiana; no DBSCAN, a métrica é calculada após excluir as observações de ruído e deve ser interpretada junto da cobertura.

  == Misturas gaussianas com EM

  Foi feita a busca de parâmetros com $k in {2, 3, 4, 5}$ e $"covariance_type" in {"spherical", "diag", "tied", "full"}$, dez inicializações cada. Em cada execução, a partição _crisp_ usada nas métricas foi obtida atribuindo cada observação ao componente de maior probabilidade a posteriori. Para cada par $(k, "covariance_type")$, foi mantida a semente de menor log-verossimilhança negativa, e entre os quatro tipos, foi mantido o de menor BIC. A @tab:em resume as quatro configurações selecionadas.

  #figure(
    table(
      columns: 6,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*$k$*], [*Covariância*], [*Silhouette*], [*ARI*], [*Objetivo ($-"log" L$)*], [*BIC*]),
      table.hline(),
      [2], [`full`], [0,580], [0,568], [326,2], [797,7],
      [3], [`full`], [0,373], [0,904], [292,0], [804,5],
      [4], [`tied`], [0,317], [0,822], [347,3], [839,9],
      [5], [`tied`], [0,300], [0,727], [326,7], [823,8],
      table.hline(),
    ),
    caption: [Misturas gaussianas com EM: por $k$, tipo de covariância de menor BIC, $-$log-verossimilhança mínima, ARI],
    kind: table,
  ) <tab:em>

  A silhueta das configurações selecionadas decresce de 0,580 em $k = 2$ para 0,300 em $k = 5$ (@fig:em-sil), de modo que $k^* = 2$, como nos demais métodos. Nesse valor, a partição _crisp_ isola as 50 _setosa_ em um grupo e reúne as 100 observações de _versicolor_ e _virginica_ no outro, que é a mesma partição obtida pelo K-Means padronizado. Em $k = 2$, todas as execuções produzem essa mesma partição, diferindo apenas no número de parâmetros e, portanto, no BIC.

  #figure(
    image("../imagens/em_silhouette.png", width: 100%),
    caption: [Silhouette em função do número de clusters $k$ (misturas gaussianas com EM).],
  ) <fig:em-sil>

  O tipo de covariância, escolhido por BIC, não foi decidido por diferença marginal. A @tab:em-bic mostra o grid completo: em $k = 3$, `full` fica com 804,5, contra 855,7 de `tied`, 968,2 de `diag` e 1231,7 de `spherical`.. O menor BIC global ocorre em $k = 2$ (797,7), apontando na mesma direção da silhueta; `em_bic_decomposition.csv` registra como penalidade e verossimilhança se combinam em cada valor.

  #figure(
    table(
      columns: 6,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*$k$*], [*Spherical*], [*Diag*], [*Tied*], [*Full*], [*Folga p/ 2º*]),
      table.hline(),
      [2], [1334,7], [1081,7], [910,4], [*797,7*], [112,7],
      [3], [1231,7], [968,2], [855,7], [*804,5*], [51,1],
      [4], [1147,9], [929,3], [*839,9*], [848,7], [8,8],
      [5], [1111,4], [925,0], [*823,8*], [843,4], [19,6],
      table.hline(),
    ),
    caption: [EM: BIC por tipo de covariância e número de componentes. Em negrito, a menor estratégia de cada $k$; a última coluna é a diferença para a segunda melhor.],
    kind: table,
  ) <tab:em-bic>

  Como diagnóstico externo, vale registrar que o ARI em $k = 3$ sobe para valor alto de 0,904, contra 0,568 em $k^* = 2$, mas a silhueta deste modelo cai para 0,373, e é por isso que ele não foi escolhido.

  As cinco observações que saem do grupo majoritário em $k = 3$ são _versicolor_ alocadas junto às _virginica_. A @tab:em-k3-cont e `em_k3_contingency.csv` trazem as contagens, e a @fig:em-clusters-k3 mostra a partição no plano das pétalas. O mapa de posteriores (@fig:em-post) reforça a leitura: a entropia média é 0,032, a probabilidade máxima mínima é 0,635 e nenhuma observação fica abaixo de 0,6. A incerteza existe, mas é localizada nos pontos de fronteira.

  #figure(
    table(
      columns: 4,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*Espécie*], [*G0*], [*G1*], [*G2*]),
      table.hline(),
      [Setosa], [0], [50], [0],
      [Versicolor], [45], [0], [5],
      [Virginica], [0], [0], [50],
      table.hline(),
    ),
    caption: [EM em $k = 3$: contingência entre espécies reais e o grupo de maior posterior],
    kind: table,
  ) <tab:em-k3-cont>
  Nota-se que apenas 5 (3% de todas) observações da espécie _versicolor_ não se encontram no grupo majoritário da sua espécie.
  #figure(
    image("../imagens/em_clusters_k3.png", width: 90%),
    caption: [EM em $k = 3$ no plano `petal_length` × `petal_width`; a legenda informa a composição de cada grupo.],
  ) <fig:em-clusters-k3>

  #figure(
    image("../imagens/em_posteriors.png", width: 100%),
    caption: [EM em $k = 3$: posteriores ordenados por espécie e confiança da atribuição no plano das pétalas; em vermelho, as observações fora do grupo majoritário.],
  ) <fig:em-post>


  == Agrupamento hierárquico Centroid Linkage

  Por ser determinístico, o procedimento produziu métricas idênticas nas dez repetições de cada valor de $k$, e os resultados correspondem, portanto, a quatro partições distintas, uma para cada $k in {2, 3, 4, 5}$. A @tab:hier resume a silhueta (distância euclidiana) e o ARI de cada partição.

  #figure(
    table(
      columns: 4,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*$k$*], [*Grupos*], [*Silhouette*], [*ARI*]),
      table.hline(),
      [2], [2], [0,580], [0,568],
      [3], [3], [0,479], [0,562],
      [4], [4], [0,406], [0,552],
      [5], [5], [0,374], [0,551],
      table.hline(),
    ),
    caption: [Centroid Linkage (distância euclidiana).],
    kind: table,
  ) <tab:hier>

  A @fig:hier-dend apresenta o dendrograma truncado. As últimas fusões evidenciam dois grandes ramos: o ramo da _setosa_, com 50 observações, e o ramo que reúne _versicolor_ e _virginica_. Dentro desse segundo ramo, as fusões são mais graduais e não indicam uma separação clara entre as duas espécies, o que torna a divisão em três grupos menos evidente do que a divisão em dois.

  #figure(
    image("../imagens/hierarchical_dendrogram.png", width: 100%),
    caption: [Dendrograma truncado do agrupamento hierárquico (Centroid Linkage, distância euclidiana), com linha de corte para a partição em $k^* = 2$.],
  ) <fig:hier-dend>

  Para $k = 2$, a partição separa a _setosa_ (50 observações) das demais espécies (100 observações), a mesma partição obtida pela Mistura Gaussiana, com silhueta de 0,580 e ARI de 0,568. A silhueta elevada reflete a separação da _setosa_, e o ARI é moderado porque _versicolor_ e _virginica_ permanecem juntas em um único grupo, denominado `"Versicolor + Virginica"`.

  Para $k = 3$, a _setosa_ permanece isolada. Um segundo grupo contém as 50 _versicolor_ e 47 das 50 _virginica_; o terceiro grupo contém as 3 _virginica_ restantes. A silhueta é 0,479 e o ARI é 0,562.

  #figure(
    image("../imagens/hierarchical_kstar_petal_clusters.png", width: 82%),
    caption: [Centroid Linkage com $k^* = 2$, projetado em `petal_length` × `petal_width`; o segundo grupo reúne majoritariamente _versicolor_ e _virginica_ e é identificado como `"Versicolor + Virginica"` por não haver maioria única de espécie.],
  ) <fig:hier-kstar-clusters>

  Como o Centroid Linkage não é monotônico, o corte realizado pelo `cut_tree` ou por `fcluster` pode não corresponder diretamente à reconstrução baseada no número de fusões em toda a faixa de $k$. Nesta análise, as partições foram reconstruídas a partir das primeiras $n-k$ fusões, garantindo exatamente $k$ grupos. A reconstrução manual foi comparada com `fcluster(..., criterion = "maxclust")`, o ARI entre os dois métodos foi 1,0 para $k in {2,3,4,5}$, indicando equivalência prática nesta base.

  #figure(
    table(
      columns: 2,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*$k$*], [*ARI reconstrução × fcluster*]),
      table.hline(),
      [2], [1,000],
      [3], [1,000],
      [4], [1,000],
      [5], [1,000],
      table.hline(),
    ),
    caption: [Concordância entre a reconstrução pelas primeiras $n-k$ fusões e o corte por `fcluster` no Centroid Linkage.],
    kind: table,
  ) <tab:hier-cut>

  Para $k = 4$, a silhueta é 0,406 e o ARI é 0,552. Neste corte, uma observação de _setosa_ se separa das outras 49, enquanto as espécies _versicolor_ e _virginica_ também permanecem divididas em grupos mistos. Para $k = 5$, são obtidos silhueta 0,374 e ARI 0,551.

  A silhueta decresce com o número de grupos e é máxima em $k = 2$ (0,580). O ARI também é máximo em $k = 2$ (0,568), seguido de $k = 3$ (0,562). Assim, a silhueta favorece a separação geométrica entre _setosa_ e as demais espécies, enquanto o ARI confirma que dividir novamente essa região não melhora o resultado externo. Como o procedimento não é iterativo nem aleatório, não há variabilidade entre execuções a ser avaliada, então não foram realizados bootstrap ou intervalos de incerteza.

  == DBSCAN

  Foram avaliadas 40 configurações (oito valores de `eps` e cinco de `minpts`). Em 32 delas foram identificados pelo menos dois agrupamentos. Nas oito restantes, não há silhueta válida nem ARI interpretável: sete configurações classificaram todas as observações como ruído e uma formou um único agrupamento. Nessas configurações, o ARI foi registrado como `NaN`.

  A @fig:dbscan-ruido mostra que o ruído diminui com o aumento de `eps` e aumenta com `minpts`. Com `eps` = 0,2, entre 132 e 150 observações são ruído; com `eps` = 1,0, a quantidade varia entre uma e seis observações, conforme `minpts`. A @fig:dbscan-cobertura resume essa mesma relação pela porcentagem da base não descartada.

  #figure(
    image("../imagens/dbscan_noise.png", width: 100%),
    caption: [DBSCAN: pontos de ruído em função de `eps`, para cada valor de `minpts`.],
  ) <fig:dbscan-ruido>

  #figure(
    image("../imagens/dbscan_coverage.png", width: 100%),
    caption: [DBSCAN: cobertura da base em função de `eps`, para cada valor de `minpts`.],
  ) <fig:dbscan-cobertura>

  A silhueta (@fig:dbscan-sil) não varia monotonicamente com `eps`. Na configuração selecionada, `eps` = 0,7 e `minpts` = 5, a silhueta é 0,610, com 8 observações classificadas como ruído e cobertura de 94,7%. Como silhueta e ARI excluem o ruído, devem ser interpretados junto com a cobertura.

  #figure(
    image("../imagens/dbscan_silhouette.png", width: 100%),
    caption: [DBSCAN: silhueta em função de `eps`, para cada valor de `minpts`. Configurações com menos de dois agrupamentos não aparecem.],
  ) <fig:dbscan-sil>

  A @tab:dbscan reúne as configurações representativas.

  #figure(
    table(
      columns: 7,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*`eps`*], [*`minpts`*], [*Grupos*], [*Ruído*], [*Cobertura*], [*Silhouette*], [*ARI*]),
      table.hline(),
      [0,3], [7], [2], [128 (85,3%)], [14,7%], [0,634], [0,000],
      [0,4], [3], [10], [39 (26,0%)], [74,0%], [0,418], [0,621],
      [0,5], [10], [3], [89 (59,3%)], [40,7%], [0,710], [1,000],
      [0,5], [15], [1], [127 (84,7%)], [15,3%], [--], [--],
      [0,6], [5], [2], [26 (17,3%)], [82,7%], [0,641], [0,611],
      [0,7], [5], [2], [8 (5,3%)], [94,7%], [0,610], [0,573],
      [1,0], [5], [2], [3 (2,0%)], [98,0%], [0,594], [0,568],
      [1,0], [10], [2], [4 (2,7%)], [97,3%], [0,598], [0,571],
      [1,0], [15], [2], [6 (4,0%)], [96,0%], [0,602], [0,568],
      table.hline(),
    ),
    caption: [Configurações representativas. Silhueta e ARI calculados sem as observações de ruído.],
    kind: table,
  ) <tab:dbscan>

  A configuração `eps` = 0,5 e `minpts` = 10 alcança silhueta 0,710 e ARI 1,0, mas descarta 89 observações: a cobertura é de apenas 40,7% e as métricas são calculadas sobre 61 das 150 observações. Por isso, esse extremo não representa uma melhoria equivalente da segmentação da base completa e não deve ser escolhido pela silhueta sem considerar a cobertura. Já em `eps` = 1,0, as configurações com `minpts` = 5, 10 e 15 preservam entre 144 e 147 observações, mas fundem a fronteira entre _versicolor_ e _virginica_ e produzem ARI próximo a 0,568.

  #figure(
    image("../imagens/dbscan_clusters.png", width: 100%),
    caption: [DBSCAN com `eps` = 0,7 e `minpts` = 5, projetado em `sepal_length` e `sepal_width`. O rótulo −1 indica ruído.],
  ) <fig:dbscan-clusters>

  Com `eps` = 0,4 e `minpts` = 3, o DBSCAN forma dez agrupamentos e descarta 39 observações (26,0%), obtendo silhueta 0,418 e ARI 0,621. A @tab:dbscan-cont apresenta as contagens dessa contingência entre as espécies reais e os grupos encontrados. A @fig:dbscan-petalas mostra essa fragmentação no plano das pétalas.

  #figure(
    table(
      columns: 12,
      align: center,
      stroke: none,
      table.hline(),
      table.header(
        [*Espécie*], [*Ruído*], [*G0*], [*G1*], [*G2*], [*G3*], [*G4*], [*G5*], [*G6*], [*G7*], [*G8*], [*G9*]
      ),
      table.hline(),
      [_Setosa_], [9], [41], [0], [0], [0], [0], [0], [0], [0], [0], [0],
      [_Versicolor_], [9], [0], [17], [19], [3], [2], [0], [0], [0], [0], [0],
      [_Virginica_], [21], [0], [5], [0], [0], [1], [3], [5], [9], [3], [3],
      table.hline(),
    ),
    caption: [`eps` = 0,4 e `minpts` = 3: contingência entre espécies e grupos.],
    kind: table,
  ) <tab:dbscan-cont>

  #figure(
    image("../imagens/dbscan_eps04_minpts3_petals.png", width: 100%),
    caption: [DBSCAN com `eps` = 0,4 e `minpts` = 3 no plano das pétalas.],
  ) <fig:dbscan-petalas>

  A @fig:dbscan-eps-comparacao ilustra a sensibilidade a `eps`: com 0,4 há segmentação mais fragmentada; com 1,0, as espécies adjacentes são fundidas e não há ruído.

  #figure(
    image("../imagens/dbscan_eps04_eps10_comparison.png", width: 100%),
    caption: [DBSCAN no plano das pétalas: comparação entre `eps` = 0,4 e `eps` = 1,0, com `minpts` = 5.],
  ) <fig:dbscan-eps-comparacao>

  Em resumo, valores pequenos de `eps` fragmentam os dados e geram ruído; valores grandes eliminam o ruído, mas fundem _versicolor_ e _virginica_. Nenhuma configuração com ruído baixo e silhueta elevada recupera as três espécies. Assim, a melhor separação das espécies coexiste com maior descarte de observações ou com fragmentação adicional, evidenciando a dificuldade de aplicar um único raio a grupos de densidades distintas.

  == PCA

  A @tab:pca, com as principais saídas da biblioteca utilizada, resume quanta variância cada componente explica.

  #figure(
    table(
      columns: 4,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*Componente*], [*Autovalor*], [*Proporção*], [*Acumulado*]),
      table.hline(),
      [1], [2,930], [0,728], [0,728],
      [2], [0,927], [0,230], [0,958],
      [3], [0,148], [0,037], [0,995],
      [4], [0,021], [0,005], [1,000],
      table.hline(),
    ),
    caption: [Autovalores e proporções de variância explicada do PCA (dados padronizados).],
    kind: table,
  ) <tab:pca>


  A @fig:pca-var mostra que as duas primeiras componentes reúnem 95,8% da variância: 72,8% na PC1 e 23,0% na PC2. Pelos coeficientes da @tab:pca-loadings, a PC1 combina principalmente `sepal_length`, `petal_length` e `petal_width`; a PC2 é dominada por `sepal_width`. A padronização z-score evitou que atributos com escalas numéricas maiores dominem a análise, conforme comprovamos experimentalmente.

  #figure(
    table(
      columns: 5,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*Componente*], [*`sepal_length`*], [*`sepal_width`*], [*`petal_length`*], [*`petal_width`*]),
      table.hline(),
      [PC1], [0,522], [−0,263], [0,581], [0,566],
      [PC2], [0,372], [0,926], [0,021], [0,065],
      [PC3], [0,721], [−0,242], [−0,141], [−0,634],
      [PC4], [−0,262], [0,124], [0,801], [−0,524],
      table.hline(),
    ),
    caption: [PCA: vetores das componentes (autovetores da matriz de correlação).],
    kind: table,
  ) <tab:pca-loadings>

  #figure(
    image("../imagens/pca_variance.png", width: 100%),
    caption: [PCA: proporção de variância explicada por componente e variância acumulada.],
  ) <fig:pca-var>

  #figure(
    image("../imagens/pca_scatter.png", width: 100%),
    caption: [PCA: observações projetadas nas duas primeiras componentes principais, coloridas pela espécie real.],
  ) <fig:pca-scatter>

  Na projeção (@fig:pca-scatter), a _setosa_ fica bem separada, enquanto _versicolor_ e _virginica_ ainda se sobrepõem. A silhueta interna é 0,613 para a partição de K-Means com $k = 2$ — a melhor entre os valores de $k$ testados — e resume a coesão e a separação desses grupos no plano. A silhueta externa, calculada com as espécies reais, é 0,400 e serve apenas como diagnóstico. A trustworthiness com dez vizinhos é 0,978: ela avalia se pontos próximos no plano também eram próximos no espaço original, penalizando vizinhos introduzidos pela projeção.

  == Kernel PCA

  Com o kernel RBF, comparamos cinco valores de $gamma$ (@tab:kpca-grid). Para cada projeção, a silhueta interna é o melhor resultado de K-Means entre $k = 2$ e $k = 5$. A configuração escolhida foi $gamma = 0,05$, que obteve a maior trustworthiness entre os valores testados (0,976). A maior silhueta interna, 0,667 ($k = 3$), ocorre em $gamma = 0,25$, mas não foi o critério de seleção. Para $gamma = 0,05$, o solver retornou 141 autovalores cuja soma (43,44297) coincide, dentro da precisão numérica, com o traço de $K_c$; essa soma é o denominador das proporções apresentadas na @tab:kpca.

  #figure(
    table(
      columns: 4,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*Componente*], [*Autovalor ($eta$)*], [*Proporção*], [*Acumulado*]),
      table.hline(),
      [1], [26,677], [0,614], [0,614],
      [2], [9,022], [0,208], [0,822],
      [3], [2,503], [0,058], [0,879],
      [4], [1,857], [0,043], [0,922],
      table.hline(),
    ),
    caption: [Kernel PCA (RBF, $gamma = 0,05$): autovalores $eta$ de $K_c$; as proporções são $eta_i / sum_j eta_j$, com soma 43,44297.],
    kind: table,
  ) <tab:kpca>

  As duas primeiras componentes somam 82,2% da soma dos autovalores retornados, e as quatro primeiras, 92,2% (@tab:kpca). O espectro também tem uma cauda longa de autovalores pequenos. Essas proporções descrevem a distribuição dos autovalores da matriz de kernel centrada e não são diretamente comparáveis às da PCA linear, calculadas no espaço original.

  #figure(
    table(
      columns: 5,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*$gamma$*], [*Sil. interna*], [*$k$*], [*Sil. externa*], [*Trustworthiness*]),
      table.hline(),
      [0,05], [0,637], [2], [0,427], [*0,976*],
      [0,10], [0,647], [2], [0,447], [0,962],
      [0,25], [0,667], [3], [0,468], [0,932],
      [0,50], [0,649], [3], [0,456], [0,915],
      [1,00], [0,583], [3], [0,417], [0,892],
      table.hline(),
    ),
    caption: [Kernel PCA (RBF): grid sobre $gamma$; seleção pela maior trustworthiness, com silhueta interna como desempate.],
    kind: table,
  ) <tab:kpca-grid>

  #figure(
    image("../imagens/kpca_variance.png", width: 100%),
    caption: [Kernel PCA (RBF, $gamma = 0,05$): proporção dos autovalores nas dez primeiras componentes e acumulado.],
  ) <fig:kpca-var>

  #figure(
    table(
      columns: 3,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*Espécie*], [*Componente 1*], [*Componente 2*]),
      table.hline(),
      [Setosa], [0,564], [−0,075],
      [Versicolor], [−0,154], [0,176],
      [Virginica], [−0,410], [−0,101],
      table.hline(),
    ),
    caption: [Kernel PCA: médias das coordenadas projetadas por espécie nas duas primeiras componentes.],
    kind: table,
  ) <tab:kpca-centroides>

  #figure(
    image("../imagens/kpca_scatter_centroids.png", width: 100%),
    caption: [Kernel PCA ($gamma = 0,05$): projeção e médias das coordenadas por espécie.],
  ) <fig:kpca-centroides>

  As médias das coordenadas projetadas por espécie são _setosa_ (0,564; −0,075), _versicolor_ (−0,154; 0,176) e _virginica_ (−0,410; −0,101). Foram calculadas após o ajuste, usando os rótulos reais, e não participam do modelo.

  Na projeção (@fig:kpca-centroides), a _setosa_ permanece separada, enquanto _versicolor_ e _virginica_ se sobrepõem, como na PCA linear. A trustworthiness de 0,976 em $gamma = 0,05$ é próxima à da PCA (0,978); a diferença de 0,002 descreve apenas estes embeddings, não uma superioridade geral de uma técnica. No grid, a trustworthiness diminui até 0,892 quando $gamma$ aumenta para 1,0, embora a silhueta interna não siga a mesma tendência. A escolha de $gamma$ privilegiou a preservação local, e as silhuetas ficam como medidas complementares.

  #figure(
    image("../imagens/kpca_scree_log.png", width: 100%),
    caption: [Kernel PCA ($gamma = 0,05$): autovalores em escala logarítmica.],
  ) <fig:kpca-var-log>

  == t-SNE

  Foram avaliadas as perplexidades 5, 10, 20 e 30, com inicialização por PCA, taxa de aprendizado automática, limite de 1000 iterações e semente 42. Todas as execuções atingiram o limite de 1000 iterações e registraram $n_"iter" = 999$, portanto este resultado não demonstra convergência formal. A @tab:tsne resume a silhueta não supervisionada, obtida por K-Means no embedding, a silhueta externa pelas espécies reais, a divergência de Kullback-Leibler (KL) e a trustworthiness com dez vizinhos.

  #figure(
    table(
      columns: 7,
      align: center,
      stroke: none,
      table.hline(),
      table.header(
        [*Perplexidade*],
        [*Sil. não sup.*],
        [*$k$ K-Means*],
        [*Sil. externa*],
        [*Divergência KL*],
        [*Iterações*],
        [*Trustworthiness*],
      ),
      table.hline(),
      [5], [0,588], [5], [0,267], [0,330], [999], [0,981],
      [10], [0,664], [2], [0,455], [0,309], [999], [0,985],
      [20], [0,819], [2], [0,508], [0,195], [999], [*0,990*],
      [30], [0,865], [2], [0,483], [0,164], [999], [0,989],
      table.hline(),
    ),
    caption: [t-SNE: trustworthiness, silhueta não supervisionada por K-Means e avaliação externa pelas espécies reais.],
    kind: table,
  ) <tab:tsne>

  A perplexidade é selecionada pela maior trustworthiness. Assim, a perplexidade selecionada é 20, com trustworthiness 0,990, silhueta não supervisionada 0,819 e silhueta externa 0,508. Para referência, a perplexidade 30, que maximiza a silhueta interna, atinge 0,865, com trustworthiness de 0,989. A silhueta externa pelas espécies reais e a divergência KL são apresentadas como medidas complementares.

  Na análise das sementes de 0 a 9 na perplexidade selecionada, 20, a silhueta não supervisionada média foi 0,819 e a trustworthiness média foi 0,990, ambas sem variação observável. A silhueta externa média foi 0,508. Como a inicialização foi fixada em PCA, esse desvio zero não constitui evidência de estabilidade robusta sob inicializações aleatórias ou em novas amostras.

  #figure(
    image("../imagens/tsne_perplexity_comparison.png", width: 100%),
    caption: [t-SNE: silhueta e divergência KL em função da perplexidade.],
  ) <fig:tsne-comp>

  Os embeddings da @fig:tsne-emb mostram o efeito da perplexidade sobre a estrutura obtida. Com perplexidade 5, a ênfase na vizinhança muito local fragmenta os dados: a _setosa_ aparece dividida em três subgrupos, e _versicolor_ também se divide em vários blocos, o que produz subestruturas que não correspondem a diferenças entre espécies. Com perplexidade 10, a _setosa_ forma um único grupo alongado, enquanto _versicolor_ e _virginica_ ocupam regiões distintas, mas com alguns pontos de _versicolor_ dentro da região de _virginica_. Com perplexidades 20 e 30, a _setosa_ forma um grupo compacto e bem afastado, e _versicolor_ e _virginica_ formam uma região contínua, com sobreposição parcial na fronteira entre elas.

  #figure(
    image("../imagens/tsne_embeddings_perplexities.png", width: 100%),
    caption: [t-SNE: embeddings bidimensionais para as perplexidades 5, 10, 20 e 30, coloridos pela espécie real.],
  ) <fig:tsne-emb>

  O t-SNE preserva principalmente relações de vizinhança, de modo que distâncias e tamanhos dos grupos no embedding não refletem diretamente o espaço original. A silhueta não supervisionada mede o particionamento produzido pelo K-Means no plano, então não deve ser interpretada diretamente como separação das espécies reais. A silhueta externa pelas espécies reais é apresentada complementarmente.

  #figure(
    table(
      columns: 5,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*Método*], [*Critério anterior*], [*Resultado anterior*], [*Critério atual*], [*Resultado atual*]),
      table.hline(),
      [PCA], [Configuração única], [Sil. 0,613; trust. 0,978], [Sem seleção de parâmetros], [Sil. 0,613; trust. 0,978],
      [Kernel PCA], [Maior silhueta], [$gamma = 0,25$; sil. 0,667; trust. 0,932], [Maior trustworthiness], [$gamma = 0,05$; sil. 0,637; trust. 0,976],
      [t-SNE], [Maior silhueta], [Perp. 30; sil. 0,865; trust. 0,989], [Maior trustworthiness], [Perp. 20; sil. 0,819; trust. 0,990],
      [UMAP], [Maior silhueta], [30/0,0; sil. 0,902; trust. 0,978], [Maior trustworthiness], [15/0,5; sil. 0,863; trust. 0,980],
      table.hline(),
    ),
    caption: [Comparação dos critérios de seleção dos métodos com hiperparâmetros; a PCA tem uma única configuração.],
    kind: table,
  ) <tab:embedding-selection-comparison>

  == UMAP

  Foram avaliadas 12 configurações, combinando `n_neighbors` ∈ {5, 10, 15, 30} e `min_dist` ∈ {0,0; 0,1; 0,5}, com distância euclidiana, dois componentes e semente 42. A silhueta não supervisionada foi calculada no espaço bidimensional com rótulos preditos por K-Means; a silhueta pelas espécies reais foi mantida apenas como avaliação externa. A @tab:umap apresenta os resultados.

  #figure(
    table(
      columns: 4,
      align: center,
      stroke: none,
      table.hline(),
      table.header([*`n_neighbors`*], [*`min_dist` = 0,0*], [*`min_dist` = 0,1*], [*`min_dist` = 0,5*]),
      table.hline(),
      [5], [0,760], [0,712], [0,597],
      [10], [0,820], [0,783], [0,720],
      [15], [0,864], [0,800], [0,863],
      [30], [*0,902*], [0,893], [0,686],
      table.hline(),
    ),
    caption: [Silhueta não supervisionada por configuração. Em destaque, o maior valor.],
    kind: table,
  ) <tab:umap>

  A silhueta não supervisionada variou entre 0,597 (`n_neighbors` = 5 e `min_dist` = 0,5) e 0,902 (`n_neighbors` = 30 e `min_dist` = 0,0), conforme a @fig:umap-sil. A trustworthiness com dez vizinhos variou entre 0,971 e 0,980. A silhueta mede principalmente a formação de grupos compactos no embedding pelo K-Means e não deve ser interpretada isoladamente como preservação geométrica ou separação biológica verdadeira.

  Para a seleção, usamos a trustworthiness como critério principal e a silhueta apenas como apoio. A maior trustworthiness no grid (0,9801) ocorreu com `n_neighbors` = 15 e `min_dist` = 0,5; a silhueta dessa configuração foi 0,8632.

  A @tab:umap-sementes resume as configurações com maior trustworthiness e silhueta secundária, avaliadas em dez sementes.

  #figure(
    table(
      columns: 5,
      align: center,
      stroke: none,
      table.hline(),
      table.header(
        [*`n_neighbors`*], [*`min_dist`*], [*Silhueta média*], [*DP silhueta*], [*Trustworthiness média (DP)*]
      ),
      table.hline(),
      [15], [0,5], [0,781], [0,051], [0,979 (0,001)],
      [10], [0,5], [0,756], [0,070], [0,979 (0,001)],
      [30], [0,5], [0,813], [0,034], [0,978 (0,002)],
      [15], [0,1], [0,846], [0,024], [0,977 (0,002)],
      table.hline(),
    ),
    caption: [Estabilidade das quatro melhores configurações pela trustworthiness, em dez sementes (0 a 9). Os desvios são padrões amostrais.],
    kind: table,
  ) <tab:umap-sementes>

  As diferenças entre essas configurações são comparáveis aos desvios de silhueta observados, especialmente entre os rankings próximos de trustworthiness. Assim, o ranking não é totalmente distinguível: `n_neighbors` = 15 e `min_dist` = 0,5 obteve a maior média de trustworthiness (0,9792), enquanto as demais oscilaram perto de 0,977–0,979. Os resultados indicam apenas consistência parcial, não estabilidade estatística plenamente separada.

  #figure(
    image("../imagens/umap_parameter_comparison.png", width: 100%),
    caption: [UMAP: silhueta em função de `n_neighbors`, para cada valor de `min_dist`.],
  ) <fig:umap-sil>

  Os embeddings da @fig:umap-emb mostram o efeito dos parâmetros. Com `n_neighbors` = 5, a ênfase em vizinhanças locais fragmenta os dados, enquanto `min_dist` = 0,5 dispersa os pontos em estruturas mais contínuas. Com `n_neighbors` = 10 e `min_dist` = 0,0, os grupos são compactos e _versicolor_ e _virginica_ aparecem mais distintos. Em `n_neighbors` = 30, as duas espécies formam uma faixa contínua com sobreposição parcial para todos os valores de `min_dist`. A _setosa_ permanece completamente separada em todas as configurações.

  #figure(
    image("../imagens/umap_embeddings_parameters.png", width: 100%),
    caption: [UMAP: embeddings bidimensionais para as 12 combinações de `n_neighbors` e `min_dist`, coloridos pela espécie real.],
  ) <fig:umap-emb>

]
