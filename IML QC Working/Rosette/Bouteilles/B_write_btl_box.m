function B_write_btl_box(B)
%B_write_btl_box - Write bottle structure to file and add Petrie-Brickman box number 
%
%Syntax:  B_write_btl_box(B)
%  B is the structure out of B_read_btl_txtfile 
%    (B.filename, B.data: cell array of bottle data)

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2011; Last revision: 26-Jan-2011 CL

%Petrie-Brickman Box structure
load Petrie_Nutrients %PN

%Circle équation
x=[];y=[];for i=0:0.1:10,x=[x;i];y=[y;sqrt(100-i^2)];end
x=[x; flipud(x); -x; -flipud(x)]*1.5; x=x/60;
y=[y; -flipud(y); -y; flipud(y)]; y=y/60;

%Open file
fid = fopen(['QC_' B.filename(1:end-4) '_BOX.txt'],'wt');

%Loop over lines of B.data
for i=1:size(B.data,1)
    switch i<4
    case 1
        box='Petrie-Brickman Box';
    case 0
        %Find box number
        lat = str2num(B.data{i,strmatchi('latitude',B.data(2,:))});
        lon = str2num(B.data{i,strmatchi('longitude',B.data(2,:))});
        box=in_petrie_box(lat,lon,PN);	%in Box
        
        %No box found
        if isempty(box)
            for k=1:length(x)
               b=in_petrie_box(lat+y(k),lon+x(k),PN);	%in Box
               if ~isempty(b), box=[box b]; end    
            end
            box=unique(box);
        end
        
        %Box number
        if ~isempty(box)
            P=PN(cat(1,PN.box)==box(1));
            box=num2str(P.box,'%.0f');
        else
            box='nan';
        end
    end
    
    %Write to file 
    lin = [];
    for j=1:size(B.data,2)
        lin = [lin sprintf('%s;',B.data{i,j})];
    end
    fprintf(fid,'%s;%s\n',lin(1:end-1),box);
end

%Close file
fclose(fid);