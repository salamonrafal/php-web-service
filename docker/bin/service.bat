@ECHO OFF

SET IMAGE_NAME=rafcio0584/php-web-container
SET TAG_NAME=0.0.2-symfony
SET VERSION_FILE_NAME=.version
SET LIST_ACTIONS=build-image remove-image help create-container start-container remove-container pause-container stop-container ssh run-container cmd-container
SET CONTAINER_NAME=web-server
SET CURRENT_DIR=%cd%

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

CALL :tolower CURRENT_DIR
CALL :normalizeForDocker CURRENT_DIR

(for %%s in (%LIST_ACTIONS%) do (
    IF "%1" == "%%s" (
        IF "%%s" == "build-image" (
            CALL :do_docker_build_image %IMAGE_NAME% , %TAG_NAME%
            CALL :print_info_image %IMAGE_NAME% , %TAG_NAME% , "Image Created"
        )

        IF "%%s" == "remove-image" (
            CALL :do_docker_remove_image %IMAGE_NAME% , %TAG_NAME%
            CALL :print_info_image %IMAGE_NAME% , %TAG_NAME% , "Image Removed"
        )

        IF "%%s" == "create-container" (
            CALL :do_docker_create_container %IMAGE_NAME% , %TAG_NAME% %CONTAINER_NAME%
            CALL :print_info_container %CONTAINER_NAME% , %IMAGE_NAME% , %TAG_NAME% , "Container Created"
        )

        IF "%%s" == "run-container" (
            CALL :print_info_container %CONTAINER_NAME% , %IMAGE_NAME% , %TAG_NAME% , "Container Run"
            CALL :do_docker_run_container %IMAGE_NAME% , %TAG_NAME% %CONTAINER_NAME%
        )

        IF "%%s" == "start-container" (
            CALL :do_docker_start_container %CONTAINER_NAME%
            CALL :print_info_container %CONTAINER_NAME% , %IMAGE_NAME% , %TAG_NAME% , "Container Started"
        )

        IF "%%s" == "remove-container" (
            CALL :do_docker_stop_container %CONTAINER_NAME%
            CALL :print_info_container %CONTAINER_NAME% , %IMAGE_NAME% , %TAG_NAME% , "Container Stopped"
            CALL :do_docker_remove_container %CONTAINER_NAME%
            CALL :print_info_container %CONTAINER_NAME% , %IMAGE_NAME% , %TAG_NAME% , "Container Removed"
        )

        IF "%%s" == "pause-container" (
            CALL :do_docker_pause_container %CONTAINER_NAME%
            CALL :print_info_container %CONTAINER_NAME% , %IMAGE_NAME% , %TAG_NAME% , "Container Paused"
        )

        IF "%%s" == "stop-container" (
            CALL :do_docker_stop_container %CONTAINER_NAME%
            CALL :print_info_container %CONTAINER_NAME% , %IMAGE_NAME% , %TAG_NAME% , "Container Stopped"
        )

        IF "%%s" == "cmd-container" (
            IF [%2]==[] (
                ECHO Empty command
                EXIT /B 1
            )

            CALL :do_docker_run_cmd_container %CONTAINER_NAME% %2
            CALL :print_info_container %CONTAINER_NAME% , %IMAGE_NAME% , %TAG_NAME% , "Container Command Executed"
        )


        IF "%%s" == "ssh" (
            CALL :do_docker_login_ssh_to_container %CONTAINER_NAME%
        )

        EXIT /B %ERRORLEVEL%
    )
))

CALL :Print_unknown_action

EXIT /B %ERRORLEVEL%


:do_docker_build_image
    docker build -t %~1:%~2 .
EXIT /B 0


:do_docker_remove_image
    docker image rm %~1:%~2
EXIT /B 0

:do_docker_run_cmd_container
    docker exec -w /var/www/web-server/ %~1 %~2
EXIT /B 0


:do_docker_create_container
    SET IMAGE_NAME=%~1:%~2
    SET CONTAINER_WEB_PORT=80
    SET CONTAINER_ALTERNATIVE_PORT=8080
    SET CONTAINER_PHP_FPM_PORT=9000

    docker container create -v "%CURRENT_DIR%\\:/var/www/web-server/" -i -a STDERR --log-driver json-file --env-file ./docker/container.env-file --expose %CONTAINER_WEB_PORT% --expose %CONTAINER_PHP_FPM_PORT% --expose %CONTAINER_ALTERNATIVE_PORT% -p %CONTAINER_ALTERNATIVE_PORT%:%CONTAINER_ALTERNATIVE_PORT% -p %CONTAINER_PHP_FPM_PORT%:%CONTAINER_PHP_FPM_PORT% -p %CONTAINER_WEB_PORT%:%CONTAINER_WEB_PORT% --name %~3 %IMAGE_NAME%
EXIT /B 0

:do_docker_run_container
    SET IMAGE_NAME=%~1:%~2
    SET CONTAINER_WEB_PORT=80
    SET CONTAINER_ALTERNATIVE_PORT=8080
    SET CONTAINER_PHP_FPM_PORT=9000

    docker container run -v "%CURRENT_DIR%\\:/var/www/web-server/" -i --log-driver json-file --env-file ./docker/container.env-file --expose %CONTAINER_WEB_PORT% --expose %CONTAINER_PHP_FPM_PORT% --expose %CONTAINER_ALTERNATIVE_PORT% -p %CONTAINER_ALTERNATIVE_PORT%:%CONTAINER_ALTERNATIVE_PORT% -p %CONTAINER_PHP_FPM_PORT%:%CONTAINER_PHP_FPM_PORT% -p %CONTAINER_WEB_PORT%:%CONTAINER_WEB_PORT% --name %~3 %IMAGE_NAME%
EXIT /B 0


:do_docker_remove_container
    docker container rm %~1
EXIT /B 0


:do_docker_start_container
    docker container start  %~1
EXIT /B 0


:do_docker_stop_container
    docker container stop %~1
EXIT /B 0


:do_docker_pause_container
    docker container pause %~1
EXIT /B 0


:do_docker_login_ssh_to_container
    docker exec -it %~1 /bin/bash
EXIT /B 0


:print_new_line
    echo.
EXIT /B 0


:print_info_image
    CALL :print_new_line
    ECHO ========== %~3 ================
    CALL :print_new_line
    ECHO Image name: %~1
    ECHO Tag: %~2
    ECHO Current dir: %CURRENT_DIR%
    CALL :print_new_line
    ECHO ===============================
    CALL :print_new_line
EXIT /B 0


:print_info_container
    CALL :print_new_line
    ECHO ========== %~4 ================
    CALL :print_new_line
    ECHO Container name: %~1
    ECHO Image name: %~2
    ECHO Tag: %~3
    ECHO Current dir: %CURRENT_DIR%
    CALL :print_new_line
    ECHO ===============================
    CALL :print_new_line
EXIT /B 0


:toupper
    for %%L IN (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO SET %~1=!%~1:%%L=%%L!
EXIT /B 0

:tolower
    for %%L IN (a b c d e f g h i j k l m n o p q r s t u v w x y z) DO SET %~1=!%~1:%%L=%%L!
EXIT /B 0

:normalizeForDocker
    SET %~1=!%~1:/=\!
    SET %~1=!%~1:\=\\!
    SET %~1=!%~1: =\ !
EXIT /B 0

:Print_unknown_action
    ECHO UNKNOWN ACTION
EXIT /B 1
