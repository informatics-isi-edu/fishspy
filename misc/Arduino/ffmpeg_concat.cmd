echo off
ECHO 'hello world'
SET mypath=%~dp0
echo %mypath%
start ruby %mypath%ffmpeg_concatenate.rb %*

%mypath%../fps_extractor/meta_extractor_fps.cmd %*

pause