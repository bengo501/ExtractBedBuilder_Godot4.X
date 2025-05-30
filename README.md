# Leito de Extração - Simulador 3D

## Visão Geral
Este é um simulador 3D de um leito de extração, desenvolvido em Godot Engine. O projeto permite visualizar e interagir com um leito de extração em um ambiente 3D, com múltiplas câmeras e controles interativos.

## Funcionalidades Principais

### Sistema de Câmeras
O simulador possui quatro tipos de câmeras diferentes:

1. **Câmera Frontal (Front)**
   - Visualização frontal do leito
   - Controles:
     - Q/E: Mover câmera para baixo/cima
     - Mouse: Zoom in/out
     - Botões de interface: Ajuste de zoom

2. **Câmera Livre (Free)**
   - Controle total da câmera
   - Controles:
     - WASD: Movimento horizontal
     - Q/E: Movimento vertical
     - Botão direito do mouse: Rotação da câmera
     - Setas: Rotação adicional

3. **Câmera Isométrica (Iso)**
   - Visualização em perspectiva isométrica
   - Controles:
     - Q/E: Mover câmera para baixo/cima
     - Mouse: Zoom in/out
     - Botões de interface: Ajuste de zoom

4. **Câmera Superior (Top)**
   - Visualização de cima
   - Controles:
     - Mouse: Zoom in/out
     - Botões de interface: Ajuste de zoom

### Atalhos de Teclado
- **1**: Ativa câmera frontal
- **2**: Ativa câmera livre
- **3**: Ativa câmera isométrica
- **4**: Ativa câmera superior
- **R**: Reseta todas as câmeras para posição inicial

### Interface do Usuário
- **Indicador de Câmera**: Mostra informações sobre a câmera atual
  - Nome da câmera
  - Posição (X, Y, Z)
  - FOV (Campo de Visão)
  - Nível de Zoom

- **Controles de Zoom**
  - Botões + e - para ajuste de zoom
  - Zoom automático baseado no tamanho do leito

- **Intensidade do Skybox**
  - Slider para ajustar a intensidade do ambiente
  - Valor padrão: 0.2
  - Range: 0.0 a 2.0

## Estrutura do Projeto

### Diretórios
- `Cenas/`: Contém as cenas do projeto
  - `main_scene.tscn`: Cena principal do simulador
- `Scripts/`: Contém os scripts do projeto
  - `camera_controller.gd`: Controlador principal das câmeras
  - `free_camera.gd`: Script da câmera livre
  - `camera_iso_control.gd`: Script da câmera isométrica
  - `extraction_bed.gd`: Script do leito de extração

### Configurações Técnicas

#### Câmeras
- **FOV (Campo de Visão)**
  - Mínimo: 30.0
  - Máximo: 120.0
  - Padrão: 60.0

- **Distância**
  - Mínima: 5.0
  - Máxima: 50.0

- **Zoom**
  - Mínimo: 0.5
  - Máximo: 2.0
  - Incremento: 0.05

#### Ajustes Automáticos
- O simulador ajusta automaticamente:
  - FOV baseado no tamanho do leito
  - Distância da câmera
  - Zoom para manter o leito visível

## Requisitos do Sistema
- Godot Engine 4.x
- Sistema operacional compatível com Godot
- Placa de vídeo com suporte a OpenGL 3.3 ou superior

## Instalação
1. Clone o repositório
2. Abra o projeto no Godot Engine
3. Execute a cena principal (`Cenas/main_scene.tscn`)

## Controles Detalhados

### Câmera Frontal e Isométrica
- **Movimento Vertical**
  - Tecla Q: Move a câmera para baixo
  - Tecla E: Move a câmera para cima
  - Velocidade: 2.0 unidades por segundo

### Câmera Livre
- **Movimento**
  - W: Move para frente
  - S: Move para trás
  - A: Move para esquerda
  - D: Move para direita
  - Q: Move para baixo
  - E: Move para cima
  - Velocidade base: 5.0 unidades por segundo

- **Rotação**
  - Botão direito do mouse + movimento: Rotação da câmera
  - Setas esquerda/direita: Rotação adicional
  - Sensibilidade do mouse: 0.03
  - Sensibilidade das setas: 1.0

## Dicas de Uso
1. Use a câmera frontal para visualização detalhada do leito
2. A câmera livre é ideal para inspeção completa do ambiente
3. A câmera isométrica oferece uma boa visão geral
4. A câmera superior é útil para verificação de alinhamentos

## Suporte
Para reportar problemas ou sugerir melhorias, por favor abra uma issue no repositório do projeto.

## Licença
Este projeto está sob a licença [inserir tipo de licença]. 