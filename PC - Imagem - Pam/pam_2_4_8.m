clear; clc; close all;

% --- Parâmetros globais da simulação ---
num_simbolos = 2^15; % Quantidade de símbolos gerados por loop
sps = 8;             % Amostras por símbolo 
rolloff = 0.5;       % Fator de roll-off do cosseno levantado
span_filtro = 10;    % Atraso do filtro (em quantidade de símbolos)
EbNo_dB = 12;        % Relação Eb/No em dB para o canal

% Vetor com as ordens de modulação 2,4,8
vetor_M = [2,4,8];

% Loop principal para testar 2-PAM, 4-PAM e 8-PAM sequencialmente
for iter = 1:length(vetor_M)
    M = vetor_M(iter);
    k = log2(M); % Quantidade de bits em cada símbolo
        
    % =====================================================================
    % 1. GERAÇÃO DO SINAL PAM E FORMATAÇÃO DE PULSO
    % =====================================================================
    
    % Define o alfabeto do PAM e normaliza os níveis entre -1 e 1
    % Ex para 4-PAM: [-1, -1/3, 1/3, 1]
    niveis_pam = (-(M - 1):2:(M - 1)) / (M - 1); 
    
    % Gera os índices aleatórios e mapeia para as amplitudes do PAM
    indices_tx = randi([0, M-1], num_simbolos, 1);
    simbolos_tx = niveis_pam(indices_tx + 1).'; 
    
    % Projeto do filtro raiz de cosseno levantado (SRRC)
    h_srrc = rcosdesign(rolloff, span_filtro, sps, 'sqrt');
    
    % Normalização dos filtros de transmissão e recepção
    filtro_tx = h_srrc / max(h_srrc);
    filtro_rx = h_srrc / sum(h_srrc.^2); % Filtro casado
    
    % Processo de upsampling 
    sinal_up = zeros(num_simbolos * sps, 1);
    sinal_up(1:sps:end) = simbolos_tx;
    
    % Passa o sinal pelo filtro formatador de pulso (Convolução)
    sinal_tx = conv(sinal_up, filtro_tx, 'same');
    
    % =====================================================================
    % 2. PASSAGEM PELO CANAL AWGN 
    % =====================================================================
    
    % Cálculo da energia do símbolo (Es) e da energia do bit (Eb)
    Es = mean(sinal_tx.^2) * sps;
    Eb = Es / k;
    
    % Converte Eb/No de dB para escala linear para achar a variância do ruído
    EbNo_linear = 10^(EbNo_dB / 10);
    N0 = Eb / EbNo_linear;
    desvio_padrao_ruido = sqrt(N0 / 2);
    
    % Adiciona o ruído térmico ao sinal transmitido
    sinal_canal = sinal_tx + desvio_padrao_ruido * randn(length(sinal_tx), 1);
    
    % =====================================================================
    % RECEPÇÃO E FILTRO CASADO 
    % =====================================================================
    
    % O sinal recebido passa pelo filtro casado para maximizar a SNR
    sinal_rx = conv(sinal_canal, filtro_rx, 'same');
    
    % Downsampling
    amostras_rx = sinal_rx(1:sps:end);
    
    limiares = (niveis_pam(2:end) + niveis_pam(1:end-1)) / 2;
    
    % =====================================================================
    % 3. PLOT
    % =====================================================================
    
    qtd_plot = 20; 
    idx_plot = (span_filtro * sps + 1) : ((span_filtro + qtd_plot) * sps);
    vetor_t = (idx_plot - 1) / sps;
    idx_simb = (span_filtro + 1) : (span_filtro + qtd_plot);
    vetor_t_simb = idx_simb - 1;
    
    % --- Figura 1: Sinal no Domínio do Tempo ---
    fig_tempo = figure('Name', sprintf('Tempo %d-PAM', M), 'Position', [50, 50, 800, 600]);
    tiledlayout(3, 1, 'Padding', 'compact');
    
    % Gráfico do transmissor
    nexttile; 
    plot(vetor_t, sinal_tx(idx_plot), 'b', 'LineWidth', 1.2);
    title(sprintf('Saída do Transmissor (%d-PAM)', M)); ylabel('Amplitude'); grid on;
    
    % Gráfico do canal (Sinal + Ruído)
    nexttile; hold on;
    plot(vetor_t, sinal_canal(idx_plot), 'r');
    plot(vetor_t, sinal_tx(idx_plot), 'b', 'LineWidth', 1); 
    title(sprintf('Sinal no Canal AWGN (Eb/No = %d dB)', EbNo_dB)); ylabel('Amplitude'); grid on;
    legend('Com Ruido', 'Original', 'Location', 'best');
    
    % Gráfico do receptor (Após filtro casado)
    nexttile; hold on;
    plot(vetor_t, sinal_rx(idx_plot), 'g');
    plot(vetor_t_simb, amostras_rx(idx_simb), 'og', 'MarkerFaceColor', 'g');
    plot(vetor_t_simb, simbolos_tx(idx_simb), 'xk', 'MarkerSize', 8, 'LineWidth', 1.5);
    % Plota as linhas pontilhadas de limiar de decisão
    for lim = limiares
        yline(lim, '--k', 'Alpha', 0.4);
    end
    title('Sinal Recebido (Após Filtro Casado)'); 
    xlabel('Tempo (Símbolos)'); ylabel('Amplitude'); grid on;
    legend('Sinal Contínuo', 'Amostrado', 'Símbolo Correto', 'Location', 'best');
    
    % --- Figura 2: Densidade Espectral de Potência (PSD) ---
    [Px, freqs] = pwelch(sinal_tx, 1024, [], 1024, sps);
    [Py, ~] = pwelch(sinal_rx, 1024, [], 1024, sps);
    
    % Converte pra dB e normaliza
    Px_dB = 10 * log10(Px); Px_dB = Px_dB - max(Px_dB);
    Py_dB = 10 * log10(Py); Py_dB = Py_dB - max(Py_dB);
    
    fig_psd = figure('Name', sprintf('PSD %d-PAM', M), 'Position', [100, 100, 700, 350]);
    hold on;
    plot(freqs, Px_dB, 'b', 'LineWidth', 1.5);
    plot(freqs, Py_dB, 'g', 'LineWidth', 1.5);
    xlim([0, sps / 2]);
    title(sprintf('Espectro - %d-PAM', M));
    xlabel('Frequência Normalizada'); ylabel('PSD (dB)'); 
    grid on; legend('Transmissor', 'Receptor');
    
    % --- Figura 3: Diagrama de Olho ---
    fig_olho = figure('Name', sprintf('Olho %d-PAM', M), 'Position', [150, 150, 900, 350]);
    tiledlayout(1, 2, 'Padding', 'compact');
    
    ax_tx = nexttile;
    desenha_diagrama_olho(ax_tx, sinal_tx, sps, span_filtro);
    title(sprintf('Olho TX (%d-PAM)', M)); ylabel('Amplitude');
    
    ax_rx = nexttile;
    desenha_diagrama_olho(ax_rx, sinal_rx, sps, span_filtro);
    title(sprintf('Olho RX após filtro casado (%d-PAM)', M));
    % Coloca os limiares pra ver se o olho está aberto nas regiões certas
    for lim = limiares
        yline(ax_rx, lim, '--k', 'Alpha', 0.5);
    end
    linkaxes([ax_tx, ax_rx], 'y'); 
    
    drawnow; 
end

% =========================================================================
% FUNÇÕES AUXILIARES
% =========================================================================

function desenha_diagrama_olho(eixo, sinal, sps, atraso)
    
    qtd_tracos = 400; 
    inicio = atraso * sps;
    
    t_olho = linspace(-1, 1, 2 * sps + 1);
    matriz_tracos = zeros(2 * sps + 1, qtd_tracos);
    
    for i = 1:qtd_tracos
        indice_atual = inicio + (i - 1) * sps + (1 : 2 * sps + 1);
        if max(indice_atual) <= length(sinal)
            matriz_tracos(:, i) = sinal(indice_atual);
        end
    end
    
    hold(eixo, 'on');
    % Plota tudo com um pouco de transparência pra dar o efeito visual do olho
    plot(eixo, t_olho, matriz_tracos, 'Color', [0 0.447 0.741 0.2]); 
    xlim(eixo, [-1, 1]);
    grid(eixo, 'on'); 
end