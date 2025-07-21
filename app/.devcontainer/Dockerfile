# Começa com uma imagem base do Ubuntu, que é muito confiável.
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# Instala as ferramentas que o Flutter precisa para rodar.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git zip unzip curl libglu1-mesa

# Baixa, instala e configura o Flutter SDK.
USER vscode
RUN git clone https://github.com/flutter/flutter.git /home/vscode/flutter
ENV PATH="/home/vscode/flutter/bin:${PATH}"

# Aceita as licenças do Android e verifica a instalação.
RUN yes | flutter doctor --android-licenses && flutter doctor