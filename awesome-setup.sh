#!/bin/bash

set -e  # Encerra o script em caso de erro

# Cores para saída
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}==> Iniciando script de configuração do ambiente Awesome no Arch...${RESET}"

# Verificações iniciais
echo -e "${GREEN}==> Verificando dependências básicas...${RESET}"

# Verifica se o usuário está no grupo wheel
if ! groups | grep -qw "wheel"; then
    echo -e "${RED}Erro: seu usuário precisa estar no grupo 'wheel' para usar sudo.${RESET}"
    exit 1
fi

# Verifica se sudo está configurado para o grupo wheel
if ! sudo grep -q "^%wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
    echo -e "${RED}Erro: o grupo 'wheel' não tem permissão sudo. Edite /etc/sudoers com visudo.${RESET}"
    exit 1
fi

# Criar diretórios caso não existam
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/fonts"
mkdir -p "$HOME/Downloads"

# Instala dependências para o yay
echo -e "${GREEN}==> Instalando base-devel e git...${RESET}"
sudo pacman -S --needed base-devel git --noconfirm

# Clonar yay
cd "$HOME/Downloads"
if [ ! -d "yay" ]; then
    echo -e "${GREEN}==> Clonando yay...${RESET}"
    git clone https://aur.archlinux.org/yay.git
fi

cd yay
makepkg -si --noconfirm

# Verifica se yay foi instalado
if command -v yay >/dev/null 2>&1; then
    echo -e "${GREEN}yay instalado com sucesso!${RESET}"
else
    echo -e "${RED}Erro: yay não foi instalado.${RESET}"
    exit 1
fi

# Instala os pacotes necessários
echo -e "${GREEN}==> Instalando pacotes com yay...${RESET}"
yay -S --needed awesome-git polybar picom-pijulius-git alacritty betterlockscreen \
    catppuccin-gtk-theme-mocha conky logo-ls lxappearance neovim neofetch papirus-icon-theme \
    feh rofi xidlehook sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg zsh \
    brightnessctl cool-retro-term cmatrix nemo redshift --noconfirm

# Clona o repositório com os arquivos de configuração
cd "$HOME/Downloads"
if [ ! -d "awesome-setup" ]; then
    echo -e "${GREEN}==> Clonando repositório awesome-setup...${RESET}"
    git clone https://github.com/MeledoJames/awesome-setup
fi

# Copia os arquivos de configuração
echo -e "${GREEN}==> Copiando arquivos de configuração...${RESET}"
cp -r ~/Downloads/awesome-setup/config/* ~/.config/
cp -r ~/Downloads/awesome-setup/fonts/* ~/.local/share/fonts/
fc-cache -v -f

# Copia configurações do SDDM
sudo cp -r ~/.config/sddm/sugar-candy /usr/share/sddm/themes/
sudo cp -r ~/.config/sddm/sddm.conf /etc/

# Habilita o betterlockscreen
echo -e "${GREEN}==> Habilitando betterlockscreen...${RESET}"
sudo systemctl enable betterlockscreen@"$USER"

# Copia arquivos adicionais para o home
cp -r ~/Downloads/awesome-setup/cmatrix.sh \
      ~/Downloads/awesome-setup/grubupdate.sh \
      ~/Downloads/awesome-setup/.xinitrc \
      ~/Downloads/awesome-setup/.Xresources \
      ~/Downloads/awesome-setup/.zprofile \
      ~/Downloads/awesome-setup/.zshrc ~/

# Define o zsh como shell padrão
echo -e "${GREEN}==> Definindo zsh como shell padrão...${RESET}"
chsh -s "$(which zsh)"

# Habilita o SDDM
echo -e "${GREEN}==> Habilitando SDDM no systemd...${RESET}"
sudo systemctl enable sddm

# Baixa o papel de parede
echo -e "${GREEN}==> Baixando papel de parede...${RESET}"
cd "$HOME/Downloads"
wget -nc https://cdnb.artstation.com/p/assets/images/images/045/365/979/large/alena-aenami-stardust-1k.jpg

echo -e "${GREEN}==> Script concluído com sucesso! Reinicie e entre no ambiente gráfico com Awesome.${RESET}"
