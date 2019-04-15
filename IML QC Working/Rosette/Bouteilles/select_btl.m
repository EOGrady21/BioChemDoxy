function select_btl(S,acclimatation,duration)
%SELECT_BTL - Automatic bottle scan range detection
%
%Syntax:  select_btl(S,acclimatation,duration)
% S is the ODF-structure of ctd casts (Down and Up cast)
% acclimation is the desired acclimation period (sec) before the bottle closing
% duration is the minimum averaging time range (sec) desired for CTD data at bottle closing
%
%Output: file btlscan.txt containing:
%   1. Bottle number 
%   2. Filename (without extension)
%   3. Pressure depth of bottle (db)
%   4. Start scan of bottle event
%   5. End scan of bottle event
%
%Toolbox required: Signal Processing

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 04-Oct-1999 CL

%btlscan.txt
fid=fopen('btlscan.txt','wt');
btlscan=[];

%Loop over all files
for i=1:size(S,2)
   disp(S(i).filename)
   
%Sampling interval   
I=strmatch('# interval = seconds',S(i).header);
interval=sscanf(char(S(i).header(I)),'%*s %*s %*s %*s %f')
   
%Removing spikes in pressure
spikes=1;
pfilt=medfilt1(S(i).p,7);
dp=abs(S(i).p-pfilt);
I1=find(dp>spikes);
I2=find(dp<=spikes);
p=S(i).p;
if ~isempty(I1);
   p(I1)=interp1(S(i).scan(I2),p(I2),S(i).scan(I1));
end

%Descent rate
dpdt=(p(3:end)-p(1:end-2))/(2*interval);
dpdt=[dpdt(1);dpdt;dpdt(end)]; 
switch interval
case 1.0
	fdpdt=medfilt1(dpdt,5);
case 0.5
	fdpdt=medfilt1(dpdt,11);
case 0.0625
	fdpdt=medfilt1(dpdt,15);
case 0.0416667
	fdpdt=medfilt1(dpdt,21);
otherwise
	fdpdt=medfilt1(dpdt,3);
end
S(i).dpdt=dpdt;

%BTL
Imaxp=S(i).scan(pfilt==max(pfilt));
I=find(fdpdt < 0.1 & fdpdt > -0.1 & S(i).scan > Imaxp(1)-100);
[S(i).scan(I(1)) S(i).scan(I(end))]

%regrouping commun data
btl=[]; pre=[]; dI2=1;
while ~isempty(dI2)
   dI=(I(2:end)-I(1:end-1));
	dI1=find(dI<=10);
   dI2=find(dI>10);
   if isempty(dI2)
      btl=[btl; S(i).scan(I(dI1(1))) S(i).scan(I(dI1(end)))]
      pre=[pre; S(i).p(I(dI1(1))) S(i).p(I(dI1(end)))];
	else
   	btl=[btl; S(i).scan(I(dI1(1))) S(i).scan(I(dI2(1)-1))];
      pre=[pre; S(i).p(I(dI1(1))) S(i).p(I(dI2(1)-1))];
  		I=I(dI2(1):end);
   	dI=(I(2:end)-I(1:end-1));
   	dI1=find(dI<=10);
   	I=I(dI1(1):end);
	end
end
I=find((btl(:,2)-btl(:,1))>acclimatation/interval);
btl=btl(I,:);
pre=pre(I,:);

%Plot selected profile
colordef black, clf
h1=plot(S(i).scan,p); hold on
ax=axis; plot([ax(1) ax(2)],[0 0],'c')
h1=plot(S(i).scan,S(i).p); grid on
set(h1,'color',[0.1 0.1 1],'LineWidth',1.5);
for j=1:size(btl,1)
	h2=plot(btl(j,:),pre(j,:),'-r');
   set(h2,'color',[1 0.1 0.1],'LineWidth',2);
end

title(['Profile # ' num2str(i) ': ' S(i).filename],...
   'FontSize',16)
xlabel('Scan number')
ylabel('Pressure (dbar)')


%btlscan.txt
for j=1:size(btl,1)
   btl(j,:)
   I1=find(S(i).scan==btl(j,1)+acclimatation/interval)
   I2=find(S(i).scan==btl(j,2))
   btlscan=[btlscan; mean(p(I1:I2)) std(p(I1:I2)) (I2-I1+1)*interval];
   fprintf(fid,'%6.0f %10s %7.1f %7.0f %7.0f\n',j,S(i).filename(1:end-4),mean(p(I1:I2)),S(i).scan(I1),S(i).scan(I2));
end

end  %(over all files)

%close btlscan.txt
fclose('all');

%statistics
fprintf('Mean duration: %5.0f sec\n',mean(btlscan(:,end)));
fprintf('Acclimatation period: %5.0f sec\n',acclimatation);
fprintf('Number of bottle found: %5.0f\n',length(btlscan));
fprintf('Number of bottle with duration > 10 sec: %5.0f\n',length(find(btlscan(:,end)>10)));
fprintf('%% bottle with duration > 10 sec: %5.0f\n',length(find(btlscan(:,end)>10))/length(btlscan)*100);
fprintf('Number of bottle with duration > 20 sec: %5.0f\n',length(find(btlscan(:,end)>20))); 
fprintf('%% bottle with duration > 20 sec: %5.0f\n',length(find(btlscan(:,end)>20))/length(btlscan)*100);

close, colordef white


