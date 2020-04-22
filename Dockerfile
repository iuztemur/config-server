﻿FROM mcr.microsoft.com/powershell:7.0.0-alpine-3.10
COPY . /usr/src/app/
EXPOSE 8085
# set proxy settings
#ENV http_proxy=http://1.1.11.111:8080
#ENV https_proxy=http://1.1.11.111:8080
RUN apk add --no-cache git
RUN git config --global http.sslVerify false
CMD [ "pwsh", "-c", "cd /usr/src/app; ./config-server.ps1" ] 