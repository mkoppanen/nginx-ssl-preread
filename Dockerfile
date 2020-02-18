FROM nginx:1.17.8-alpine AS builder

# Download sources
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
  gcc \
  libc-dev \
  make \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  curl \
  gnupg \
  libxslt-dev \
  gd-dev \
  geoip-dev

# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
  tar -zxC /tmp -f nginx.tar.gz \
  && \
  cd /tmp/nginx-$NGINX_VERSION \
  && \
  ./configure $CONFARGS --with-stream --with-stream_ssl_preread_module \
  && \
  make -j8 \
  && \
  make install \
  && \
  rm -rf /tmp/nginx-$NGINX_VERSION

FROM nginx:1.17.8-alpine
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx

EXPOSE 80
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

