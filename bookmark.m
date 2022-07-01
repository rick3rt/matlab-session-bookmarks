function bookmark(command, bkmark)
    %BOOKMARK store your open files in the MATLAB editor for later use.
    %   BOOKMARK list               lists all available bookmarks that are stored,
    %                               including date the bookmark was stored.
    %
    %   BOOKMARK list <name>        will list all files storen in a bookmark file.
    %
    %   BOOKMARK save <name>        will store all open files in a bookmark file.
    %                               You can restore these open files using:
    %
    % 	BOOKMARK restore <name>     Restores you saved bookmarks.
    %
    %   BOOKMARK delete <name>      Will delete the bookmark.
    %
    %   BOOKMARK closeall           Will close all open editors. Prompts for confirmation.
    %   BOOKMARK closeall -y        Will close all open editors without prompt for confirmation.
    %
    %  R. Waasdorp, r.waasdorp@tudelft.nl, 14-04-2022
    %

    if nargin == 0
        command = 'help';
    end
    if ~exist('bkmark', 'var')
        bkmark = '';
    end

    switch command
        case {'save', 'store'}
            files = listOpenFiles();
            saveBookmarks(bkmark, files);
            fprintf('Saved bookmark ''%s''\n', bkmark);
            bookmark('list', bkmark);
            createSignatures();
        case {'read', 'restore'}
            files = readBookmarks(bkmark);
            openFilesInEditor(files);
        case 'list'
            if nargin == 1
                d = dir(flf('')); d = d(3:end);
                fprintf('Stored bookmarks:\n')
                [~, idx] = sort([d.datenum], 'descend');
                d = d(idx);
                for k = 1:numel(d)
                    fprintf('\t%s(%s)\n', pad(d(k).name, 20), d(k).date);
                end
            elseif nargin == 2 && strcmp(bkmark, 'all')
                d = dir(flf('')); d = d(3:end);
                fprintf('Stored bookmarks:\n')
                for k = 1:numel(d)
                    fprintf('\t%s(%s)\n', pad(d(k).name, 20), d(k).date);
                end
                fprintf('%s\n', repelem('-', 60))
                for k = 1:numel(d)
                    bookmark('list', d(k).name);
                    fprintf('%s\n', repelem('-', 60))
                end
            elseif nargin == 2
                files = readBookmarks(bkmark);
                fprintf('Files stored in ''%s'':\n', bkmark);
                for k = 1:numel(files)
                    [~, name, ext] = fileparts(files{k});
                    fprintf('\t%s%s\n', name, ext);
                end
            end
        case {'delete', 'rm'}
            fprintf('Removing bookmark: ''%s''...\n', bkmark);
            f = flf(bkmark); delete(f);
            createSignatures();
        case 'closeall'
            closeAllEditors(bkmark); % bkmark can be -y to force
        case 'help'
            help bookmark
        otherwise
            error('Unknown option... ');
    end

end

function files = listOpenFiles()
    editorInfo = matlab.desktop.editor.getAll;
    files = {editorInfo.Filename};
    files = files(:);
end

function saveBookmarks(fname, files)
    fd = fopen(flf(fname), 'wt');
    for k = 1:numel(files)
        fprintf(fd, '%s\n', files{k});
    end
    fclose(fd);
end

function files = readBookmarks(fname)
    fd = fopen(flf(fname), 'rt');
    tline = fgetl(fd);
    files = {};
    while ischar(tline)
        files{end + 1, 1} = tline; %#ok<AGROW>
        tline = fgetl(fd);
    end
    fclose(fd);
end

function openFilesInEditor(files)
    fprintf('Opening files...\n')
    files(~isfile(files)) = [];
    edit(files{:})
end

function out = flf(in)
    out = fullfile(fileparts(mfilename('fullpath')), 'data', in);
end

function createSignatures()
    d = dir(flf('')); d = d(3:end);
    bkmarks = {d.name};
    % get path to functionSignatures.json
    p = fileparts(mfilename('fullpath')); % get dir of bashmarks project
    fjson = fullfile(p, 'functionSignatures.json');
    ftemp = fullfile(p, 'functionSignatures.template');
    % read template
    json = fileread(ftemp);
    % and fill it
    bkmarks = cellfun(@(x) strcat('''', x, ''''), bkmarks, 'UniformOutput', false);
    str = ['{' strjoin(bkmarks, ',') '}'];
    str2 = ['{' strjoin(['''all''', bkmarks], ',') '}'];
    json = strrep(json, 'BOOKMARKS', str);
    json = strrep(json, 'BKMARKS_LIST', str2);
    % open file, overwrite mode
    fD = fopen(fjson, 'w');
    fprintf(fD, '%s', json);
    fclose(fD);
end

function closeAllEditors(flag)
    if isempty(flag)
        flag = input('This will close all open editors, are you sure? [y/n]...', 's');
    end
    if contains(flag, 'y')
        closeNoPrompt(matlab.desktop.editor.getAll);
    else
        fprintf('k y got it, no touchy\n');
    end
end
