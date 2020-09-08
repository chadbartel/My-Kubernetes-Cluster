FROM amd64/ubuntu:18.04

RUN apt-get update 
RUN apt-get install -y apt-transport-https
RUN apt-get install -y git

CMD /bin/bash