% Gerar um pulso retangular
% Aplicar a transformada de Fourier 
% Exemplo de Script para estudo de período e taxa de amostragem
%Parametros de entrada
t_f = 30e-6; %tempo final
t_i = 0; %tempo inicial
tam = 128; %quantidade de amostragens
%geração do vetor
t=linspace(t_i,t_f,tam);%geração vetor tempo
%proessamento dos dados
ta = t(2) - t(1);%determinação do período de amostragem
fa=1/ta;%frequencia da amostragem
x1 = zeros(size(t));
x1((end/2)-(end/8):(end/2)+(end/8))=ones(size(x1((end/2)- (end/8):(end/2)+(end/8))));
sinal = 6*x1
%display dos resultados
plot(sinal)
fs = 1/ta; % Taxa de amostragem
ni = length(sinal); % Tamanho do sinal de entrada
nf = 2^(nextpow2(ni)); % Novo tamanho do sinal
% A transformada via FFT
Sinal_ff = fft(sinal,nf);
Sinal_ff = Sinal_ff/fs;
% O novo sinal no domínio do tempo
sinal_tf = [sinal,zeros(1,nf-ni)];
% A resolução na frequencia
df = fs/nf;
% Vetor frequencia
f = (0:df:df*(length(sinal_tf)-1)) - fs/2;
% Centralizar a frequência zero (DC)
Sinal_ff_shifted = db(fftshift(abs(Sinal_ff)));
% PLOT
figure;
% Gráfico Domínio do Tempo
subplot(2,1,1);
plot(t * 1e6, sinal, 'LineWidth', 2); % Tempo em microssegundos
title('Sinal no Domínio do Tempo');
xlabel('Tempo (\mu s)');
ylabel('Amplitude');
grid on;
% Gráfico Domínio da Frequência (Magnitude)
subplot(2,1,2);
plot(f * 1e-6, Sinal_ff_shifted, 'r', 'LineWidth', 2); % MHz
title('Espectro de Magnitude (Transformada de Fourier)');
xlabel('Frequência (MHz)');
ylabel('|X(f)|');
grid on

% Centralizar a frequência zero (DC)
Sinal_ff_shifted = fftshift(Sinal_ff);
% PLOT
figure;
% Gráfico Domínio do Tempo
subplot(2,1,1);
plot(t * 1e6, sinal, 'LineWidth', 2); % Tempo em microssegundos
title('Sinal no Domínio do Tempo');
xlabel('Tempo (\mu s)');
ylabel('Amplitude');
grid on;
% Gráfico Domínio da Frequência (Magnitude)
subplot(2,1,2);
plot(f * 1e-6, abs(Sinal_ff_shifted), 'r', 'LineWidth', 2); % Frequência em MHz
title('Espectro de Magnitude (Transformada de Fourier)');
xlabel('Frequência (MHz)');
ylabel('|X(f)|');
grid on
% Centralizar a frequência zero (DC)
Sinal_ff_shifted = fftshift(Sinal_ff);
% PLOT
figure;
% Gráfico Domínio do Tempo
subplot(2,1,1);
plot(t * 1e6, sinal, 'LineWidth', 2); % Tempo em microssegundos
title('Sinal no Domínio do Tempo');
xlabel('Tempo (\mu s)');
ylabel('Amplitude');
grid on;
% Gráfico Domínio da Frequência (Magnitude)
subplot(2,1,2);
plot(f * 1e-6, abs(Sinal_ff_shifted), 'r', 'LineWidth', 2); % Frequência em MHz
title('Espectro de Magnitude (Transformada de Fourier)');
xlabel('Frequência (MHz)');
ylabel('|X(f)|');
grid on
% Exemplo de Script para estudo de paríodo e taxa de amostragem
%Parametros de entrada
t_f = 0.4e-6; %tempo final
t_i = 0; %tempo inicial
tam = 100; %quantidade de amostragens
%geração do vetor
t=linspace(t_i,t_f,tam);%geração vetor tempo
%proessamento dos dados
ta = t(2) - t(1);%determinação do príodo de amostragem
fa=1/ta;%frequencia da amostragem
y=10*cos(2*pi*t*10000000); 
%display dos resultados
plot(t,y)