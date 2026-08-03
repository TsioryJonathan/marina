FROM ocaml/opam:ubuntu-24.04-ocaml-4.13 AS builder
WORKDIR /home/opam/marina
COPY --chown=opam:opam . .

RUN opam update && opam install -y ocamlfind ounit2
RUN eval $(opam env) && make && make test

FROM ubuntu:24.04
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  libc6 \
  && rm -rf /var/lib/apt/lists/*
RUN useradd -m marina
COPY --from=builder --chown=marina:marina /home/opam/marina/marina /usr/local/bin/marina
USER marina
ENTRYPOINT ["/usr/local/bin/marina"]
CMD ["--help"]
