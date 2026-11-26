%
%%%%%%% SIMULA Sistema de Transmissão em Banda BAse  %%%%%%%%%%%%%%%%%%%%%%
%
% Lab VI - Modulação Digital em Banda Base e Banda Passante
% Banda Base: com pammod
%
% Para PC I
% By: Prof. Jair Silva
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
clc, clear all, close all;
%
%...................... Parametros de Entrada .............................
Rb = 100e6;   % Taxa de transmissão [bits/s]
M = 4;        % Nível da modulação
k = log2(M);  % bits por símbolo
Rs = Rb/k;    % Taxa de simbolos ou Baud rate (Simbolos/s)
n = 6000000;    % Numero de bits da Sequencia (Bitstream)
nsamp = 4;    % Taxa de Oversampling
v_snr = 0:2:16;      % Vetor SNR em dB

%...................... Parametros Calculados .............................
Tb = 1/Rb;    % Duração de um bit
Ts = 1/Rs;    % Duração de um símbolo (Pulso para este caso)

%&&&&&&&&&&&& Simulação do Sistema &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%
%
disp('...................................................................')
disp('...... Modulação Digital para Transmissão em Banda Base ...........')

for kk = 1:length(v_snr)
    %
    % ********************* TRANSMISSOR ***************************************
    %
    % Gera a sequencia de bits contendo informação
    x = randi([0,M-1],1,n);
    
    % "Modulação" Digital NRZ Bipolar
    xmod = pammod(x,M); % mapeamento PAM
    
    % Aplica filtro conformador de pulso retangular (com reamostragem)
    x_up = rectpulse(xmod,nsamp);
    
    % Geração do vetor tempo
    tam = length(x_up);
    tf  = tam/Rs;       % Instante final do sinal
    ti  = 0;            % Instante inicial do sinal
    t = linspace(ti,tf,tam);
    ta = t(2) - t(1);   % Periodo de amostragem
    
    
    % *********************** CANAL *******************************************
    % Adiciona ruído Gaussiano branco ao sinal
    snr = v_snr(kk);
    y_ruido = awgn(x_up,snr,'measured');
    % *************************************************************************
    
    
    % ********************** RECEPTOR *****************************************
    % Conformação de pulso na recepção (com reamostragem)
    y_down = intdump(y_ruido,nsamp);
    
    % "Demodulação" Digital NRZ Bipolar
    y = pamdemod(y_down,M); % Demapeamento PAM
    
    %******************* Calcula os erros *************************************
    d_bit = (abs(x-y));
    n_erros = sum(d_bit);
    ber_awgn(kk) = mean(d_bit);
    
end

% ------------------------- Mostra alguns Gráficos ------------------------
% Plota a curva de BER versus SNR
figure
semilogy(v_snr,ber_awgn), grid
xlabel('SNR (dB)')
ylabel('BER')

%
disp('...................................................................')
%
%