clear all;
clc;

% Faixa de frequência em Hz e conversão para rad/s
f = linspace(0.0002, 2, 181);
w = 2 * pi * f;

% 1. Filtro Butterworth (N=7, ganho DC = 1/2)
n1 = 1;
d1 = conv([1 0.44504 1], conv([1 1.24698 1], conv([1 1.80194 1], [1 1])));
h1 = freqs((1/2)*n1, d1, w);

% 2. Filtro Chebyshev (N=4, ganho DC = 1/3)
n2 = 0.3791;
d2 = conv([1 0.35071 1.06352], [1 0.84668 0.35641]);
h2 = freqs((1/3)*n2, d2, w);

% 3. Filtro Elíptico (N=3, ganho DC = 1/2)
n3 = 0.1543 * [1 0 5.15321];
d3 = conv([1 0.53793 1.14858], [1 0.69222]);
h3 = freqs((1/2)*n3, d3, w);

% Cálculo em dB equivalente ao QUCS: dB(2*Vo)
mag1_dB = 20 * log10(abs(2 * h1));
mag2_dB = 20 * log10(abs(2 * h2));
mag3_dB = 20 * log10(abs(2 * h3));

% Gráfico em dB vs Frequência (Hz)
figure(1);
plot(f, mag1_dB, f, mag2_dB, f, mag3_dB);
title('Gráficos de |H(jf)| em dB versus f (Hz)');
xlabel('f (Hz)');
ylabel('Magnitude (dB)');
legend('Butterworth (VoBdB)', 'Chebyshev (VoCdB)', 'Elíptico (VoEdB)');
grid on;