clear all; 
clc; 

% Definição da faixa de frequências, Valor inicial, incremento, final
w = 0:0.001:4;

% 1. Filtro Butterworth
[z1, p1, k1] = buttap(4);
n1 = poly(z1);
d1 = poly(p1);
[h1, ~] = freqs(k1*n1, d1, w);
mag1 = abs(h1);
phase1 = angle(h1) * (180/pi); % conversão para graus

% 2. Filtro Chebyshev Tipo 1
[z2, p2, k2] = cheb1ap(4, 3);
n2 = poly(z2);
d2 = poly(p2);
[h2, ~] = freqs(k2*n2, d2, w);
mag2 = abs(h2);
phase2 = angle(h2) * (180/pi);

% 3. Filtro Elíptico
[z3, p3, k3] = ellipap(4, 3, 30); 
n3 = poly(z3); 
d3 = poly(p3); 
[h3, ~] = freqs(k3*n3, d3, w);
mag3 = abs(h3);
phase3 = angle(h3) * (180/pi);

% Gráficos de |H(j\omega)|
figure(1);
plot(w, mag1, w, mag2, w, mag3); 
title('Gráficos de |H(j\omega)| versus \omega');
xlabel('\omega (rad/s)');
ylabel('|H(j\omega)|');
legend('Butterworth', 'Chebyshev', 'Elíptico');

% Gráficos de fase
figure(2);
plot(w, phase1, w, phase2, w, phase3);
title('Gráficos de \phi(\omega) versus \omega');
xlabel('\omega (rad/s)');
ylabel('\phi(\omega) (graus)');
legend('Butterworth', 'Chebyshev', 'Elíptico');

% Gráficos em dB
figure(3);
plot(w, 20*log10(mag1), w, 20*log10(mag2), w, 20*log10(mag3));
title('Gráficos de |H(j\omega)| em dB versus \omega');
xlabel('\omega (rad/s)');
ylabel('20log|H(j\omega)| (dB)');
legend('Butterworth', 'Chebyshev', 'Elíptico');  