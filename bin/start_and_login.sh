#!/bin/bash
# initialize a new container

usage () {
    echo "Usage: start_and_login.sh [-m /host/dir/to/mnt/for/runs] ARG1 ARG2 ARG3"
    echo ""
    echo "ARG1: name of the container "
    echo "      Recommend to include the mesa version number, such as 'mesa-r9793'."
    echo "ARG2: image name ID"
    echo "      There are three options: numedo14, numedo16 or numedo18."
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

while getopts "m:h" opt; do
    case $opt in
	m)
	    EMNT=$OPTARG
	    echo "external mount:" $EMNT >&2
	    ;;
	h)
	    usage
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    ;;
    esac
done

shift $((OPTIND-1))

if [ "$#" -ne 3 ]; then
    usage
    exit
else
    docker  run  -h $1 --name $1 \
	    -v $3:/home/user/mesa \
	    -v $EMNT:/home/user/mnt \
	    -t -i  $2 /bin/bash
fi


