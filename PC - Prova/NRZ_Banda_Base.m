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
M = 2;        % Nível da modulação
k = log2(M);  % bits por símbolo
n = 30000;    % Numero de bits da Sequencia (Bitstream)
nsamp = 4;    % Taxa de Oversampling
snr = 9;      % Vetor SNR em dB
%&&&&&&&&&&&& Simulação do Sistema &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%
%
disp('...................................................................')
disp('...... Modulação Digital para Transmissão em Banda Base ...........')
%
% ********************* TRANSMISSOR ***************************************
%
% Gera a sequencia de bits contendo informação
x = randi([0,M-1],1,n); 

% "Modulação" Digital NRZ Bipolar
xmod = pammod(x,M); % mapeamento PAM 

% Aplica filtro conformador de pulso retangular (com reamostragem)
x_up = rectpulse(xmod,nsamp);


% *********************** CANAL *******************************************
% Adiciona ruído Gaussiano branco ao sinal
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
ber_awgn = mean(d_bit);

% ------------------------- Mostra alguns Gráficos ------------------------
% Plota os sinais no dominio do Tempo
figure
plot(real(x_up(1:nsamp*50))) % plota o sinal modulado
hold on
plot(real(y_ruido(1:nsamp*50)),'r') % plota o sinal ruidoso
% Mostra o diagram de olho na saída do canal
if nsamp == 1
offset = 0;
h = eyediagram(real(y_down),2,1,offset);
else
offset = 2;
h = eyediagram(real(y_down),3,1,offset);
end
set(h,'Name','Diagram de Olho sem Offset');
% Mostra o Diagrama de Constelação
scatterplot(y_down)
%************** Mostra Resultados Provisórios na Tela *********************
%
disp(sprintf('SNR: %4.1f dB',snr));
disp(sprintf('BER: %5.1e ',ber_awgn));
disp(sprintf('Qtd de erros: %3d',n_erros));
%
disp('...................................................................')
%
%