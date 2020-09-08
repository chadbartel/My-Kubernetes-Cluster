FROM amd64/ubuntu:18.04

RUN apt-get install update -y
RUN apt-get install upgrade -y
RUN apt-get install git -y

CMD /bin/bash