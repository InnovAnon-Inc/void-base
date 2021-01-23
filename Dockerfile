FROM innovanon/voidlinux as builder
RUN sleep 91                  \
 && xbps-install -Suy         \
 && xbps-install   -y         \
      autoconf                \
      automake                \
      cross-x86_64-linux-gnu  \
      cmake                   \
      curl                    \
      gcc                     \
      git                     \
      gmp-devel               \
      isl-devel               \
      libmpc-devel            \
      make                    \
      mpfr-devel              \
      ninja                   \
      upx                     \
 && git config --global http.proxy $SOCKS_PROXY

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

