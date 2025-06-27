# login to exited but already existing container
# argument is container name that can be obtained
# with command `docker ps -a`
# optional --newshell flag to start a new bash shell in already running container

NEWSHELL=false
CONTAINER_NAME=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --newshell)
            NEWSHELL=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--newshell] <container_name>"
            echo ""
            echo "Login to a Docker container by name."
            echo ""
            echo "Arguments:"
            echo "  <container_name>    Name of the container to connect to"
            echo ""
            echo "Options:"
            echo "  --newshell          Start a new bash shell in already running container (like login+.sh)"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 mycontainer              # Start container if stopped and attach"
            echo "  $0 --newshell mycontainer   # Start new bash shell in running container"
            echo ""
            echo "Container names can be obtained with: docker ps -a"
            exit 0
            ;;
        *)
            if [ -z "$CONTAINER_NAME" ]; then
                CONTAINER_NAME="$1"
            else
                echo "Error: Multiple container names specified"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$CONTAINER_NAME" ]; then
    echo "You must enter exactly one argument which is the container name, which was specified when the container was started."
    echo "The container name is also the hostname of the container. See also 'NAMES' column of output 'docker ps -a':"
    echo ""
    echo "Usage: $0 [--newshell] <container_name>"
    echo "  --newshell: Start a new bash shell in already running container (like login+.sh)"
    echo "  <container_name>: Name of the container to connect to"
    docker ps -a
    exit 1
fi

echo "login to container $CONTAINER_NAME"

if [ "$NEWSHELL" = true ]; then
    # Start a new bash shell in already running container (like login+.sh)
    docker exec -it $CONTAINER_NAME /bin/bash
else
    # Start container if stopped and attach to it (original behavior)
    docker start -i $CONTAINER_NAME
fi
