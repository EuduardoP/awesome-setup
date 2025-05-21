#!/bin/bash

# Detecta se está rodando em Wayland ou X11
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "Wayland detectado."

    # Verifica se xorg-xwayland está instalado
    if ! command -v Xwayland &> /dev/null; then
        echo "Erro: Xwayland não está instalado. Instale xorg-xwayland."
        exit 1
    fi

    # Força uso do X11 via XWayland
    export QT_QPA_PLATFORM=xcb
    echo "Forçando uso de QT_QPA_PLATFORM=xcb para compatibilidade."

else
    echo "X11 detectado."
fi

# Garante que DISPLAY está setado
if [ -z "$DISPLAY" ]; then
    echo "DISPLAY não está definido. Tentando definir para :0"
    export DISPLAY=:0
fi

# Interface gráfica com YAD
if output=$(yad \
    --width=390 --height=290 \
    --center \
    --fixed \
    --separator="\n" \
    --title='Garuda Hyprland Installer' \
    --button='Exit!application-exit:1' \
    --button='Install!system-run:0' \
    --text=" \n     Install Garuda Hyprland"); then

    # Executa Calamares com pkexec para privilégios
    echo "Iniciando Calamares..."
    pkexec env DISPLAY=$DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR calamares
else
    echo "Instalação cancelada."
fi
