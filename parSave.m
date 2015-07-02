function parSave( fname, segments )
%parSave Save from inside a parfor loop
save( fname, 'segments' );
end

