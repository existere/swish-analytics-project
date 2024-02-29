# Base image is python:3.11.8-alpine (bugfix/stable release) and then installs most of python:2.7.18-alpine (latest python2) on top
FROM python:3.11.8-alpine

ENV GPG_KEY C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF
ENV PYTHON_VERSION 2.7.18
ENV PYTHON_PIP_VERSION 20.3

RUN set -ex \
	&& apk add --no-cache --virtual .fetch-deps \
		gnupg \
		openssl \
		tar \
		xz \
	\
    # download source code
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& rm -r "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
    # extract source code
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& apk add --no-cache --virtual .build-deps  \
		bzip2-dev \
		gcc \
		gdbm-dev \
		libc-dev \
		linux-headers \
		make \
		ncurses-dev \
		openssl \
		openssl-dev \
		pax-utils \
		readline-dev \
		sqlite-dev \
		tcl-dev \
		tk \
		tk-dev \
		zlib-dev \
    # add build deps before removing fetch deps in case there's overlap
	&& apk del .fetch-deps \
	\
	&& cd /usr/src/python \
	&& ./configure \
		--enable-shared \
		--enable-unicode=ucs4 \
    # build and isntall python2
	&& make -j$(nproc) \
	&& make install \
    # install pip
	\
		&& wget -O /tmp/get-pip.py 'https://bootstrap.pypa.io/pip/2.7/get-pip.py' \
		&& python2 /tmp/get-pip.py "pip==$PYTHON_PIP_VERSION" \
		&& rm /tmp/get-pip.py \
	\
    # search for and delete unnecessary test files in /usr/local to reduce image size
	&& find /usr/local -depth \
		\( \
			\( -type d -a -name test -o -name tests \) \
			-o \
			\( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
    # search for runtime dependencies and install
	&& runDeps="$( \
		scanelf --needed --nobanner --recursive /usr/local \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --virtual .python-rundeps $runDeps \
	&& apk del .build-deps \
	&& rm -rf /usr/src/python ~/.cache \
    # install R
    && apk add --no-cache R R-dev

# copy requirements files for python and R
COPY requirements-python2.txt /tmp/requirements-python2.txt
COPY requirements-python3.txt /tmp/requirements-python3.txt
COPY requirements.R /tmp/requirements.R

# install python2 and python3 packages
RUN set -ex \
    && python2 -m pip install --no-cache-dir -r /tmp/requirements-python2.txt \
    && python3 -m pip install --no-cache-dir -r /tmp/requirements-python3.txt

# install R packages
RUN Rscript -e "options(repos = list(CRAN = 'https://cloud.r-project.org/')); packages <- readLines('/tmp/requirements.R'); install.packages(packages)"


# confirm versions of python2, python3, pip, and R
RUN ls -Fla /usr/local/bin/p* \
    && which python  && python -V \
    && which python2 && python2 -V \
    && which python3 && python3 -V \
    && which pip     && pip -V \
    && which pip2    && pip2 -V \
    && which pip3    && pip3 -V \
    && which R       && R --version

CMD ["python2"]
