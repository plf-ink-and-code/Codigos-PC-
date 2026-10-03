% exemplo script, estudo de periodo e taxa de amostragem
clc, clear all, close all % Apaga toda as variaveis da memoria

% Parametros de entrada 
tf= 0.4e-6; % duração do vetor tempo
ti=0; % tempo inicial
tam=128; % qtd de amostras do vetor

% Processamento dos sinais
t=linspace(ti,tf,tam); % Geração do vetor tempo

% Determinação da taxa de amostragem

ta=t(2)-t(1); % Periodo de amostragem

Fs= 1/ta; % taxa de amostragem [amostras/s]

% Demonstração dos resultados
disp(Fs)
 
% Crição do cos
fc= Fs/50;
x = 2*cos(2*pi*fc*t);

plot(x)



