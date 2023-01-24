@echo off
set "INFILE=objdump.txt"
set "OUTFILE=libnrniv.def"
set "FIRSTLINE=[Ordinal/Name Pointer] Table"
set "LASTLINE=The Function Table (interpreted .pdata section contents)"
setlocal EnableExtensions DisableDelayedExpansion
set "FLAG="
> "%OUTFILE%" (
    echo EXPORTS
    for /F "delims=" %%L in ('findstr /N "^" "%INFILE%"') do (
        set "LINE=%%L"
        setlocal EnableDelayedExpansion
        set "LINE=!LINE:*:=!"
        if "!LINE!"=="%FIRSTLINE%" (
            endlocal
            set "FLAG=TRUE"
        ) else if "!LINE!"=="%LASTLINE%" (
            endlocal
            goto :CONTINUE
        ) else if defined FLAG (
			if NOT "!LINE!"=="" (
				if "!LINE:~8,1!"==" " (
					echo !LINE:~9!
				) else (
					echo !LINE:~8!
				)
			)
            endlocal
        ) else (
            endlocal
        )
    )
)
:CONTINUE
endlocal