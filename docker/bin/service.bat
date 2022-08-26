@ECHO OFF

SET IMAGE_NAME=rafcio0584/php-web-container
SET TAG_NAME=1.0.0-symfony
SET VERSION_FILE_NAME=.version
SET LIST_ACTIONS=build-image remove-image create-container start-container remove-container pause-container stop-container ssh run-container cmd-container help
SET CONTAINER_NAME=web-server
SET CURRENT_DIR=%cd%
SET APP_ENV='local'
SET ENABLED_SHARED_DIR_DEFAULT=yes

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
            CALL :print_info_container %CONTAINER_NAME% , %IMAGE_NAME% , %TAG_NAME% , "Container Created"

            IF NOT "%~2"=="" (
                IF "%~2"=="no" (
                    CALL :do_docker_create_container %IMAGE_NAME% , %TAG_NAME% , %CONTAINER_NAME% , 0
                ) ELSE (
                    CALL :do_docker_create_container %IMAGE_NAME% , %TAG_NAME% , %CONTAINER_NAME% , 1
                )
            )
        )

        IF "%%s" == "run-container" (
            CALL :print_info_container %CONTAINER_NAME% , %IMAGE_NAME% , %TAG_NAME% , "Container Run"

            IF NOT "%~2"=="" (
                IF "%~2"=="no" (
                    CALL :do_docker_run_container %IMAGE_NAME% , %TAG_NAME% , %CONTAINER_NAME% , 0
                ) ELSE (
                    CALL :do_docker_run_container %IMAGE_NAME% , %TAG_NAME% , %CONTAINER_NAME% , 1
                )
            )
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

        if "%%s" == "help" (
            CALL :print_help_info %2
        )

        EXIT /B %ERRORLEVEL%
    )
))

CALL :print_unknown_action

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

    IF NOT "%~4"==1 (
        SET SHARED_DIR_DEVELOP=1
    ) ELSE (
        SET SHARED_DIR_DEVELOP=0
    )

    IF %SHARED_DIR_DEVELOP%==1 (
        SET VOLUMES=-v "%CURRENT_DIR%\\:/var/www/web-server/"
    )  ELSE (
        SET VOLUMES=
    )

    ECHO SHARED_DIR_DEVELOP: %SHARED_DIR_DEVELOP%
    ECHO VOLUMES: %VOLUMES%

    docker container create %VOLUMES% -i -a STDERR --log-driver json-file --env-file ./docker/container.env-file --expose %CONTAINER_WEB_PORT% --expose %CONTAINER_PHP_FPM_PORT% --expose %CONTAINER_ALTERNATIVE_PORT% -p %CONTAINER_ALTERNATIVE_PORT%:%CONTAINER_ALTERNATIVE_PORT% -p %CONTAINER_PHP_FPM_PORT%:%CONTAINER_PHP_FPM_PORT% -p %CONTAINER_WEB_PORT%:%CONTAINER_WEB_PORT% --name %~3 %IMAGE_NAME%
EXIT /B 0

:do_docker_run_container
    SET IMAGE_NAME=%~1:%~2
    SET CONTAINER_WEB_PORT=80
    SET CONTAINER_ALTERNATIVE_PORT=8080
    SET CONTAINER_PHP_FPM_PORT=9000

    IF NOT "%~4"==1 (
        SET SHARED_DIR_DEVELOP=1
    ) ELSE (
        SET SHARED_DIR_DEVELOP=0
    )

    IF %SHARED_DIR_DEVELOP%==1 (
        SET VOLUMES=-v "%CURRENT_DIR%\\:/var/www/web-server/"
    )  ELSE (
        SET VOLUMES=
    )

    ECHO SHARED_DIR_DEVELOP: %SHARED_DIR_DEVELOP%
    ECHO VOLUMES: %VOLUMES%

    docker container run %VOLUMES% -id --log-driver json-file --env-file ./docker/container.env-file --expose %CONTAINER_WEB_PORT% --expose %CONTAINER_PHP_FPM_PORT% --expose %CONTAINER_ALTERNATIVE_PORT% -p %CONTAINER_ALTERNATIVE_PORT%:%CONTAINER_ALTERNATIVE_PORT% -p %CONTAINER_PHP_FPM_PORT%:%CONTAINER_PHP_FPM_PORT% -p %CONTAINER_WEB_PORT%:%CONTAINER_WEB_PORT% --name %~3 %IMAGE_NAME%
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


:print_unknown_action
    ECHO ERROR: UNKNOWN ACTION
    CALL :print_help_info
EXIT /B 1


:print_help_info
    ECHO Script help to build and deploy docker image and container on Windows local machine
    CALL :print_new_line
    ECHO List actions: %LIST_ACTIONS%
    IF NOT "%~1"=="" (
        CALL :print_new_line
        CALL :print_man_commands_factory %~1
    )
EXIT /B 0


:print_man_commands_factory
    IF "%~1" == "build-image" (
        CALL :print_man_command_build_image
        EXIT /B 0
    )
    IF "%~1" == "remove-image" (
        CALL :print_man_command_remove_image
        EXIT /B 0
    )
    IF "%~1" == "create-container" (
        CALL :print_man_command_create_container
        EXIT /B 0
    )
    IF "%~1" == "start-container" (
        CALL :print_man_command_start_container
        EXIT /B 0
    )
    IF "%~1" == "remove-container" (
        CALL :print_man_cmd_rm_container
        EXIT /B 0
    )
    IF "%~1" == "pause-container" (
        CALL :print_man_command_pause_container
        EXIT /B 0
    )
    IF "%~1" == "stop-container" (
        CALL :print_man_command_stop_container
        EXIT /B 0
    )
    IF "%~1" == "ssh" (
        CALL :print_man_command_ssh
        EXIT /B 0
    )
    IF "%~1" == "run-container" (
        CALL :print_man_command_run_container
        EXIT /B 0
    )
    IF "%~1" == "cmd-container" (
        CALL :print_man_command_cmd_container
        EXIT /B 0
    )
    IF "%~1" == "help" (
        CALL :print_man_command_help
        EXIT /B 0
    )
EXIT /B 0


:print_man_command_build_image
    ECHO ACTION NAME: remove-image
    ECHO USAGE: docker/bin.service.bat build-image
    ECHO DESCRIPTION: build docker image from current source code
    CALL :print_new_line
EXIT /B 0


:print_man_command_remove_image
    ECHO ACTION NAME: remove-image
    ECHO USAGE: docker/bin.service.bat remove-image
    ECHO DESCRIPTION: remove docker image from local docker
    CALL :print_new_line
EXIT /B 0


:print_man_command_create_container
    ECHO ACTION NAME: create-container
    ECHO USAGE: docker/bin.service.bat create-container ^<enable_shared_dir^>
    ECHO DESCRIPTION: create docker container (but only create not run)
    ECHO PARAMETERS:
    ECHO   - ^<enable_shared_dir^>: If yes mount current folder inside docer container, If no folder with source code build in docker image. Default: yes
EXIT /B 0


:print_man_command_start_container
    ECHO ACTION NAME: start-container
    ECHO USAGE: docker/bin.service.bat start-container
    ECHO DESCRIPTION: start docker container which before you created (IF container was not created throw error)
EXIT /B 0


:print_man_cmd_rm_container
    ECHO ACTION NAME: remove-container
    ECHO USAGE: docker/bin.service.bat remove-container
    ECHO DESCRIPTION: destroy docker container. If service container still run then script will stop container before removing it.
EXIT /B 0


:print_man_command_pause_container
    ECHO ACTION NAME: pause-container
    ECHO USAGE: docker/bin.service.bat pause-container
    ECHO DESCRIPTION: Pause running docker container with service
EXIT /B 0


:print_man_command_stop_container
    ECHO ACTION NAME: stop-container
    ECHO USAGE: docker/bin.service.bat stop-container
    ECHO DESCRIPTION: Stop running docker container with service
EXIT /B 0


:print_man_command_ssh
    ECHO ACTION NAME: ssh
    ECHO USAGE: docker/bin.service.bat ssh
    ECHO DESCRIPTION: Run bash terminal inside running docker container
EXIT /B 0


:print_man_command_run_container
    ECHO ACTION NAME: run-container
    ECHO USAGE: docker/bin.service.bat run-container ^<enable_shared_dir^>
    ECHO DESCRIPTION: Run container if container not exist then script will create it before start
    ECHO PARAMETERS:
    ECHO   - ^<enable_shared_dir^>: If yes mount current folder inside docer container, If no folder with source code build in docker image. Default: yes
EXIT /B 0


:print_man_command_cmd_container
    ECHO ACTION NAME: cmd-container
    ECHO USAGE: docker/bin.service.bat cmd-container ^<command^>
    ECHO DESCRIPTION: Run specific command inside docker container
    ECHO PARAMETERS:
    ECHO   - ^<command^>: specific command like 'composer install'
EXIT /B 0


:print_man_command_help
    ECHO ACTION NAME: help
    ECHO USAGE: docker/bin.service.bat help ^<action-name^>
    ECHO DESCRIPTION: Print manual about usage this script. You can specify actio name if you would like se details about usage.
    ECHO PARAMETERS:
    ECHO   - ^<action-name^>: name of action available on this list: %LIST_ACTIONS%
EXIT /B 0

