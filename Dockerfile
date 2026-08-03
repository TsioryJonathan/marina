FROM ocaml/opam:alpine AS builder
USER opam
WORKDIR /home/opam/marina
RUN opam switch create 4.13 && eval $(opam env --switch=4.13)
COPY --chown=opam:opam . .
RUN eval $(opam env) && opam update && opam install -y ocamlfind ounit2
RUN eval $(opam env) && make && make test

FROM alpine:3.20
RUN adduser -D -u 1000 marina
COPY --from=builder --chown=marina:marina /home/opam/marina/marina /usr/local/bin/marina
USER marina
ENTRYPOINT ["/usr/local/bin/marina"]
CMD ["--help"]
