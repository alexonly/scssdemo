@ECHO OFF
@SETLOCAL
@SETLOCAL EnableDelayedExpansion

set orderlog=\\cxlsvr118\ccstg_d\ordertest.log
set ccsunlog=\\cxlsvr118\ccstg_d\ccsunlog.log
REM CREATE TABLE CHECK
set TABLE_JAR_PATH=\\cxlsvr118\ccstg_d\trigger\CreateTableChecker.jar
java -jar %TABLE_JAR_PATH% "%CLEARCASE_XPN%"

if "%ERRORLEVEL%" == "100" (
echo ***TablScript指令錯誤，發現二個以上的Create Table指令。
echo ***請將上層目錄undo checkout，請修正此檔案內容，再行check in。
exit 1
)

if "%ERRORLEVEL%" == "200" (
echo ***TablScript檔案檢查發生錯誤，通知資規科人員處理。
echo ***請將上層目錄undo checkout，再行check in。
exit 1
)

REM	=====================================
REM			USELESS SQL 2減量檢查
REM	=====================================
set SQL_CHECKER_PATH_NEW=\\cxlsvr118\ccstg_d\trigger\SQLCheckerNEW\RegularExpression.exe
set SQL_CHECKER_CONFIG_FILE_PATH_NEW=\\cxlsvr118\ccstg_d\trigger\SQLCheckerNEW\config.txt

	

if "%CLEARCASE_TRTYPE_KIND%" == "pre-operation" (
if NOT "%CLEARCASE_ELTYPE%" == "directory" (

if   "%CLEARCASE_USER:~1,5%" == "92002" (	
REM for /f "tokens=1* delims=" %%G in ('java -jar \\cxlsvr118\ccstg_d\trigger\SQLCheckerNEW\SQLCheckerCF_AC.jar "%CLEARCASE_XPN%" "%CLEARCASE_USER%"') do set "MSG=%%G"
for /f "tokens=1* delims=" %%G in ('java -jar \\cxlsvr118\ccstg_d\trigger\SQLCheckerNEW\SQLChecker.jar "%CLEARCASE_XPN%" "%CLEARCASE_USER%"') do set "MSG=%%G"
) ELSE (	
	if   "%CLEARCASE_USER:~1,5%" == "910014" (
	rem echo NeedQLCheckerCLEARCASE_USER%CLEARCASE_USER%CLEARCASE_XPN%CLEARCASE_XPN% >> %orderlog%	
REM for /f "tokens=1* delims=" %%G in ('java -jar \\cxlsvr118\ccstg_d\trigger\SQLCheckerNEW\SQLCheckerCF.jar "%CLEARCASE_XPN%" "%CLEARCASE_USER%"') do set "MSG=%%G"
	) ELSE ( 
rem echo elseNeedQLCheckerCLEARCASE_USER%CLEARCASE_USER%CLEARCASE_XPN%CLEARCASE_XPN% >> %orderlog%	
call \\cxlsvr118\ccstg_d\trigger\residualCheck\checkIsFK.bat "%CLEARCASE_XPN%"
rem  echo !ERRORLEVEL! elseNeedQLCheckerCLEARCASE_USER%CLEARCASE_USER%CLEARCASE_XPN%CLEARCASE_XPN% >> %orderlog%	
if not "!ERRORLEVEL!" == "7193" (
rem echo checkNeedQLCheckerCLEARCASE_USER%CLEARCASE_USER%CLEARCASE_XPN%CLEARCASE_XPN% >> %orderlog%	
for /f "tokens=1* delims=" %%G in ('java -jar \\cxlsvr118\ccstg_d\trigger\SQLCheckerNEW\SQLChecker.jar "%CLEARCASE_XPN%" "%CLEARCASE_USER%"') do set "MSG=%%G"
)
	)
)


)
)

REM if   "%CLEARCASE_USER%" == "i9100401" (	

if "%MSG%" == "100" echo Check In不成功，請undo-checkout父目錄。[ %CLEARCASE_XPN% ]
if "%MSG%" == "100" exit 1

if "%CLEARCASE_USER%" == "i9100401" (
echo ==============CHECKIN before CHECKLIST==================== >> %orderlog%
echo DATETIME=%DATE%%TIME% >> %orderlog%
echo CLEARCASE_ELTYPE=%CLEARCASE_ELTYPE% >> %orderlog%
echo CLEARCASE_USER=%CLEARCASE_USER% >> %orderlog%
echo CLEARCASE_OP_KIND=%CLEARCASE_OP_KIND% >> %orderlog%
echo CLEARCASE_TRTYPE_KIND=%CLEARCASE_TRTYPE_KIND% >> %orderlog%
echo CLEARCASE_VIEW_KIND=%CLEARCASE_VIEW_KIND% >> %orderlog%
echo CLEARCASE_XN_SFX=%CLEARCASE_XN_SFX% >> %orderlog%
echo CLEARCASE_SNAPSHOT_PN=%CLEARCASE_SNAPSHOT_PN% >> %orderlog%
echo CLEARCASE_VOB_PN=%CLEARCASE_VOB_PN% >> %orderlog%
echo CLEARCASE_XPN="%CLEARCASE_XPN%" >> %orderlog%
)


call \\cxlsvr118\ccstg_d\trigger\checklist.bat

if "%CLEARCASE_USER%" == "i9100401" (
echo ==============CHECKIN after CHECKLIST==================== >> %orderlog%
echo DATETIME=%DATE%%TIME% >> %orderlog%
echo CLEARCASE_ELTYPE=%CLEARCASE_ELTYPE% >> %orderlog%
echo CLEARCASE_USER=%CLEARCASE_USER% >> %orderlog%
echo CLEARCASE_OP_KIND=%CLEARCASE_OP_KIND% >> %orderlog%
echo CLEARCASE_TRTYPE_KIND=%CLEARCASE_TRTYPE_KIND% >> %orderlog%
echo CLEARCASE_VIEW_KIND=%CLEARCASE_VIEW_KIND% >> %orderlog%
echo CLEARCASE_XN_SFX=%CLEARCASE_XN_SFX% >> %orderlog%
echo CLEARCASE_SNAPSHOT_PN=%CLEARCASE_SNAPSHOT_PN% >> %orderlog%
echo CLEARCASE_VOB_PN=%CLEARCASE_VOB_PN% >> %orderlog%
echo CLEARCASE_XPN="%CLEARCASE_XPN%" >> %orderlog%
)


REM if "%ERRORLEVEL%" == "3" (
REM echo checkin.bat
REM echo ***SQL檔所在目錄或命名規則不合,SQL的目錄及命名規則如下：
REM echo "com\cathay\<syscode>\<subcode>\[batch|module]\com.cathay.<syscode>.<subcode>.[batch|module].<module_name>.XXX.sql
REM echo.
REM echo 注意：該檔所在目錄已經被 CHECKOUT 了，請將目錄 UNCHECKOUT 之後再Add to Source Control
REM exit 1
REM )

if "%ERRORLEVEL%" == "19" (
echo ***Update 或 Delete語句，必須包含where條件
exit 1
)

if "%ERRORLEVEL%" == "4" (
echo ***SQL 為 SELECT 子句, 請指定 WITH UR, WITH CS, WITH NOLOCK, WITH ROWLOCK 等 ISOLATION 範圍
exit 1
)

if "%ERRORLEVEL%" == "5" (
echo ***ETL 的檔案副檔名必須為 *.sh *.sql *.sub *.load *.ddl *.dlist *.rlist *.ilist *.mlist *.list *.wlist *.DML，請將上層目錄undo checkout
exit 1
)

REM if "%ERRORLEVEL%" == "6" (
REM echo ***禁止使用select @@的語句
REM exit 1
REM )

REM	索引變更記錄 !
REM	@for /f "tokens=1" %%u in ('echo %date%') do @set ad=%%u
REM	@for /f "delims=/ tokens=1-3" %%u in ('echo %ad%') do @set d=%%u%%v%%w
REM	@for /f "delims=: tokens=1-2" %%u  in ('echo %time%') do @set t=%%u%%v
REM	@for /f "delims=: tokens=1-3" %%u in ('echo %time%') do @set as=%%w
REM	@for /f "delims=. tokens=1-2" %%u in ('echo %as%') do @set s=%%u & set  ms=%%v
REM	@set CT=\\cxlsvr118\ccstg_d\index\operation\update\now\%d%%t%%s:~0,-1%%ms%.txt
REM	echo CLEARCASE_VOB_PN=%CLEARCASE_VOB_PN% >> %CT%
REM	echo CLEARCASE_XPN=%CLEARCASE_XPN% >> %CT%
REM	echo CLEARCASE_ELTYPE=%CLEARCASE_ELTYPE% >> %CT%


if "%CLEARCASE_USER%" == "i9100401" (
echo ==============CHECKIN before httppost==================== >> %orderlog%
echo DATETIME=%DATE%%TIME% >> %orderlog%
echo CLEARCASE_ELTYPE=%CLEARCASE_ELTYPE% >> %orderlog%
echo CLEARCASE_USER=%CLEARCASE_USER% >> %orderlog%
echo CLEARCASE_OP_KIND=%CLEARCASE_OP_KIND% >> %orderlog%
echo CLEARCASE_TRTYPE_KIND=%CLEARCASE_TRTYPE_KIND% >> %orderlog%
echo CLEARCASE_VIEW_KIND=%CLEARCASE_VIEW_KIND% >> %orderlog%
echo CLEARCASE_XN_SFX=%CLEARCASE_XN_SFX% >> %orderlog%
echo CLEARCASE_SNAPSHOT_PN=%CLEARCASE_SNAPSHOT_PN% >> %orderlog%
echo CLEARCASE_VOB_PN=%CLEARCASE_VOB_PN% >> %orderlog%
echo CLEARCASE_XPN="%CLEARCASE_XPN%" >> %orderlog%
)


if "%ERRORLEVEL%" GEQ "1" (
REM if "%CLEARCASE_TRTYPE_KIND%" == "pre-operation" (
\\cxlsvr118\ccstg_d\trigger\http_post.bat %ERRORLEVEL%
REM )
)

if "%CLEARCASE_USER%" == "i9100401" (
echo ==============CHECKIN post httppost==================== >> %orderlog%
echo DATETIME=%DATE%%TIME% >> %orderlog%
echo CLEARCASE_ELTYPE=%CLEARCASE_ELTYPE% >> %orderlog%
echo CLEARCASE_USER=%CLEARCASE_USER% >> %orderlog%
echo CLEARCASE_OP_KIND=%CLEARCASE_OP_KIND% >> %orderlog%
echo CLEARCASE_TRTYPE_KIND=%CLEARCASE_TRTYPE_KIND% >> %orderlog%
echo CLEARCASE_VIEW_KIND=%CLEARCASE_VIEW_KIND% >> %orderlog%
echo CLEARCASE_XN_SFX=%CLEARCASE_XN_SFX% >> %orderlog%
echo CLEARCASE_SNAPSHOT_PN=%CLEARCASE_SNAPSHOT_PN% >> %orderlog%
echo CLEARCASE_VOB_PN=%CLEARCASE_VOB_PN% >> %orderlog%
echo CLEARCASE_XPN="%CLEARCASE_XPN%" >> %orderlog%
)

@ENDLOCAL
@ECHO ON