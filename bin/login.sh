# login to exited but already existing container
# argument is container name that can be obtained
# with command `docker ps -a`

if [ "$#" -ne 1 ]; then
    echo "You must enter exactly one argument which is the container name, which was specified when the container was starter."
    echo "The container name is also the hostname of the container. See also 'NAMES' column of output 'docker ps -a':"
    docker ps -a
    exit
else
    echo login to container $1
    docker start -i $1
fi
