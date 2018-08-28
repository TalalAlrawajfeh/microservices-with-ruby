FROM ruby:latest

LABEL maintainer="talal@bluekangaroo.co"

# these are default values, to override them run docker with flag -e VARNAME=varvalue
ENV PATH="/usr/src/app/products-service:${PATH}"
ENV DATABASE_HOST=172.17.0.2
ENV DATABASE_PORT=3306
ENV DATABASE_USERNAME=root
ENV DATABASE_PASSWORD=root
ENV SINATRA_PORT=5000

RUN apt-get update &\
    apt-get upgrade

COPY products-service /usr/src/app/products-service
WORKDIR /usr/src/app/products-service

RUN rm -rf /usr/src/app/products-service/vendor
RUN bundle install --path vendor/cache
RUN chmod a+rwx run.sh

EXPOSE ${SINATRA_PORT}/tcp

CMD ["run.sh"]

# docker build -t products-service .
# docker run -d products-service
# docker inspect <container-id> to see the ip address
# curl -X GET http://172.17.0.3:5000/product