FROM ubuntu

# http://stackoverflow.com/questions/25193161/chfn-pam-system-error-intermittently-in-docker-hub-builds (??)
RUN ln -s -f /bin/true /usr/bin/chfn

RUN apt-get update

RUN apt-get -y install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

USER postgres

RUN /etc/init.d/postgresql start &&\
    psql -U postgres -c "create user galaxy with password 'galaxy'" &&\
    psql -U postgres -c "create database galaxy" &&\
    psql -U postgres -c "grant all privileges on database galaxy to galaxy" &&\
    /etc/init.d/postgresql stop

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible. 
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql/data"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/data", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
