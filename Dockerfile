FROM amd64/ubuntu:18.04

RUN apt update -y
RUN apt upgrade -y
RUN apt-get install -y apt-transport-https
RUN apt-get install -y git
RUN apt install -y curl

# Install and configure Kubernetes command-line utility - kubectl
RUN curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

CMD /bin/bash