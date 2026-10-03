%entradas:
A = 6; %Amplitude
Ts = 10/1000000; %Periodo do sinal 
fs = 1/Ts; %frequencia do sinal
ti = -Ts; %tempo inicial
tf = Ts; %tempo final
n = 1024; %quantidade de amostras: f_amostragem = n/(tf-ti) = n/(2Ts) >= 2f_max | n >= 100 ok
t = linspace(ti, tf, n); 
ts = t(2)-t(1); % Periodo de amostragem
sinal = zeros(size(t));
 %Amostras      %500 - 250 (Linha e coluna) 
sinal((end/2)-(end/4):(end/2)+(end/4))=A*ones(size(sinal((end/2)- (end/4):(end/2)+(end/4))));

% A Transformada via FFT, usando o arquivo Analisador_de_Espectro
[Sinal_F,Sinal_N,f,df]=Analisador_de_Espectro(sinal,ts);

%Plot pulso retangular e FFT
figure 
subplot(2,1,1)
plot(t,sinal);
title('Pulso Retangular');
xlabel('tempo');
ylabel('amplitude');
axis([-Ts Ts 0 1.2*A]);
subplot(2,1,2)
% O matlab a fft dele de 1 ate N/2 e freq positiva e de N/2 ate N é
% negativo
% como nosso vetor esta negativo primeiro tem q usar o shift
% pow2db = 10*log10(x)
plot(f,pow2db(fftshift(abs(Sinal_F))));
xlabel('frequencia [hz]');
ylabel('PSD [dBV/hz]');







