#!/bin/bash
# initialize a new container

usage () {
    echo "Usage: start_and_login.sh [-m /host/dir/to/mnt/for/runs] ARG1 ARG2 ARG3"
    echo ""
    echo "ARG1: name of the container "
    echo "      Recommend name is the default mesa source tree directory name including"
    echo "      the mesa version number, such as 'mesa-r9793'."
    echo "ARG2: image name"
    echo "      The name is 'nudome:1n.0' where n=4, 6 or 8."
    echo "ARG3: full path to the mesa code directory on your host system"
    echo "      Examples: '/path/to/MESA/mesa-r9793' or '\$HOME/MESA/mesa-r9793'"
    echo "-m  : optionally provide full path to dir (e.g. for runs) to be mounted in"
    echo "      '\$HOME/mnt'"
}

if [ $# -eq 0 ]
then
    usage
    exit
fi	

EMNT=""

while getopts "m:h" opt; do
    case $opt in
        m)
            EMNT=$OPTARG
            echo "external mount:" $EMNT >&2
            ;;
        h)
            usage
            exit
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

if [ "$#" -ne 3 ]; then
    usage
    exit
else
    docker_cmd="docker run -h $1 --name $1 -v $3:/home/user/mesa"
    
    # Add the external mount option if -m was provided
    if [ -n "$EMNT" ]; then
        docker_cmd="$docker_cmd -v $EMNT:/home/user/mnt"
    fi
    
    docker_cmd="$docker_cmd -t -i $2 /bin/bash"
    eval $docker_cmd
fi
