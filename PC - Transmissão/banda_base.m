% simulação sistema de transmissão banda-base em um canal AWGN
% Comandos iniciais
clc, clear all, close all

% Parametros de entradas
N_bits = 128;
nsamp = 4; % fator de superamostragem
snr = 12; % [dB]

% Geração de bits (mensagem)
m_t = randi([0,1], N_bits,1);

% --------Tx-----------
% Gera a sequencia de pulsos com valores de 0 a 1
x_uni_polar = rectpulse(m_t,nsamp);
% Multiplica a amplitude em 2 e desloca o grafico no eixo y em -1
x = 2*x_uni_polar - 1;

% --------Canal--------
y = awgn(x,snr, "measured");

% --------Rx-----------

% Retirando a parte bipolar do sinal, ou seja variando de 0 a 1 e não de -1
% a 1
x_rx_uni_polar_1 = y +1;
x_rx_uni_polar_2 = x_rx_uni_polar_1/2;


m_r = intdump(x_rx_uni_polar_2,nsamp);
% Se o valor integrado for maior que o limiar é 1 se não é 0
limiar = 0.5;
m_r_decidido = m_r > limiar;

y_uni_polar = rectpulse(m_r_decidido,nsamp);


% Plot
figure
plot(real(x)) 
grid on
xlabel('Samples')
ylabel('Sequência de pulsos')
ylim([-2,2])

figure
plot(real(y_uni_polar)) 
grid on
xlabel('Samples')
ylabel('Sequência de pulsos com ruido')
ylim([-3,3])
