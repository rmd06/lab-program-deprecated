@echo off

REM Reference: http://stackoverflow.com/questions/8397674/windows-batch-file-looping-through-directories-to-process-files

REM REQUIRE ffmpeg installation

call :treeProcess
goto :eof

:treeProcess
REM Do whatever you want here over the files of this subdir, for example:
for %%f in (*.avi) do (
    ffmpeg -i %%f -vcodec mpeg4 new-%%~nf.mp4
)
for /D %%d in (*) do (
    cd %%d
    call :treeProcess
    cd ..
)
exit /b