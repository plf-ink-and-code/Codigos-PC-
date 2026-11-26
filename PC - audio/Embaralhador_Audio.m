% Inicialização
clc, clear all, close all
% ===============  Parâmetros de Simulação ==============================
Fc      = 15e3;     % Frequencia Central da Modulação 
snr     = 100;      % Relação Sinal-Ruído]
% ===============  Leitura do Sinal de Audio ============================
[m, Fs]   = audioread('audio.wav');     % Carrega o sinal
                                           % Compare Fs com Fc
% =======================================================================
% --------- Primeira parte - Cálculos Preliminares ----------------------
dt        = 1/Fs;                          % Periodo de amostragem                              
t         = (0:dt:(length(m)-1)*dt).';     % Gera o vetor tempo
ts  = 1/Fs; 
k = 4; 
f_max = Fs/k; 
f_o = 10*f_max; 
% fc1 = 1000;             % Frequencia central do primeiro sinal (Banda Base)
% m  = sin(2*pi*fc1*t);   % primeiro sinal a ser multiplexado 
% ------------------------------------------------------------------------
% Filtrar o sinal original 
fpass   = 4000;  
y = lowpass(m,fpass,Fs); % 4kHz - freq. de corte do passa baixas
% ---------- Segunda Parte: Modula o Sinal de Áudio  ---------------------
s = ssbmod(m,Fc,Fs);                     % Modula o sinal de Audio
                                         % O Filtro passa baixa é
                                         % implementado internamente 
% ------------------------------------------------------------------------
%#########################################################################
%############### Quarta Parte - Canal Ruidoso ############################
s_ruidoso = awgn(s,snr,'measured');
%#########################################################################
%#########################################################################
% ------------- Quinta Parte - Desembaralha o Sinal de Audio --------------
s_r = ssbmod(s_ruidoso,Fc,Fs);  % Agora Modula o sinal Audio Recebido
% -------------------------------------------------------------------------
% --------  Sexta Parte - Escuta dos sinais para comparação  -------------- 
sound(m,Fs);          % Sinal Original
sound(s_r,Fs);        % Sinal Desembaralhado
% .................... Fim da Simulação ..................................
% ........... Plota alguns Gráficos ...................................... 
% Plota o sinal de mensagem m1 no dominio do tempo e da frequencia
figure(1)         
subplot(2,1,1)
plot(t,m,'b'), grid, 
title ('Sinal de Audio'); xlabel('tempo [s]'), ylabel('ampl. [u.a.]')
axis tight
[Sinal_ff,sinal_tf,f,df] = Analisador_de_Espectro(m',ts);
% [M,mn,f,df] = FFT_pot2(m.',dt);  % Determina o espectro
figure(2)
subplot(2,1,1), plot(f, 10*log10(abs(fftshift(Sinal_ff))), 'b'), grid
title ('Espectro de Potência em Banda Base');
xlabel('Frequência[Hz]'), ylabel('PSD [dB/Hz]'), axis tight
% Plota o sinal Multiplexado em QAM no dominio do tempo e da frequencia
figure(1)
subplot(2,1,2), plot(t,s,'g'), grid, title ('Sinal Embaralhado')
xlabel('tempo [s]'), ylabel('ampl. [u.a.]')
axis tight
figure(2)
[S_mod,s1,f_mod,df_mod] = FFT_pot2(s.',dt);           % Espectro
subplot(2,1,2), plot(f_mod,10*log10(fftshift(abs(S_mod))),'g'), grid
title ('Espectro de Potência em Banda Passante do Sinal Embaralhado');
xlabel('Frequência[Hz]'), ylabel('PSD [dB/Hz]'), axis tight
% Plota o resultado da modulação com ruído no tempo e na frequencia 
figure(3) 
subplot(2,1,1), plot(t,s,'g'), hold on
plot(t,s_ruidoso,'r--'), grid
legend ('Sinal na Entrada do Canal', 'Sinal na Saída do Canal')
xlabel('tempo [s]'), ylabel('ampl. [u.a.]'), axis tight
[S_ruido,s_ruido,f_ruido,df_ruido] = FFT_pot2(s_ruidoso.',dt);   % Espectro
subplot(2,1,2), plot(f_mod,10*log10(fftshift(abs(S_mod))),'g'), grid
hold on, plot(f_ruido,10*log10(fftshift(abs(S_ruido))),'r--')
title ('Espectro de Potência dos Sinais na Entrada e Saída do Canal');
xlabel('Frequência[Hz]'), ylabel('PSD [dB/Hz]')
legend ('Sinal na Entrada do Canal', 'Sinal na Saída do Canal')
axis tight
% Plota os sinais desembaralhado e o sinal gerado 
figure(4) 
plot(t,m), hold on
plot(t,s_r,'k--'), grid
xlabel('tempo [s]'), ylabel('ampl. [u.a.]'), axis tight
legend('sinal de Audio gerado', 'sinal de Audio recebido')
figure(5)
[SR] = FFT_pot2(s_r.',dt);   % Espectro
plot(f,10*log10(fftshift(abs(M)))), hold on
plot(f,10*log10(fftshift(abs(SR))),'k--'), grid
title ('Espectro de Potência em Banda Base');
xlabel('Frequência[Hz]'), ylabel('PSD [dB/Hz]'), axis tight 
legend('sinal de Audio gerado', 'sinal de Audio recebido')
% =========================================================================
%