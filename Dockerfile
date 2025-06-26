FROM node:22.17.0-alpine

LABEL org.opencontainers.image.source=https://github.com/astrawan/docker-rust-node

# origin: https://github.com/rust-lang/docker-rust
RUN apk add --no-cache \
  ca-certificates \
  gcc

ENV RUSTUP_HOME=/usr/local/rustup \
  CARGO_HOME=/usr/local/cargo \
  PATH=/usr/local/cargo/bin:$PATH \
  RUST_VERSION=1.85.1

RUN set -eux; \
  apkArch="$(apk --print-arch)"; \
  case "$apkArch" in \
  x86_64) rustArch='x86_64-unknown-linux-musl'; rustupSha256='e6599a1c7be58a2d8eaca66a80e0dc006d87bbcf780a58b7343d6e14c1605cb2' ;; \
  aarch64) rustArch='aarch64-unknown-linux-musl'; rustupSha256='a97c8f56d7462908695348dd8c71ea6740c138ce303715793a690503a94fc9a9' ;; \
  *) echo >&2 "unsupported architecture: $apkArch"; exit 1 ;; \
  esac; \
  url="https://static.rust-lang.org/rustup/archive/1.28.2/${rustArch}/rustup-init"; \
  wget "$url"; \
  echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
  chmod +x rustup-init; \
  ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
  rm rustup-init; \
  chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
  rustup --version; \
  cargo --version; \
  rustc --version; \
  rustup target add x86_64-pc-windows-gnu

ENV MINGW64_OPENSSL_FILE=mingw-w64-x86_64-openssl-3.5.0-1-any.pkg.tar.zst
ENV VERSION_MANAGER_VERION=3.0.0
ENV COCOGITTO_VERSION=6.3.0

RUN apk add --no-cache \
  build-base \
  curl \
  git \
  mingw-w64-gcc \
  mingw-w64-binutils \
  musl-dev \
  openssh-client-default \
  openssl-dev \
  openssl-libs-static \
  zstd 

RUN curl -fsSLO https://repo.msys2.org/mingw/mingw64/${MINGW64_OPENSSL_FILE} 

RUN curl -fsSLO https://github.com/annie444/version/releases/download/v${VERSION_MANAGER_VERION}/version-v${VERSION_MANAGER_VERION}-x86_64-unknown-linux-musl.tar.gz

RUN curl -fsSLO https://github.com/cocogitto/cocogitto/releases/download/${COCOGITTO_VERSION}/cocogitto-${COCOGITTO_VERSION}-x86_64-unknown-linux-musl.tar.gz

RUN unzstd < ${MINGW64_OPENSSL_FILE} | tar -C /opt --exclude '.BUILDINFO' --exclude '.MTREE' --exclude '.PKGINFO' --exclude 'mingw64/bin' --exclude 'mingw64/etc' --exclude 'mingw64/share' -xvf -

RUN tar -xzf version-v${VERSION_MANAGER_VERION}-x86_64-unknown-linux-musl.tar.gz -C /opt

RUN tar -xzf cocogitto-${COCOGITTO_VERSION}-x86_64-unknown-linux-musl.tar.gz -C /opt

RUN mv -v /opt/mingw64 /opt/mingw64-openssl

RUN mv -v /opt/x86_64-unknown-linux-musl /opt/cocogitto

RUN ln -s /opt/version/version /usr/local/bin/version-manager

RUN ln -s /opt/cocogitto/cog /usr/local/bin/cog

RUN rm -fr *.zst

RUN rm -fr *.gz

RUN which cog

RUN which version-manager
