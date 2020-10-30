clc
close all
clear all
%whos

Imagen_Brain = imread('089_Brain_27.jpg');                                 %Leer Imagen
Imagen_Bone = imread('095_Bone_18.jpg');                                   %Leer Imagen Bone
s = size(Imagen_Brain);                                                    %Tamaño de la Imagen
[T,EM] = graythresh(Imagen_Brain);                                         %Segmentacion OTSU
BW = imbinarize(Imagen_Brain,T);                                           %Binarizacion de la Imagen con Segmentacion OTSU
BW2 = imfill(BW,'holes');                                                  %Rellena huecos de BW; BW2=Imagen sin huecos
BW3 = bwareafilt(BW2,1);                                                   %Mantiene el objeto mas grande(Contorno de la Cabeza); BW3=Imagen del Contorno del Craneo


BW7 = uint8(BW3);                                                          %BW3 como imagen uint8
BW4 = BW7 & Imagen_Brain;                                                  %Segmentacion de prueba
BW_Prueba = uint8(Imagen_Brain.*0);
for i= 2:s(1)-1
    for j= 2:s(2)-1
        if (Imagen_Brain(i,j)> 240)
           BW_Prueba(i,j) = 1;
        else
           BW_Prueba(i,j) = 0;
        end
     end
end
BW_Prueba2 = logical(BW_Prueba);                                           %BW_Prueba2 = Hueso del Craneo + Otros
BW_Prueba3 = bwareafilt(BW_Prueba2,1);                                     %Mantener el objeto mas grande; BW_Prueba3 = Hueso del Craneo Aislado
BW_Prueba4 = xor(BW,BW_Prueba3);                                           %Operacion Logica XOR entre BW y Hueso del Craneo Aislado
BW_Prueba5 = bwareafilt(BW_Prueba4,1);                                     %Mantener el objeto mas grande de XOR
BW_Prueba6 = BW_Prueba3 + BW_Prueba5;                                      %Hueso del Craneo + Cerebro
BW_Prueba6_Morph = bwmorph(BW_Prueba6,'remove');                           %Morfoligia del Hueso del craneo y Cerebro
[Label,n] = bwlabel(BW_Prueba6_Morph,8);                                   %Etiquetado de los contornos
cc = bwconncomp(BW_Prueba6_Morph);                                         %Cantidad de Objetos con Conectividad 8
Etiquetas = labelmatrix(cc);                                               %Etiquetado de los Objetos
Color = label2rgb(Etiquetas);                                              %Aplicacion de Color a las Etiquetas
Objetos = cc.NumObjects;                                                   %Cantidad del Objetos en la Imagen
Et_Craneo = (Label==1);                                                    %Etiqueta del Craneo (Primer objeto)
g = [1 max(max(Label))];                                                   %Vector de tamaño [1 Maximo valor de Label]
Area = zeros(g);                                                           %Vecotr de Areas
BW_Areas_Afectadas = (BW_Prueba6_Morph).*0;                                %%
for j=2:max(max(Label))
    var = (Label== j);
    ar = imfill(var,'holes');
    Area(j) = sum(ar(:));
    BW_Areas_Afectadas = or(BW_Areas_Afectadas,ar);
end                                                                        %Ciclo para Tomar las Areas de Cada Objeto
Area_Afectada = sum(Area);                                                 %Total del Area Afectada
BW_Area_Craneo = imfill(Et_Craneo,'holes');                                %Area del Craneo
Area_Craneo = bwarea(BW_Area_Craneo);                                      %Tomar Area del Craneo
Area_Porcentaje = (Area_Afectada/Area_Craneo)* 100;                        %Area Afectada como Porcentaje
Im_Craneo = uint8(BW_Area_Craneo);
A = double(Im_Craneo.*Imagen_Brain);
BW_Areas_Cerebro = Et_Craneo + BW_Areas_Afectadas; 
BW_Morph_Areas = bwmorph(BW_Areas_Afectadas,'skel',Inf);
Terminaciones = sum(sum(bwmorph(BW_Morph_Areas,'endpoints')));
Num_Euler = bweuler(BW_Areas_Cerebro);
Descrpitores = [Area_Afectada Objetos Terminaciones Num_Euler];





%%BONR
%%DISCONTINUIDDES
%%ERSQUINAS
BW_Prueba_Bone = uint8(Imagen_Bone.*0);
for i= 2:s(1)-1
    for j= 2:s(2)-1
        if (Imagen_Bone(i,j)> 120)
           BW_Prueba_Bone(i,j) = 1;
        else
           BW_Prueba_Bone(i,j) = 0;
        end
     end
end
BW_Prueba_Bone2 = logical(BW_Prueba_Bone);                                 %BW_Prueba2 = Hueso del Craneo + Otros
BW_Prueba_Bone3 = imfill(BW_Prueba_Bone2,'holes');
BW_Morph_Bone = bwmorph(BW_Prueba_Bone3,'skel',Inf);
Terminaciones_Bone = sum(sum(bwmorph(BW_Morph_Bone,'endpoints')));
Bifurcaciones_Bone = sum(sum(bwmorph(BW_Morph_Bone,'branchpoints')));
BW_Morph_Bone2 = bwmorph(BW_Prueba_Bone3,'remove');                        %Morfoligia del Hueso del craneo y Cerebro
cc_Bone = bwconncomp(BW_Morph_Bone2);                                      %Cantidad de Objetos con Conectividad 8
Etiquetas_Bone = labelmatrix(cc_Bone);                                     %Etiquetado de los Objetos
Objetos_Bone = cc_Bone.NumObjects;                                         %Cantidad del Objetos en la Imagen
BW_Prueba_Bone4 = not(BW_Prueba_Bone3);
cc_Bone2 = bwconncomp(BW_Prueba_Bone4);
Descriptores_Bone = [Bifurcaciones_Bone Terminaciones_Bone Objetos_Bone];


%figure(1),subplot(1,2,1),imshow(Imagen_Brain),title('Imagen Original')     %Morstrar Imagen Original
%subplot(1,2,2),imshow(BW), title('Imagen Segmentada')                      %Mostrar Imgaen Segmentada
%figure(2), imshow(BW3), title('Contorno de la Cabeza')                    %Mostrar BW3
%figure(3),imshow(BW_Prueba2), title('Hueso del Craneo sin Aislar')         %Mostrar Hueso del Craneo + Otros
%figure(4),imshow(BW_Prueba3), title('Hueso del Craneo Aislado')            %Mostrar Hueso del Craneo Aislado
%figure(5), imshow(BW_Prueba4), title('Duramadre y Cerebro')                %Mostrar Operacion logica BW_Prueba4
%figure(6), imshow(BW_Prueba5), title('Cerebro Aislado')                    %Mostrar el objeto mas grande de XOR
%figure(7), imshow(BW_Prueba6), title('Hueso del Craneo + Cerebro')         %Mostrar Hueso del Craneo + Cerebro
%figure(8), imshow(BW_Prueba6_Morph) , title('Contornos:Craneo y Cerebro')  %Morfologia del Hueso del Craneo y Cerebro
%figure(9), imshow(Color,'InitialMagnification','fit'),title('Etiquetado')  %Mostrar Etiquetado con Colores
%figure(10), 
%subplot(1,2,1), imshow(Imagen_Brain), title('Imagen Original')                   %Mostrar Imagen Original con Imagen Etiquetada
%subplot(1,2,2), imshow(Color,'InitialMagnification','fit'),title('Etiquetado')
%figure(11),imshow(Et_Craneo + (Label==n)),title('Contorno del Craneo y ultimo objeto en el cerebro')
%figure(12), imshow(Et_Craneo + imfill((Label==n),'holes')),title('Ejemplo')%Ejemplo de Toma de todas las Areas                 
%figure(13),imshow(BW_Area_Craneo), title('Area del Craneo')                %Mostrar Area del Craneo
%figure(14),imshow(BW_Areas_Cerebro),title('Areas Afectadas en el Cerebro') %Areas Afectadas en el cerebro
%figure(15),imshow(BW_Morph_Areas),title('Areas Afectadas en el Cerebro')   %Areas Afectadas en el cerebro
%figure(16),imshow(Et_Craneo + BW_Morph_Areas),title('Areas Afectadas en el Cerebro')              %Areas Afectadas en el cerebro
%figure(17), 
%subplot(1,2,1),imshow(Imagen_Bone),title('Imagen Original')
%subplot(1,2,2),imshow(BW_Prueba_Bone2),title('Segmentacion')
%figure(18), imshow(BW_Prueba_Bone3)
%figure(19), imshow(BW_Morph_Bone),title('Morfologia')
%figure(20), imshow(bwmorph(BW_Morph_Bone,'endpoints')),title('Terminaciones')
%figure(21), imshow(bwmorph(BW_Morph_Bone,'branchpoints')),title('Bifurcaciones')
%figure(22), imshow(BW_Morph_Bone2)
%figure(23), imshow(BW_Prueba_Bone4)






%Color = label2rgb(Etiquetas, @copper, 'k', 'shuffle')
%for i= 2:s(1)-1
%    for j= 2:s(2)-1
%        ventana = BW(i-1:i+1, j-1:j+1);
%        pixSUM = sum(ventana(:));
%        if (pixSUM>2 && pixSUM<8)
%           Descriptor_Borde(i,j) = 1;
%        end
%     end
%end



%BW5 = uint8(BW4);
%BW6 = BW5 + Imagen;
%figure(5), imshow(BW6)
%BW4_Border = bwmorph(BW4,'remove');
%BW4_Skeleton = bwmorph(BW4,'skel',Inf);
%figure(5), imshow(BW4_Border)
%figure(6), imshow(BW4_Skeleton)
%BW5 = uint8(BW4);
%BW6 =  BW5 .* Imagen;                                     %Segmentacion de prueba
%BW6 = BW6 .* 3.5;
%figure(7), imshow(BW6)
%Field Holds Llenar huecos%
%figure(1), subplot(2,3,1),imshow(a), title('Name')       //Subplot
%pl = ar(200,:);                                          //Perfil de linea
%plot(pl);                                                //Grafica del Perfil de Linea
%ar(200,:)=0                                              //Linea Negra en toda fila 200
%arb7 = bitand(ar,128);                                   //Comparacion del bit 7 con 128
%arb7 = bitand(ar,128)*2;                                 //Comparacion del bit 7 con 128 con compensacion 2
%arb6 = bitand(ar,64)*4;                                  //Comparacion del bit 6 con 128 con compensacion 4
%arb5 = bitand(ar,32)*8;                                  //Comparacion del bit 5 con 128 con compensacion 8
%arb4 = bitand(ar,16)*16;                                 //Comparacion del bit 4 con 128 con compensacion 16
%arb3 = bitand(ar,8)*32;                                  //Comparacion del bit 3 con 128 con compensacion 32
%arb2 = bitand(ar,4)*64;                                  //Comparacion del bit 2 con 128 con compensacion 64
%arb1 = bitand(ar,2)*128;                                 //Comparacion del bit 1 con 128 con compensacion 128
%arb0 = bitand(ar,1)*256;                                 //Comparacion del bit 0 con 128 con compensacion 256
%imwrite(img,'Name.png');                                 //Guardar Imagen 'img' con nombre 'Name' y formato .png
%s = size(a);                                             //Tamaño de la imagen a


%histograma_R = zeros(1,256);
%histograma_G = zeros(1,256);
%histograma_B = zeros(1,256);
%for f = 1:s(1)
%    for c = 1:s(2)
%        ngR = ar(f,c);
%        histograma_R(ngR + 1) = histograma_R(ngR + 1) + 1;
%        ngG = ag(f,c);
%        histograma_G(ngG + 1) = histograma_G(ngG + 1) + 1;
%        ngB = ab(f,c);
%        histograma_B(ngB + 1) = histograma_B(ngB + 1) + 1;
%     end
%end
%                                                         //Histograma 1D de R - G - B


%histograma_2D = zeros(256);
%for f = 1:s(1)
%    for c = 1:s(2)
%        ngF = ar(f,c);
%        ngC = ag(f,c);
%        histograma_2D(ngF + 1,ngC + 1) = histograma_2D(ngF + 1,ngC + 1) + 1;
%     end
%end
%figure(1), imshow(Histograma_2D,[])
%                                                        //Histograma 2D de R - G

%b = a + 50;                                             //Imagen b = Imagen a + 50 de Iluminacion;
%b = a * 1.5;                                            //Imagen b = Imagen a * 1.5 de Iluminacion;
%b = a .* 1.5;                                           //Imagen b = Imagen a * 1.5 de Iluminacion Punto a Punto;
%ag = ag/255;                                            //Valor Normalizado;
%ag = ag*255;                                            //Valor Denormalizado;
%ag = double(ag);                                        //Valores de punto Flotante
%bg = uint8(bg);                                         //Valores de entero de 8 bits Sin Signo
%b = a .^ 1.5;                                           //Factor Gamma 1.5//Niveles de gris bajan una cantidad(Se Oscurece la Imagen);
%b = a .^ 0.5;                                           //Factor Gamma 0.5//Niveles de gris suben una cantidad(Se Aclara la Imagen);

%figure(1), subplot(1,2,1),imshow(Imagen),title('Imagen Original')                   %Ver Imagen
%histograma = zeros(1,256);
%for f = 1:s(1)
%    for c = 1:s(2)
%        ng = Imagen(f,c);
%        histograma(ng + 1) = histograma(ng + 1) + 1;
%    end
%end
%subplot(1,2,2),plot(histograma),title('Histograma');
%saveas(figure(1),'076_Brain_1_Histograma.jpg')
%saveas(figure(2),'076_Brain_1_Segmentacion.jpg')
