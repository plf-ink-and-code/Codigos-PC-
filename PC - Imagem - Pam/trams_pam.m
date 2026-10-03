% Inicialização
clc, close all, clear all

% ---PARÂMETROS DE ENTRADA---

M = 4;
k = log2(M);         % Bits por símbolo (k = 2 para 4-PAM)
snr = 12;            % Relação Sinal-Ruído em dB
nsamp = 4;           % Fator de superamostragem

% ---LEITURA E PROCESSAMENTO DA IMAGEM ---

% Leitura da imagem e conversão para escala de cinza e transforma numa foto 128x128 (linha e coluna da matriz)
img = imread("foto_gatinho_3x4.jpeg");
img_1 = rgb2gray(imresize(img,[128 128]));

% Conversão da imagem para matriz de bits 
img_1_bin = de2bi(img_1, 8);

% Transformação da matriz de bits em um vetor linha 
img_tx_bin = img_1_bin(:).';

%  ................. TX .....................................................

% Pega a fila de bits (vetor linha) e quebra em colunas de k bits
matriz_bits_tx = reshape(img_tx_bin, k, [])';
simbolos_tx = bi2de(matriz_bits_tx, 'left-msb'); % Converte para decimal (0 a 3)

% Modulação PAM e Formatação de Pulso Retangular
sinal_pam = pammod(simbolos_tx, M);
x = rectpulse(sinal_pam, nsamp);

% -----------------  Canal  -----------------------------------------------
y = awgn(x, snr, 'measured');
% -------------------------------------------------------------------------

% ................. RX .....................................................

% Filtro Integrador e Demodulação PAM
sinal_amostrado = intdump(y, nsamp);
simbolos_rx = pamdemod(sinal_amostrado, M);

% --- Adaptação PAM: Retornar de Símbolos para Bits ---

matriz_bits_rx = de2bi(simbolos_rx, k, "left-msb"); % Volta a ser uma matriz de k colunas com bits
img_rx_bin = reshape(matriz_bits_rx', 1 , []); % Volta a ser um vetor linha

% Vetor de bits recuperados para uma matriz igual a tx
recovered_img_1_bin = reshape(img_rx_bin, size(img_1_bin));

% Adicionado o uint8() : converte os dados para o formato de imagem (0 a 255) para o imshow não estourar o brilho da foto. double(0 a 1).
% Conversão para formato original da imagem
recovered_img_1 = uint8(reshape(bi2de(recovered_img_1_bin), size(img_1)));

% Calculo de Erros e BER
erros = (img_tx_bin ~= img_rx_bin); % Cria um vetor de 0 e 1 comparando se a sequencia de bits transmitida é diferente a recebida
erros = sum(erros);  %Se for igual é 0 se for diferente é 1, aqui somamos para saber o número de erros obtidos

% length(responde maior dimensão, como estamos com um vetor row, 1 x N vai ser o N)x size (128x128)
ber = erros/length(img_tx_bin); %Calcula o Bit Erro Rate numero de bits errados pelo numero de transmitidos

fprintf('Erros de bit: %d | BER: %.4e\n', erros, ber);

% +++++++++++++++++++  Plotagens  +++++++++++++++++++++++++++++++++++++++++
figure('Position', [150 150 800 400]);
subplot(1,2,1), imshow(img_1), title('Imagem Original')
subplot(1,2,2), imshow(recovered_img_1), title(sprintf('Imagem Recuperada (SNR = %d dB)', snr))