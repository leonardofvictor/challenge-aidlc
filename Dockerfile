# Origem: https://github.com/rodrigo-tsuru/ai-assistants-devspaces (copiado sem alteracoes de conteudo)
FROM quay.io/devfile/universal-developer-image:latest
RUN npm install -g @anthropic-ai/claude-code && \
npm install -g @github/copilot
ARG AIDLC_VERSION=2.10.0
ENV AIDLC_INSTALL_ROOT=/opt/aidlc \
    AIDLC_BIN_DIR=/opt/aidlc/bin \
    PATH=/opt/aidlc/bin:$PATH

# Prepara o diretório como root, entregando ao usuário da imagem
USER 0
RUN mkdir -p /opt/aidlc/bin && chown -R 10001:0 /opt/aidlc

# Instala como usuário não-root (o instalador recusa root)
USER 10001
RUN tmp="$(mktemp -d)" \
 && curl -fsSL -o "$tmp/install.sh" \
      "https://github.com/awslabs/aidlc-workflows/releases/download/v${AIDLC_VERSION}/install.sh" \
 && sh "$tmp/install.sh" --version "${AIDLC_VERSION}" --yes --quiet \
 && rm -rf "$tmp"

# Ajusta para UID arbitrário do OpenShift (grupo 0) e expõe no PATH dos hooks
USER 0
RUN chgrp -R 0 /opt/aidlc && chmod -R g=u /opt/aidlc \
 && ln -s /opt/aidlc/bin/aidlc /usr/local/bin/aidlc
USER 10001
