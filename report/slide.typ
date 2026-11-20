// Compilar a partir de report/:
// typst compile --font-path fonts slide.typ slide.pdf
#import "@preview/diatypst:0.10.0": *

#set text(font: "IBM Plex Sans", size: 10.5pt, lang: "pt")
#set list(spacing: 0.5em, indent: 0.45em, body-indent: 0.32em)
#set par(leading: 0.55em)

#let ink = rgb("#123B53")
#let faint = rgb("#5F7079")
#let soft = rgb("#E9F1F4")
#let good = rgb("#2E7D5B")

#let note(it) = text(size: 0.72em, fill: faint)[#it]
#let caption(it) = align(center)[#text(size: 0.76em, fill: faint)[#it]]
#let check(it) = text(fill: good, weight: "bold")[✓] + [ #it]

#page(
  width: 16 / 9 * 10.5cm,
  height: 10.5cm,
  margin: 0cm,
  fill: ink,
)[
  #place(top + left, dx: 0.9cm, dy: 1.05cm)[
    #block(width: 13.4cm)[
      #text(size: 8.5pt, tracking: 1.2pt, fill: white.transparentize(25%))[APRENDIZADO NÃO SUPERVISIONADO · BASE IRIS · EQUIPE 9]
      #v(0.45cm)
      #text(size: 21pt, weight: "bold", fill: white)[Análise comparativa de técnicas de aprendizado não supervisionado]
      #v(0.25cm)
      #text(size: 12.5pt, fill: white.transparentize(10%))[Agrupamento e redução de dimensionalidade]
      #v(0.35cm)
      #text(size: 9pt, fill: white.transparentize(30%))[7 algoritmos de agrupamento · 4 técnicas de redução]
    ]
  ]
  #place(bottom + left, dx: 0.9cm, dy: -0.75cm)[
    #text(size: 10.5pt, fill: white)[Andre Saghaard \& Bianca Paes]
    #h(0.4cm)
    #text(size: 9.5pt, fill: white.transparentize(25%))[UFPE · Recife · 26 de novembro de 2026]
  ]
]

#show: slides.with(
  title: "Estrutura não supervisionada da base Iris",
  subtitle: "Como agrupamento e redução interpretam setosa, versicolor e virginica",
  authors: ("Andre Saghaard", "Bianca Paes"),
  date: "26 de novembro de 2026",
  institute: "UFPE · Recife",
  title-color: ink,
  ratio: 16 / 9,
  layout: "medium",
  count: "number",
  footer: true,
  footer-title: "Aprendizado não supervisionado",
  footer-subtitle: "Iris · 2026 · Equipe 9",
  theme: "normal",
  toc: false,
  first-slide: false,
)

== Objetivos do estudo

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 0.55cm,
  align: horizon,
  [
    #block(fill: soft, inset: 0.6em, radius: 4pt, height: 4.4cm)[
      #text(size: 1.15em, weight: "bold", fill: ink)[Pergunta]
      #v(0.35cm)
      #text(size: 0.95em)[
        Como diferentes algoritmos não supervisionados interpretam a estrutura dos dados da Iris?
      ]
    ]
  ],
  [
    #block(fill: soft, inset: 0.6em, radius: 4pt, height: 4.4cm)[
      #text(size: 1.15em, weight: "bold", fill: ink)[Comparação]
      #v(0.35cm)
      #text(size: 0.95em)[
        O que muda com o número de grupos, hiperparâmetros, distância e tratamento de ruído?
      ]
    ]
  ],
  [
    #block(fill: soft, inset: 0.6em, radius: 4pt, height: 4.4cm)[
      #text(size: 1.15em, weight: "bold", fill: ink)[Conclusão]
      #v(0.35cm)
      #text(size: 0.95em)[
        Que estruturas \(k\) encontra?
        Como silhueta, ARI e cobertura influenciam a interpretação?
      ]
    ]
  ],
)

== Visão geral dos modelos

#grid(
  columns: (1fr, 1fr),
  column-gutter: 0.65cm,
  row-gutter: 0.55cm,
  align: top,
  [
    #text(size: 0.82em, weight: "bold", fill: ink)[AGRUPAMENTO PARTICIONAL]
    #v(0.2cm)
    #text(size: 0.78em)[
      - *K-Means*: centróides e distância euclidiana.
      - *Fuzzy K-Means*: pertinências fuzzy aos centróides.
      - *K-Medoids*: medoides reais e distância city-block.
      - *Kernel Fuzzy K-Means*: pertinência fuzzy no espaço RBF.
    ]
  ],
  [
    #text(size: 0.82em, weight: "bold", fill: ink)[MODELOS PROBABILÍSTICOS E POR DENSIDADE]
    #v(0.2cm)
    #text(size: 0.78em)[
      - *EM/GMM*: mistura de gaussianas e responsabilidades posteriores.
      - *DBSCAN*: densidade local e detecção explícita de ruído.
    ]
  ],
  [
    #text(size: 0.82em, weight: "bold", fill: ink)[AGRUPAMENTO HIERÁRQUICO]
    #v(0.2cm)
    #text(size: 0.78em)[
      - *Centroid Linkage*: fusões sucessivas pela distância entre centróides.
    ]
  ],
  [
    #text(size: 0.82em, weight: "bold", fill: ink)[REDUÇÃO DE DIMENSIONALIDADE]
    #v(0.2cm)
    #text(size: 0.78em)[
      - *PCA*: projeção linear por variância.
      - *Kernel PCA*: projeção não linear por kernel RBF.
      - *t-SNE*: preservação de vizinhanças locais.
      - *UMAP*: estrutura local por grafo de vizinhança.
    ]
  ],
)

= Protocolo experimental

== Base Iris e protocolo

#grid(
  columns: (1.35fr, 1fr),
  gutter: 0.6cm,
  align: horizon,
  [
    #text(size: 0.92em)[
      - *150 observações* — 3 espécies × 50, *4 atributos numéricos* (sépala e pétala).
      - A espécie ficou *fora de $X$*: usada apenas na avaliação externa.
      - *Padronização z-score* (`StandardScaler`) em todos os algoritmos e reduções.
    ]
  ],
  [
    #block(fill: soft, inset: 0.5em, radius: 3pt, width: 100%)[
      #grid(
        columns: (1fr, 1fr),
        row-gutter: 0.3cm,
        column-gutter: 0.3cm,
        [#text(size: 1.55em, weight: "bold", fill: ink)[150] #note[observações]],
        [#text(size: 1.55em, weight: "bold", fill: ink)[4] #note[atributos]],
        [#text(size: 1.55em, weight: "bold", fill: ink)[3] #note[espécies × 50]],
        [#text(size: 1.55em, weight: "bold", fill: ink)[0] #note[valores ausentes]],
      )
    ]
    #v(0.3cm)
    #note[z-score por atributo (média 0, desvio 1), ajustado somente com $X$. Torna distâncias, kernels e centróides comparáveis entre si.]
  ],
)

== Seleção de $k^*$ e métricas

#grid(
  columns: (1.05fr, 1fr),
  gutter: 0.65cm,
  align: horizon,
  [
    #text(size: 0.92em)[
      #block(fill: soft, inset: 0.45em, radius: 3pt, width: 100%)[
        *1.* 10 sementes por configuração \
        *2.* menor função objetivo por $k$ (ou por $k, m$) \
        *3.* silhueta na partição crisp \
        *4.* $k^* = arg max_k "Sil"(k)$ \
        *5.* ARI só na partição final de $k^*$
      ]
    ]
  ],
  [
    #text(size: 0.92em)[
      - *Silhueta:* coesão × separação dos grupos.
      - *ARI:* concordância com as espécies, corrigida pelo acaso.
      - *Trustworthiness* (redução): preservação dos 10 vizinhos mais próximos.
      - No DBSCAN, as métricas saem *só dos pontos não-ruído*.
    ]
    #v(0.35cm)
    #note[No Fuzzy K-Means, a silhueta também escolhe $m$. No EM, a covariância é escolhida por BIC.]
  ],
)

#v(0.35cm)
#block(fill: soft, inset: 0.5em, radius: 3pt, width: 100%)[
  #text(size: 0.86em)[
    *Por que $k in {2,3,4,5}$?* A silhueta exige $k >= 2$; a faixa inclui a estrutura de 3 espécies e seus vizinhos. *$k = 3$ não foi premissa*, apenas candidato.
  ]
]

== Busca de hiperparâmetros

#text(size: 0.70em)[
  #table(
    columns: (1.05fr, 1.75fr, 1.9fr),
    align: (left, left, left),
    inset: (x: 0.3em, y: 0.22em),
    stroke: none,
    table.hline(stroke: 0.6pt + faint),
    table.header([*Algoritmo*], [*Grade avaliada*], [*Critério de seleção*]),
    table.hline(stroke: 0.4pt + faint),
    [K-Means], [$k in {2,3,4,5}$; 10 sementes (40 execuções)], [menor SSE por $k$; $k^*$ pela silhueta],
    [Fuzzy K-Means], [$k$, $m in {1,5; 2,0; 2,5}$ (120 execuções)], [menor $J_m$ por $(k,m)$; $(k,m)$ pela silhueta],
    [K-Medoids], [$k$; 10 sementes (40), city-block], [menor inércia por $k$; $k^*$ pela silhueta],
    [Kernel Fuzzy], [$k$, $m$, $sigma^2 in {"auto"; 0,5; 1,0; 2,0}$ (480)], [melhor semente pelo objetivo; $(m, sigma^2)$ e $k^*$ pela silhueta],
    [EM], [$k$, covariância em 4 tipos (160)], [menor $-$log $L$; covariância por BIC; $k^*$ pela silhueta],
    [Hierárquico], [$k in {2,3,4,5}$; determinístico], [cortes após $n - k$ fusões; $k^*$ pela silhueta],
    [DBSCAN], [$"eps"$ em 8 valores, $"minpts"$ em 5 (40)], [maior silhueta com no máximo 10 ruídos; cobertura junto],
    table.hline(stroke: 0.6pt + faint),
  )
]

#v(0.25cm)
#note[Além de $k$ e das 10 sementes, cada algoritmo teve o próprio hiperparâmetro na busca; os valores convencionais foram apenas ponto de partida.]

== Avaliação dos embeddings

#grid(
  columns: (1.2fr, 1fr),
  gutter: 0.65cm,
  align: horizon,
  [
    #text(size: 0.9em)[
      - *Saídas padrão:* autovalores, variância, cargas e projeção 2D (+ KL e iterações no t-SNE/UMAP).
      - Silhueta no plano usa rótulos de *K-Means* ($k in {2,3,4,5}$) — *nunca as espécies*.
      - Seleção por *trustworthiness* (Kernel PCA, t-SNE, UMAP); a externa é só diagnóstico.
    ]
  ],
  [
    #text(size: 0.76em)[
      #table(
        columns: (auto, 1fr, auto),
        align: (left, center, center),
        inset: (x: 0.26em, y: 0.2em),
        stroke: none,
        table.hline(stroke: 0.5pt + faint),
        table.header([*Técnica*], [*Busca*], [*Tentativas*]),
        table.hline(stroke: 0.35pt + faint),
        [PCA], [ajuste único], [1],
        [Kernel PCA], [$gamma$ em 5 valores], [5],
        [t-SNE], [perplexidade em 4 valores], [4],
        [UMAP], [$4 times 3$], [12],
        table.hline(stroke: 0.5pt + faint),
      )
    ]
  ],
)

#v(0.3cm)
#block(fill: soft, inset: 0.5em, radius: 3pt, width: 100%)[
  #text(size: 0.86em)[
    *Máximos de grids diferentes não são ranqueáveis:* PCA (1 ajuste), Kernel PCA (5), t-SNE (4) e UMAP (12) têm viés de seleção distinto.
  ]
]

= Agrupamento

== K-Means

#grid(
  columns: (1fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #text(size: 0.72em)[
      #table(
        columns: (auto, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.3em, y: 0.22em),
        stroke: none,
        table.hline(stroke: 0.5pt + faint),
        table.header([*$k$*], [*Silhouette*], [*ARI*], [*SSE*]),
        table.hline(stroke: 0.35pt + faint),
        [2], [*0,580*], [0,568], [223,7],
        [3], [0,459], [*0,620*], [141,0],
        [4], [0,387], [0,472], [114,4],
        [5], [0,343], [0,415], [91,1],
        table.hline(stroke: 0.5pt + faint),
      )
    ]
    #note[Menor SSE por $k$; `k-means++`.]
  ],
  [
    #align(center)[#image("imagens/kmeans_silhouette.png", height: 4.2cm)]
    #caption[Silhouette $times$ $k$ (K-Means).]
  ],
)

#v(0.2cm)
#text(size: 0.9em)[
  - *$k^* = 2$* (silhueta 0,580): isola as 50 _setosa_; _versicolor_ + _virginica_ juntas → ARI 0,568.
  - *ARI máximo em $k = 3$* (0,620): 25/150 fora do grupo majoritário.
  - Silhueta decresce até $k = 5$; em $k >= 4$ a _setosa_ se subdivide (27/23).
]

#v(0.15cm)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #text(size: 0.76em)[
      *Contingência em $k^* = 2$*
      #table(
        columns: (1.2fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.25em, y: 0.18em),
        stroke: none,
        table.hline(stroke: 0.5pt + faint),
        table.header([*Espécie*], [*Grupo setosa*], [*Grupo misto*]),
        table.hline(stroke: 0.35pt + faint),
        [Setosa], [50], [0],
        [Versicolor], [0], [50],
        [Virginica], [0], [50],
        table.hline(stroke: 0.5pt + faint),
      )
    ]
  ],
  [
    #text(size: 0.76em)[
      *Estabilidade entre sementes*
      - $k=2$: 10/10 soluções iguais.
      - $k=3$: métricas variadas entre sementes.
      - 40 execuções totais ($k=2$–5 × 10).
      - Convergência registrada em 2–8 iterações.
    ]
  ],
)

== K-Medoids

#grid(
  columns: (1fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #text(size: 0.76em)[
      #table(
        columns: (auto, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.3em, y: 0.24em),
        stroke: none,
        table.hline(stroke: 0.5pt + faint),
        table.header([*$k$*], [*Silhouette*], [*ARI*], [*Inércia*]),
        table.hline(stroke: 0.35pt + faint),
        [2], [*0,608*], [0,531], [270,2],
        [3], [0,488], [*0,665*], [208,1],
        [4], [0,370], [0,611], [200,4],
        [5], [0,293], [0,492], [187,2],
        table.hline(stroke: 0.5pt + faint),
      )
    ]
    #note[City-block; soluções idênticas entre sementes.]
  ],
  [
    #align(center)[#image("imagens/kmedoids_silhouette.png", height: 4.6cm)]
    #caption[Silhouette $times$ $k$ (K-Medoids).]
  ],
)

#v(0.2cm)
#text(size: 0.9em)[
  - *$k^* = 2$* pela silhueta city-block (0,608); *ARI máximo em $k = 3$* (0,665).
  - Inércia sem cotovelo claro: $-23,0%$ ($k = 2 -> 3$), depois $-3,7%$ e $-6,6%$.
  - Nas quatro configurações por $k$, a setosa aparece separada das demais espécies; a confusão se concentra em _versicolor_/_virginica_.
]

#v(0.12cm)
#grid(
  columns: (1.2fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #align(center)[#image("imagens/kmedoids_clusters.png", height: 3.8cm)]
    #caption[K-Medoids em $k = 3$: medóides marcados.]
  ],
  [
    #text(size: 0.78em)[
      *Contingência em $k^* = 2$*
      - Setosa: 50 no grupo da setosa.
      - Versicolor: 2 no grupo da setosa; 48 no grupo misto.
      - Virginica: 50 no grupo misto.
      - 10 sementes idênticas por inicialização heurística, não estabilidade estatística independente.
    ]
  ],
)

== Fuzzy K-Means

#grid(
  columns: (1fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #text(size: 0.70em)[
      #table(
        columns: (auto, auto, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.26em, y: 0.2em),
        stroke: none,
        table.hline(stroke: 0.5pt + faint),
        table.header([*$k$*], [*$m$*], [*Silhouette*], [*ARI*], [*$J_m$*]),
        table.hline(stroke: 0.35pt + faint),
        [2], [1,5], [*0,580*], [0,568], [214,8],
        [3], [1,5], [0,459], [*0,620*], [131,3],
        [4], [2,0], [0,401], [0,588], [74,5],
        [5], [1,5], [0,339], [0,425], [81,2],
        table.hline(stroke: 0.5pt + faint),
      )
    ]
    #note[Por $k$, maior silhueta entre $m$; $J_m$ mínimo entre sementes.]
  ],
  [
    #align(center)[#image("imagens/fuzzy_kmeans_silhouette.png", height: 4.2cm)]
    #caption[Silhouette $times$ $k$ (Fuzzy K-Means).]
  ],
)

#v(0.2cm)
#text(size: 0.9em)[
  - *$(k^* = 2, m = 1,5)$*: silhueta 0,580, ARI 0,568 — crisp idêntico ao K-Means.
  - *ARI máximo em $k = 3$* (0,620); máximo do grid é 0,630 ($m = 2,0$), fora da seleção.
  - Baixa sensibilidade a $m$ (0,459 vs 0,457 em $k = 3$); $J_m$ só escolhe a semente.
]

#v(0.12cm)
#grid(
  columns: (1.25fr, 1fr),
  gutter: 0.5cm,
  align: horizon,
  [
    #align(center)[#image("imagens/fuzzy_memberships.png", height: 3.8cm)]
    #caption[Graus de pertinência do Fuzzy K-Means.]
  ],
  [
    #text(size: 0.74em)[
      *Contingência em $k^* = 2$*
      - Setosa: 50 no grupo setosa.
      - Versicolor: 50 no grupo misto.
      - Virginica: 50 no grupo misto.
      - Mesmo crisp que K-Means; $U$ muda com $m$:
        $norm{U_{1.5}-U_{2.0}}_F=1.56$, máximo 0,178.
    ]
  ],
)

== Tunagem — Fuzzy x Kernel Fuzzy

#grid(
  columns: (1fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #text(size: 0.82em)[
      *Fuzzy K-Means*
      - Grade: $k in {2,3,4,5}$ × $m in {1,5;2,0;2,5}$.
      - 10 sementes para cada par $(k,m)$.
      - Menor $J_m$ escolhe a semente dentro do mesmo $(k,m)$.
      - Maior silhueta escolhe $m$ dentro de cada $k$.
      - Resultado: $(k,m) = (2;1,5)$.
    ]
  ],
  [
    #text(size: 0.82em)[
      *Kernel Fuzzy K-Means*
      - Grade: $k$, $m$ e $sigma^2 in {"auto";0,5;1,0;2,0}$.
      - 10 execuções × 5 inicializações internas por configuração.
      - Objetivo comparado apenas dentro da mesma tripla $(k,m,sigma^2)$.
      - Silhueta compara configurações diferentes.
      - Resultado: $(k,m,sigma^2)=(2;1,5;1,0)$.
    ]
  ],
)

#v(0.25cm)
#block(fill: soft, inset: 0.5em, radius: 3pt, width: 100%)[
  #text(size: 0.84em)[
    *Diferença essencial:* no Kernel Fuzzy, $sigma^2$ entra na largura do RBF e o objetivo não é comparável entre larguras diferentes; por isso a silhueta decide a configuração.
  ]
]

== Kernel Fuzzy K-Means

#grid(
  columns: (1fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #text(size: 0.72em)[
      #table(
        columns: (auto, auto, auto, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.2em, y: 0.2em),
        stroke: none,
        table.hline(stroke: 0.5pt + faint),
        table.header([*$k$*], [*$m$*], [*$sigma^2$*], [*Silhouette*], [*ARI*], [*Objetivo*]),
        table.hline(stroke: 0.35pt + faint),
        [2], [1,5], [1,0], [*0,580*], [0,568], [76,72],
        [3], [2,5], [0,5], [0,540], [0,529], [24,87],
        [4], [1,5], [2,0], [0,398], [*0,587*], [34,46],
        [5], [2,5], [1,0], [0,374], [0,495], [10,29],
        table.hline(stroke: 0.5pt + faint),
      )
    ]
    #note[480 execuções (48 combinações × 10 sementes); melhor semente pelo objetivo; $(m, sigma^2)$ pela silhueta.]
  ],
  [
    #align(center)[#image("imagens/kernel_fuzzy_kmeans_silhouette.png", height: 4.2cm)]
    #caption[Silhouette $times$ $k$, melhor $(m, sigma^2)$ por $k$.]
  ],
)

#v(0.2cm)
#text(size: 0.9em)[
  - *$k^* = 2$* com $m = 1,5$ e $sigma^2 = 1,0$: silhueta 0,580, ARI 0,568; em $k^*$, as 50 setosa ficam em um grupo e as 100 restantes no outro.
  - Objetivo estabiliza em 76,72 após *18 iterações*; usado apenas para escolher a semente.
  - Destaque externo: $k = 4$ (ARI 0,587); o $k = 3$ selecionado fica em 0,529.
]

== Kernel Fuzzy — graus de pertinência

#grid(
  columns: (1.35fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #align(center)[#image("imagens/kernel_fuzzy_kmeans_k2_silhouette_memberships.png", height: 5.2cm)]
    #caption[Kernel Fuzzy K-Means em $k = 2$: pertinência por amostra.]
  ],
  [
    #text(size: 0.88em)[
      - *Setosa:* pertinência alta e estável ao grupo correspondente.
      - *Versicolor e virginica:* fronteira mais incerta, com graus intermediários.
      - A atribuição *crisp* resulta em 50 setosa no seu grupo e 50 versicolor/virginica no outro.
      - Mesmo quando o argumento é alto, a diferença entre grupos mostra que a separação não é totalmente exclusiva.
    ]
  ],
)

== Misturas gaussianas com EM

#grid(
  columns: (1fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #text(size: 0.68em)[
      #table(
        columns: (auto, auto, 1fr, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.2em, y: 0.18em),
        stroke: none,
        table.hline(stroke: 0.5pt + faint),
        table.header([*$k$*], [*Cov.*], [*Sil.*], [*ARI*], [*$-$log $L$*], [*BIC*]),
        table.hline(stroke: 0.35pt + faint),
        [2], [`full`], [*0,580*], [0,568], [326,2], [797,7],
        [3], [`full`], [0,373], [*0,904*], [292,0], [804,5],
        [4], [`tied`], [0,317], [0,822], [347,3], [839,9],
        [5], [`tied`], [0,300], [0,727], [326,7], [823,8],
        table.hline(stroke: 0.5pt + faint),
      )
    ]
    #note[Por $k$, covariância de menor BIC; $-$log $L$ mínimo entre sementes.]
  ],
  [
    #align(center)[#image("imagens/em_clusters_k3.png", height: 4.3cm)]
    #caption[EM em $k = 3$ no plano `petal_length` × `petal_width`.]
  ],
)

#v(0.2cm)
#text(size: 0.9em)[
  - *$k^* = 2$* pela silhueta (0,580): mesma partição do K-Means; `full` vence o BIC.
  - *Diagnóstico em $k = 3$:* ARI *0,904* — só 5/150 (3,3%) fora do grupo majoritário.
  - Incerteza localizada: entropia média 0,032; nenhuma posterior abaixo de 0,6.
]

== EM — contingência em $k = 3$

#grid(
  columns: (1.15fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #text(size: 0.78em)[
      #table(
        columns: (1.2fr, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.3em, y: 0.24em),
        stroke: none,
        table.hline(stroke: 0.5pt + faint),
        table.header([*Espécie*], [*Setosa*], [*Versicolor*], [*Virginica + 5 versicolor*]),
        table.hline(stroke: 0.35pt + faint),
        [Setosa], [50], [0], [0],
        [Versicolor], [0], [45], [5],
        [Virginica], [0], [0], [50],
        table.hline(stroke: 0.5pt + faint),
      )
    ]
    #note[Contingência da solução `full` em $k = 3$ com melhor ARI.]
  ],
  [
    #text(size: 0.88em)[
      - Setosa isolada em um grupo.
      - Virginica fica em um grupo misto com 5 versicolor.
      - 45 versicolor formam o grupo majoritário; 5 versicolor são associados ao grupo misto.
      - Resultado: ARI 0,904 e 145/150 observações no grupo esperado.
    ]
  ],
)

== Agrupamento hierárquico Centroid Linkage

#grid(
  columns: (1fr, 1fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #text(size: 0.74em)[
      #table(
        columns: (auto, auto, 1fr, 1fr),
        align: center,
        inset: (x: 0.28em, y: 0.22em),
        stroke: none,
        table.hline(stroke: 0.5pt + faint),
        table.header([*$k$*], [*Grupos*], [*Silhouette*], [*ARI*]),
        table.hline(stroke: 0.35pt + faint),
        [2], [2], [*0,580*], [*0,568*],
        [3], [3], [0,479], [0,562],
        [4], [4], [0,406], [0,552],
        [5], [5], [0,374], [0,551],
        table.hline(stroke: 0.5pt + faint),
      )
    ]
    #note[UPGMC, euclidiana; determinístico. Partições pelas primeiras $n - k$ fusões.]
  ],
  [
    #align(center)[#image("imagens/hierarchical_dendrogram.png", height: 4.0cm)]
    #caption[Dendrograma truncado do Centroid Linkage.]
  ],
)

#v(0.2cm)
#text(size: 0.9em)[
  - Dendrograma: dois grandes ramos — _setosa_ (50) e _versicolor_ + _virginica_; fusões graduais no segundo.
  - *$k^* = 2$* (silhueta 0,580, ARI 0,568); em $k = 3$, ARI 0,562 — dividir não melhora.
  - Reconstrução por fusões equivale ao `fcluster` (ARI 1,0 em todos os $k$).
]

== DBSCAN — ruído e cobertura

#grid(
  columns: (1fr, 1fr),
  gutter: 0.4cm,
  align: horizon,
  [
    #align(center)[#image("imagens/dbscan_noise.png", height: 3.9cm)]
    #caption[Ruído em função de `eps`, para cada `minpts`.]
  ],
  [
    #align(center)[#image("imagens/dbscan_coverage.png", height: 3.9cm)]
    #caption[Cobertura da base em função de `eps`.]
  ],
)

#v(0.2cm)
#text(size: 0.9em)[
  - *40 configurações:* 32 com $>= 2$ grupos; 8 inválidas (7 tudo-ruído, 1 grupo único).
  - Ruído cai com `eps` e sobe com `minpts`: 132–150 ruídos em `eps` = 0,2; 1–6 em `eps` = 1,0.
  - Silhueta e ARI *excluem o ruído*: ler sempre junto da cobertura.
]

== DBSCAN — configuração selecionada

#grid(
  columns: (1.05fr, 1fr),
  gutter: 0.45cm,
  align: horizon,
  [
    #text(size: 0.66em)[
      #table(
        columns: (auto, auto, auto, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.18em, y: 0.18em),
        stroke: none,
        table.hline(stroke: 0.5pt + faint),
        table.header([*`eps`*], [*`minpts`*], [*Grupos*], [*Ruído*], [*Sil.*], [*ARI*]),
        table.hline(stroke: 0.35pt + faint),
        [0,3], [7], [2], [128 (85,3%)], [0,634], [0,000],
        [0,4], [3], [10], [39 (26,0%)], [0,418], [0,621],
        [0,6], [5], [2], [26 (17,3%)], [0,641], [0,611],
        [0,7], [5], [2], [8 (5,3%)], [*0,610*], [*0,573*],
        [1,0], [5], [2], [3 (2,0%)], [0,594], [0,568],
        table.hline(stroke: 0.5pt + faint),
      )
    ]
    #note[Métricas sem o ruído; a linha 0,7/5 é a selecionada.]
  ],
  [
    #align(center)[#image("imagens/dbscan_clusters.png", height: 4.4cm)]
    #caption[`eps` = 0,7 e `minpts` = 5; $-1$ indica ruído.]
  ],
)

#v(0.15cm)
#text(size: 0.9em)[
  - Selecionada `eps` = 0,7 e `minpts` = 5: silhueta 0,610, ARI 0,573, cobertura 94,7%.
  - *Armadilha:* `eps` = 0,5 / `minpts` = 10 dá ARI 1,0 com 89 ruídos (cobertura 40,7%) — não comparável.
  - Nenhuma configuração com ruído baixo recupera as três espécies.
]

= Redução de dimensionalidade

== PCA — saídas padrão

#grid(
  columns: (1.1fr, 1fr),
  gutter: 0.45cm,
  align: horizon,
  [
    #text(size: 0.70em)[
      #table(
        columns: (auto, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.2em, y: 0.18em),
        stroke: none,
        table.hline(stroke: 0.45pt + faint),
        table.header([*Comp.*], [*Autovalor*], [*Prop.*], [*Acum.*]),
        table.hline(stroke: 0.3pt + faint),
        [1], [2,930], [0,728], [0,728],
        [2], [0,927], [0,230], [0,958],
        [3], [0,148], [0,037], [0,995],
        [4], [0,021], [0,005], [1,000],
        table.hline(stroke: 0.45pt + faint),
      )
    ]
    #v(0.12cm)
    #text(size: 0.70em)[
      #table(
        columns: (auto, 1fr, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.18em, y: 0.16em),
        stroke: none,
        table.hline(stroke: 0.45pt + faint),
        table.header([*Comp.*], [*`sepal_length`*], [*`sepal_width`*], [*`petal_length`*], [*`petal_width`*]),
        table.hline(stroke: 0.3pt + faint),
        [PC1], [0,522], [$-0,263$], [0,581], [0,566],
        [PC2], [0,372], [0,926], [0,021], [0,065],
        table.hline(stroke: 0.45pt + faint),
      )
    ]
    #note[Cargas completas no relatório.]
  ],
  [
    #align(center)[#image("imagens/pca_variance.png", height: 4.2cm)]
    #caption[Variância explicada por componente e acumulada.]
  ],
)

#v(0.15cm)
#text(size: 0.9em)[
  - *PC1 + PC2 = 95,8%* da variância (72,8% + 23,0%).
  - PC1 combina `sepal_length`, `petal_length` e `petal_width`; PC2 é dominada por `sepal_width`.
]

== PCA — projeção e métricas

#grid(
  columns: (1fr, 1.05fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #align(center)[#image("imagens/pca_scatter.png", height: 5.2cm)]
    #caption[Duas primeiras componentes, coloridas pela espécie real.]
  ],
  [
    #text(size: 0.92em)[
      - _Setosa_ separada; _versicolor_/_virginica_ sobrepostas — como no agrupamento.
      - Silhueta interna (K-Means, $k = 2$): *0,613*; externa: *0,400*.
      - Trustworthiness (10 vizinhos): *0,978*.
    ]
  ],
)

== Kernel PCA — saídas padrão

#grid(
  columns: (1.1fr, 1fr),
  gutter: 0.45cm,
  align: horizon,
  [
    #text(size: 0.68em)[
      #table(
        columns: (auto, 1fr, auto, 1fr, 1fr),
        align: center,
        inset: (x: 0.18em, y: 0.17em),
        stroke: none,
        table.hline(stroke: 0.45pt + faint),
        table.header([*$gamma$*], [*Sil. int.*], [*$k$*], [*Sil. ext.*], [*Trust.*]),
        table.hline(stroke: 0.3pt + faint),
        [0,05], [0,637], [2], [0,427], [*0,976*],
        [0,10], [0,647], [2], [0,447], [0,962],
        [0,25], [0,667], [3], [0,468], [0,932],
        [0,50], [0,649], [3], [0,456], [0,915],
        [1,00], [0,583], [3], [0,417], [0,892],
        table.hline(stroke: 0.45pt + faint),
      )
    ]
    #note[Kernel RBF; seleção pela maior trustworthiness.]
  ],
  [
    #align(center)[#image("imagens/kpca_variance.png", height: 4.2cm)]
    #caption[Dez primeiras componentes de $gamma = 0,05$.]
  ],
)

#v(0.15cm)
#text(size: 0.88em)[
  - Seleção pela trustworthiness: *$gamma = 0,05$* (0,976) — não pela silhueta (máx. 0,667 em $gamma = 0,25$).
  - Duas primeiras componentes = *82,2%* dos autovalores ($eta_1 = 26,68$; $eta_2 = 9,02$); espectro com cauda longa (141 autovalores, traço 43,44).
]

== Kernel PCA — projeção e métricas

#grid(
  columns: (1fr, 1.05fr),
  gutter: 0.55cm,
  align: horizon,
  [
    #align(center)[#image("imagens/kpca_scatter.png", height: 5.2cm)]
    #caption[Duas primeiras componentes, coloridas pela espécie real.]
  ],
  [
    #text(size: 0.92em)[
      - Mesmo padrão da PCA linear: _setosa_ separada; _versicolor_/_virginica_ sobrepostas.
      - Trustworthiness cai de *0,976* ($gamma = 0,05$) a 0,892 ($gamma = 1,0$); a silhueta não segue a tendência.
      - Silhuetas (interna 0,637; externa 0,427) são descrição, não critério.
    ]
  ],
)

== t-SNE — saídas padrão

#grid(
  columns: (1.1fr, 1fr),
  gutter: 0.45cm,
  align: horizon,
  [
    #text(size: 0.66em)[
      #table(
        columns: (auto, 1fr, auto, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.16em, y: 0.16em),
        stroke: none,
        table.hline(stroke: 0.45pt + faint),
        table.header([*Perp.*], [*Sil. não sup.*], [*$k$ KM*], [*Sil. ext.*], [*KL*], [*Trust.*]),
        table.hline(stroke: 0.3pt + faint),
        [5], [0,588], [5], [0,267], [0,330], [0,981],
        [10], [0,664], [2], [0,455], [0,309], [0,985],
        [20], [0,819], [2], [0,508], [0,195], [*0,990*],
        [30], [0,865], [2], [0,483], [0,164], [0,989],
        table.hline(stroke: 0.45pt + faint),
      )
    ]
    #note[Inicialização PCA, semente 42; todas pararam em 999/1000 iterações.]
  ],
  [
    #align(center)[#image("imagens/tsne_perplexity_comparison.png", height: 4.3cm)]
    #caption[Silhueta e divergência KL por perplexidade.]
  ],
)

#v(0.15cm)
#text(size: 0.88em)[
  - Selecionada perplexidade *20* pela trustworthiness (*0,990*); KL 0,195.
  - *Sem convergência formal:* todas as execuções atingiram o limite de 1000 iterações.
  - Silhueta interna 0,819 (K-Means no plano); externa 0,508 — só diagnóstico.
]

== t-SNE — embeddings

#grid(
  columns: (1.15fr, 1fr),
  gutter: 0.5cm,
  align: horizon,
  [
    #align(center)[#image("imagens/tsne_embedding.png", height: 4.9cm)]
    #caption[Embedding da perplexidade 20.]
  ],
  [
    #text(size: 0.92em)[
      - Perplexidade 5 *fragmenta* (setosa em 3 subgrupos); 20–30 dão a estrutura estável.
      - _Setosa_ compacta e afastada; _versicolor_/_virginica_ contínuas, com sobreposição parcial.
      - Distâncias e tamanhos no embedding *não refletem* o espaço original.
    ]
  ],
)

== UMAP — saídas padrão

#grid(
  columns: (1.1fr, 1fr),
  gutter: 0.45cm,
  align: horizon,
  [
    #text(size: 0.72em)[
      #table(
        columns: (auto, 1fr, 1fr, 1fr),
        align: center,
        inset: (x: 0.22em, y: 0.2em),
        stroke: none,
        table.hline(stroke: 0.45pt + faint),
        table.header([*`n_neighbors`*], [*`min_dist` 0,0*], [*0,1*], [*0,5*]),
        table.hline(stroke: 0.3pt + faint),
        [5], [0,760], [0,712], [0,597],
        [10], [0,820], [0,783], [0,720],
        [15], [0,864], [0,800], [0,863],
        [30], [*0,902*], [0,893], [0,686],
        table.hline(stroke: 0.45pt + faint),
      )
    ]
    #note[Silhueta não supervisionada; a seleção usa trustworthiness.]
  ],
  [
    #align(center)[#image("imagens/umap_parameter_comparison.png", height: 4.3cm)]
    #caption[Silhueta em função de `n_neighbors`, para cada `min_dist`.]
  ],
)

#v(0.15cm)
#text(size: 0.88em)[
  - Silhueta varia 0,597–0,902; máxima em `n_neighbors` = 30, `min_dist` = 0,0 — *não é o critério*.
  - Seleção pela trustworthiness: *15 / 0,5* (0,980), com silhueta complementar 0,863.
]

#v(0.2cm)
#text(size: 0.68em)[
  #table(
    columns: (auto, auto, 1fr, 1fr),
    align: center,
    inset: (x: 0.2em, y: 0.18em),
    stroke: none,
    table.hline(stroke: 0.5pt + faint),
    table.header([*`n_neighbors`*], [*`min_dist`*], [*Silhueta*], [*Trustworthiness*]),
    table.hline(stroke: 0.35pt + faint),
    [15], [0,5], [0,863], [*0,980*],
    [30], [0,0], [*0,902*], [0,978],
    [15], [0,1], [0,800], [0,978],
    [10], [0,5], [0,720], [0,979],
    table.hline(stroke: 0.5pt + faint),
  )
]

== UMAP — embedding e estabilidade

#grid(
  columns: (1.05fr, 1fr),
  gutter: 0.5cm,
  align: horizon,
  [
    #align(center)[#image("imagens/umap_embedding.png", height: 5.0cm)]
    #caption[Configuração selecionada: `n_neighbors` = 15 e `min_dist` = 0,5.]
  ],
  [
    #text(size: 0.66em)[
      #table(
        columns: (auto, auto, 1fr, 1fr, 1.25fr),
        align: center,
        inset: (x: 0.18em, y: 0.16em),
        stroke: none,
        table.hline(stroke: 0.45pt + faint),
        table.header([*`n_neigh.`*], [*`min_dist`*], [*Sil. méd.*], [*DP*], [*Trust. méd. (DP)*]),
        table.hline(stroke: 0.3pt + faint),
        [15], [0,5], [0,781], [0,051], [0,979 (0,001)],
        [10], [0,5], [0,756], [0,070], [0,979 (0,001)],
        [30], [0,5], [0,813], [0,034], [0,978 (0,002)],
        [15], [0,1], [0,846], [0,024], [0,977 (0,002)],
        table.hline(stroke: 0.45pt + faint),
      )
    ]
    #v(0.2cm)
    #text(size: 0.88em)[
      - Em 10 sementes: trust. média máxima *0,979* (15/0,5); diferenças da ordem da variação entre sementes.
      - A setosa permanece separada nas configurações visualizadas; versicolor e virginica formam uma faixa contínua com sobreposição.
    ]
  ],
)

= Comparação e conclusão

== Comparação

#text(size: 0.86em)[
  #table(
    columns: (1.7fr, auto, 1fr, 1fr),
    align: (left, center, center, center),
    inset: (x: 0.34em, y: 0.3em),
    stroke: none,
    table.hline(stroke: 0.6pt + faint),
    table.header([*Método*], [*$k^*$*], [*Sil($k^*$)*], [*ARI($k^*$)*]),
    table.hline(stroke: 0.35pt + faint),
    [K-Means], [2], [0,580], [0,568],
    [Fuzzy K-Means], [2], [0,580], [0,568],
    [K-Medoids], [2], [0,608], [0,531],
    [Kernel Fuzzy], [2], [0,580], [0,568],
    [EM (`full`)], [2], [0,580], [0,568],
    [Hierárquico (centroid)], [2], [0,580], [0,568],
    [DBSCAN (0,7 / 5)], [2], [0,610], [0,573],
    table.hline(stroke: 0.6pt + faint),
  )
]

#v(0.25cm)
#block(fill: soft, inset: 0.5em, radius: 3pt, width: 100%)[
  #text(size: 0.86em)[
    A silhueta seleciona $k^* = 2$ nos métodos avaliados; no DBSCAN, a configuração escolhida também possui 2 grupos.
    O ARI em $k^*$ fica entre 0,531 e 0,573: _setosa_ separada, _versicolor_/_virginica_ juntas.
  ]
]

#v(0.2cm)
#block(fill: ink, inset: 0.5em, radius: 3pt, width: 100%)[
  #text(size: 0.86em, fill: white)[
    *Acordo pelo critério interno:* os sete métodos escolhem $k^* = 2$ pela silhueta.
    A comparação externa mostra diferenças menores de ARI e a sobreposição entre versicolor e virginica.
  ]
]

== Comparação — agrupamento e redução

#grid(
  columns: (1fr, 1fr),
  gutter: 0.6cm,
  align: horizon,
  [
    #text(size: 0.84em)[
      *Agrupamento (ARI em $k = 3$)*
      - EM (`full`): *0,904* — melhor do estudo, 5/150 fora.
      - K-Medoids: 0,665 · K-Means/Fuzzy: 0,620 · Hierárquico: 0,562.
      - Kernel Fuzzy: 0,529 selecionado; melhor diagnóstico em $k = 4$ (0,587).
      - DBSCAN: ARI alto exige descarte de pontos — não comparável.
    ]
  ],
  [
    #text(size: 0.84em)[
      *Redução (configuração selecionada)*
      - Trustworthiness: t-SNE *0,990* · PCA 0,978 · UMAP 0,980 · Kernel PCA 0,976.
      - Silhueta interna: UMAP 0,863 · t-SNE 0,819 · KPCA 0,637 · PCA 0,613.
      - Silhuetas de embedding *não são comparáveis* às de agrupamento.
      - Grids de 1, 5, 4 e 12 tentativas: comparar com trustworthiness, não só o máximo.
    ]
  ],
)

#v(0.25cm)
#block(fill: soft, inset: 0.45em, radius: 3pt, width: 100%)[
  #text(size: 0.8em)[
    *Silhueta pergunta* “onde estão os grupos mais coesos?”; *ARI pergunta* “quanto coincidem com as espécies?”.
    Numa base com uma espécie separada e duas sobrepostas, as respostas divergem.
  ]
]

== Conclusões

#grid(
  columns: (1.1fr, 1fr),
  gutter: 0.65cm,
  align: horizon,
  [
    #text(size: 0.88em)[
      *O que os resultados mostram*
      - A estrutura dominante observada é a separação da _setosa_: em todos os métodos, ela forma o agrupamento mais distinto.
      - A silhueta seleciona *$k^* = 2$* nos métodos avaliados; o ARI em $k^*$ fica entre 0,531 e 0,573.
      - Melhor acordo com as espécies: *EM em $k = 3$* (ARI 0,904; 3,3% fora), depois K-Medoids (0,665).
    ]
  ],
  [
    #text(size: 0.88em)[
      *Limitações e cuidados*
      - *ARI é avaliação externa:* escolher $k$ por ARI seria vazamento de rótulos.
      - DBSCAN: ARI alto com cobertura baixa não é comparável a 150 pontos.
      - Embeddings vêm de grids (1, 5, 4, 12): comparação entre técnicas com viés.
      - Iris é pequena e balanceada: não generalizar automaticamente.
    ]
  ],
)

#v(0.2cm)
#block(fill: soft, inset: 0.5em, radius: 3pt, width: 100%)[
  #text(size: 0.82em)[
    *Padronização z-score em todos os algoritmos;* a comparação é qualitativa e experimental.
  ]
]

#v(0.2cm)
#block(fill: ink, inset: 0.5em, radius: 3pt, width: 100%)[
  #text(size: 0.86em, fill: white)[
    A base apresenta uma separação clara da _setosa_ e uma fronteira mais difícil entre _versicolor_ e _virginica_.
    O $k^*$ não supervisionado captura a primeira; o ARI em $k = 3$ revela a segunda.
  ]
]

== Obrigado

#v(0.5cm)
#align(center)[
  #text(size: 2.0em, weight: "bold", fill: ink)[Dúvidas?]
  #v(0.2cm)
  #text(size: 0.90em, fill: faint)[Andre Saghaard \& Bianca Paes · UFPE · Recife · 26 de novembro de 2026]
]

#v(0.55cm)
#block(fill: soft, inset: 0.6em, radius: 3pt, width: 100%)[
  #text(size: 0.86em, weight: "bold", fill: ink)[Principais resultados]
  #v(0.18cm)
  #text(size: 0.82em)[
    $k^* = 2$ pela silhueta · setosa isolada em praticamente todos os modelos
    \
    EM em $k = 3$: melhor ARI externo (0,904)
    \
    Trustworthiness principal nos embeddings: KPCA 0,976 · t-SNE 0,990 · UMAP 0,980
  ]
]
