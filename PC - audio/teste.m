%                                                                         %
% =========================================================================
%                                                                         %
%                    - Principios Comunicações I -                        %
%    ----------  Embaralhador e Desembaralhador de Aúdio   -------------  %
%          ......... Com um sinal de Audio   ............                 %
%                                                                         %
% by Prof. Jair Silva                                                     %
%                                                                         %
% =========================================================================
% Inicialização
clc, clear all, close all

% ===============  Parâmetros de Simulação ==============================
snr     = 100;      % Relação Sinal-Ruído

% ===============  Leitura do Sinal de Audio ============================
[m, Fs]   = audioread('audio.wav');     % Carrega o sinal
m         = m(:,1);                     % Converte para mono (caso seja estéreo)

% =======================================================================
% --------- Primeira parte - Cálculos Preliminares ----------------------
t_s = 1/Fs;                          % Periodo de amostragem                              
dt  = t_s;                           % Passo de tempo para as funções de espectro
t = (0:t_s:(length(m)-1)*t_s).';     % Gera o vetor tempo

k = 4;
f_max = Fs/k;
f_o = 10*f_max;
F_s_bp = 10*f_o;

% ---------- Segunda Parte: Modula o Sinal de Áudio (Embaralhador) -------
s = ssbmod(m, f_o, F_s_bp);              % Modula o sinal de Audio usando f_o e F_s_bp
                                         % O Filtro passa-baixa é implementado internamente 

% #########################################################################
% ############### Quarta Parte - Canal Ruidoso ############################
s_ruidoso = awgn(s, snr, 'measured');
% #########################################################################

% ------------- Quinta Parte - Desembaralha o Sinal de Audio --------------
s_r = ssbmod(s_ruidoso, f_o, F_s_bp);    % Desembaralha o sinal de áudio recebido

% --------  Sexta Parte - Escuta dos sinais para comparação  -------------- 
sound(m, Fs)         % Sinal Original
sound(s, Fs)         % Sinal Embaralhado
sound(s_r, Fs)       % Sinal Desembaralhado

% .................... Fim da Simulação ..................................
% ........... Plota alguns Gráficos ...................................... 

% Plota o sinal de mensagem m no dominio do tempo e da frequencia
figure(1)         
subplot(2,1,1)
plot(t, m, 'b'), grid, 
title('Sinal de Audio'); xlabel('tempo [s]'), ylabel('ampl. [u.a.]')
axis tight

[M, mn, f, df] = FFT_pot2(m.', dt);  % Determina o espectro

figure(2)
subplot(2,1,1), plot(f, 10*log10(fftshift(abs(M))), 'b'), grid
title('Espectro de Potência em Banda Base');
xlabel('Frequência [Hz]'), ylabel('PSD [dB/Hz]'), axis tight

% Plota o sinal Multiplexado em SSB no dominio do tempo e da frequencia
figure(1)
subplot(2,1,2), plot(t, s, 'g'), grid, title('Sinal Embaralhado')
xlabel('tempo [s]'), ylabel('ampl. [u.a.]')
axis tight

figure(2)
[S_mod, s1, f_mod, df_mod] = Analisador_de_Espectro(s.', dt);           % Espectro
subplot(2,1,2), plot(f_mod, 10*log10(fftshift(abs(S_mod))), 'g'), grid
title('Espectro de Potência em Banda Passante do Sinal Embaralhado');
xlabel('Frequência [Hz]'), ylabel('PSD [dB/Hz]'), axis tight

% Plota o resultado da modulação com ruído no tempo e na frequencia 
figure(3) 
subplot(2,1,1), plot(t, s, 'g'), hold on
plot(t, s_ruidoso, 'r--'), grid
legend('Sinal na Entrada do Canal', 'Sinal na Saída do Canal')
xlabel('tempo [s]'), ylabel('ampl. [u.a.]'), axis tight

[S_ruido, s_ruido_spec, f_ruido, df_ruido] = Analisador_de_Espectro(s_ruidoso.', dt);   % Espectro
subplot(2,1,2), plot(f_mod, 10*log10(fftshift(abs(S_mod))), 'g'), grid
hold on, plot(f_ruido, 10*log10(fftshift(abs(S_ruido))), 'r--')
title('Espectro de Potência dos Sinais na Entrada e Saída do Canal');
xlabel('Frequência [Hz]'), ylabel('PSD [dB/Hz]')
legend('Sinal na Entrada do Canal', 'Sinal na Saída do Canal')
axis tight

% Plota os sinais desembaralhado e o sinal gerado 
figure(4) 
plot(t, m), hold on
plot(t, s_r, 'k--'), grid
xlabel('tempo [s]'), ylabel('ampl. [u.a.]'), axis tight
legend('Sinal de Áudio Gerado', 'Sinal de Áudio Recebido')

figure(5)
[SR] = FFT_pot2(s_r.', dt);   % Espectro
plot(f, 10*log10(fftshift(abs(M)))), hold on
plot(f, 10*log10(fftshift(abs(SR))), 'k--'), grid
title('Espectro de Potência em Banda Base');
xlabel('Frequência [Hz]'), ylabel('PSD [dB/Hz]'), axis tight 
legend('Sinal de Áudio Gerado', 'Sinal de Áudio Recebido')
% =========================================================================