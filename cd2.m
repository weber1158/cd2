function cd2(addNewFolder)
%Change current folder [user selects from dropdown menu]
%
%Syntax
% cd2()
% cd2(addNewFolder)
% cd2(-removeFolder)
%
%
%Description
% Opens a dialog box for you to choose from a list of your favorite
% folders. You will need to add your favorite folders manually before
% they show up in the dialog box.
%
% Don't forget to use the 'pathtool' function to permanently add cd2 to
% the search path!
%
% >> pathtool
%
%
%Inputs
% [no input] - opens dialog box
% addNewFolder [text]  - path to the folder you wish to add. Also works
%                         with cell vectors of folder paths.                        
% removeFolder [text]  - include a '-' sign at the beginning of the string
%                         to remove a folder. Cannot be used to remove
%                         multiple folders at once!
%
%
%Example 1
%
% The following command will add a folder called 'Metadata' to the list of
% favorite folders:
%
% >> cd2('C:\Users\JohnDoe\Desktop\Data\20250106\Metadata')
%
% You can now change your path to that folder without ever having to type
% the name of the folder again:
%
% >> cd2
%
% Opens the cd2 dialog box. Select the folder, and viola!
%
%
%Example 2
%
% Add the current folder to the list of favorite folders
%
% >> cd2(cd)
%
% It's that easy.
%
%Example 3
%
% If you want to remove a folder from the favorites, simply place a '-'
% sign at the beginning of the folder name when calling the function.
%
% >> cd2('-C:\Users\JohnDoe\Desktop')
%
% The above command will remove 'C:\Users\JohnDoe\Desktop' from the list.
%
%
%Example 4
%
% The function also supports adding a multiple folders at once. Use a list
% of folder names (given as a cell vector) as the input argument. Note,
% removing multiple folders at once is not currently supported.
%
% >> cd2({'C:\Program Files\MATLAB','C:\Windows\Fonts','C:\Users\Public'})
%
% The command above will add the 3 given folders to the list of favorites.

% Copyright 2025 Austin M. Weber

if exist('addNewFolder','var')
  addNewFavoriteFolder(addNewFolder)
else
  openFolderSelector
end

end % End main function

% ========================================================================
% =======================  Begin local functions =========================
% ========================================================================

%%%
%%% Remove the folder(s) specified by the user
%%%
function addNewFavoriteFolder(f)
 arguments
  f {mustBeText}
 end
 if checkRemoveFolder(f)
   removeFolder(f)
 else
   favFoldersPath = which('favoriteFolders.txt');
   if ~iscell(f)
     fileID = fopen(favFoldersPath,'r');
     t = fread(fileID,'*char')';
     fclose(fileID);
     f = char(f);
     addF = [t,',' f];
     fileID = fopen(favFoldersPath,'w');
     fwrite(fileID,addF);
     fclose(fileID);
     fprintf('Folder ''%s'' added successfully.\n',f)
   else
     for i = 1:length(f)
      fileID = fopen(favFoldersPath,'r');
      t = fread(fileID,'*char')';
      fclose(fileID);
      fi = char(f{i});
      addF = [t,',' fi];
      fileID = fopen(favFoldersPath,'w');
      fwrite(fileID,addF);
      fclose(fileID);
      fprintf('Folder ''%s'' added successfully.\n',f{i})
     end
   end
 end
end

%%%
%%% Open the folder selection dialog box
%%%
function openFolderSelector
 favFoldersPath = which('favoriteFolders.txt');
 favFolders = readtable(favFoldersPath,"Delimiter","comma",...
                        "ReadVariableNames",false);
 favFolders = rows2vars(favFolders);
 favFolders.OriginalVariableNames = [];
 favFolders.Properties.VariableNames = {'Folder'};
 favFolders = sortrows(favFolders,'Folder','descend');
 idx = listdlg('Name','Folders',...
               'PromptString',{'Select a folder.',...
                               ' ',...
                               'To add folders, use the syntax:',...
                               '>> cd2(''''C:\path\to\folder'''')',...
                               ' ',...
                               'To remove folders, use the syntax:',...
                               '>> cd2(''''-C:\path\to\folder'''')',...
                               ' '},...
             'ListString',favFolders.Folder,...
             'SelectionMode','single',...
             'OKString','Open');
 if isempty(idx)
   return
 end
 selectedFolder = favFolders.Folder{idx};
 if strcmp(selectedFolder,' None')
   return
 else
 cd(selectedFolder)
 fprintf('Folder ''%s'' opened successfully.\n',selectedFolder)
 end
end

%%%
%%% Did the user use the syntax to remove a folder?
%%%
function b = checkRemoveFolder(s)
  if ~iscell(s)
    s = char(s);
    s1 = s(1);
    if strcmp(s1,'-')
      b = true;
    else
      b = false;
    end
  else
    s = s{1};
    s1 = s(1);
    if strcmp(s1,'-')
      error('Removing multiple folders at once is not supported.')
    else
      b = false;
    end
  end
end

%%%
%%% Remove the folder specified by the user
%%%
function removeFolder(s)
  favFoldersPath = which('favoriteFolders.txt');
  s = char(s);
  s(1) = [];
  fileID = fopen(favFoldersPath,'r');
  t = fread(fileID,'*char')';
  fclose(fileID);
  t = strrep(t,s,''); % Remove the string
  t = strrep(t,',,',','); % Replace any double-commas with a single comma
  fileID = fopen(favFoldersPath,'w');
  fwrite(fileID,t);
  fclose(fileID);
  fprintf('Folder ''%s'' removed successfully.\n',s)
end

