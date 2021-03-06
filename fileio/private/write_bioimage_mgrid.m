function write_bioimage_mgrid(filename, elec)

% --------------------------------------------------------
% WRITE_BIOIMAGE_MGRID writes BioImage Suite .mgrid files from a FieldTrip
% elec datatype structure
%
% Use as:
%   write_bioimage_mgrid(filename, elec)
%   where filename has an .mgrid file extension and elec has both a label
%   and an elecpos field
%
% To view the mgrid file in BioImage Suite, ensure that the orientation of
% the scan (e.g., RAS) corresponds with the orientation of the electrode
% positions (in head coordinates) of elec
%
% Copyright (C) 2016, Arjen Stolk & Sandon Griffin
% --------------------------------------------------------


% extract info from label field
for e = 1:numel(elec.label) % electrode loop
  ElecStrs{e,1} = regexprep(elec.label{e}, '\d+(?:_(?=\d))?', ''); % without electrode numbers
  ElecNrs(e) = str2double(regexp(elec.label{e},'-?\d+\.?\d*|-?\d*\.?\d+', 'match')); % without electrode strings
end
GridDescript = unique(ElecStrs);
ngrids = numel(GridDescript);
for g = 1:ngrids % grid loop
  Grid2Elec{g} = match_str(ElecStrs, GridDescript{g}); % assign electrodes to grids
end

% open and write ascii-file line by line
fid = fopen(filename, 'wt'); % open ascii-file

% file header
fprintf(fid, '#vtkpxElectrodeMultiGridSource File\n');
fprintf(fid, '#Description\n');
fprintf(fid, 'patient\n');
fprintf(fid, '#Comment\n');
fprintf(fid, 'no additional comment\n');
fprintf(fid, '#Number of Grids\n');
fprintf(fid, [' ' num2str(ngrids) '\n']);

for g = 1:ngrids % grid loop
  
  % grid info
  fprintf(fid, '#- - - - - - - - - - - - - - - - - - -\n');
  fprintf(fid, ['# Electrode Grid ' num2str(ngrids-1) '\n']); % mgrid count starts at 0
  fprintf(fid, '- - - - - - - - - - - - - - - - - - -\n');
  fprintf(fid, '#vtkpxElectrodeGridSource File v2\n');
  fprintf(fid, '#Description\n');
  fprintf(fid, [GridDescript{g} '\n']);
  fprintf(fid, '#Dimensions\n');
  
  % determine grid dimensions
  if isequal(numel(Grid2Elec{g}), 256)
    GridDim(1) = 16; GridDim(2) = 16;
  elseif isequal(numel(Grid2Elec{g}), 64)
    GridDim(1) = 8; GridDim(2) = 8;
  elseif isequal(numel(Grid2Elec{g}), 48)
    e6 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(6)]),:);
    e7 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(7)]),:);
    d6to7 = sqrt(sum((e6-e7).^2)); % distance of elec 6 to 7
    if d6to7 < 15
      GridDim(1) = 6; GridDim(2) = 8;
    else
      GridDim(1) = 8; GridDim(2) = 6;
    end
  elseif isequal(numel(Grid2Elec{g}), 32)
    e4 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(4)]),:);
    e5 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(5)]),:);
    d4to5 = sqrt(sum((e4-e5).^2)); % distance of elec 4 to 5
    if d4to5 < 15 % within 15 mm
      GridDim(1) = 4; GridDim(2) = 8;
    else
      GridDim(1) = 8; GridDim(2) = 4;
    end
  elseif isequal(numel(Grid2Elec{g}), 20)
    e4 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(4)]),:);
    e5 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(5)]),:);
    d4to5 = sqrt(sum((e4-e5).^2)); % distance of elec 4 to 5
    if d4to5 < 15
      GridDim(1) = 4; GridDim(2) = 5;
    else
      GridDim(1) = 5; GridDim(2) = 4;
    end
  elseif isequal(numel(Grid2Elec{g}), 16)
    e4 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(4)]),:);
    e5 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(5)]),:);
    e9 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(9)]),:);
    d4to5 = sqrt(sum((e4-e5).^2)); % distance of elec 4 to 5
    d4to9 = sqrt(sum((e4-e9).^2)); % distance of elec 4 to 9
    if d4to5 > 15 && d4to9 > 15
      GridDim(1) = 4; GridDim(2) = 4;
    elseif d4to5 < 15 && d4to9 > 15
      GridDim(1) = 2; GridDim(2) = 8;
    else
      GridDim(1) = 1; GridDim(2) = 16;
    end
  elseif isequal(numel(Grid2Elec{g}), 12)
    e6 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(6)]),:);
    e7 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(7)]),:);
    d6to7 = sqrt(sum((e6-e7).^2)); % distance of elec 6 to 7
    if d6to7 > 15
      GridDim(1) = 2; GridDim(2) = 6;
    else
      GridDim(1) = 1; GridDim(2) = 12;
    end
  elseif isequal(numel(Grid2Elec{g}), 10)
    GridDim(1) = 1; GridDim(2) = 10;
  elseif isequal(numel(Grid2Elec{g}), 8)
    e4 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(4)]),:);
    e5 = elec.elecpos(match_str(elec.label, [GridDescript{g} num2str(5)]),:);
    d4to5 = sqrt(sum((e4-e5).^2)); % distance of elec 4 to 5
    if d4to5 < 15
      GridDim(1) = 1; GridDim(2) = 8;
    else
      GridDim(1) = 2; GridDim(2) = 4;
    end
  elseif isequal(numel(Grid2Elec{g}), 6)
    GridDim(1) = 1; GridDim(2) = 6;
  else
      error('At least one of the electrode tracts or grids has dimensions that are not supported by write_bioimage_mgrid. If electrodes are missing from a grid, enter NaN(1,3) for electrode position');
  end
  fprintf(fid, [' ' num2str(GridDim(1)) ' ' num2str(GridDim(2)) '\n']);
  fprintf(fid, '#Electrode Spacing\n');
  fprintf(fid, ' 10.0000 10.0000\n');
  fprintf(fid, '#Electrode Type\n');
  fprintf(fid, '0\n');
  fprintf(fid, '#Radius\n');
  fprintf(fid, '2.000000\n');
  fprintf(fid, '#Thickeness\n');
  fprintf(fid, '0.050000\n');
  fprintf(fid, '#Color\n');
  fprintf(fid, [num2str(rand) ' ' num2str(rand) ' ' num2str(rand) '\n']);
  
  % mgrid electrode numbering:
  % When BIS reads an mgrid file, electrodes within a set of contacts (i.e., grid, depth, or
  % strip) are implicitly assigned a number based on the order they are
  % printed in the mgrid file.  The first electrode printed in the mgrid
  % file corresponds with the electrode in the top left of the mgrid GUI.
  % Subsequent electrodes are assigned numbers moving to the right and
  % then down in mgrid file.
  %
  % for instance in an 4x5 grid, the electrodes will appear in the
  % following orientation in the BiImage Suite GUI
  %  
  %   #5    #10    #15   #20
  %   #4    #9     #14   #19
  %   #3    #8     #13   #18
  %   #2    #7     #12   #17
  %   #1    #6     #11   #16
    
  % In this example, electrodes must be printed in the electrode file in the following
  % order: 5 10 15 20 4 9 14 19 3 8...
    
  mgrid_print_order = [];
  for nrows = 0:GridDim(2)-1
    nextrow = GridDim(2)-nrows:GridDim(2):numel(Grid2Elec{g})-nrows;
    mgrid_print_order = [mgrid_print_order nextrow];
  end
  
  for m = mgrid_print_order
    
    e = match_str(elec.label,[GridDescript{g} num2str(m)]);
    
    % electrode info
    fprintf(fid, '#- - - - - - - - - - - - - - - - - - -\n');
    
    % indexing electrode positions within a grid/depth in BIS:
    % mgrid gui indexes the rows and columns starting from the top left (0,0)
    % and increasing down and to the right.  These indexes are explicitly
    % used to identify the electrodes in the mgrid file
    %
    % for instance in an 4x5 grid, the electrodes indexes will appear in the
    % mgrid GUI as follows
    %
    %   (0,0)   (1,0)    (2,0)   (3,0)
    %   (0,1)   (1,1)    (2,1)   (3,1)
    %   (0,2)   (1,2)    (2,2)   (3,2)
    %   (0,3)   (1,3)    (2,3)   (3,3)
    %   (0,4)   (1,4)    (2,4)   (3,4)
    %
    % In this example, the first electrode to be written in the mgrid file
    % will be 'Electrode 0 0' which corresponds to electrode #5 of the grid    
            
    if GridDim(1) == 1 % if the electrode is part of a depth or strip
      ElecNr(1) = 0;
      ElecNr(2) = GridDim(2)-m;
    else % if the electrode is part of a grid
      r = rem(m,GridDim(2));
      if r == 0
        ElecNr(1) = (m/GridDim(2)) - 1;
        ElecNr(2) = 0;
      else
        ElecNr(1) = floor(m/GridDim(2));
        ElecNr(2) = GridDim(2) - r;
      end
    end
    fprintf(fid, ['# Electrode ' num2str(ElecNr(1)) ' ' num2str(ElecNr(2)) '\n']);
    fprintf(fid, '- - - - - - - - - - - - - - - - - - -\n');
    fprintf(fid, '#vtkpxElectrodeSource2 File\n');
    fprintf(fid, '#Position\n');
    fprintf(fid, [' ' num2str(elec.elecpos(e,1)) ' ' ...
      num2str(elec.elecpos(e,2)) ' ' num2str(elec.elecpos(e,3)) '\n']);
    fprintf(fid, '#Normal\n');
    fprintf(fid, ' 1.0000 0.0000 0.0000\n');
    fprintf(fid, '#Motor Function\n');
    fprintf(fid, '0\n');
    fprintf(fid, '#Sensory Function\n');
    fprintf(fid, '0\n');
    fprintf(fid, '#Visual Function\n');
    fprintf(fid, '0\n');
    fprintf(fid, '#Language Function\n');
    fprintf(fid, '0\n');
    fprintf(fid, '#Auditory Function\n');
    fprintf(fid, '0\n');
    fprintf(fid, '#User1 Function\n');
    fprintf(fid, '0\n');
    fprintf(fid, '#User2 Function\n');
    fprintf(fid, '0\n');
    fprintf(fid, '#Seizure Onset\n');
    fprintf(fid, '0\n');
    fprintf(fid, '#Spikes Present\n');
    fprintf(fid, '0\n');
    fprintf(fid, '#Electrode Present\n');
    if any(isnan(elec.elecpos(e,:))) % check if electrode is present
      fprintf(fid, '0\n'); % 0 = not present
    else
      fprintf(fid, '1\n'); % 1 = present
    end
    fprintf(fid, '#Electrode Type\n');
    fprintf(fid, '0\n');
    fprintf(fid, '#Radius\n');
    fprintf(fid, '2.000000\n');
    fprintf(fid, '#Thickeness\n');
    fprintf(fid, '0.050000\n');
    fprintf(fid, '#Values\n');
    fprintf(fid, '1\n');
    fprintf(fid, '0.000000\n');
    
  end % end of elec loop
end % end of grid loop
fclose(fid);
