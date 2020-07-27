# Not all distros have sbin in PATH for regular users.
PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
COPY_PATH="$1"
set -e
VERSION=`cinder-volume --version 2>&1`
MAJOR_VERSION="$( cut -d '.' -f 1 <<< "$VERSION" )"
if [ "$MAJOR_VERSION" != '9' ]; then
    echo "This system is not a Newton version. \"cinder-volume --version\" for Newton should be 9.x.x but this system is $VERSION"
    exit 1
else
    echo "OpenStack Cinder version is $VERSION"
fi

if ! [ -n "$COPY_PATH" ]
then
    echo -e "Enter path upto cinder directory for the kaminario driver \nSyntax : ./kaminario_patch.sh /path/to/copy"
    exit 1
fi

#TODO - check that the path looks like a cinder dir (i.e. includes volume/drivers subdir). if not, print error and exit

read -r -p "Are you sure this is the path \"$COPY_PATH\" ? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        FILENAME="KaminarioCinderDriverException"
        if ! grep -q "$FILENAME" $COPY_PATH/exception.py
        then
            cat exception.txt >> $COPY_PATH/exception.py
        fi

        COPY_PATH="$COPY_PATH/volume/drivers/kaminario"
        mkdir -p "$COPY_PATH"
        file="$COPY_PATH/__init__.py"
        if ! [ -f "$file" ]
        then
            touch $file
        fi

        cp -vR kaminario/* $COPY_PATH
        ;;
    *)
        echo "Not applying patch"
        exit 2
        ;;
esac
