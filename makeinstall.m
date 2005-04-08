function makeinstall(varargin)
% MAKEINSTALL   creates a toolbox installation file.
%   Use MAKEINSTALL to create a INSTALL.M file, which
%   will include a simple installation script and all the
%   Matlab files which are needed for the toolbox. If the
%   CONTENTS.M file is missing, it will be automatically 
%   created. Furthermore the command TBCLEAN will be added to 
%   the toolbox folder, which enables to remove the toolbox 
%   folder and the startup entries.
%
%   Call MAKEINSTALL in the toolbox folder or specify this
%   folder with MAKEINSTALL TB-FOLDER.
%
%   In order to initialize some needed variables, call this
%   programme the first time and then modify the entries in 
%   the automatically created resource file MAKEINSTALL.RC.
%   You may change the entries in MAKEINSTALL.RC for your
%   convenience. 
%
%   Please note, that further files will be automatically 
%   generated in the toolbox folder if they do not exist yet: 
%   CONTENTS.M, INFO.XML and TBCLEAN.M.
%
%   The contents of CONTENTS.M will be generated from the help
%   lines in the M-files. If there are no help lines or if 
%   this help text is not correctly placed, a warning message 
%   will occur. Please ensure that the help text corresponds 
%   with the predefined structure of M-files:
%
%       function p = angle(h)
%       % ANGLE Polar angle.
%       %   ANGLE(H) returns the phase angles, in radians, of
%       %   a matrix with complex elements. Use ABS for the 
%       %   magnitudes.
%       p = atan2(imag(h),real(h));
%
%   where there is a first help line (H1) below the function 
%   line and a following help text. The H1 line is used also 
%   by other functions like LOOKFOR. If you like to generate 
%   CONTENTS.M automatically with MAKEINSTALL although 
%   CONTENTS.M already exists, you have to remove the old 
%   CONTENTS.M file. Thus, manual modifications will be kept.
%
%   The contents of INFO.XML can be modified with some 
%   variables in the resource file MAKEINSTALL.RC. However, 
%   you have to remove the old INFO.XML file, if you like to 
%   modify it the next time with MAKEINSTALL. Thus, manual 
%   modifications will be preserved.
%
%   This programme is free software under the GNU General
%   Public License.  To view the text of this license, type
%   MAKEINSTALL GPL.

% FREE SOFTWARE - please refer the source
% Copyright (c) 2002-2005 by AMRON
% Norbert Marwan, Potsdam University, Germany
% http://www.agnld.uni-potsdam.de
%
% I'm grateful for every suggestion and hint which improves this
% programme. Thanks to Gaetan Koers of Vrije Universiteit Brussel
% for hints about Windows compatibility and improvement the help-text
% parser. Thanks also to Volkmar Glauche of University of Hamburg 
% (Universitatsklinikum) for usefule hints and comments about the
% root-folder of the toolbox and the startup.m entries.
%
% This programme is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or any later version.
%
% This programme is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% $Date$
% $Revision$
%
% $Log$
% Revision 3.8  2005/02/22 12:27:14  marwan
% windoof bug fixed (ocurred during removing of old toolbox)
%
% Revision 3.7  2004/11/15 10:09:49  marwan
% change addpath -end to addpath -begin
%
% Revision 3.6  2004/11/10 07:52:15  marwan
% CVS compatibility included
%
% Revision 3.5  2004/11/10 06:29:16  marwan
% Initial commitment
%
%

% initialization some variables
error(nargchk(0,1,nargin));
olddir=pwd;
toolbox_name=''; install_file=''; install_path=''; deinstall_file=''; src_dir=''; check_for_old='';
install_dirPC=''; install_dirUNIX=''; version_file=''; version_number=''; release=''; 
infostring=''; old_dirs=''; xml_name=''; xml_start=''; xml_demo=''; xml_web=''; restart=0;
count_warnings = 0;
max_warnings = 10; % more warnings than this number will be suppressed - feel free to change this number

% read the resource file
if nargin==1
  if exist(char(varargin{1}))==7
    src_dir=varargin{1};
    cd(src_dir); 
    disp(['   Change to directory ', src_dir,''])
  else
    toolbox_name=varargin{1};
  end
elseif nargin==2
  if exist(char(varargin{2}))==7
    src_dir=varargin{2};
    cd(src_dir); 
    disp(['   Change to directory ', src_dir,''])
  end
  toolbox_name=varargin{1};
end

% get version number of the makeinstall-script
mi_file=[mfilename('fullpath'), '.m'];
mi_version='none';
fid=fopen(mi_file,'r');
if fid~=-1
  while 1
    temp=fgetl(fid);
    if ~ischar(temp), break
    elseif ~isempty(temp)
      if temp(1)=='%'
        i=findstr(temp,'Version:');
        if ~isempty(i), mi_version=temp(i(1)+9:end); break, end
        i=findstr(temp,'$Revision:');
        if ~isempty(i), mi_version=strtok(temp(i(1)+11:end),'$'); break, end
      end
    end
  end
  err=fclose(fid);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% splash the GPL

filename='makeinstall';
txt=[{''};{'		    GNU GENERAL PUBLIC LICENSE'};{'		       Version 2, June 1991'};{''};
{' Copyright (C) 1989, 1991 Free Software Foundation, Inc.'};{'                       59 Temple Place, Suite 330, Boston, MA  02111-1307  USA'};{' Everyone is permitted to copy and distribute verbatim copies'};{' of this license document, but changing it is not allowed.'};{''};
{'			    PREAMBLE'};{''};
{'  The licenses for most software are designed to take away your'};{'freedom to share and change it.  By contrast, the GNU General Public'};{'License is intended to guarantee your freedom to share and change free'};{'software--to make sure the software is free for all its users.  This'};{'General Public License applies to most of the Free Software'};{'Foundation''s software and to any other program whose authors commit to'};{'using it.  (Some other Free Software Foundation software is covered by'};{'the GNU Library General Public License instead.)  You can apply it to'};{'your programs, too.'};{''};
{'  When we speak of free software, we are referring to freedom, not'};{'price.  Our General Public Licenses are designed to make sure that you'};{'have the freedom to distribute copies of free software (and charge for'};{'this service if you wish), that you receive source code or can get it'};{'if you want it, that you can change the software or use pieces of it'};{'in new free programs; and that you know you can do these things.'};{''};{'  To protect your rights, we need to make restrictions that forbid'};{'anyone to deny you these rights or to ask you to surrender the rights.'};{'These restrictions translate to certain responsibilities for you if you'};{'distribute copies of the software, or if you modify it.'};{''};
{'  For example, if you distribute copies of such a program, whether'};{'gratis or for a fee, you must give the recipients all the rights that'};{'you have.  You must make sure that they, too, receive or can get the'};{'source code.  And you must show them these terms so they know their'};{'rights.'};{''};
{'  We protect your rights with two steps: (1) copyright the software, and'};{'(2) offer you this license which gives you legal permission to copy,'};{'distribute and/or modify the software.'};{''};
{'  Also, for each author''s protection and ours, we want to make certain'};{'that everyone understands that there is no warranty for this free'};{'software.  If the software is modified by someone else and passed on, we'};{'want its recipients to know that what they have is not the original, so'};{'that any problems introduced by others will not reflect on the original'};{'authors'' reputations.'};{''};
{'  Finally, any free program is threatened constantly by software'};{'patents.  We wish to avoid the danger that redistributors of a free'};{'program will individually obtain patent licenses, in effect making the'};{'program proprietary.  To prevent this, we have made it clear that any'};{'patent must be licensed for everyone''s free use or not licensed at all.'};{''};
{'  The precise terms and conditions for copying, distribution and'};{'modification follow.'};{''};
{'		    GNU GENERAL PUBLIC LICENSE'};
{'   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION'};{''};
{'  0. This License applies to any program or other work which contains'};{'a notice placed by the copyright holder saying it may be distributed'};{'under the terms of this General Public License.  The "Program", below,'};{'refers to any such program or work, and a "work based on the Program"'};{'means either the Program or any derivative work under copyright law:'};{'that is to say, a work containing the Program or a portion of it,'};{'either verbatim or with modifications and/or translated into another'};{'language.  (Hereinafter, translation is included without limitation in'};{'the term "modification".)  Each licensee is addressed as "you".'};{''};
{'Activities other than copying, distribution and modification are not'};{'covered by this License; they are outside its scope.  The act of'};{'running the Program is not restricted, and the output from the Program'};{'is covered only if its contents constitute a work based on the'};{'Program (independent of having been made by running the Program).'};{'Whether that is true depends on what the Program does.'};{''};
{'  1. You may copy and distribute verbatim copies of the Program''s'};{'source code as you receive it, in any medium, provided that you'};{'conspicuously and appropriately publish on each copy an appropriate'};{'copyright notice and disclaimer of warranty; keep intact all the'};{'notices that refer to this License and to the absence of any warranty;'};{'and give any other recipients of the Program a copy of this License'};{'along with the Program.'};{''};
{'You may charge a fee for the physical act of transferring a copy, and'};{'you may at your option offer warranty protection in exchange for a fee.'};{''};
{'  2. You may modify your copy or copies of the Program or any portion'};{'of it, thus forming a work based on the Program, and copy and'};{'distribute such modifications or work under the terms of Section 1'};{'above, provided that you also meet all of these conditions:'};{''};
{'    a) You must cause the modified files to carry prominent notices'};{'    stating that you changed the files and the date of any change.'};{''};
{'    b) You must cause any work that you distribute or publish, that in'};{'    whole or in part contains or is derived from the Program or any'};{'    part thereof, to be licensed as a whole at no charge to all third'};{'    parties under the terms of this License.'};{''};
{'    c) If the modified program normally reads commands interactively'};{'    when run, you must cause it, when started running for such'};{'    interactive use in the most ordinary way, to print or display an'};{'    announcement including an appropriate copyright notice and a'};{'    notice that there is no warranty (or else, saying that you provide'};{'    a warranty) and that users may redistribute the program under'};{'    these conditions, and telling the user how to view a copy of this'};{'    License.  (Exception: if the Program itself is interactive but'};{'    does not normally print such an announcement, your work based on'};{'    the Program is not required to print an announcement.)'};{''};
{'These requirements apply to the modified work as a whole.  If'};{'identifiable sections of that work are not derived from the Program,'};{'and can be reasonably considered independent and separate works in'};{'themselves, then this License, and its terms, do not apply to those'};{'sections when you distribute them as separate works.  But when you'};{'distribute the same sections as part of a whole which is a work based'};{'on the Program, the distribution of the whole must be on the terms of'};{'this License, whose permissions for other licensees extend to the'};{'entire whole, and thus to each and every part regardless of who wrote it.'};{''};
{'Thus, it is not the intent of this section to claim rights or contest'};{'your rights to work written entirely by you; rather, the intent is to'};{'exercise the right to control the distribution of derivative or'};{'collective works based on the Program.'};{''};
{'In addition, mere aggregation of another work not based on the Program'};{'with the Program (or with a work based on the Program) on a volume of'};{'a storage or distribution medium does not bring the other work under'};{'the scope of this License.'};{''};
{'  3. You may copy and distribute the Program (or a work based on it,'};{'under Section 2) in object code or executable form under the terms of'};{'Sections 1 and 2 above provided that you also do one of the following:'};{''};
{'    a) Accompany it with the complete corresponding machine-readable'};{'    source code, which must be distributed under the terms of Sections'};{'    1 and 2 above on a medium customarily used for software interchange; or,'};{''};
{'    b) Accompany it with a written offer, valid for at least three'};{'    years, to give any third party, for a charge no more than your'};{'    cost of physically performing source distribution, a complete'};{'    machine-readable copy of the corresponding source code, to be'};{'    distributed under the terms of Sections 1 and 2 above on a medium'};{'    customarily used for software interchange; or,'};{''};
{'    c) Accompany it with the information you received as to the offer'};{'    to distribute corresponding source code.  (This alternative is'};{'    allowed only for noncommercial distribution and only if you'};{'    received the program in object code or executable form with such'};{'    an offer, in accord with Subsection b above.)'};{''};
{'The source code for a work means the preferred form of the work for'};{'making modifications to it.  For an executable work, complete source'};{'code means all the source code for all modules it contains, plus any'};{'associated interface definition files, plus the scripts used to'};{'control compilation and installation of the executable.  However, as a'};{'special exception, the source code distributed need not include'};{'anything that is normally distributed (in either source or binary'};{'form) with the major components (compiler, kernel, and so on) of the'};{'operating system on which the executable runs, unless that component'};{'itself accompanies the executable.'};{''};
{'If distribution of executable or object code is made by offering'};{'access to copy from a designated place, then offering equivalent'};{'access to copy the source code from the same place counts as'};{'distribution of the source code, even though third parties are not'};{'compelled to copy the source along with the object code.'};{''};
{'  4. You may not copy, modify, sublicense, or distribute the Program'};{'except as expressly provided under this License.  Any attempt'};{'otherwise to copy, modify, sublicense or distribute the Program is'};{'void, and will automatically terminate your rights under this License.'};{'However, parties who have received copies, or rights, from you under'};{'this License will not have their licenses terminated so long as such'};{'parties remain in full compliance.'};{''};
{'  5. You are not required to accept this License, since you have not'};{'signed it.  However, nothing else grants you permission to modify or'};{'distribute the Program or its derivative works.  These actions are'};{'prohibited by law if you do not accept this License.  Therefore, by'};{'modifying or distributing the Program (or any work based on the'};{'Program), you indicate your acceptance of this License to do so, and'};{'all its terms and conditions for copying, distributing or modifying'};{'the Program or works based on it.'};{''};
{'  6. Each time you redistribute the Program (or any work based on the'};{'Program), the recipient automatically receives a license from the'};{'original licensor to copy, distribute or modify the Program subject to'};{'these terms and conditions.  You may not impose any further'};{'restrictions on the recipients'' exercise of the rights granted herein.'};{'You are not responsible for enforcing compliance by third parties to'};{'this License.'};{''};
{'  7. If, as a consequence of a court judgment or allegation of patent'};{'infringement or for any other reason (not limited to patent issues),'};{'conditions are imposed on you (whether by court order, agreement or'};{'otherwise) that contradict the conditions of this License, they do not'};{'excuse you from the conditions of this License.  If you cannot'};{'distribute so as to satisfy simultaneously your obligations under this'};{'License and any other pertinent obligations, then as a consequence you'};{'may not distribute the Program at all.  For example, if a patent'};{'license would not permit royalty-free redistribution of the Program by'};{'all those who receive copies directly or indirectly through you, then'};{'the only way you could satisfy both it and this License would be to'};{'refrain entirely from distribution of the Program.'};{''};
{'If any portion of this section is held invalid or unenforceable under'};{'any particular circumstance, the balance of the section is intended to'};{'apply and the section as a whole is intended to apply in other'};{'circumstances.'};{''};
{'It is not the purpose of this section to induce you to infringe any'};{'patents or other property right claims or to contest validity of any'};{'such claims; this section has the sole purpose of protecting the'};{'integrity of the free software distribution system, which is'};{'implemented by public license practices.  Many people have made'};{'generous contributions to the wide range of software distributed'};{'through that system in reliance on consistent application of that'};{'system; it is up to the author/donor to decide if he or she is willing'};{'to distribute software through any other system and a licensee cannot'};{'impose that choice.'};{''};
{'This section is intended to make thoroughly clear what is believed to'};{'be a consequence of the rest of this License.'};{''};
{'  8. If the distribution and/or use of the Program is restricted in'};{'certain countries either by patents or by copyrighted interfaces, the'};{'original copyright holder who places the Program under this License'};{'may add an explicit geographical distribution limitation excluding'};{'those countries, so that distribution is permitted only in or among'};{'countries not thus excluded.  In such case, this License incorporates'};{'the limitation as if written in the body of this License.'};{''};
{'  9. The Free Software Foundation may publish revised and/or new versions'};{'of the General Public License from time to time.  Such new versions will'};{'be similar in spirit to the present version, but may differ in detail to'};{'address new problems or concerns.'};{''};
{'Each version is given a distinguishing version number.  If the Program'};{'specifies a version number of this License which applies to it and "any'};{'later version", you have the option of following the terms and conditions'};{'either of that version or of any later version published by the Free'};{'Software Foundation.  If the Program does not specify a version number of'};{'this License, you may choose any version ever published by the Free Software'};{'Foundation.'};{''};
{'  10. If you wish to incorporate parts of the Program into other free'};{'programs whose distribution conditions are different, write to the author'};{'to ask for permission.  For software which is copyrighted by the Free'};{'Software Foundation, write to the Free Software Foundation; we sometimes'};{'make exceptions for this.  Our decision will be guided by the two goals'};{'of preserving the free status of all derivatives of our free software and'};{'of promoting the sharing and reuse of software generally.'};{''};
{'			    NO WARRANTY'};{''};
{'  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY'};{'FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN'};{'OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES'};{'PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED'};{'OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF'};{'MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS'};{'TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE'};{'PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,'};{'REPAIR OR CORRECTION.'};{''};
{'  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING'};{'WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR'};{'REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,'};{'INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING'};{'OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED'};{'TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY'};{'YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER'};{'PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE'};{'POSSIBILITY OF SUCH DAMAGES.'};];
which_res=which([filename,'.m']);
gplrc_path=[strrep(which_res,[filename,'.m'],''), 'private'];
gplrc_file=[gplrc_path, filesep, '.gpl.',filename];
if ~exist(gplrc_path)
  mkdir(strrep(which_res,[filename,'.m'],''),'private')
end
if ~exist(gplrc_file) | strcmpi(varargin,'gpl')
  if ~exist(gplrc_file) 
    disp('First click on the license to accept them.')
  else
    disp('Click on the license to close them.')
  end
  fid=fopen(gplrc_file,'w');
  fprintf(fid,'%s\n','If you delete this file, the GNU Public License will');
  fprintf(fid,'%s','splash up at the next time the programme starts.');
  fclose(fid);

  h=figure('NumberTitle','off',...,
         'ButtonDownFcn','close',...
         'Name','GNU General Public License');
  ha=get(h,'Position');
  h=uicontrol('Style','Listbox',...
            'ButtonDownFcn','close',...
            'CallBack','close',...
            'Position',[0 0 ha(3) ha(4)],...
	    'Value',1,...
	    'FontName','Courier',...
	    'BackgroundColor',[.8 .8 .8],...
	    'String',txt);
  waitfor(h)
end

if isempty(varargin) | ~strcmpi(varargin,'gpl')
files=what;
if length(files.m)==0
   warning on; warning('No M-files found in this directory.'); 
end

rc_file=fullfile(pwd,'makeinstall.rc');
time_string=datestr(now);

fid=fopen(rc_file,'r');
if fid>0
  disp('   Reading the resource file')
  while 1
    l=fgetl(fid);
    if ~ischar(l), break, end
    if ~isempty(l), eval(l); end
  end
  fclose(fid);

  if isempty(toolbox_name), [dummy toolbox_name]=fileparts(pwd); end
  if isempty(install_file), install_file='install.m'; end
  if isempty(deinstall_file), deinstall_file='tbclean.m'; end
  if isempty(src_dir), src_dir=pwd; end
  if isempty(install_dirPC), install_dirPC=pwd; end
  if isempty(install_dirUNIX), install_dirUNIX=install_dirPC; end
  if isempty(version_number), version_number='none'; end
  if isempty(release), release=' '; end
%  if isempty(infostring), infostring=''; end
  old_dirs=lower(old_dirs);
  if ~iscell(old_dirs), old_dirs=cellstr(old_dirs); end
  check_for_old='';
  check_for_old='[findstr([lower(toolboxpath),''demo''],lower(p))';
  check_for_old=[check_for_old,' findstr(lower(toolboxpath),lower(p))'];
  for i=1:length(old_dirs)
    check_for_old=[check_for_old,' findstr(''',old_dirs{i},''',lower(p))'];
  end
  check_for_old=[check_for_old,']'];


  % make install file
    disp('   Reading the install source code')
    fid=fopen(mi_file, 'r'); warning off
    i=1; flag=0;
    while 1
       temp=fgetl(fid);
       if ~ischar(temp), break, end
       if length(temp)>1
	 if strcmpi(temp,'%<-- ASCII begins here: install -->')
	   eofbyte=ftell(fid);
	   flag=1;
	 elseif strcmpi(temp,'%<-- ASCII begins here: clean -->')
	   eofbyte=ftell(fid)-eofbyte-1000;
	   flag=2;
	 elseif strcmpi(temp,'%<-- ASCII ends here -->')
	   flag=0; i=1;
	 end
	 
         if findstr(temp(1:2),'%@')==1
           aline=repmat('-',1,length(toolbox_name)+17);
	       switch flag
	       case 1
    % read install part
                 b(i,1)={temp(3:end)};
	             b(i)=strrep(b(i),'$lines$',aline);
	             b(i)=strrep(b(i),'$installpath$',install_path);
	             b(i)=strrep(b(i),'$toolboxdirpc$',install_dirPC);
	             b(i)=strrep(b(i),'$toolboxdirunix$',install_dirUNIX);
	             b(i)=strrep(b(i),'$toolboxname$',toolbox_name);
        %	     b(i)=strrep(b(i),'$install_file$',install_file);
	             b(i)=strrep(b(i),'$generation_date$',time_string);
	             b(i)=strrep(b(i),'$check_for_old$',check_for_old);
	             b(i)=strrep(b(i),'$mi_version$',mi_version);
	             if isempty(infostring)
	                b(i)=strrep(b(i),'$infostring$','');
	             else
	                b(i)=strrep(b(i),'$infostring$',['disp(''',infostring,''')']);
	             end
	       case 2
    % read uninstall part
                 c(i,1)={temp(3:end)};
	             c(i)=strrep(c(i),'$lines$',aline);
	             c(i)=strrep(c(i),'$toolboxdir$',install_dirPC);
	             c(i)=strrep(c(i),'$toolboxname$',toolbox_name);
	             c(i)=strrep(c(i),'$deinstall_file$',strtok(deinstall_file,'.'));
	             c(i)=strrep(c(i),'$deinstall_file_up$',strtok(upper(deinstall_file),'.'));
	             c(i)=strrep(c(i),'$generation_date$',time_string);
             end
	         i=i+1;
         end
       end
    end
    err=fclose(fid);

    if exist(fullfile(olddir,'install.m')) delete(fullfile(olddir,'install.m')); end
    fid=fopen(fullfile(olddir,install_file),'w');
    startbyte=eofbyte;
    for i2=1:length(b), b(i2)=strrep(b(i2),'$startbyte$',num2str(startbyte-500)); err=fprintf(fid,'%s\n',char(b(i2))); end
    err=fclose(fid);

  disp(['   Source directory ', src_dir,''])
  if ~exist(src_dir), error('Predefined source directory is nonexistent. Check the resource file.'), end
  cd(src_dir)

  % make clean file
%  if ~exist(deinstall_file)
    disp(['   Create ', deinstall_file,''])
    fid=fopen(deinstall_file,'w');
    for i2=1:length(c), err=fprintf(fid,'%s\n',char(c(i2))); end
    err=fclose(fid);
%  end
  
  % get version number
  fid=fopen(version_file,'r');
  if fid~=-1
    while 1
      temp=fgetl(fid);
      if ~ischar(temp), break
      elseif ~isempty(temp)
        if temp(1)=='%'
          i=findstr(temp,'Version:');
          if ~isempty(i), version_number=temp(i(1)+9:end); break, end
          i=findstr(temp,'$Revision:');
          if ~isempty(i), version_number=strtok(temp(i(1)+11:end),'$'); break, end
        end
      end
    end
    err=fclose(fid);
  end
  if strcmpi(version_number,'none')
    if max_warnings & count_warnings == max_warnings
      disp('   ** TOO MUCH WARNINGS!') 
      disp('   I give up! Following warning messages will be suppressed.') 
    end
    if count_warnings < max_warnings
      disp('   ** Warning: No version number found!') 
      disp('   Please provide a version file or number in the makeinstall.rc file.')
    end
    count_warnings = count_warnings + 1;
  else
    disp(['   Found version number ', version_number,''])
  end
  if ~strcmpi(release,' ') & ~isempty(release)
    disp(['   Found release ', release,''])
  end
  if ~isempty(infostring)
    if length(infostring)>40, txt=[infostring(1:37),'...']; else txt=infostring; end
    disp(['   Found infotext ''', txt,''''])
  end
  disp(['   Time stamp ', time_string,''])

  % make launch pad file
  if ~exist(fullfile(src_dir,'info.xml')) & ~isempty(xml_name) 
     disp('   Create info.xml')
     files.m(strcmpi(files.m,'info.xml'))=[];
     files.m(strcmpi(files.m,install_file))=[];
     v=version;
     mrelease=str2num(v(findstr(v,'(R')+2:findstr(v,')')-1));
     if mrelease>12, area='toolbox'; icon_path='$toolbox/matlab/icons'; else area='matlab'; icon_path='$toolbox/matlab/general'; end
     fid=fopen('info.xml','w'); 
     fprintf(fid,'%s\n\n','<productinfo>');
     fprintf(fid,'%s\n',['<matlabrelease>',num2str(mrelease),'</matlabrelease>']);
     fprintf(fid,'%s\n',['<name>',xml_name,'</name>']);
     fprintf(fid,'%s\n',['<area>',area,'</area>']);
     fprintf(fid,'%s\n\n',['<icon>',icon_path,'/matlabicon.gif</icon>']);
     fprintf(fid,'%s\n\n','<list>');
     if ~isempty(xml_start)
        fprintf(fid,'%s\n','<listitem>');
        fprintf(fid,'%s\n',['<label>Start ',toolbox_name,'</label>']);
        fprintf(fid,'%s\n',['<callback>',xml_start,'</callback>']);
        fprintf(fid,'%s\n',['<icon>',icon_path,'/figureicon.gif</icon>']);
        fprintf(fid,'%s\n\n','</listitem>');
     end
     fprintf(fid,'%s\n','<listitem>');
     fprintf(fid,'%s\n','<label>Help</label>');
     if isunix
       fprintf(fid,'%s\n',['<callback>helpwin ',install_dirUNIX,'/</callback>']);
     else
       fprintf(fid,'%s\n',['<callback>helpwin ',install_dirPC,'/</callback>']);
     end
     fprintf(fid,'%s\n',['<icon>',icon_path,'/bookicon.gif</icon>']);
     fprintf(fid,'%s\n\n','</listitem>');
     if ~isempty(xml_demo)
        fprintf(fid,'%s\n','<listitem>');
        fprintf(fid,'%s\n','<label>Demo</label>');
        fprintf(fid,'%s\n',['<callback>',xml_demo,'</callback>']);
        fprintf(fid,'%s\n',['<icon>',icon_path,'/demoicon.gif</icon>']);
        fprintf(fid,'%s\n\n','</listitem>');
     end
     if ~isempty(xml_web)
        fprintf(fid,'%s\n','<listitem>');
        fprintf(fid,'%s\n','<label>Product Page (Web)</label>');
        fprintf(fid,'%s\n',['<callback>web ',xml_web,' -browser;</callback>']);
        fprintf(fid,'%s\n',['<icon>',icon_path,'/webicon.gif</icon>']);
        fprintf(fid,'%s\n\n','</listitem>');
     end
     fprintf(fid,'%s\n\n','</list>');
     fprintf(fid,'%s','</productinfo>');
     fclose(fid);
  end

  % make contents file
  if ~exist(fullfile(src_dir,'Contents.m'))
     disp('   Create Contents.m')
     files.m(strcmpi(files.m,'Contents.m'))=[];
     files.m(strcmpi(files.m,install_file))=[];
     fid=fopen('Contents.m','w'); 
     fprintf(fid,'%s\n',['% ',toolbox_name]);
     fprintf(fid,'%s\n',['% Version ',num2str(version_number),'   ',date]);
     fprintf(fid,'%s\n','%');
     for i = 1:length(files.m)
        helptext=help(char(files.m{i}));
        ind=findstr(char(10),helptext);
	if isempty(ind)
           if max_warnings & count_warnings == max_warnings
             disp('   ** TOO MUCH WARNINGS!') 
             disp('   I give up! Following warning messages will be suppressed.') 
           end
	   if count_warnings < max_warnings
  	     disp(['   ** Warning: ',char(files.m{i}),' does not contain any helptext. It is highly',char(10),'   recommended to include a helptext in every M-file.'])
	   end
	   count_warnings = count_warnings + 1;
	else
           helpline=deblank(helptext(1:ind(1)));
           [fnname,helpstring]=strtok(helpline(2:length(helpline)));
           fnname = fliplr(deblank(fliplr(fnname)));
	   if ~strcmpi(fnname,strtok(char(files.m{i}),'.'))
              if max_warnings & count_warnings == max_warnings
                disp('   ** TOO MUCH WARNINGS!') 
                disp('   I give up! Following warning messages will be suppressed.') 
              end
	      if count_warnings < max_warnings
	        disp(['   ** Warning: ',char(files.m{i}),' does not have a valid helptext. Please refer ',char(10),'   the Matlab manual for the correct structure of M-files.'])
	      end
	      count_warnings = count_warnings + 1;
	      fnname=lower(strtok(char(files.m{i}),'.'));
	   end
           line=[lower(fnname),blanks(size(char(files.m),2)-length(fnname)-1),'- ',helpstring];
           fprintf(fid,'%s\n',['%    ', line]);
	end
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this part was suggested by Gaetan Koers (Vrije Universiteit Brussel)
     for i=1:numel(files.classes)
         line=[files.classes{i}, ' methods:'];
         fprintf(fid,'%%\n%s\n%%\n',['%    ', line]);
         gk_list = dir(['@', files.classes{i}]);
         for j = 1:numel(gk_list)
             gk_fname = gk_list(j).name;
             if ~gk_list(j).isdir %~strcmp(gk_fname, '.') & ~strcmp(gk_fname, '..')
                 helptext=help(fullfile(files.classes{i},gk_fname));
                 ind=findstr(char(10),helptext);
                 if isempty(ind)
                     if max_warnings & count_warnings == max_warnings
                       disp('   ** TOO MUCH WARNINGS!') 
                       disp('   I give up! Following warning messages will be suppressed.') 
                     end
	             if count_warnings < max_warnings
                       disp(['   ** Warning: ', files.classes{i}, ' method ', char(gk_fname),' does not contain any helptext. It is highly',char(10),'   recommended to include a helptext in every M-file.'])
		     end
	             count_warnings = count_warnings + 1;
                 else
                     helpline=deblank(helptext(1:ind(1)));
                     [fnname,helpstring]=strtok(helpline(2:length(helpline)));
                     fnname = fliplr(deblank(fliplr(fnname)));
                      if ~strcmpi(fnname,strtok(char(gk_fname),'.'))
                         if max_warnings & count_warnings == max_warnings
                           disp('   ** TOO MUCH WARNINGS!') 
                           disp('   I give up! Following warning messages will be suppressed.') 
                         end
	                     if count_warnings < max_warnings
                               disp(['   ** Warning: ', files.classes{i}, ' method ',char(gk_fname),' does not have a valid helptext. Please refer ',char(10),'   the Matlab manual for the correct structure of M-files.'])
                         end
	                     count_warnings = count_warnings + 1;
			             fnname=lower(strtok(char(gk_fname),'.'));
                     end
                     line=[lower(fnname),blanks(size(char(files.m),2)-length(fnname)-1),'- ',helpstring];
                     fprintf(fid,'%s\n',['%    ', line]);
                 end
             end
         end
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     fprintf(fid,'\n%s\n\n',['% Generated at ',time_string,' by MAKEINSTALL']);
     fclose(fid);
  else
  % modify contents file
     disp('   Modify Contents.m')
     fid=fopen('Contents.m','r'); contents=''; 
     while 1
       temp=fgetl(fid);
       if ~ischar(temp), break, end
       contents=[contents;{temp}];
     end
     fclose(fid);
     if isempty(findstr(lower(contents{2}),'version'))
       contents(3:end+1)=contents(2:end);
     end
     if ~strcmp(release,' ') & ~isempty(release), release=[' (',release,') ']; end
     contents{2}=['% Version ',version_number,release,date];
     if (isempty(contents{end}) | findstr(contents{end},'Modified at')>0); l=length(contents); else l=length(contents)+1; end
     contents{l}=['% Modified at ',time_string,' by MAKEINSTALL'];
     
     fid=fopen('Contents.m','w'); 
     for i=1:length(contents)
       fprintf(fid,'%s\n',contents{i});
     end
     fclose(fid);
  end
  
  % find sub-directories
  dirnames='';filenames='';
  temp='.:';
  while ~isempty(temp)
    [temp1 temp]=strtok(temp,':');
    if ~isempty(temp1)
      dirnames=[dirnames; {temp1}];
      temp2=strrep(temp1,'./','');
      if isempty(findstr(lower(fliplr(temp2(end-min([3,length(temp2)])+1:end))), 'svc'))
        x2=dir(temp1);
        for i=1:length(x2)
          if ~x2(i).isdir, filenames=[filenames; {[temp1,'/', x2(i).name]}]; end
          if x2(i).isdir & ~strcmp(x2(i).name,'.') & ~strcmp(x2(i).name,'..'), temp=[temp,temp1,filesep,x2(i).name,':']; end
        end
      end
    end
  end
  dirnames=strrep(dirnames,filesep,'/');
  dirnames=strrep(dirnames,'./','');
  filenames=strrep(filenames,'./','');
  
  % ignore CVS folders
  remove = [];
  for i=1:length(dirnames)
      test_string = fliplr(dirnames{i});
      if strcmpi(test_string(1:min([3,length(test_string)])),fliplr('CVS')), remove = [remove; i]; end
  end
  dirnames(remove) = [];
  

  % ignore makeinstall.rc and .cvsignore
  i=1;
  while i<=length(filenames)
    if strncmpi('p.',fliplr(filenames{i}),2), filenames(i)=[]; i=i-1; end
    if strcmpi('makeinstall.rc',filenames{i}), filenames(i)=[]; i=i-1; end
    if strcmpi('.cvsignore',filenames{i}), filenames(i)=[]; i=i-1; end
    i=i+1;
  end
  
  % read the toolbox files 
  i=0;
  
  while i<=length(filenames), 
    i=i+1;
    if i>length(filenames), break, end
    if strcmp(filenames{i},'.') | strcmp(filenames{i},'..') | strcmpi(filenames{i},install_file) | strcmpi(filenames{i},'install.m') | strncmpi(filenames{i},'private/.gpl',12)
      filenames(i)=[]; i=i-1;
    end
  end
  
  b=[]; c=[]; bfile='';
  for i=1:length(filenames),
    disp(['   Reading ', char(filenames{i}),''])
    fid=fopen(char(filenames{i}),'r');

    % ASCII data
    if ...
    strcmpi(lower(strtok(fliplr(filenames{i}),'.')),'txt') | ...
    strcmpi(lower(strtok(fliplr(filenames{i}),'.')),'xet') | ...
    strcmpi(lower(strtok(fliplr(filenames{i}),'.')),'m') | ...
    strcmpi(lower(strtok(fliplr(filenames{i}),'.')),'cr') | ...
    strcmpi(lower(strtok(fliplr(filenames{i}),'.')),'lmx') | ...
    strcmpi(lower(strtok(fliplr(filenames{i}),'.')),'lmth') | ...
    strcmpi(lower(strtok(fliplr(filenames{i}),'.')),'mth')

      c=[c, ['%<-- ASCII begins here: __',char(filenames{i}),'__ -->'], 10];
      in=char(fread(fid,'char')');
      in=strrep(in,char(10),[char(10),'%@']);
%      while 1
%         temp=fgetl(fid);
%         if ~ischar(temp), break
%         else
           c=[c, ['%@',in],10];
%         end
%      end
      c=[c, '%<-- ASCII ends here -->', 10];
    
    % binary data
    else
      clear temp
      bfile=[bfile; filenames(i)];
      temp_in=fread(fid);
      if ~isempty(temp_in)
        temp(2,:)=temp_in'; 
      end
      temp(1,:)='%';
      temp=temp(:);
      btemp=temp';
      b=[b, ['%<-- Binary begins here: __',char(filenames(i)),'__ __',num2str(length(btemp)),'__ -->',10]];
      b=[b, btemp, 10];
      b=[b, ['%<-- Binary ends here -->',10]];
    end

    err=fclose(fid);

  end

  % compute a checksum
  c=double([c, b]);
  checksum=dec2hex(sum((1:length(c)).*c));
  disp(['   Checksum is ', checksum,''])
  
  % write the archiv into the install file
  disp(['   Writing ', install_file,''])
  fid=fopen(fullfile(olddir,install_file),'a');
  err=fprintf(fid,'%s\n',['% -------------------------------------------']);
  err=fprintf(fid,'%s\n',['% GENERATED ENTRIES - DO NOT MODIFY ANYTHING!']);
  err=fprintf(fid,'%s\n',['%<-- Header begins here -->']);
  err=fprintf(fid,'%s\n',['%@',checksum]);
  err=fprintf(fid,'%s\n',['%@',time_string]);
  err=fprintf(fid,'%s\n',['%@',version_number, release]);
  err=fprintf(fid,'%s\n',['%<-- Header ends here -->']);
  err=fwrite(fid,c); 
  err=fclose(fid);

  cd(olddir)
  

else
  % make makeinstall.rc file
  if isempty(toolbox_name), [dummy toolbox_name]=fileparts(pwd); end
  fid=fopen(rc_file,'w');
  if fid~=-1
    warning on
    disp('   ** Warning: Could not find the makeinstall resource file.')
    disp('   Creating now the makeinstall resource file.')
    disp('   Please modify the entries in ')
    disp(['     ',rc_file])
    disp('   and restart if you would like to use other than the default')
    disp('   settings. Now automatically restart with default settings.')
    err=fprintf(fid,'%s\n\n',['% modify the following lines for your purpose']);
    err=fprintf(fid,'%s\n\n',['toolbox_name=''',toolbox_name,''';          % name of the toolbox']);
    err=fprintf(fid,'%s\n',['install_file=''install.m'';             % name of the install script']);
    err=fprintf(fid,'%s\n',['deinstall_file=''tbclean.m'';           % name of the deinstall script']);
    err=fprintf(fid,'%s\n',['old_dirs='''';                          % possible old (obsolete) toolbox folders']);
    err=fprintf(fid,'%s\n',['install_path='''';                      % the root folder where the toolbox folder will be located (default is $USER$/matlab or $MATLABROOT$/toolbox)']);
    err=fprintf(fid,'%s\n',['install_dirUNIX=''',toolbox_name,''';   % the folder where the toolbox files will be extracted (UNIX)']);
    err=fprintf(fid,'%s\n',['install_dirPC=install_dirUNIX;          % the folder where the toolbox files will be extracted (PC)']);
    err=fprintf(fid,'%s\n\n',['src_dir=''',pwd,'''; % folder with the origin toolbox']);
    err=fprintf(fid,'%s\n',['version_file='''';                      % include in this file a line like this: % $Revision$']);
    err=fprintf(fid,'%s\n',['version_number='''';                    % or put the version number in this variable']);
    err=fprintf(fid,'%s\n',['release='''';                           % the release number']);
    err=fprintf(fid,'%s\n\n',['infostring='''';                        % further information displayed during installation']);
    err=fprintf(fid,'%s\n',['% if the info.xml does not yet exist it will be created with the following']);
    err=fprintf(fid,'%s\n',['% parameters; else these parameters have no effect']);
    err=fprintf(fid,'%s\n',['xml_name=''',toolbox_name,''';                          % name of the toolbox for the launch pad entry']);
    err=fprintf(fid,'%s\n',['xml_start='''';                         % start programme for the launch pad entry']);
    err=fprintf(fid,'%s\n',['xml_demo='''';                          % demo programme for the launch pad entry']);
    err=fprintf(fid,'%s\n',['xml_web='''';                           % link to the toolbox web site in the launch pad entry']);
    fclose(fid);
    restart=1;
  else
    disp('Sorry. A problem during file system access occurred.')
    error('Could not open the makeinstall resource file.')
  end
  cd(olddir)
end
end
warning on

if restart, makeinstall(varargin{:}), end

% --------------------------------
% GENERATED ENTRIES - DO NOT EDIT!
%<-- ASCII begins here: install -->
%@function aout=install(varargin);
%@% INSTALL   Install script for $toolboxname$.
%@%    INSTALL creates the $toolboxname$ folder and (optionally) 
%@%    the needed entries in the startup.m file.
%@% 
%@%    INSTALL PATH creates the $toolboxname$ folder 
%@%    in the specified PATH.
%@%    
%@%    This installation script was generated by using 
%@%    the MAKEINSTALL tool. For further information
%@%    visit http://matlab.pucicu.de
%@
%@% Copyright (c) 2001-2005 by AMRON
%@% Norbert Marwan, Potsdam University, Germany
%@% http://www.agnld.uni-potsdam.de
%@%
%@% THIS IS A GENERATED INSTALL-FILE, DO NOT EDIT!
%@% Generation date: $generation_date$
%@% $Date$
%@% $Revision$
%@
%@install_file='';install_path='$installpath$';installfile_info.date='';installfile_info.bytes=[];
%@time_stamp='';checksum='';checksum_file='';
%@errcode=0;
%@
%@%try
%@  warning('off')
%@  if nargin
%@    install_path = varargin{1};
%@  end
%@
%@  if exist('install.log')==2, delete('install.log'), end
%@  %rehash
%@  disp('$lines$')
%@  disp('  INSTALLATION $toolboxname$');
%@  disp('$lines$')
%@  install_file=[mfilename,'.m'];
%@  currentpath=pwd; time_stamp='time_stamp not yet obtained'; checksum='checksum not yet obtained';
%@  
%@%%%%%%% read the archive
%@%%%%%%% and look for checksum and date in archive
%@  errcode=90;
%@  disp('  Reading the archiv ')
%@  fid=fopen(install_file,'r'); 
%@  fseek(fid,0,'eof'); eofbyte=ftell(fid);
%@  fseek(fid,$startbyte$,'bof');
%@  while 1
%@     temp=fgetl(fid);
%@     startbyte=ftell(fid);
%@     if length(temp)>1
%@       if strcmpi(temp,'%<-- Header begins here -->')
%@          errcode=90.1;
%@          checksum=fgetl(fid);
%@          temp1=fgetl(fid);
%@          temp2=fgetl(fid);
%@       end
%@       if strcmpi(temp,'%<-- Header ends here -->')
%@          startbyte=ftell(fid);
%@          break
%@       end
%@     end
%@  end
%@  checksum(1:2)=[];
%@  fseek(fid,startbyte,'bof');
%@  errcode=90.2;
%@  A=fread(fid,eofbyte,'char');
%@  errcode=90.3;
%@  checksum_file=dec2hex(sum((1:length(A))'.*A));
%@  if ~strcmpi(checksum_file,checksum)
%@    error(['The installation file is corrupt!',10,'Ensure that the archive container was ',...
%@           'not modified (check FTP/ ',10,'proxy/ firewall settings, anti-virus scanner for emails etc.)!'])
%@  else
%@    disp(['  Checksum test passed (', checksum,')'])
%@  end
%@  fclose(fid);
%@
%@  disp(['  $toolboxname$ version ', temp2(3:end),''])
%@  time_stamp=temp1(3:end); disp(['  $toolboxname$ time stamp ', time_stamp,'']); 
%@  
%@  errcode=91;
%@  if isunix
%@    toolboxpath='$toolboxdirunix$';
%@  else
%@    toolboxpath='$toolboxdirpc$';
%@  end
%@  
%@  
%@%%%%%%% check for older versions
%@  
%@  p=path; i1=0;
%@  
%@  while $check_for_old$>i1;
%@    errcode=92;
%@    i1=$check_for_old$;
%@    if ~isempty(i1)
%@      i1=i1(1);
%@      if isunix, i2=findstr(':',p); else, i2=findstr(';',p); end
%@      i3=i2(i2>i1);                 % last index pathname
%@      if ~isempty(i3), i3=i3(1)-1; else, i3=length(p); end
%@      i4=i2(i2<i1);                 % first index pathname
%@      if ~isempty(i4), i4=i4(end)+1; else, i4=1; end
%@      oldtoolboxpath=p(i4:i3);
%@      disp(['  Old $toolboxname$ found in ', oldtoolboxpath,''])
%@      rem_old = input('> Delete old toolbox? Y/N [Y]: ','s');
%@      if isempty(rem_old), rem_old = 'Y'; end
%@      if strcmpi('Y',rem_old)
%@%%%%%%% removing old entries in startup-file
%@        errcode=94;
%@        rmpath(oldtoolboxpath)
%@        if i4>1, p(i4-1:i3)=''; else, p(i4:i3)=''; end
%@        startup_exist = exist('startup');
%@        if startup_exist
%@             startupfile=which('startup');
%@             startuppath=startupfile(1:findstr('startup.m',startupfile)-1);
%@             errcode=94.1;
%@             if ~isunix
%@               toolboxroot=fullfile(matlabroot,'toolbox');
%@               curr_pwd = pwd; home_pwd = matlabroot; 
%@             else
%@               toolboxroot=startuppath;
%@               curr_pwd = pwd; cd ('~'); home_pwd = pwd; cd(curr_pwd);
%@             end
%@             instpaths=textread(startupfile,'%[^\n]');
%@             instpaths_old=instpaths;
%@             k=1;
%@             while k<=length(instpaths)
%@               if findstr(oldtoolboxpath,strrep(instpaths{k},'~',home_pwd))
%@                 errcode=94.2;
%@                 instpaths(k)=[];
%@               else
%@                 k=k+1;
%@               end
%@             end
%@             fid=fopen(startupfile,'w');
%@             errcode=94.3;
%@             if fid < 0
%@               disp(['  ** Warning: Could not get access to ',startupfile,'.']);
%@               disp(['  ** Could not remove toolbox from the startup.m file.']);
%@               disp(['  ** Ensure that you have write access!']);
%@             else
%@               for i2=1:length(instpaths), 
%@                 err=fprintf(fid,'%s\n', char(instpaths{i2})); 
%@               end
%@               err=fclose(fid);
%@             end
%@        end
%@%%%%%%% removing old paths
%@        errcode=93;
%@        if exist(oldtoolboxpath)==7
%@           disp(['  Change to ',oldtoolboxpath,''])
%@           cd(oldtoolboxpath)
%@           dirnames='';filenames='';
%@           temp='.:';
%@           while ~isempty(temp)
%@             [temp1 temp]=strtok(temp,':');
%@             if ~isempty(temp1)
%@               dirnames=[dirnames; {temp1}];
%@               x2=dir(temp1);
%@               for i=1:length(x2)
%@                 if ~x2(i).isdir, filenames=[filenames; {[temp1,'/', x2(i).name]}]; end
%@         	   if x2(i).isdir & ~strcmp(x2(i).name,'.') & ~strcmp(x2(i).name,'..'), temp=[temp,temp1,filesep,x2(i).name,':']; end
%@               end
%@             end
%@           end
%@           dirnames=strrep(dirnames,['.',filesep],'');
%@           for i=1:length(dirnames),l(i)=length(dirnames{i});;end
%@           [i i4]=sort(l);
%@           dirnames=dirnames(fliplr(i4));
%@           for i=1:length(dirnames)
%@              delete([dirnames{i}, filesep,'*']),
%@              delete(dirnames{i}),
%@              disp(['  Removing files in ',char(dirnames{i}),''])
%@           end
%@           cd(currentpath)
%@           delete(oldtoolboxpath)
%@           disp(['  Removing ',oldtoolboxpath,''])
%@        end
%@%%%%%%%
%@      end
%@    end
%@  end
%@  clear p i i1 i2 i3 i4 temp* x2
%@  
%@%%%%%%% add entry into startpath in startup.m
%@  i=findstr(toolboxpath,path);
%@  if isempty(i)
%@     errcode=95;
%@     if exist('startup')
%@        errcode=95.1;
%@        startupfile=which('startup');
%@        startuppath=startupfile(1:findstr('startup.m',startupfile)-1);
%@  
%@        if ~isunix
%@           errcode=95.11;
%@           toolboxroot=fullfile(matlabroot,'toolbox');
%@        else
%@           errcode=95.12;
%@           toolboxroot=startuppath;
%@        end
%@        instpaths=textread(startupfile,'%[^\n]');
%@  
%@     else
%@        errcode=95.2;
%@        if ~isunix
%@           errcode=95.21;
%@           startupfile=fullfile(matlabroot,'toolbox','local','startup.m');
%@  	   toolboxroot=fullfile(matlabroot,'toolbox');
%@  	   instpaths={''};
%@        else
%@           errcode=95.22;
%@           cd ~
%@           if exist('matlab')~=7, mkdir matlab, end
%@           cd matlab
%@   	   startuppath=[pwd,'/'];
%@  	   startupfile=[startuppath,'startup.m'];
%@  	   toolboxroot=startuppath;
%@  	   instpaths={''};
%@        end
%@     end
%@    
%@        errcode=95.21;
%@        if ~isempty(install_path)
%@           switch ( exist(install_path) )
%@              case 0
%@                in = input(['> Create ', install_path, '? Y/N [Y]: '],'s');
%@                if isempty(in), in = 'Y'; end
%@                if strcmpi('Y',in)
%@                   err = mkdir(install_path);
%@                   if ~err
%@                     disp(['  ** Could not create ', install_path, '! Using ',startuppath,' as installation path.'])
%@                   else                
%@                     toolboxroot = install_path;
%@                   end                
%@                else 
%@                   disp(['  ** Do not create ', install_path, '! Using ',startuppath,' as installation path.'])
%@                end
%@              case 2
%@                disp(['  ** ', install_path, ' is not a directory! Using ',startuppath,' as installation path.'])
%@              case 7
%@                toolboxroot = install_path;
%@           end
%@        end
%@
%@     errcode=95.3;
%@     TBfullpath=fullfile(toolboxroot,toolboxpath);
%@     if ~exist(TBfullpath), err=mkdir(toolboxroot,toolboxpath); end
%@
%@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%@% resolve ./ and ../ to absolute path
%@% this part was suggested by Gaetan Koers (Vrije Universiteit Brussel)
%@     gk_TBfullpath = [];
%@     if str2num(version('-release')) >= 14
%@          % TBfullpath starts with './' or '.\'
%@          gk_tmp = regexpi(TBfullpath, '^\.{1}[\/|\\](.*)', 'tokens');
%@          if ~isempty(gk_tmp)
%@              gk_relpath = gk_tmp{1}{1};
%@              gk_TBfullpath = fullfile(pwd, gk_relpath);
%@          end
%@          % TBfullpath starts with '../' or '..\'
%@          gk_tmp = regexpi(TBfullpath, '^\.{2}[\/|\\](.*)', 'tokens');
%@          if ~isempty(gk_tmp)
%@              gk_relpath = gk_tmp{1}{1};
%@              gk_tmp = regexpi(pwd, '(.*[\\|\/]).*', 'tokens');
%@              gk_TBfullpath = fullfile(gk_tmp{1}{1}, gk_relpath);
%@          end
%@     else
%@          % TBfullpath starts with './' or '.\'
%@          [gk_tmp_start gk_tmp_finish gk_tmp]= regexpi(TBfullpath, '^\.{1}[\/|\\](.*)');
%@          if ~isempty(gk_tmp)
%@              gk_relpath = TBfullpath(gk_tmp_start(1) - 1 + gk_tmp{1}(1):gk_tmp{1}(2));
%@              gk_TBfullpath = fullfile(pwd, gk_relpath);
%@          end
%@          % TBfullpath starts with '../' or '..\'
%@          [gk_tmp_start gk_tmp_finish gk_tmp] = regexpi(TBfullpath, '^\.{2}[\/|\\](.*)');
%@          if ~isempty(gk_tmp)
%@              gk_relpath = TBfullpath(gk_tmp_start(1) - 1 + gk_tmp{1}(1):gk_tmp{1}(2));
%@              gk_pwd = pwd;
%@              [gk_tmp_start gk_tmp_finish gk_tmp] = regexpi(gk_pwd, '(.*[\\|\/]).*');
%@              gk_TBfullpath = fullfile(gk_pwd(gk_tmp_start(1) - 1 + gk_tmp{1}(1):gk_tmp{1}(2)), gk_relpath);
%@          end
%@     end
%@     if ~isempty(gk_TBfullpath), TBfullpath = gk_TBfullpath; end
%@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%@     
%@
%@     disp(['> In order to get permanent access, the toolbox should be added',10,'> to the top (default) or end (E) of your startup path.'])
%@     in = input(['> Add toolbox permanently into your startup path (highly recommended)? Y/E/N [Y]: '],'s');
%@     if isempty(in), in = 'Y'; end
%@     if strcmpi('Y',in)
%@       instpaths{end+1,1}={['addpath ''',TBfullpath,''' -begin']};
%@       disp('  Adding Toolbox at the end of the startup.m file')
%@     elseif strcmpi('E',in)
%@       instpaths{end+1,1}={['addpath ''',TBfullpath,''' -end']};
%@       disp('  Adding Toolbox at the top of the startup.m file')
%@     end
%@
%@     if strcmpi('Y',in) | strcmpi('E',in)
%@       errcode=95.4;
%@       fid=fopen(startupfile,'w');
%@       if fid < 0
%@         disp(['  ** Warning: Could not get access to ',startupfile,'.']);
%@         disp(['  ** Could not add toolbox into the startup.m file.']);
%@         disp(['  ** Ensure that you have write access!']);
%@       else
%@         for i2=1:length(instpaths), err=fprintf(fid,'%s\n', char(instpaths{i2}));end
%@         err=fclose(fid);
%@       end
%@     end
%@
%@  else
%@     errcode=96;
%@     startupfile=which('startup');
%@     startuppath=startupfile(1:findstr('startup.m',startupfile)-1);
%@     if ~isunix
%@        toolboxroot=fullfile(matlabroot,'toolbox');
%@     else
%@        toolboxroot=startuppath;
%@     end
%@    
%@        errcode=96.21;
%@        if ~isempty(install_path)
%@           switch ( exist(install_path) )
%@              case 0
%@                disp(['> Create ', install_path, '?'])
%@                in = input('> Create ', install_path, '? Y/N [Y]: ','s');
%@                if isempty(in), in = 'Y'; end
%@                if strcmpi('Y',in)
%@                   err = mkdir(install_path);
%@                   if ~err
%@                     disp(['  ** Could not create ', install_path, '! Using ',startuppath,' as installation path.'])
%@                   else                
%@                     toolboxroot = install_path;
%@                   end                
%@                else 
%@                   disp(['  ** Do not create ', install_path, '! Using ',startuppath,' as installation path.'])
%@                end
%@              case 2
%@                disp(['  ** ', install_path, ' is not a directory! Using ',startuppath,' as installation path.'])
%@              case 7
%@                toolboxroot = install_path;
%@           end
%@        end
%@     TBfullpath=fullfile(toolboxroot,toolboxpath);
%@     if ~exist(TBfullpath), err=mkdir(toolboxroot,toolboxpath); end
%@  end
%@  
%@  
%@%%%%%%% read the archive
%@  errcode=97;
%@  fprintf('  Importing the archiv ')
%@  cd(currentpath)
%@  max_sc=30;
%@  scale=[sprintf('%3.0f',0),'% |',repmat(' ',1,max_sc),'|'];
%@  fprintf('%s',scale)
%@  b=''; c.file=''; c.data=''; bfile=''; folder=''; i2=0;
%@    
%@    % read ASCII
%@    errcode=97.1;
%@    i1=findstr(char(A'),'%<-- ASCII begins here');
%@    i2=findstr(char(A'),'%<-- ASCII ends here -->');
%@    
%@    for k=1:length(i1),
%@      wb=round(i1(k)*max_sc/eofbyte);
%@      errcode=97.11;
%@      scale=[sprintf('%3.0f',100*wb/max_sc),'% |',repmat('*',1,wb),repmat(' ',1,max_sc-wb),'|'];
%@      fprintf([repmat('\b',1,max_sc+7),'%s'],scale)
%@      B=A(i1(k):i2(k)-2);
%@     
%@      i4=find(B==10);
%@      i3=[0;i4(1:end-1)]+1;
%@      filename=strrep(...
%@                strrep(char(B(i3(1):i4(1)-1)'),'%<-- ASCII begins here: __',''),...
%@  	      '__ -->','');
%@      errcode=['97.1',reshape(dec2hex(double(filename))',1,length(filename)*2)];
%@      i6=findstr(filename,'/');
%@      if i6>0
%@         folder=[folder; {filename(1:i6(end)-1)}];
%@      end
%@      c(k).file={filename};
%@      c(k).data=strrep(char(B(i4(1)+3:end)'),[char(10),'%@'],char(10));;
%@    end
%@  
%@    % read binary
%@    errcode=97.2;
%@    i1=findstr(char(A'),'%<-- Binary begins here');
%@    i2=findstr(char(A'),'%<-- Binary ends here -->');
%@    for k=1:length(i1),
%@      wb=round(i1(k)*max_sc/eofbyte);
%@      errcode=97.21;
%@      scale=[sprintf('%3.0f',100*wb/max_sc),'% |',repmat('*',1,wb),repmat(' ',1,max_sc-wb),'|'];
%@      fprintf([repmat('\b',1,max_sc+7),'%s'],scale)
%@      B=A(i1(k):i2(k));
%@  
%@      i4=find(B==10);
%@      i3=[0;i4(1:end-1)]+1;
%@      i5=findstr(char(B(i3(1):i4(1))'),'__');
%@      filename=char(B(i5(1)+2:i5(2)-1)');
%@      errcode=['97.2',reshape(dec2hex(double(filename))',1,length(filename)*2)];
%@      i6=findstr(filename,'/');
%@      if i6>0
%@  	folder=[folder; {filename(1:i6(end)-1)}];
%@      end
%@      bfile=[bfile; {filename}];
%@      nbytes=str2num(char(B(i5(3)+2:i5(4)-1)'));
%@      if nbytes>=2
%@        temp=reshape(B(i4(1)+1:i4(1)+nbytes),2,nbytes/2);
%@        b=[b;{temp(2,:)}];
%@      else
%@        b=[b;{''}];
%@      end
%@  
%@    end
%@    wb=max_sc;
%@    scale=[sprintf('%3.0f',100*wb/max_sc),'% |',repmat('*',1,wb),repmat(' ',1,max_sc-wb),'|'];
%@    fprintf([repmat('\b',1,max_sc+7),'%s'],scale)
%@  fprintf('\n')
%@  clear temp* i i1 i2 i3 i4 i5 i6 A B
%@  
%@  errcode='97.3';
%@  cd(TBfullpath)
%@  disp(['  Toolbox folder is ',TBfullpath,''])
%@  
%@%%%%%%% make sub-directories
%@  errcode='97.4';
%@  for i=1:length(folder);
%@     i1=folder{i}; i2='.'; olddir=pwd;
%@     if exist([TBfullpath, filesep, i1])~=7
%@        while ~isempty(i2) & ~isempty(i1)
%@          cd(i2)
%@          [i2 i1]=strtok(i1,'/');
%@          if exist([pwd, filesep, i2])~=7 & exist([pwd, filesep, i2])
%@             disp(['  ** Warning: Found ', i2, ' will be overwritten.'])
%@             errcode=['97.5',reshape(dec2hex(double(i2))',1,length(i2)*2)];
%@             delete(i2)
%@          end
%@          if ~exist([pwd, filesep, i2])
%@            disp(['  Make directory ',pwd, filesep, i2,''])
%@            errcode=['97.6',reshape(dec2hex(double(i2))',1,length(i2)*2)];
%@            mkdir(i2)
%@          end
%@        end
%@        cd(olddir)
%@     end
%@  end
%@
%@%%%%%%% write the programme files
%@  errcode=98;
%@  num_errors=0;
%@  for i=1:length(c),
%@    disp(['  Creating ',char(c(i).file),''])
%@    fid=fopen(char(c(i).file),'w');
%@    if fid < 0
%@       disp(['  ** Warning: Could not get access to ',char(c(i).file),'.']);
%@       disp(['  ** Ensure that you have write access in this filesystem!']);
%@       num_errors=num_errors+1;
%@       if num_errors == 2; 
%@         disp('Abort!')
%@         disp('Too much errors due to write access failure in this filesystem.')
%@         cd(currentpath), return
%@       end
%@    else
%@      if strcmpi(c(i).file,'info.xml')
%@        v=version;
%@        release=str2num(v(findstr(v,'(R')+2:findstr(v,')')-1));
%@        if release>12, area='toolbox'; icon_path='$toolbox/matlab/icons'; else area='matlab'; icon_path='$toolbox/matlab/general'; end
%@        i3=findstr(c(i).data,'<matlabrelease>'); i4=findstr(c(i).data,'</matlabrelease>');
%@        if ~isempty(i3) & i4>i3;
%@          c(i).data=strrep(c(i).data,c(i).data(i3:i4-1),['<matlabrelease>',num2str(release)]);
%@        end
%@        i3=findstr(c(i).data,'<area>'); i4=findstr(c(i).data,'</area>');
%@        if ~isempty(i3) & i4>i3;
%@          c(i).data=strrep(c(i).data,c(i).data(i3:i4-1),['<area>',area]);
%@        end
%@        c(i).data=strrep(c(i).data,'<icon>$toolbox/matlab/general',['<icon>',icon_path]);
%@        c(i).data=strrep(c(i).data,'<icon>$toolbox/matlab/icons',['<icon>',icon_path]);
%@      end
%@      err=fprintf(fid,'%s',char(c(i).data));
%@      err=fclose(fid);
%@    end
%@  end
%@
%@%%%%%%% pcode the programme files
%@  for i=1:length(c),
%@    try
%@      [tPath tFile tExt]=fileparts(char(c(i).file));
%@      if strcmpi(tExt,'.m') & ~strcmpi(tFile,'Readme') & ~strcmpi(tFile,'Contents')
%@        if mislocked(char(c(i).file)), munlock(char(c(i).file)); clear(char(c(i).file)); end
%@        disp(['  Pcode ',char(c(i).file),''])
%@        pcode(char(c(i).file),'-inplace')
%@      end  
%@    catch
%@    end
%@  end
%@
%@%%%%%%% write the binary files
%@  num_errors=0;
%@  for i=1:length(b),
%@    disp(['  Creating ',char(bfile(i)),''])
%@    fid=fopen(char(bfile(i)),'w');
%@    if fid < 0
%@       disp(['  ** Warning: Could not get access to ',char(bfile(i)),'.']);
%@       disp(['  ** Ensure that you have write access in this filesystem!']);
%@       num_errors=num_errors+1;
%@       if num_errors == 2; 
%@         disp('Abort!')
%@         disp('Too much errors due to write access failure in this filesystem.')
%@         cd(currentpath), return
%@       end
%@    else
%@      err=fwrite(fid,b{i}); 
%@      err=fclose(fid);
%@    end
%@  end
%@  tx=version; tx=strtok(tx,'.'); 
%@  if str2num(tx)>=5 & exist('rehash'), rehash, end
%@  if str2num(tx)>=6 & exist('rehash'), eval('rehash toolboxcache'), end
%@  
%@%%%%%%% removing installation file
%@  errcode=99;
%@  cd(currentpath)
%@  i = input('> Delete installation file? Y/N [Y]: ','s');
%@  if isempty(i), i = 'Y'; end
%@  
%@  if strcmpi('Y',i)
%@    disp('  Removing installation file')
%@    delete(install_file)
%@  end
%@  
%@%%%%%%% make toolbox accessible in the current matlab session
%@  addpath(TBfullpath,'-end');
%@  
%@  disp('  Installation finished!')
%@  
%@  if ~exist('rehash')
%@    disp('  ** Warning: Could not rehash your Matlab system.')
%@    disp('  ** Probably a restart of Matlab will be necessary in order')
%@    disp('  ** to get access to the installed toolbox.')
%@  end
%@  
%@  disp('$lines$')
%@  $infostring$
%@  disp('For an overview type:')
%@  disp(['helpwin ',toolboxpath])
%@  warning('on')
%@  
%@  
%@%%%%%%% error handling
%@
%@if 0 ; %catch
%@  z2=whos;x_lasterr=lasterr;y_lastwarn=lastwarn;
%@  if ~strcmpi(x_lasterr,'Interrupt')
%@    if fid>-1, 
%@      try, z_ferror=ferror(fid); catch, z_ferror='No error in the installation I/O process.'; end
%@    else
%@      z_ferror='File not found.'; 
%@    end
%@    installfile_info=dir([currentpath,filesep,install_file]);
%@    fid=fopen(fullfile(currentpath,'install.log'),'w');
%@    checksum_test=findstr(x_lasterr,'The installation file is corrupt!');
%@    if isempty(checksum_test),checksum_test=0; end
%@    if ~checksum_test
%@      err=fprintf(fid,'%s\n','This script is under development and your assistance is');
%@      err=fprintf(fid,'%s\n','urgently welcome. Please inform the distributor of the');
%@      err=fprintf(fid,'%s\n','toolbox, where the error occured and send us the following');
%@      err=fprintf(fid,'%s\n','error report and the informations about the toolbox (distributor,');
%@      err=fprintf(fid,'%s\n','name etc.). Provide a brief description of what you were');
%@      err=fprintf(fid,'%s\n','doing when this problem occurred.');
%@      err=fprintf(fid,'%s\n','E-mail or FAX this information to us at:');
%@      err=fprintf(fid,'%s\n','    E-mail:  marwan@agnld.uni-potsdam.de');
%@      err=fprintf(fid,'%s\n','       Fax:  ++49 +331 977 1142');
%@      err=fprintf(fid,'%s\n\n\n','Thank you for your assistance.');
%@      err=fprintf(fid,'%s\n',repmat('-',50,1));
%@      err=fprintf(fid,'%s\n',datestr(now,0));
%@      err=fprintf(fid,'%s\n',['Matlab ',char(version),' on ',computer]);
%@      err=fprintf(fid,'%s\n',repmat('-',50,1));
%@      err=fprintf(fid,'%s\n','Makeinstall Version ==> $mi_version$');
%@      err=fprintf(fid,'%s\n',['Install File ==> ',install_file,'/',installfile_info.date,'/',num2str(installfile_info.bytes)]);
%@      err=fprintf(fid,'%s\n',['Container ==> ',time_stamp,'/',checksum]);
%@      err=fprintf(fid,'%s\n\n',repmat('-',50,1));
%@      err=fprintf(fid,'%s\n',x_lasterr);
%@      err=fprintf(fid,'%s\n',y_lastwarn);
%@      err=fprintf(fid,'%s\n',z_ferror);
%@      err=fprintf(fid,'%s\n',[' errorcode ==> ',num2str(errcode)]);
%@      err=fprintf(fid,'%s\n',' workspace dump ==>');
%@      if ~isempty(z2), 
%@        err=fprintf(fid,'%s\n',['Name',char(9),'Size',char(9),'Bytes',char(9),'Class']);
%@        for j=1:length(z2);
%@          err=fprintf(fid,'%s',[z2(j).name,char(9),num2str(z2(j).size),char(9),num2str(z2(j).bytes),char(9),z2(j).class]);
%@          if ~strcmp(z2(j).class,'cell') & ~strcmp(z2(j).class,'struct')
%@            content=eval(z2(j).name);
%@            content=mat2str(content(1:min([size(content,1),500]),1:min([size(content,2),500])));
%@            err=fprintf(fid,'\t%s',content(1:min([length(content),500])));
%@          elseif strcmp(z2(j).class,'cell')
%@            content=eval(z2(j).name);
%@            err=fprintf(fid,'\t');
%@            for j2=1:min([length(content),500])
%@              if isnumeric(content{j2})
%@                err=fprintf(fid,'{%s} ',content{j2}(1:end));
%@              elseif iscell(content{j2})
%@                err=fprintf(fid,'{%s} ',content{j2}{1:end});
%@              end
%@            end
%@          elseif strcmp(z2(j).class,'struct')
%@            content=fieldnames(eval(z2(j).name));
%@            content=char(content); content(:,end+1)=' '; content=content';
%@            err=fprintf(fid,'\t%s',content(:)');
%@          end
%@          err=fprintf(fid,'%s\n','');
%@        end
%@      end
%@    else
%@      err=fprintf(fid,'%s\n','Installation aborted due to a failed checksum test!');
%@      err=fprintf(fid,'%s\n',['Checksum should be:     ', checksum]);
%@      err=fprintf(fid,'%s\n\n',['Checksum of archive is: ', checksum_file]);
%@      err=fprintf(fid,'%s\n','Ensure that the installation file was not modified by any');
%@      err=fprintf(fid,'%s\n','other programme, as an anti-virus scanner for emails or a');
%@      err=fprintf(fid,'%s\n','mis-configured FTP programme.');
%@    end
%@    err=fclose(fid);
%@    disp('----------------------------');
%@    disp('       ERROR OCCURED ');
%@    disp('    during installation');
%@    disp('----------------------------');
%@    disp(x_lasterr);
%@    if ~checksum_test
%@      disp(z_ferror);
%@      disp(['   errorcode is ',num2str(errcode)]);
%@      disp('----------------------------');
%@      disp('   This script is under development and your assistance is ')
%@      disp('   urgently welcome. Please inform the distributor of the')
%@      disp('   toolbox, where the error occured and send us the error')
%@      disp('   report and the informations about the toolbox (distributor,')
%@      disp('   name etc.). For your convenience, this information has been')
%@      disp('   recorded in: ')
%@      disp(['   ',fullfile(currentpath,'install.log')]), disp(' ')
%@      disp('   Provide a brief description of what you were doing when ')
%@      disp('   this problem occurred.'), disp(' ')
%@      disp('   E-mail or FAX this information to us at:')
%@      disp('       E-mail:  marwan@agnld.uni-potsdam.de')
%@      disp('          Fax:  ++49 +331 977 1142'), disp(' ')
%@      disp('   Thank you for your assistance.')
%@    end
%@  end
%@  warning('on')
%@  cd(currentpath)
%@end
%<-- ASCII ends here -->
%<-- ASCII begins here: clean -->
%@function $deinstall_file$
%@%$deinstall_file_up$   Removes $toolboxname$.
%@%    $deinstall_file_up$ removes all files of $toolboxname$ from
%@%    the filesystem and its entry from the Matlab
%@%    startup file.
%@%    
%@%    This installation script was generated by using 
%@%    the MAKEINSTALL tool. For further information
%@%    visit http://matlab.pucicu.de
%@
%@% Copyright (c) 2002-2003 by AMRON
%@% Norbert Marwan, Potsdam University, Germany
%@% http://www.agnld.uni-potsdam.de
%@%
%@% Generation date: $generation_date$
%@% $Date$
%@% $Revision$
%@
%@error(nargchk(0,0,nargin));
%@
%@try
%@  warning('off')
%@  disp('$lines$')
%@  disp('    REMOVING $toolboxname$    ')
%@  disp('$lines$')
%@  currentpath=pwd;
%@
%@%%%%%%% check for older versions
%@  
%@  p=path; i1=0;
%@  
%@  while findstr(upper('$toolboxdir$'),upper(p))>i1;
%@    i1=findstr(upper('$toolboxdir$'),upper(p));
%@    if ~isempty(i1)
%@      i1=i1(1);
%@      if isunix, i2=findstr(':',p); else, i2=findstr(';',p); end
%@      i3=i2(i2>i1);                 % last index pathname
%@      if ~isempty(i3), i3=i3(1)-1; else, i3=length(p); end
%@      i4=i2(i2<i1);                 % first index pathname
%@      if ~isempty(i4), i4=i4(end)+1; else, i4=1; end
%@      oldtoolboxpath=p(i4:i3);
%@      disp(['  $toolboxname$ found in ', oldtoolboxpath,''])
%@      i = input('> Delete $toolboxname$? Y/N [Y]: ','s');
%@      if isempty(i), i = 'Y'; end
%@      if strcmpi('Y',i)
%@%%%%%%% removing old paths
%@        if exist(oldtoolboxpath)==7
%@           disp(['  Removing files in ',oldtoolboxpath,''])
%@           cd(oldtoolboxpath)
%@           dirnames='';filenames='';
%@           temp='.:';
%@           while ~isempty(temp)
%@             [temp1 temp]=strtok(temp,':');
%@             if ~isempty(temp1)
%@               dirnames=[dirnames; {temp1}];
%@               x2=dir(temp1);
%@               for i=1:length(x2)
%@                 if ~x2(i).isdir, filenames=[filenames; {[temp1,'/', x2(i).name]}]; end
%@         	   if x2(i).isdir & ~strcmp(x2(i).name,'.') & ~strcmp(x2(i).name,'..'), temp=[temp,temp1,filesep,x2(i).name,':']; end
%@               end
%@             end
%@           end
%@           dirnames=strrep(dirnames,['.',filesep],'');
%@           for i=1:length(dirnames),l(i)=length(dirnames{i});;end
%@           [i i4]=sort(l);
%@           dirnames=dirnames(fliplr(i4));
%@           for i=1:length(dirnames)
%@              delete([dirnames{i}, filesep,'*'])
%@              delete(dirnames{i})
%@              disp(['  Removing files in ',char(dirnames{i}),''])
%@           end
%@           cd(currentpath)
%@           delete(oldtoolboxpath)
%@           disp(['  Removing folder ',oldtoolboxpath,''])
%@        end
%@%%%%%%% removing entry in startup-file
%@        rmpath(oldtoolboxpath)
%@        if i4>1, p(i4-1:i3)=''; else, p(i4:i3)=''; end
%@          startup_exist = exist('startup');
%@          if startup_exist
%@             disp(['  Removing startup entry'])
%@             startupfile=which('startup');
%@             startuppath=startupfile(1:findstr('startup.m',startupfile)-1);
%@             instpaths=textread(startupfile,'%[^\n]');
%@             k=1;
%@             while k<=length(instpaths)
%@               if ~isempty(findstr(oldtoolboxpath,instpaths{k}))
%@               instpaths(k)=[];
%@               end
%@               k=k+1;
%@             end
%@             fid=fopen(startupfile,'w');
%@             for i2=1:length(instpaths), 
%@               err=fprintf(fid,'%s\n', char(instpaths(i2,:))); 
%@             end
%@             err=fclose(fid);
%@             disp(['  $toolboxname$ now removed.'])
%@          end
%@        end
%@    end
%@  end
%@  tx=version; tx=strtok(tx,'.'); if str2num(tx)>=6 & exist('rehash'), rehash, end
%@  warning on
%@  
%@%%%%%%% error handling
%@
%@catch
%@  x=lasterr;y=lastwarn;
%@  if ~strcmpi(lasterr,'Interrupt')
%@    if fid>-1, 
%@      try, z=ferror(fid); catch, z='No error in the installation I/O process.'; end
%@    else
%@      z='File not found.'; 
%@    end
%@    fid=fopen('deinstall.log','w');
%@    err=fprintf(fid,'%s\n','This script is under development and your assistance is');
%@    err=fprintf(fid,'%s\n','urgently welcome. Please inform the distributor of the');
%@    err=fprintf(fid,'%s\n','toolbox, where the error occured and send us the following');
%@    err=fprintf(fid,'%s\n','error report and the informations about the toolbox (distributor,');
%@    err=fprintf(fid,'%s\n','name etc.). Provide a brief description of what you were');
%@    err=fprintf(fid,'%s\n','doing when this problem occurred.');
%@    err=fprintf(fid,'%s\n','E-mail or FAX this information to us at:');
%@    err=fprintf(fid,'%s\n','    E-mail:  marwan@agnld.uni-potsdam.de');
%@    err=fprintf(fid,'%s\n','       Fax:  ++49 +331 977 1142');
%@    err=fprintf(fid,'%s\n\n\n','Thank you for your assistance.');
%@    err=fprintf(fid,'%s\n',repmat('-',50,1));
%@    err=fprintf(fid,'%s\n',datestr(now,0));
%@    err=fprintf(fid,'%s\n',['Matlab ',char(version),' on ',computer]);
%@    err=fprintf(fid,'%s\n',repmat('-',50,1));
%@    err=fprintf(fid,'%s\n','$toolboxname$');
%@    err=fprintf(fid,'%s\n',x);
%@    err=fprintf(fid,'%s\n',y);
%@    err=fprintf(fid,'%s\n',z);
%@    err=fclose(fid);
%@    disp('----------------------------');
%@    disp('       ERROR OCCURED ');
%@    disp('   during deinstallation');
%@    disp('----------------------------');
%@    disp(x);
%@    disp(z);
%@    disp('----------------------------');
%@    disp('   This script is under development and your assistance is ')
%@    disp('   urgently welcome. Please inform the distributor of the')
%@    disp('   toolbox, where the error occured and send us the error')
%@    disp('   report and the informations about the toolbox (distributor,')
%@    disp('   name etc.). For your convenience, this information has been')
%@    disp('   recorded in: ')
%@    disp(['   ',fullfile(pwd,'deinstall.log')]), disp(' ')
%@    disp('   Provide a brief description of what you were doing when ')
%@    disp('   this problem occurred.'), disp(' ')
%@    disp('   E-mail or FAX this information to us at:')
%@    disp('       E-mail:  marwan@agnld.uni-potsdam.de')
%@    disp('          Fax:  ++49 +331 977 1142'), disp(' ')
%@    disp('   Thank you for your assistance.')
%@  end
%@  warning('on')
%@  cd(currentpath)
%@end
%@
%<-- ASCII ends here -->
