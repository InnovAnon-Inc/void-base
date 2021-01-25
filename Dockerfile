FROM innovanon/voidlinux as builder
WORKDIR /tmp
RUN sleep 91                  \
 && xbps-install -Suy         \
 && xbps-install   -y         \
      autoconf                \
      automake                \
      binutils                \
      clang                   \
      cross-x86_64-linux-gnu  \
      cmake                   \
      curl                    \
      gcc                     \
      git                     \
      gmp-devel               \
      isl-devel               \
      libmpc-devel            \
      libtool                 \
      llvm                    \
      make                    \
      m4                      \
      mpfr-devel              \
      ninja                   \
      perf                    \
      upx                     \
 && git config --global http.proxy $SOCKS_PROXY \
 && git clone --depth=1 --recursive -b 0.19                               \
                                    https://github.com/google/autofdo.git \
 && cd                                                        autofdo     \
 && aclocal -I .                                                          \
 && autoheader                                                            \
 && autoconf                                                              \
 && automake --add-missing -c                                             \
 && ./configure                                                           \
 && make -j1                                                              \
 && make install                                                          \
 && cd ..                                                                 \
 && rm -rf                                                    autofdo

FROM scratch as squash
COPY --from=builder / /
RUN chown -R tor:tor /var/lib/tor
SHELL ["/usr/bin/bash", "-l", "-c"]
ARG TEST

FROM squash as test
ARG TEST
RUN tor --verify-config \
 && sleep 127           \
 && xbps-install -S     \
 && exec true || exec false

FROM squash as final

