% Inicialização
clc, clear all, close all 

%...................... Parametros de Entrada .............................
M = 4;               % Nível de modulação 4 pois dai cada simb vai ter 2 bits
k = log2(M);         % Quantidade de bits em cada símbolo (2 bits)
nsamp = 4;           % Oversampling 
Rb = 500e3;          % Taxa de transmissão de 500 kb/s 
Rs = Rb/k;           % Taxa de simbolos 
snr_imagem = 14.59;     % SNR em dB

% Leitura da imagem
img = imread("foto_3x4.jpg"); % Lê a foto do arquivo
img_1 = rgb2gray(imresize(img, [128,128])); % Força para 128x128 e deixa em escala de cinza
img_1_bin = de2bi(img_1, 8); % Converte a matriz da foto para bits
img_tx_bin = img_1_bin(:).'; % Deita a matriz e transforma numa linha só de bits

% ************* TX ***************************************
matriz_bits_tx = reshape(img_tx_bin, k, [])'; % Quebra a fila de bits em colunas de k bits
simbolos_tx = bi2de(matriz_bits_tx, 'left-msb'); % Transforma os bits em valor decimal

xmod = pammod(simbolos_tx, M); 
x_tx = rectpulse(xmod, nsamp); % Cria um pulso retangular com os valores da mod pam 4

% Prepara vetor tempo e periodo de amostragem
tam = length(x_tx); % Vê o tamanho do sinal
tf  = tam/Rs;       % Acha o tempo final
ti  = 0;            % O tempo inicial é zero
t = linspace(ti, tf, tam); % Cria o vetor do tempo total
ts = t(2) - t(1);   % Calcula o periodo de amostragem 

% Filtro FIR
ordem = 21; 
fcorte1 = 0.2;
h_fir = fir1(ordem, fcorte1); % filtro passa baixas
x_filt = filter(h_fir, 1, x_tx); % filtra o sinal

% Analise Espectral TX
[Sinal_F_orig, x_tx_n, f_orig, df_orig] = Analisador_de_Espectro(x_tx, ts);
[Sinal_F_filt, x_filt_n, f_filt, df_filt] = Analisador_de_Espectro(x_filt, ts);

% *************** CANAL *******************************************
y = awgn(x_filt, snr_imagem, 'measured'); 

% Analise Espectral Canal
[Sinal_F_ruido, y_n, f_ruido, df_ruido] = Analisador_de_Espectro(y, ts);

% ************** RX *****************************************
x_rx = intdump(y, nsamp); % Filtro integrador recebe o sinal
x_demod = pamdemod(x_rx, M); 

matriz_bits_rx = de2bi(x_demod, k, 'left-msb'); % Transforma os simb em bits
img_rx_bin = reshape(matriz_bits_rx', 1, []); % Coloca todos os bits numa fila dnv

recovered_img_1_bin = reshape(img_rx_bin, size(img_1_bin)); % Remonta a matriz no formato da foto 
recovered_img_1 = uint8(reshape(bi2de(recovered_img_1_bin), size(img_1))); % Converte com uint8 pra foto não ficar estorada


%*********** Calcula os erros *************************************
erros_img = sum(img_tx_bin ~= img_rx_bin); % Conta quantos bits chegaram errados, comparando os 2 elementos
ber_img = erros_img / length(img_tx_bin); 

fprintf('SNR: %.1f dB | Erros: %d | BER: %.4e\n', snr_imagem, erros_img, ber_img); 


% ********* Plotagem *********************************

% Sinal no Tempo
figure; 
plot(real(x_tx(1:nsamp*50)), 'b'); hold on; 
plot(real(y(1:nsamp*50)), 'r'); 
title('Sinal no Tempo'); 
legend('TX', 'Canal'); 

% Espectro Sem Filtro 
figure;
plot(f_orig, fftshift(db(abs(Sinal_F_orig))), 'k'); grid on;
title('Analise Espectral - Sinal Sem Filtro TX'); 
xlabel('Frequencia (Hz)'); ylabel('Magnitude (dB)');

% Espectro Com Filtro 
figure;
plot(f_filt, fftshift(db(abs(Sinal_F_filt))), 'r'); grid on;
title('Analise Espectral - Sinal Filtrado TX'); 
xlabel('Frequencia (Hz)'); ylabel('Magnitude (dB)');

% Espectro rx com filtro
figure;
plot(f_filt, fftshift(db(abs(Sinal_F_ruido))), 'r'); grid on;
title('Analise Espectral - Sinal Canal'); 
xlabel('Frequencia (Hz)'); ylabel('Magnitude (dB)');

% Diagrama de Olho
offset = 2; % Coloca offset pra alinhar o olho no meio do grafico
h_eye = eyediagram(real(x_rx(1:2000)), 3, 1, offset); 

% Comparacao de Imagens
figure;
subplot(1,2,1), imshow(img_1), title('Original'); 
subplot(1,2,2), imshow(recovered_img_1), title('Recuperada'); 

