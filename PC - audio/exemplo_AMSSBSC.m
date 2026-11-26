
%% -------- Simulação AM-SSB/SC -------------------------------------------
%% Inicialização 
clc, clear all, close all

%% Dados de entrada
Am = 1;      % Amplitude do sinal modulante [V]
fm = 1e3;    % Frequencia do sinal modulante [Hz]
f0 = 10*fm;  % frequencia da portadora [Hz]. fo >> fm
E0 = 1;      % Amplitude da portadora [V]
Fs = 10*(f0+fm); % Taxa de amostragem [S/s]
ts = 1/Fs;   % Periodo de amostragem
tam = 1024;  % Tamanho dos vetores 

%% Geração do vetor tempo
t = 0:ts:(tam-1)*ts;

%% Geração do sinal modulante/modulador (sinal tonal)
x = Am*cos(2*pi*fm*t);

%% ------------  Transmissor ----------------------------------------------
y = ssbmod(x,f0,Fs); % sinal modulado 

%--------------------------------------------------------------------------



%% --------------  Canal --------------------------------------------------
r = awgn

%--------------------------------------------------------------------------



%% ------------  Receptor -------------------------------------------------
xr = 
%--------------------------------------------------------------------------

%% Plotagem dos sinais e esoectros
figure, plot(t,x)   % sinal modulante
[X,x_tf,f,df] = Analisador_de_Espectro(x,ts);
figure, plot(f,fftshift(10*log10(abs(X))))

figure, plot(t,y);
[Y,y_tf,f,df] = Analisador_de_Espectro(y,ts);
figure, plot(f,fftshift(10*log10(abs(Y))))


