%=========================================================================
function [Sinal_ff,sinal_tf,f,df] = FFT_pot2(sinal,ts)
%
% FFT_pot2 --> Gera a transformada de Fourier de um sinal de tempo discreto
% A sequencia é preenchida com zeros para determinar a resolução
% em frequência final df e o o novo sinal é sinal_tf. O
% resultado está no vetor Sinal_ff.
%
% Entradas:
% sinal - sinal de entrada
% ts - periodo de amostragem
%
% Saídas:
% Sinal_ff - Espectro de amplitude do sinal
% sinal_tf - Novo sinal no domínio do tempo
% f - Vetor frequencia
% df - resolução no domíno da frequencia
%
%
% Prof. Jair Silva
% Comunicação de Dados
%
% See also: nextpow2 and fft
% =========================================================================
%
fs = 1/ts; % Taxa de amostragem
ni = length(sinal); % Tamanho do sinal de entrada
nf = 2^(nextpow2(ni)); % Novo tamanho do sinal
% A transformada via FFT
Sinal_ff = fft(sinal,nf);
Sinal_ff = Sinal_ff/fs;
% O novo sinal no domínio do tempo
sinal_tf = [sinal,zeros(1,nf-ni)];
% A resolução na frequencia, espaçamento da frequencia
df = fs/nf;
% Vetor frequencia, 0, df, 2df, ..., fmax = FS/2, e começa em -FS/2
f = (0:df:df*(length(sinal_tf)-1)) - fs/2;

% EOF