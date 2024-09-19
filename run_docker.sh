if [ ! "$(docker ps -q -f name=saurav-archlinux-ws)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=saurav-archlinux-ws)" ]; then
        # cleanup
        # docker rm saurav-archlinux-ws
        echo "rm disabled"
    fi
    # run your container
    docker run -it --name=saurav-archlinux-ws --gpus=all --net=host --privileged --ipc=host -v /home/saurav:/workspace:rw agarwalsaurav/archlinux:latest bash
else
    # exec into your container
    docker exec -it saurav-archlinux-ws bash
fi
