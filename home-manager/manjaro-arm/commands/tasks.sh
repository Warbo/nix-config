while true
do
    while ts | grep running
    do
        ts -t
        echo DONE 1>&2
        sleep 1
    done
    sleep 5
done
