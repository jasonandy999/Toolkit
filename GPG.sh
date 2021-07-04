#!/bin/bash

# Current Version: 1.0.1

## How to get and use?
# git clone "https://github.com/hezhijie0327/Toolkit.git"
# bash ./Toolkit/GPG.sh -m "import" -t "private" -p "<PASSWORD>" -k "<KEY>"
# bash ./Toolkit/GPG.sh -m "sign" -e "asc" -p "<PASSWORD>" -f "<FILE>"
# bash ./Toolkit/GPG.sh -m "verify" -f "<FILE>" -s "<SIGNATURE>"

## Parameter
while getopts e:f:k:m:p:s:t: GetParameter; do
    case ${GetParameter} in
        e) ENCODED="${OPTARG}";;
        f) FILE="${OPTARG}";;
        k) KEY="${OPTARG}";;
        m) GPG_MODE="${OPTARG}";;
        p) PASSWORD="${OPTARG}";;
        s) SIGNATURE="${OPTARG}";;
        t) TYPE="${OPTARG}";;
    esac
done

## Function
# Check Configuration Validity
function CheckConfigurationValidity() {
    if [ "${GPG_MODE}" == "" ]; then
        echo "An error occurred during processing. Missing (GPG_MODE) value, please check it and try again."
        exit 1
    elif [ "${GPG_MODE}" != "import" ] && [ "${GPG_MODE}" != "sign" ] && [ "${GPG_MODE}" != "verify" ]; then
        echo "An error occurred during processing. Invalid (GPG_MODE) value, please check it and try again."
        exit 1
    fi
    if [ "${GPG_MODE}" == "import" ]; then
        if [ "${KEY}" == "" ]; then
            echo "An error occurred during processing. Missing (KEY) value, please check it and try again."
            exit 1
        elif [ ! -f "${KEY}" ]; then
            echo "An error occurred during processing. Invalid (KEY) value, please check it and try again."
            exit 1
        fi
        fi
        if [ "${PASSWORD}" == "" ] && [ "${TYPE}" == "private" ]; then
            echo "An error occurred during processing. Missing (PASSWORD) value, please check it and try again."
            exit 1
        fi
        if [ "${TYPE}" == "" ]; then
            echo "An error occurred during processing. Missing (TYPE) value, please check it and try again."
            exit 1
        elif [ "${TYPE}" != "private" ] && [ "${TYPE}" != "public" ]; then
            echo "An error occurred during processing. Invalid (TYPE) value, please check it and try again."
            exit 1
        fi
    elif [ "${GPG_MODE}" == "sign" ]; then
        if [ "${ENCODED}" == "" ]; then
            echo "An error occurred during processing. Missing (ENCODED) value, please check it and try again."
            exit 1
        elif [ "${ENCODED}" != "asc" ] && [ "${ENCODED}" != "gpg" ] && [ "${ENCODED}" != "sig" ]; then
            echo "An error occurred during processing. Invalid (ENCODED) value, please check it and try again."
            exit 1
        fi
        if [ "${FILE}" == "" ]; then
            echo "An error occurred during processing. Missing (FILE) value, please check it and try again."
            exit 1
        elif [ ! -f "${FILE}" ]; then
            echo "An error occurred during processing. Invalid (FILE) value, please check it and try again."
            exit 1
        fi
        if [ "${PASSWORD}" == "" ]; then
            echo "An error occurred during processing. Missing (PASSWORD) value, please check it and try again."
            exit 1
        fi
    elif [ "${GPG_MODE}" == "verify" ]; then
        if [ "${FILE}" == "" ]; then
            echo "An error occurred during processing. Missing (FILE) value, please check it and try again."
            exit 1
        elif [ ! -f "${FILE}" ]; then
            echo "An error occurred during processing. Invalid (FILE) value, please check it and try again."
            exit 1
        fi
        if [ "${SIGNATURE}" == "" ]; then
            echo "An error occurred during processing. Missing (SIGNATURE) value, please check it and try again."
            exit 1
        elif [ ! -f "${SIGNATURE}" ]; then
            echo "An error occurred during processing. Invalid (SIGNATURE) value, please check it and try again."
            exit 1
        fi
    fi
}
# Check Requirement
function CheckRequirement() {
    which "gpg" > "/dev/null" 2>&1
    if [ "$?" -eq "1" ]; then
        echo "gpg is not existed."
        exit 1
    fi
}

## Process
# Call CheckConfigurationValidity
CheckConfigurationValidity
# Call CheckRequirement
CheckRequirement
if [ "${GPG_MODE}" == "import" ]; then
    if [ "${TYPE}" == "private" ]; then
        gpg --batch --import --passphrase "${PASSWORD}" "${KEY}"
    elif [ "${TYPE}" == "public" ]; then
        gpg --batch --import "${KEY}"
    fi
elif [ "${GPG_MODE}" == "sign" ]; then
    if [ "${ENCODED}" == "asc" ]; then
        gpg --armor --detach-sign --passphrase "${PASSWORD}" --pinentry-mode "loopback" "${FILE}"
    elif [ "${ENCODED}" == "gpg" ]; then
        gpg --sign --passphrase "${PASSWORD}" --pinentry-mode "loopback" "${FILE}"
    elif [ "${ENCODED}" == "sig" ]; then
        gpg --detach-sign --passphrase "${PASSWORD}" --pinentry-mode "loopback" "${FILE}"
    fi
elif [ "${GPG_MODE}" == "verify" ]; then
    gpg --verify "${SIGNATURE}" "${FILE}"
fi
