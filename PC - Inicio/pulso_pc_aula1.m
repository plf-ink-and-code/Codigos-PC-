%% 1. ENTRADAS DOS SINAIS
A = 6; % Amplitude
Ts = 10/1000000; % Periodo do sinal 
fs = 1/Ts; % Frequencia do sinal
ti = -Ts; % Tempo inicial
tf = Ts; % Tempo final
n = 1024; % Quantidade de amostras: f_amostragem = n/(2Ts) >= 2f_max | n >= 100 ok
t = linspace(ti, tf, n); 
ts = t(2)-t(1); % Periodo de amostragem

% Criação do vetor do sinal
sinal = zeros(size(t));
% Pulso retangular: Amostras 500 - 250
sinal((end/2)-(end/4):(end/2)+(end/4)) = A*ones(size(sinal((end/2)-(end/4):(end/2)+(end/4))));


%% 2. PROCESSAMENTO
% A Transformada via FFT, usando o arquivo Analisador_de_Espectro
[Sinal_F, Sinal_N, f, df] = Analisador_de_Espectro(sinal, ts);

% Calcula a FFT nativa para projetar o filtro
S = fft(sinal);
mag = abs(S);

% Define o limite de 10% da amplitude máxima
limiar = 0.1 * max(mag);

% Pega a ÚLTIMA frequência cujo lóbulo ainda é maior que 10% (largura de banda)
idx_corte = find(mag(1:floor(n/2)) >= limiar, 1, 'last');

% Monta o filtro (1 até o corte, 0 no resto, mantendo a simetria da FFT)
H = zeros(size(S));
H(1:idx_corte) = 1;                     
H(end-idx_corte+2:end) = 1;             

% Filtra multiplicando na frequência
S_filtrado = S .* H;

% Retorna para o tempo aplicando a transformada inversa
sinal_filtrado = real(ifft(S_filtrado));


%% 3. PLOTS E SAÍDAS
% -- Figura 1: Pulso Original e Espectro --
figure;
subplot(2,1,1)
plot(t, sinal);
title('Pulso Retangular');
xlabel('Tempo [s]');
ylabel('Amplitude');
axis([-Ts Ts 0 1.2*A]);

subplot(2,1,2)
plot(f, pow2db(fftshift(abs(Sinal_F))));
title('Espectro do Sinal (PSD)');
xlabel('Frequência [Hz]');
ylabel('PSD [dBV/Hz]');

% -- Figura 2: Comparação Sinal Original vs Filtrado --
figure;
plot(t, sinal, 'k--', 'LineWidth', 1.2); 
hold on;
plot(t, sinal_filtrado, 'b', 'LineWidth', 1.5);
title('Sinal Filtrado na Frequência (Harmônicas/Efeito de Gibbs presentes)');
xlabel('Tempo [s]');
ylabel('Amplitude');
legend('Sinal Original', 'Sinal Filtrado');
axis([-Ts Ts -2 1.5*A]);