% Modulação LoRa (CSS) - Simulação completa em um único arquivo
%
% Seções (cada uma pode ser executada sozinha com "Run Section"):
%   1) Um símbolo: Tx (chirp), Canal (AWGN) e Rx (dechirp + FFT)
%   2) Operação com SNR negativo
%   3) Spreading Factor: símbolos, Ts e taxa de bits
%   4) Frame completo: preâmbulo, sync e dados
%   5) Transmissão de imagem de ponta a ponta
%   6) BER x SNR para diferentes SF (Monte Carlo, mais lenta)
%
% Em todas: o símbolo m é o chirp base deslocado ciclicamente em m amostras (Tx);
% o receptor multiplica pelo conjugado do chirp base (dechirp), o que gera um tom
% único, e a FFT concentra a energia no bin m (Rx).

% Inicialização
clc, close all, clear all

%% =========================================================================
%  1) UM SÍMBOLO: Tx (chirp), Canal (AWGN) e Rx (dechirp + FFT)
%  =========================================================================
% Gráficos: domínio do tempo, espectro ANTES e APÓS o dechirp

% ---PARÂMETROS DE ENTRADA---
SF = 8;              % Spreading Factor
BW = 125e3;          % Largura de banda [Hz]
snr = 0;             % Relação Sinal-Ruído por amostra [dB]
simbolo = 50;        % Símbolo transmitido (0 a 2^SF - 1)

N = 2^SF;            % Número de símbolos distintos (M = 2^SF) e amostras por símbolo (fs = BW)
Ts = N/BW;           % Duração do símbolo [s]  (Ts = 2^SF/BW)
n = (0:N-1).';       % Índice de amostra

% Chirp base (up-chirp, símbolo 0). A frequência varre de -BW/2 até +BW/2
chirp_base = exp(1j*2*pi*(n.^2/(2*N) - n/2));

%  ................. TX .....................................................
idx = mod(n + simbolo, N);
x = chirp_base(idx + 1);

% -----------------  Canal  -----------------------------------------------
y = awgn(x, snr, 'measured');
% -------------------------------------------------------------------------

% ................. RX .....................................................
% Dechirp: multiplica pelo conjugado do chirp base (sobra um tom de frequência simbolo/N)
y_dechirp = y .* conj(chirp_base);

% A FFT concentra toda a energia desse tom em um único bin
Y_f = fft(y_dechirp);
[pico, bin] = max(abs(Y_f));
simbolo_rx = bin - 1;                    % O índice do pico é o valor do símbolo

Gp = 10*log10(N);                        % Ganho de processamento [dB]
fprintf('SF = %d | N = %d | Ts = %.3f ms | Gp = %.1f dB\n', SF, N, Ts*1e3, Gp);
fprintf('Símbolo transmitido: %d | Símbolo recebido: %d | Pico = %.1f\n\n', simbolo, simbolo_rx, pico);

% +++++++++++++++++++  Plotagens  +++++++++++++++++++++++++++++++++++++++++
t_ms = n/BW*1e3;                         % Tempo [ms]
bins = -N/2 : N/2-1;                     % Eixo de bins (FFT centralizada)
bin_eixo = mod(simbolo_rx + N/2, N) - N/2;   % Posição do pico no eixo centralizado
R_f = fft(y);                            % Espectro antes do dechirp

figure('Position', [100 100 800 800]);
tiledlayout(3, 1, 'Padding', 'compact');

nexttile; hold on;
plot(t_ms, real(y), 'r');
plot(t_ms, real(x), 'b', 'LineWidth', 1.5);
title(sprintf('Domínio do tempo - SNR = %d dB (sinal já não é visível a olho nu)', snr));
xlabel('Tempo (ms)'); ylabel('Amplitude'); grid on;
legend('Sinal recebido (chirp + ruído)', 'Chirp transmitido (limpo)', 'Location', 'northeast');

nexttile;
plot(bins, fftshift(abs(R_f)), 'r');
title('Espectro ANTES do dechirp - energia do chirp espalhada na banda toda');
xlabel('Bin de frequência'); ylabel('|R(f)|'); grid on; xlim([-N/2 N/2]);

nexttile; hold on;
plot(bins, fftshift(abs(Y_f)), 'k');
plot(bin_eixo, pico, 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g', 'MarkerSize', 8);
title('Espectro APÓS o dechirp - sinal concentrado em 1 bin, ruído distribuído nos demais');
xlabel('Bin de frequência (= valor do símbolo)'); ylabel('|Y(f)|'); grid on; xlim([-N/2 N/2]);
legend('Espectro pós-dechirp', 'Pico detectado (símbolo)', 'Location', 'northwest');

%% =========================================================================
%  2) OPERAÇÃO COM SNR NEGATIVO
%  =========================================================================
% Saída da FFT após o dechirp com SNR = -10 dB, para vários símbolos.
% Ganho de processamento: Gp = 10*log10(2^SF)  (SF = 8 -> Gp ≈ 24 dB)

% ---PARÂMETROS DE ENTRADA---
SF = 8;                              % Spreading Factor
snr = -10;                           % Relação Sinal-Ruído por amostra [dB]
simbolos = [20 75 130 185 240];      % Símbolos transmitidos (um por coluna)

N = 2^SF;
n = (0:N-1).';
chirp_base = exp(1j*2*pi*(n.^2/(2*N) - n/2));

%  ................. TX .....................................................
idx = mod(n + simbolos, N);          % N x 5
x = chirp_base(idx + 1);

% -----------------  Canal  -----------------------------------------------
y = awgn(x(:), snr, 'measured');     % Sinal serial, depois volta a ter 1 símbolo por coluna
y = reshape(y, N, []);
% -------------------------------------------------------------------------

% ................. RX .....................................................
Y_f = fft(y .* conj(chirp_base));    % Dechirp + FFT, coluna a coluna
[pico, bin] = max(abs(Y_f), [], 1);
simbolos_rx = bin - 1;

Gp = 10*log10(N);
fprintf('SF = %d | Gp = %.1f dB | SNR na entrada = %d dB\n', SF, Gp, snr);
fprintf('SNR teórico após dechirp + FFT = SNR + Gp = %.1f dB\n', snr + Gp);
for i = 1:length(simbolos)
    ruido_rms = sqrt((sum(abs(Y_f(:,i)).^2) - pico(i)^2)/(N-1));   % Ruído nos demais bins
    snr_pos = 20*log10(pico(i)/ruido_rms);
    fprintf('Símbolo %3d -> detectado %3d | pico = %5.1f | ruído rms = %4.1f | SNR pós = %4.1f dB\n', ...
        simbolos(i), simbolos_rx(i), pico(i), ruido_rms, snr_pos);
end
fprintf('\n');

% +++++++++++++++++++  Plotagens  +++++++++++++++++++++++++++++++++++++++++
cores = lines(length(simbolos));
marcas = {'o', 'x', '*', 's', 'p'};

figure('Position', [100 100 900 450]); hold on;
for i = 1:length(simbolos)
    plot(0:N-1, abs(Y_f(:,i)), 'LineStyle', 'none', 'Marker', marcas{i}, ...
        'MarkerSize', 4, 'Color', cores(i,:), 'HandleVisibility', 'off');
end
for i = 1:length(simbolos)
    plot(bin(i)-1, pico(i), 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 9, ...
        'MarkerFaceColor', cores(i,:), 'MarkerEdgeColor', 'k');
end
title(sprintf('Saída da FFT com SNR = %d dB (SF = %d, Gp = %.1f dB)', snr, SF, Gp));
xlabel('Amostras (bin da FFT = valor do símbolo)'); ylabel('Amplitude (a.u.)');
legend(arrayfun(@(s) sprintf('Símbolo %d', s), simbolos, 'UniformOutput', false), 'Location', 'northeastoutside');
grid on; xlim([0 N-1]);

%% =========================================================================
%  3) SPREADING FACTOR: SÍMBOLOS, Ts E TAXA DE BITS
%  =========================================================================
%   M = 2^SF  |  Ts = 2^SF/BW  |  Rb = SF/Ts

BW = 125e3;                  % Largura de banda [Hz]
SF_tabela = 7:12;            % Spreading Factors da tabela

fprintf('BW = %.0f kHz\n', BW/1e3);
fprintf('SF | Símbolos (2^SF) | Ts = 2^SF/BW [ms] | Rb = SF/Ts [bps] | Gp [dB]\n');
for SF = SF_tabela
    M = 2^SF;
    Ts = M/BW;
    Rb = SF/Ts;
    Gp = 10*log10(M);
    fprintf('%2d | %15d | %17.3f | %16.0f | %6.1f\n', SF, M, Ts*1e3, Rb, Gp);
end
fprintf('\n');

% ---SÍMBOLOS COMO CHIRPS (SF = 7)---
SF = 7;
N = 2^SF;
n = (0:N-1).';
chirp_base = exp(1j*2*pi*(n.^2/(2*N) - n/2));
simbolos = [0 32 96 127];

figure('Position', [100 100 1100 320]);
tiledlayout(1, length(simbolos), 'Padding', 'compact');

for s = simbolos
    x = chirp_base(mod(n + s, N) + 1);

    % Frequência instantânea medida no próprio sinal (ciclos/amostra)
    f_inst = angle(x(2:end) .* conj(x(1:end-1))) / (2*pi);
    t_norm = ((1:N-1).' - 0.5) / N;                 % Tempo normalizado por Ts

    % Quebra a linha onde o chirp volta de +BW/2 para -BW/2
    f_inst(abs(diff([f_inst(1); f_inst])) > 0.5) = NaN;

    nexttile; hold on;
    plot(t_norm, f_inst*BW/1e3, 'Color', [0.93 0.65 0.15], 'LineWidth', 2);
    plot(t_norm(1), (s/N - 0.5)*BW/1e3, 'o', 'MarkerFaceColor', [0 0.447 0.741], ...
        'MarkerEdgeColor', [0 0.447 0.741], 'MarkerSize', 7);      % Frequência inicial do símbolo
    title(sprintf('símbolo %d\n%s', s, dec2bin(s, SF)));
    xlabel('Tempo (t/Ts)'); ylabel('Frequência (kHz)');
    xlim([0 1]); ylim([-BW/2e3*1.1, BW/2e3*1.1]); grid on;
end

%% =========================================================================
%  4) FRAME COMPLETO: PREÂMBULO, SYNC E DADOS
%  =========================================================================
%   Preâmbulo: up-chirps | Sync: 2.25 down-chirps | Dados: símbolos
%   Depois passa pelo canal AWGN e o receptor recupera os símbolos de dados.

% ---PARÂMETROS DE ENTRADA---
SF = 7;              % Spreading Factor
BW = 125e3;          % Largura de banda [Hz]
snr = -5;            % Relação Sinal-Ruído por amostra [dB]
n_pre = 8;           % Quantidade de up-chirps do preâmbulo
n_dados = 8;         % Quantidade de símbolos de dados

N = 2^SF;
n = (0:N-1).';
chirp_base = exp(1j*2*pi*(n.^2/(2*N) - n/2));      % Up-chirp (símbolo 0)
down_chirp = conj(chirp_base);                      % Down-chirp

%  ................. TX .....................................................
simbolos_tx = randi([0, N-1], 1, n_dados);
x_dados = chirp_base(mod(n + simbolos_tx, N) + 1);
x_dados = x_dados(:);

x_pre = repmat(chirp_base, n_pre, 1);                              % Preâmbulo
x_sync = [repmat(down_chirp, 2, 1); down_chirp(1:N/4)];            % Sync (2.25 down-chirps)
x = [x_pre; x_sync; x_dados];                                      % Frame completo

% -----------------  Canal  -----------------------------------------------
y = awgn(x, snr, 'measured');
% -------------------------------------------------------------------------

% ................. RX .....................................................
% Sincronismo ideal: já sabemos onde os dados começam no frame
inicio_dados = length(x_pre) + length(x_sync) + 1;
y_dados = reshape(y(inicio_dados:end), N, []);

Y_f = fft(y_dados .* conj(chirp_base));
[~, bin] = max(abs(Y_f), [], 1);
simbolos_rx = bin - 1;

erros = sum(simbolos_tx ~= simbolos_rx);
fprintf('Símbolos transmitidos: %s\n', num2str(simbolos_tx));
fprintf('Símbolos recebidos:    %s\n', num2str(simbolos_rx));
fprintf('Erros de símbolo: %d de %d (SNR = %d dB)\n\n', erros, n_dados, snr);

% +++++++++++++++++++  Plotagens  +++++++++++++++++++++++++++++++++++++++++
f_inst = angle(x(2:end) .* conj(x(1:end-1))) / (2*pi);
t_simb = ((1:length(x)-1).' - 0.5) / N;             % Tempo em unidades de símbolo
f_inst(abs(diff([f_inst(1); f_inst])) > 0.5) = NaN;

inicio_sync = n_pre;
inicio_dados_simb = n_pre + 2.25;
ymax = BW/2e3;

figure('Position', [100 100 1100 400]); hold on;
plot(t_simb, f_inst*BW/1e3, 'b', 'LineWidth', 2);
xline(inicio_sync, '--k');
xline(inicio_dados_simb, '--k');
text(inicio_sync/2, ymax*1.15, 'Preâmbulo (up-chirps)', 'HorizontalAlignment', 'center');
text(inicio_sync + 1.125, ymax*1.15, 'Sync', 'HorizontalAlignment', 'center');
text(inicio_dados_simb + n_dados/2, ymax*1.15, 'Dados', 'HorizontalAlignment', 'center');
title(sprintf('Frame LoRa (SF = %d, BW = %.0f kHz): frequência x tempo', SF, BW/1e3));
xlabel('Tempo (símbolos)'); ylabel('Frequência (kHz)');
ylim([-ymax*1.2, ymax*1.3]); xlim([0, n_pre + 2.25 + n_dados]); grid on;

%% =========================================================================
%  5) TRANSMISSÃO DE IMAGEM DE PONTA A PONTA
%  =========================================================================
%   bits da imagem -> símbolos de SF bits -> chirps (TX) -> AWGN (canal) ->
%   dechirp + FFT + pico (RX) -> bits -> imagem recuperada
%   Precisa do arquivo foto_gatinho_3x4.jpeg na mesma pasta.

% ---PARÂMETROS DE ENTRADA---
SF = 8;                              % Spreading Factor
BW = 125e3;                          % Largura de banda [Hz]
snr_lista = [-10 -12 -14 -16 -18];   % Relações Sinal-Ruído testadas [dB]

N = 2^SF;
Ts = N/BW;
n = (0:N-1).';
chirp_base = exp(1j*2*pi*(n.^2/(2*N) - n/2));

% ---LEITURA E PROCESSAMENTO DA IMAGEM---
img = imread("foto_gatinho_3x4.jpeg");
img_1 = rgb2gray(imresize(img,[128 128]));

pixels = double(reshape(img_1, [], 1));
matriz_bits_tx = int2bit(pixels, 8);
img_tx_bin = matriz_bits_tx(:);

%  ................. TX .....................................................
% Agrupa os bits em símbolos de SF bits (completa com zeros se faltar)
n_pad = mod(-length(img_tx_bin), SF);
bits_pad = [img_tx_bin; zeros(n_pad, 1)];
matriz_bits_simb = reshape(bits_pad, SF, []);
simbolos_tx = double(bit2int(matriz_bits_simb, SF));   % Valores de 0 a 2^SF - 1
simbolos_tx = simbolos_tx(:).';
n_simb = length(simbolos_tx);

x = chirp_base(mod(n + simbolos_tx, N) + 1);            % N x n_simb
x = x(:);                                               % Sinal serial

fprintf('SF = %d | Ts = %.3f ms | %d símbolos | tempo no ar = %.1f s\n', SF, Ts*1e3, n_simb, n_simb*Ts);
fprintf('Ganho de processamento Gp = %.1f dB\n', 10*log10(N));

figure('Position', [100 100 1000 650]);
tiledlayout(2, 3, 'Padding', 'compact');
nexttile; imshow(img_1); title('Imagem Original');

for i = 1:length(snr_lista)
    snr = snr_lista(i);

    % -----------------  Canal  -------------------------------------------
    y = awgn(x, snr, 'measured');
    % ---------------------------------------------------------------------

    % ................. RX .................................................
    Y = reshape(y, N, []) .* conj(chirp_base);          % Dechirp
    [~, k] = max(abs(fft(Y)), [], 1);                   % FFT + pico
    simbolos_rx = k - 1;

    % Símbolos de volta para bits (descarta o preenchimento)
    matriz_bits_rx = int2bit(simbolos_rx(:), SF);
    img_rx_bin = matriz_bits_rx(:);
    img_rx_bin = img_rx_bin(1:length(img_tx_bin));

    % Bits de volta para pixels 128x128
    pixels_rx_bin = reshape(img_rx_bin, 8, []);
    pixels_rx = bit2int(pixels_rx_bin, 8);
    recovered_img_1 = uint8(reshape(pixels_rx, 128, 128));

    % Calculo de Erros e BER
    erros = sum(img_tx_bin ~= img_rx_bin);
    ber_img = erros/length(img_tx_bin);
    fprintf('SNR = %3d dB | Erros de bit: %d | BER: %.4e\n', snr, erros, ber_img);

    nexttile; imshow(recovered_img_1);
    title(sprintf('SNR = %d dB | BER = %.2e', snr, ber_img));
end
fprintf('\n');

%% =========================================================================
%  6) BER x SNR PARA DIFERENTES SF (Monte Carlo - pode levar 1 ou 2 minutos)
%  =========================================================================
%   Cada aumento de 1 no SF dobra o número de símbolos e desloca a curva de BER
%   em ~3 dB para a esquerda (o receptor aguenta SNR ainda mais negativo).

% ---PARÂMETROS DE ENTRADA---
SF_vec = 7:12;               % Spreading Factors simulados
n_simb = 4000;               % Símbolos por ponto da curva
lote = 500;                  % Símbolos processados por vez (limita o uso de memória)
margem = 6:1:15;             % SNR relativo ao ganho: SNR = -Gp + margem [dB]

ber = nan(length(SF_vec), length(margem));
snr_mat = nan(length(SF_vec), length(margem));

for i = 1:length(SF_vec)
    SF = SF_vec(i);
    N = 2^SF;
    Gp = 10*log10(N);
    n = (0:N-1).';
    chirp_base = exp(1j*2*pi*(n.^2/(2*N) - n/2));

    for j = 1:length(margem)
        snr = -Gp + margem(j);
        erros = 0;

        for b = 1:(n_simb/lote)
            % ................. TX .....................................
            simbolos_tx = randi([0, N-1], 1, lote);
            x = chirp_base(mod(n + simbolos_tx, N) + 1);      % N x lote

            % ---------------- Canal ------------------------------------
            y = awgn(x(:), snr, 'measured');
            % -----------------------------------------------------------

            % ................. RX .....................................
            Y = reshape(y, N, lote) .* conj(chirp_base);       % Dechirp
            [~, k] = max(abs(fft(Y)), [], 1);                  % FFT + pico
            simbolos_rx = k - 1;

            bits_tx = int2bit(simbolos_tx(:), SF);
            bits_rx = int2bit(simbolos_rx(:), SF);
            erros = erros + sum(bits_tx(:) ~= bits_rx(:));
        end

        ber(i, j) = erros/(SF*n_simb);
        snr_mat(i, j) = snr;
    end
    fprintf('SF %d concluído (Gp = %.1f dB)\n', SF, Gp);
end

figure('Position', [100 100 800 500]); hold on;
for i = 1:length(SF_vec)
    ber_plot = ber(i, :);
    ber_plot(ber_plot == 0) = NaN;            % Zero erros não aparece em escala log
    semilogy(snr_mat(i, :), ber_plot, '-o', 'LineWidth', 1.5);
end
set(gca, 'YScale', 'log');
title('BER x SNR - Modulação CSS (LoRa) em canal AWGN');
xlabel('SNR por amostra (dB)'); ylabel('BER'); grid on;
ylim([1e-5 1]);
legend(arrayfun(@(s) sprintf('SF %d', s), SF_vec, 'UniformOutput', false), 'Location', 'southwest');
