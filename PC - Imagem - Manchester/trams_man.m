% Inicialização
clc, close all, clear all

% ---PARÂMETROS DE ENTRADA---
snr = -6;            % Relação Sinal-Ruído em dB
nsamp = 4;           % Fator de superamostragem

% ---LEITURA E PROCESSAMENTO DA IMAGEM---

% Leitura da imagem e conversão para escala de cinza e transforma numa foto 128x128 (linha e coluna da matriz)
img = imread("foto_gatinho_3x4.jpeg");
img_1 = rgb2gray(imresize(img,[128 128]));

% Transformar a imagem em um vetor linha de pixels, usa o double() pois o formato original da imagem e uint8()
pixels = double(reshape(img_1, [], 1));

% Conversão cada coluna = 1 pixel que tem 8 bits
matriz_bits_tx = int2bit(pixels, 8);
% Transformar num vetor linha
img_tx_bin = matriz_bits_tx(:);

%  ................. TX .....................................................
% Resultado: o vetor img_tx_bin deixa de ser [0, 1] e vira bits_polar [-1, 1]
bits_polar = 2 * img_tx_bin - 1; 
% Deita as colunas, temos um vetor linha
% A metade 1 do pulso fica na linha de cima, a metade 2 fica na linha de baixo
matriz_tx = [-bits_polar, bits_polar]';
% O operador (:) lê a matriz obrigatoriamente de cima para baixo, coluna a coluna
% Empilha as duas metades de cada bit, criando uma vetor vertical
sinal_tx = matriz_tx(:);

% Repete o bit pela quantidade de nsamp, superamostra o sinal
x = rectpulse(sinal_tx,nsamp);

% -----------------  Canal  -----------------------------------------------
y = awgn(x, snr, 'measured');
% -------------------------------------------------------------------------

% ................. RX .....................................................

% Usamos o intdump que atua como um filtro casado, além de quebrar a superamostra
% Ele soma o valor superamostrado e define a energia do sinal superamostrado para definir se ele vai valer 1 ou 0, limpa o ruido
sinal_amostrado = intdump(y,nsamp);

% 2. REAGRUPAMENTO DOS PARES MANCHESTER
% Pegamos o vetor coluna recebido e cortamos em pares
% O reshape cria uma matriz de 2 linhas, exatamente como fizemos no TX:
% - Linha 1 = Primeira metade do pulso recebido 
% - Linha 2 = Segunda metade do pulso recebido 
matriz_rx_pares = reshape(sinal_amostrado, 2, []);

% Bit '1' foi enviado como [-1,  1] -> Metade 2 é MAIOR que a Metade 1.
% Bit '0' foi enviado como [ 1, -1] -> Metade 2 é MENOR que a Metade 1.

% (Linha 2 > Linha 1). Se for verdade, 1 se for falso 0
% double() para sair como valor numerico e a gente faz a transporta para ser um vetor coluna
img_rx_bin = double(matriz_rx_pares(2, :) > matriz_rx_pares(1, :))';


% =========================================================================
% RECONSTRUÇÃO DA IMAGEM E PLOTAGEM
% =========================================================================

% Pega a fila e fatia de volta em colunas de 8 bits
pixels_rx_bin = reshape(img_rx_bin, 8, []);

% Converte as colunas binárias de volta para números decimais (0 a 255)
pixels_rx = bit2int(pixels_rx_bin, 8);

% Molda os pixels de volta para o formato quadrado [128x128]
% O uint8() volta ao formato original da foto
recovered_img_1 = uint8(reshape(pixels_rx, 128, 128));

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