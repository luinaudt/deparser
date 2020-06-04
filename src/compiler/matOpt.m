% ordre etats : Eth Ipv4 IPv6 UDP TCP
% ordre transitions : E4 E6 EU ET 46 4U 4T 6U 6T UT
Id = [1 1 1 1 0 0 0 0 0 0; 
     -1 0 0 0 1 1 1 0 0 0; 
      0 -1 0 0 -1 0 0 1 1 0;
      0 0 -1 0 0 -1 0 -1 0 1;
      0 0 0 -1 0 0 -1 0 -1 -1] % matrice Incidence
Sd = zeros(2^5,5); % états deparser
for i = 1:length(Sd)
  tmp = dec2bin(i-1,5);
  for j=1:length(tmp)
    Sd(length(Sd)-i+1,j) = bin2dec(tmp(j));
  end 
end
Ids=Id
for i=1:size(Ids,1)
  for j=1:size(Ids,2)
   if Ids(i,j) == 0
      Ids(i,j) = 0;
    elseif Ids(i,j) == -1
      Ids(i,j)=1;
    end
  end
end

Sc = [1 1 0 1 0;
      1 1 0 0 1;
      1 0 1 1 0;
      1 0 1 0 1]
Sc2 = [1 1 0 1 0;
      1 1 0 0 1;
      1 0 1 1 0;
      1 0 1 0 1;
      1 1 0 0 0] %cas avec juste Eth Ipv4
      
SxI = Sc * Ids
Ad = triu(ones(5)-(eye(5))); % matrice d'adjacence
Ec = [1 1 1 1 1; 1 1 0 1 1; 1 0 1 1 1; 1 1 1 1 0; 1 1 1 0 1]; % matrice etat control
Ads = Ec.*Ad % matrice adjacence simplifiée

IdNoUn=((Ec*Ids)-1).*Ids % unaccessible transition column = 0
Sc*IdNoUn

%generation matrice incidence custom
nbEtat=5;
GenI=zeros(nbEtat, ((nbEtat)*(nbEtat-1))/2);
size(GenI);
posS=1;
%On a de 1 à n etats
for i = 1:nbEtat-1
  i_aligned = (nbEtat-i);
  tmp = zeros(nbEtat, i_aligned);
  tmp(i,:) = 1;
  tmp(i+1:end,:) = 2*eye(i_aligned) - triu(ones(i_aligned)) + 0;
  posE = posS + (i_aligned-1);
  GenI(:,posS:posE)=tmp;
  posS = posE+1;
endfor
