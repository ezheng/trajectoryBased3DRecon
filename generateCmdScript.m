function generateCmdScript()


fileName = 'cmd_killDevil';
fid = fopen(fileName, 'w');

for i = 100:20:500
fprintf( fid, ' bsub -q week -M16 matlab -nodisplay -nojvm -nosplash -r "killDevil_MotionCaptureReconstructionDemo(%d)"\n',i );
end

fclose(fid);

system('chmod %s +x', fileName);
system('%s', fileName);