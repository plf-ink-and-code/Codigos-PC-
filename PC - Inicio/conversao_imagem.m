% =========================================================================
% 
% Código para conversão de imagem em sequencia de bits
%
% by Rayane de Souza e Vinicius Maciel 
% Maio de 2021
% =========================================================================

% Inicialização 
clc, close all, clear all

% .................  Transmissão  ......................................... 

% Leitura da imagem 
img_1 = imread('rover.jpg');

% Conversão da imagem para matriz de bits
img_1_bin = de2bi(img_1);

% Transformação da matriz de bits em um vetor
img_Tx_bin = img_1_bin(:).';


% -----------------  Canal  -----------------------------------------------
% Por enquanto back-to-back (B2B)
img_Rx_bin = img_Tx_bin; 
% -------------------------------------------------------------------------

% ................. Recepção ..............................................

% Conversão do vetor de bits recuperados para uma matriz de pixels
recovered_img_1_bin = uint8(reshape(img_Rx_bin,size(img_1_bin)));

% Conversão para formato original da imagem, isto é 3D
recovered_img_1 = reshape(bi2de(recovered_img_1_bin),size(img_1));


% +++++++++++++++++++  Plotagens  +++++++++++++++++++++++++++++++++++++++++
% Exibição das imagens lida e recuperada
figure;
subplot(2,1,1), image(img_1), title('Imagem Original')
subplot(2,1,2), image(recovered_img_1), title('Imagem Recuperada')

% Compara as duas figuras
isequal(img_1,recovered_img_1)

% EoF

