FROM fedora:25

# Application directory
ENV SUPERSET_HOME /superset
ENV PYTHONPATH $SUPERSET_HOME:$PYTHONPATH

#Update system
RUN dnf -y install gcc gcc-c++ libffi-devel redhat-rpm-config \
	python3-devel python3-wheel \
	openssl-devel cyrus-sasl-devel openldap-devel \
	git gettext

RUN dnf -y update python3-setuptools python3-pip 

RUN dnf clean all

RUN alias python='/usr/bin/python3'
RUN alias pip='/usr/bin/pip3'

#Update python
RUN pip3 install --no-cache-dir \
	psycopg2  pyhive \
	flask-appbuilder superset

#Install TD SQL Alchemy
RUN git clone https://github.com/RemiTurpaud/sqlalchemy-teradata.git /tmp/tdss
RUN pip3 install -e /tmp/tdss

#Install Teradata ODBC drivers
ADD tdodbc*linux_indep.*.tar.gz tmp/
RUN cd tmp; find . -name '*.tar.gz' -exec tar zxvf {} --strip=1 \;
RUN rpm -ivh /tmp/tdicu*.noarch.rpm --prefix=/opt/ --nodeps
RUN rpm -ivh /tmp/TeraGSS*.noarch.rpm  /tmp/tdodbc*.noarch.rpm --prefix=/opt/ --nodeps

RUN cp /opt/teradata/client/16.00/odbc_64/odbc.ini ~/.odbc.ini
RUN cp /opt/teradata/client/16.00/odbc_64/odbcinst.ini ~/.odbcinst.ini

# Create home folder
RUN mkdir $SUPERSET_HOME

#Application defaults (used to create new environments)
RUN mkdir /etc/superset-defaults
ADD superset.cfg /etc/superset-defaults/superset.cfg
ADD admin.cfg /etc/superset-defaults/admin.cfg

#Add entry point
COPY init.sh /init.sh
RUN chmod +x /init.sh

VOLUME $SUPERSET_HOME
EXPOSE 8088

ENTRYPOINT [ "/init.sh" ]
