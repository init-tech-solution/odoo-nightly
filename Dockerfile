FROM python:3.9.15-slim-bullseye

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]
ENV LANG=C.UTF-8

# INIT: Create "odoo" user
RUN useradd -ms /bin/bash odoo

# INIT: Source "odoo core" folder
WORKDIR /var/lib/odoo

# INIT: Copy source folders
COPY ./odoo /var/lib/odoo/odoo
# COPY ./addons /var/lib/odoo/addons
# COPY ./odoo.egg-info /var/lib/odoo/odoo.egg-info
# COPY ./setup /var/lib/odoo/setup

# INIT: Copy files
# COPY ./LICENSE /var/lib/odoo/
# COPY ./MANIFEST.in /var/lib/odoo/
# INIT: File main exec line below
COPY ./odoo-bin /var/lib/odoo/
# COPY ./PKG-INFO /var/lib/odoo/
# COPY ./setup.cfg /var/lib/odoo/
# COPY ./setup.py /var/lib/odoo/


# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
        # INIT ADD LIBS \
        gcc build-essential \
        libsasl2-dev libldap2-dev libpq-dev libdmtx-dev \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g rtlcss

COPY ./requirements.txt /var/lib/odoo

RUN pip install -r /var/lib/odoo/requirements.txt

# INIT: "odoo config" folder
RUN mkdir -p /etc/odoo/ \
    && chown -R odoo /etc/odoo/
# INIT: "odoo data" folder
RUN mkdir -p /var/lib/odoo/data \
    && chown -R odoo /var/lib/odoo/data
COPY ./etc/odoo.conf /etc/odoo/

RUN chown odoo /etc/odoo/odoo.conf \
    # INIT: Source "odoo custom" extra-addons folder
    && mkdir -p /var/lib/odoo/extra-addons \
    && chown -R odoo /var/lib/odoo/extra-addons
COPY ./extra-addons /var/lib/odoo/extra-addons

# VOLUME ["/var/lib/odoo" "/mnt/extra-addons"]
# EXPOSE 8069 8071 8072
ENV ODOO_RC=/etc/odoo/odoo.conf
USER odoo

CMD [ "python", "/var/lib/odoo/odoo-bin", "-c", "/etc/odoo/odoo.conf" ]
