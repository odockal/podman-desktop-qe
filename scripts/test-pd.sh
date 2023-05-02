#!/bin/bash

# Log file to process
LOG_FILE=$1

# Possible errors that we expect - we will blacklist them
BLACKLIST_ERRORS=("GPU process launch failed: error_code=1002" "Theme parsing error: gtk.css")
ASSERTION_ERRORS=()
ERRORS=()

# Main program events we are expecting to see in the log
EVENTS=("System ready. Loading extensions"
"PluginSystem: initialization done"
"Autostarting container engine"
"PluginSystem: received dom-ready event from the UI"
"Delayed startup"
"Stopped all extensions")

# Extensions that are laoded by default in main app - expecting to see multuiple events from extension lifecycle
EXTENSIONS=("compose" "docker" "kind" "kube-context" "lima" "podman" "registries")

verify_function() {
    if grep -Fq "$1" ${LOG_FILE}; then
    # if [[ "${LOG}" == *$1* ]]; then
        echo "$1 PASSED"
    else
        error="Assertion Error: missing expected '$1'"
        echo "$error"
        ASSERTION_ERRORS+=("$error")
    fi
}

verify_extension() {
    extension=$1
    echo "Verifying $1 extension"
    verify_function "Activating extension (${extension})"
    verify_function "Activation extension (${extension}) ended"
    verify_function "stopping ${extension} extension"
}

main() {
    # clean up errors.log from previous run
    if [ -f "errors.log" ]; then
        rm errors.log
    fi

    # check main events
    echo "Verifying main events..."
    for event in "${EVENTS[@]}"; do
        verify_function "${event}"
    done

    # check extensions activation and stopping
    echo "Verifying extensions..."
    for extension in "${EXTENSIONS[@]}"; do
        verify_extension "${extension}"
    done

    # check errors
    echo "Checking errors in the log"
    while IFS= read -r line
    do
        omit=0
        for expected_error in "${BLACKLIST_ERRORS[@]}"; do
            if [[ "$line" =~ "$expected_error" ]]; then
                echo "Omitting expected error: '$line'"
                omit=1
                break;
            fi
        done
        if [ $omit == 0 ]; then
            ERRORS+=("$line")
        fi
    done < <(grep -Rni "error" ${LOG_FILE})


    # Test run evaluation, print error and create errors.log file if necessary
    echo "Printing errors collected, outputs to errors.log file"
    if [ ${#ASSERTION_ERRORS[@]} -gt 0 ]; then
        message="Number of Assertion errors found: ${#ASSERTION_ERRORS[@]}"
        echo ${message}
        echo ${message} >> errors.log
        for error in "${ASSERTION_ERRORS[@]}"; do
            echo "$error"
            echo "${error}" >> errors.log
        done
    fi

    if [ ${#ERRORS[@]} -gt 0 ]; then
        message="Number of Log errors found: ${#ERRORS[@]}"
        echo ${message}
        echo ${message} >> errors.log
        for error in "${ERRORS[@]}"; do
            echo "$error"
            echo "${error}" >> errors.log
        done
    fi
}

main ${LOG}
