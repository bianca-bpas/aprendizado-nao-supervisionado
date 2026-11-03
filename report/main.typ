#import "@preview/charged-ieee:0.1.4": ieee
#import "sections/abstract.typ": abstract
#import "sections/introduction.typ": introduction
#import "sections/methodology.typ": methodology
#import "sections/results-and-discussions.typ": results-and-discussions
#import "sections/conclusions.typ": conclusions

#show bibliography: set std.bibliography(title: text(10pt)[Referências])

#show: ieee.with(
  title: [Análise comparativa de técnicas de aprendizado não supervisionado sobre a base Iris],
  abstract: abstract,
  authors: yaml("authors.yml"),
  bibliography: bibliography("refs.bib"),
)

#introduction
#methodology
#results-and-discussions
#conclusions-and-future-work
