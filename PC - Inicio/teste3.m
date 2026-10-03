%Limpando o espaço de trabalho
clc, clear all, close all

%parametros de entrada
Nbits = 256; %quantidade de bits a serem gerados
oversample = 4; %numero de repetição de cada bit do sinal digital para gerar o
SNR = 12; %[6dB] relação sinal ruido significa que o sinal é 4x maior que o ruido

% Geração de bits
mt = randi([0, 1], 1, Nbits); %variavel geradora de bits (utiliza a função rand)

                     
%--------Tx---------  

%Criação do sinal retangular bipolar
x = rectpulse(mt, oversample);  %Gera um pulso retangular a partir da sequencia de bits digitais
                               %4 faz o oversample pega um bit e repete ele 4 vezes para ter um sinal retangular
                               %Se deixar só um a curva gerada seria uma dente
x = 2*x - 1; %Expande o tamanho do pulso e desloca, assim quando for zero ele vai ser -1 quando for 1 ele vai ser 1


%--------Canal---------  

y_in = awgn(x, SNR, 'measured'); %(a) Adiciona um (n) ruido (w)branco (g)gaussiano ao sinal pegando x medindo a sua potencia (measured) e gerando a partir da relação sinal ruido (SNR)
                                 %A partir da função de probabilidade gaussiana ele gere uma sequencia de bits pseudo aleatória e pondera com a potência

%--------Rx---------

y = (y_in + 1)/2; %Retorna o sinal para unipolar
mr = round(intdump(y, oversample)); %Reconstroi a sequencia de bits atrávés da média dos 4 bits expandidos , assim se o ruido não for alto ele já reconstrói o sinal


%Calculo de erro
erros = (mt ~= mr); %Cria um vetor de 0 e 1 comparando se a sequencia de bits transmitida é diferente a recebida
erros = sum(erros)  %Se for igual é 0 se for diferente é 1, aqui somamos para saber o número de erros obtidos
BER = erros/Nbits %Calcula o Bit Erro Rate numero de bits errados pelo numero de transmitidos, nosso erro foi zero

% Teste do sistema


%Apresentaçãodos resultados
figure %Define a figura
plot(x); %plota o sinal no tempo
hold on %segura imagem para sobreescrever com o proximo plot
plot(y_in); %plota o y de entrada antes de transformar para unipolar