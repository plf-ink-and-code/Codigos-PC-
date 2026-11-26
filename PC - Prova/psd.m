% 1. Calcula a Densidade Espectral de Potência (PSD) dos 3 sinais
[Px_tx, freqs] = pwelch(x_tx, 1024, [], 1024, nsamp);
[Px_filt, ~]   = pwelch(x_filt, 1024, [], 1024, nsamp);
[Py_rx, ~]     = pwelch(y, 1024, [], 1024, nsamp);

% 2. Converte para dB e normaliza pelo máximo (topo em 0 dB)
Px_tx_dB   = 10 * log10(Px_tx);   Px_tx_dB   = Px_tx_dB - max(Px_tx_dB);
Px_filt_dB = 10 * log10(Px_filt); Px_filt_dB = Px_filt_dB - max(Px_filt_dB);
Py_rx_dB   = 10 * log10(Py_rx);   Py_rx_dB   = Py_rx_dB - max(Py_rx_dB);


% --- FIGURA 1: Espectro Sem Filtro (Original TX) ---
figure('Name', 'PSD - Sinal Sem Filtro');
plot(freqs, Px_tx_dB, 'k', 'LineWidth', 1.5);
xlim([0, nsamp / 2]); % Limita até a Frequência de Nyquist
xlabel('Frequência Normalizada'); 
ylabel('PSD (dB)');
title('Densidade Espectral de Potência - Sinal Sem Filtro');
grid on;


% --- FIGURA 2: Espectro Com Filtro (FIR TX) ---
figure('Name', 'PSD - Sinal Filtrado');
plot(freqs, Px_filt_dB, 'r', 'LineWidth', 1.5);
xlim([0, nsamp / 2]);
xlabel('Frequência Normalizada'); 
ylabel('PSD (dB)');
title('Densidade Espectral de Potência - Sinal Filtrado (FIR)');
grid on;


% --- FIGURA 3: Espectro Com Ruído (Canal AWGN) ---
figure('Name', 'PSD - Sinal com Ruído');
plot(freqs, Py_rx_dB, 'm', 'LineWidth', 1.5);
xlim([0, nsamp / 2]);
xlabel('Frequência Normalizada'); 
ylabel('PSD (dB)');
title('Densidade Espectral de Potência - Sinal com Ruído');
grid on;